@import simd;
@import MetalKit;

#import <math.h>

#import "Renderer.h"
#import "ShaderTypes.h"
#import "Map.h"
#import "Object.h"
#import "Textures.h"
#import "Hues.h"
#import "World.h"
#import "UnicodeFont.h"

@implementation Renderer {
    id<MTLDevice> _device;
    id<MTLRenderPipelineState> _pipelineState;
    id<MTLCommandQueue> _commandQueue;
    
    Textures *_textures;
    float _scaleFactor;
    vector_uint2 _viewportSize;
    MTKView *_view;
    NSMutableArray<id<MTLTexture>> *_drawQueue;
    
    NSUInteger _bufferCount;
    dispatch_semaphore_t _frameBoundarySemaphore;
    NSUInteger _currentFrameIndex;
    NSArray<id<MTLBuffer>> *_dynamicDataBuffers;
    
    World *_world;
    vector_float2 _position;
    
    NSUInteger _frames;
}

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView world:(nonnull World *)world {
    self = [super init];
    
    if (self) {
        _world = world;
        _position = (vector_float2){_world.position.x, _world.position.y};
        
        _view = mtkView;
        _device = _view.device;
        _textures = [[Textures alloc] initWithDevice:_device];
        _drawQueue = [NSMutableArray array];
        _scaleFactor = 4.f;
        
        _bufferCount = 3;
        _frameBoundarySemaphore = dispatch_semaphore_create(_bufferCount);
        _currentFrameIndex = 0;
        _dynamicDataBuffers = [self buildDynamicDataBuffers];

        _pipelineState = [self buildRenderPipelineState];
        _commandQueue = [_device newCommandQueue];
        _frames = 0;
    }
    
    return self;
}

- (id<MTLRenderPipelineState>)buildRenderPipelineState {
    id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentShader"];
    
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = _view.colorPixelFormat;
    
    pipelineStateDescriptor.colorAttachments[0].blendingEnabled = YES;
    pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    pipelineStateDescriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    
    id<MTLRenderPipelineState> pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                                                       error:nil];
    
    NSAssert(pipelineState, @"Failed to create render pipeline");
    
    return pipelineState;
}

- (NSArray<id<MTLBuffer>> *)buildDynamicDataBuffers {
    NSMutableArray *mutableDynamciDataBuffers = [NSMutableArray arrayWithCapacity:_bufferCount];
    
    for (int i = 0; i < _bufferCount; ++i) {
        id<MTLBuffer> dynamicDataBuffer = [_device newBufferWithLength:0x400 * _world.range * _world.range * sizeof(Vertex) options:MTLResourceStorageModeShared];
        
        [mutableDynamciDataBuffers addObject:dynamicDataBuffer];
    }
    
    return [mutableDynamciDataBuffers copy];
}

- (void)render:(MTKView *)view {
    dispatch_semaphore_wait(_frameBoundarySemaphore, DISPATCH_TIME_FOREVER);
    _currentFrameIndex = (_currentFrameIndex + 1) % _bufferCount;
    
    if (_currentFrameIndex == 0) {
        _frames++;
    }
        
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    
    if (renderPassDescriptor != nil) {
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, _viewportSize.x, _viewportSize.y, 0.0, 1.0}];
        [renderEncoder setRenderPipelineState:_pipelineState];
        
        [self drawWorld];
        [self flushDrawQueueWithEncoder:renderEncoder];

        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
        
        __weak dispatch_semaphore_t semaphore = _frameBoundarySemaphore;
        [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> commandBuffer) {
            dispatch_semaphore_signal(semaphore);
        }];
    }
    
    [commandBuffer commit];
}

- (void)drawInMTKView:(MTKView *)view {
    @autoreleasepool {
        [self render:view];
    }
}

- (BOOL)isQuadInViewportWithTop:(Vertex)top left:(Vertex)left bottom:(Vertex)bottom right:(Vertex)right {
    vector_float2 scaledViewportSize = {
        (float)_viewportSize.x / _scaleFactor,
        (float)_viewportSize.y / _scaleFactor
    };
    
    return right.position.x > -scaledViewportSize.x && top.position.y > -scaledViewportSize.y && left.position.x < scaledViewportSize.x && bottom.position.y < scaledViewportSize.y;
}

- (void)enqueueQuad:(Vertex[])vertices texture:(id<MTLTexture>)texture {
    Vertex *buffer = [_dynamicDataBuffers[_currentFrameIndex] contents] + ((_drawQueue.count * 4) * sizeof(Vertex));
        
    memcpy(buffer, vertices, 4 * sizeof(Vertex));

    [_drawQueue addObject:texture];
}

- (void)flushDrawQueueWithEncoder:(id<MTLRenderCommandEncoder>)encoder {
    [encoder setVertexBuffer:_dynamicDataBuffers[_currentFrameIndex] offset:0 atIndex:0];
    
    [encoder setVertexBytes:&_viewportSize length:sizeof(_viewportSize) atIndex:1];
    [encoder setVertexBytes:&_scaleFactor length:sizeof(_scaleFactor) atIndex:2];
            
    for (int i = 0; i < _drawQueue.count; ++i) {
        [encoder setVertexBufferOffset:i * sizeof(Vertex) * 4 atIndex:0];
        
        if (i == 0 || (i > 0 && _drawQueue[i] != _drawQueue[i - 1])) {
            [encoder setFragmentTexture:_drawQueue[i] atIndex:0];
        }
        
        [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    }
    
    _drawQueue = [NSMutableArray array];
}
                
- (void)drawWorld {
    int range = _world.range * 2;
            
    for (int x = 0; x < range; ++x) {
        for (int y = 0; y < range; ++y) {
            NSArray<Object *> *objects = _world.objects[x * range + y];
            
            for (int i = 0; i < objects.count; ++i) {
                Object *current = objects[i];
                
                vector_uint2 tilePosition = {
                    _world.position.x + x - (range / 2),
                    _world.position.y + y - (range / 2)
                };
                    
                if (current.objectType == otLand) {
                    [self drawLand:current.artId atPosition:tilePosition z:current.z];
                } else if (current.objectType == otStatic) {
                    if (current.itemAnimation && current.itemAnimation.frameCount > 0) {
                        int frameOffset = ( _frames / ( current.itemAnimation.frameInterval + 1 ) ) % current.itemAnimation.frameCount;
                                                
                        [self drawStatic:current.artId + current.itemAnimation.frames[frameOffset] atPosition:tilePosition z:current.z];

                    } else {
                        [self drawStatic:current.artId atPosition:tilePosition z:current.z];
                    }
                }
            }
        }
    }
    
    [self drawText:[NSString stringWithFormat:@"Ultima Online (preview) (%d, %d)", _world.position.x, _world.position.y]
  atScreenPosition:(vector_float2){15, 15}];
    
//    [self drawBodyAnimation:192 atPosition:_world.position z:0];
}

- (void)drawLand:(uint32_t)tileId atPosition:(vector_uint2)position z:(int8_t)z {
    MapCell bottom = [_world.map readCellAtPosition:position + (vector_uint2){1, 1}];
    MapCell left = [_world.map readCellAtPosition:position + (vector_uint2){0, 1}];
    MapCell right = [_world.map readCellAtPosition:position + (vector_uint2){1, 0}];

    if (z == bottom.z && z == left.z && z == right.z) {
        [self drawTile:tileId atPosition:position z:z];
    } else {
        [self drawTerrainQuad:tileId atPosition:position z:z];
    }
}

-(void)drawQuad:(id<MTLTexture>)texture atScreenPosition:(vector_float2)position {
    vector_float2 scaledViewportSize = {
        (float)_viewportSize.x / _scaleFactor,
        (float)_viewportSize.y / _scaleFactor
    };
    float width = texture.width;
    float height = texture.height;
    
    float xOffset = -scaledViewportSize.x + position.x;
    float yOffset = scaledViewportSize.y - position.y - height;
                
    Vertex quadVertices[] = {
        {{width + xOffset, height + yOffset}, {1.f, 0.f}},
        {{xOffset        , height + yOffset}, {0.f, 0.f}},
        {{width + xOffset, yOffset},          {1.f, 1.f}},
        {{xOffset        , yOffset},          {0.f, 1.f}},

    };
    
    if ([self isQuadInViewportWithTop:quadVertices[1]
                                 left:quadVertices[3]
                               bottom:quadVertices[2]
                                right:quadVertices[0]]) {
        [self enqueueQuad:quadVertices texture:texture];
    }
}

- (void)drawQuad:(id<MTLTexture>)texture atPosition:(vector_uint2)position z:(int8_t)z {
    vector_float2 relativePosition = {
        (float)position.x - _world.position.x,
        (float)position.y - _world.position.y
    };
        
    float xOffset = 22.f * relativePosition.x + -22.f * relativePosition.y - 0.5f;
    float yOffset = -22.f + (-22.f * relativePosition.x) + (-22.f * relativePosition.y) + (4.f * z) - 0.5f;
    
    float width = texture.width / 2.f;
    float height = texture.height;
        
    Vertex quadVertices[] = {
        {{ width + xOffset, height + yOffset}, {1.f, 0.f}},
        {{-width + xOffset, height + yOffset}, {0.f, 0.f}},
        {{ width + xOffset, yOffset},          {1.f, 1.f}},
        {{-width + xOffset, yOffset},          {0.f, 1.f}},
    };
    
    if ([self isQuadInViewportWithTop:quadVertices[1]
                                 left:quadVertices[3]
                               bottom:quadVertices[2]
                                right:quadVertices[0]]) {
        [self enqueueQuad:quadVertices texture:texture];
    }
}

- (void)drawText:(NSString *)text atScreenPosition:(vector_float2)position {
    NSArray<id<MTLTexture>> *textures = [_textures texturesForAsciiText:text withFont:4];
    
    vector_float2 offset = {0, 0};
    
    NSUInteger maxHeight = 0;
    
    for (int i = 0; i < textures.count; ++i) {
        if (textures[i].height > maxHeight) {
            maxHeight = textures[i].height;
        }
    }
    
    for (int i = 0; i < textures.count; ++i) {
        id<MTLTexture> texture = textures[i];
        
        if (texture == nil) {
            continue;
        }
        
        vector_float2 additionalOffset = {0, maxHeight - texture.height};
        
        [self drawQuad:texture atScreenPosition:position + offset + additionalOffset];
        
        offset.x += texture.width;
    }
}

- (void)drawBodyAnimation:(uint32_t)animationId atPosition:(vector_uint2)position z:(int8_t)z {
    id<MTLTexture> texture = [_textures textureForBodyAnimation:animationId atFrame:0];
        
    if (texture == nil) {
        return;
    }
    
    [self drawQuad:texture atPosition:position z:z];
}

- (void)drawStatic:(uint32_t)itemId atPosition:(vector_uint2)position z:(int8_t)z {
    id<MTLTexture> texture = [_textures textureForStatic:itemId];
    
    if (texture == nil) {
        return;
    }
    
    [self drawQuad:texture atPosition:position z:z];
}

- (void)drawTile:(uint32_t)tileId atPosition:(vector_uint2)position z:(int8_t)z {
    id<MTLTexture> texture = [_textures textureForTile:tileId];

    if (texture == nil) {
        return;
    }
    
    [self drawQuad:texture atPosition:position z:z];
}

- (void)drawTerrainQuad:(uint32_t)tileId atPosition:(vector_uint2)position z:(int8_t)z {
    id<MTLTexture> texture = [_textures textureForLand:tileId];
    
    if (texture == nil) {
        return;
    }
    
    vector_float2 relativePosition = {
        (float)position.x - _world.position.x,
        (float)position.y - _world.position.y
    };
        
    float xOffset = 22.f * relativePosition.x + -22.f * relativePosition.y - 0.5f;
    float yOffset = -22.f * relativePosition.x + -22.f * relativePosition.y - 0.5f;
            
    MapCell bottom = [_world.map readCellAtPosition:position + (vector_uint2){1, 1}];
    MapCell left = [_world.map readCellAtPosition:position + (vector_uint2){0, 1}];
    MapCell right = [_world.map readCellAtPosition:position + (vector_uint2){1, 0}];
    
    if (abs(z - bottom.z) > abs(right.z - left.z)) {
        //      1
        //    / | \
        //   /  |  \
        //  3   |   0
        //   \  |  /
        //    \ | /
        //      2

        Vertex quadVertices[] = {
            {{ 22.f + xOffset,   0.f + yOffset + (4.f * right.z)},  {1.f, 0.f}},
            {{  0.f + xOffset,  22.f + yOffset + (4.f * z)},        {0.f, 0.f}},
            {{  0.f + xOffset, -22.f + yOffset + (4.f * bottom.z)}, {1.f, 1.f}},
            {{-22.f + xOffset,   0.f + yOffset + (4.f * left.z)},   {0.f, 1.f}},
       };
        
        if ([self isQuadInViewportWithTop:quadVertices[1]
                                     left:quadVertices[3]
                                   bottom:quadVertices[2]
                                    right:quadVertices[0]]) {
            [self enqueueQuad:quadVertices texture:texture];
        }
    } else {
        //      3
        //    /   \
        //   /     \
        //  2-------1
        //   \     /
        //    \   /
        //      0
        
        Vertex quadVertices[] = {
            {{  0.f + xOffset, -22.f + yOffset + (4.f * bottom.z)}, {1.f, 1.f}},
            {{ 22.f + xOffset,   0.f + yOffset + (4.f * right.z)},  {1.f, 0.f}},
            {{-22.f + xOffset,   0.f + yOffset + (4.f * left.z)},   {0.f, 1.f}},
            {{  0.f + xOffset,  22.f + yOffset + (4.f * z)},        {0.f, 0.f}},
       };
        
        if ([self isQuadInViewportWithTop:quadVertices[3]
                                     left:quadVertices[2]
                                   bottom:quadVertices[0]
                                    right:quadVertices[1]]) {
            [self enqueueQuad:quadVertices texture:texture];
        }
    }
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

@end
