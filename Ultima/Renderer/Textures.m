#import "Textures.h"
#import "UnicodeFont.h"
#import "AsciiFont.h"
#import "BodyAnimation.h"
#import "Hues.h"

@implementation Textures {
    id<MTLDevice> _device;
    NSCache<NSString *, id<MTLTexture>> *_textureCache;
    NSCache<NSString *, id<MTLTexture>> *_textTextureCache;
    UnicodeFont *_unicodeFonts[12];
    NSArray<AsciiFont *> *_asciiFonts;
}

- (nullable instancetype)initWithDevice:(id<MTLDevice>)device {
    self = [super init];
    
    if (self) {
        _device = device;
        
        _textureCache = [[NSCache alloc] init];
        _textTextureCache = [[NSCache alloc] init];
        
        for (int i = 0; i < 12; ++i) {
            _unicodeFonts[i] = [[UnicodeFont alloc] initWithId:i + 1];
        }
        
        _asciiFonts = [AsciiFont loadAll];
    }
    
    return self;
}

-(id<MTLTexture>)textureForHues {
    NSString *cacheLookup = @"hues";
    id<MTLTexture> texture = [_textureCache objectForKey:cacheLookup];
     
    if (texture) {
        return texture;
    }
    
    Hues *hues = [[Hues alloc] init];
    
    for (int i = 0; i < 3000; ++i) {
         
    }
    
    return nil;
}

-(id<MTLTexture>)textureForBodyAnimation:(uint32_t)animationId atFrame:(uint32_t)frameIndex {
    NSString *cacheLookup = [NSString stringWithFormat:@"body-animation-%d-%d", animationId, frameIndex];
    id<MTLTexture> texture = [_textureCache objectForKey:cacheLookup];
    
    if (texture) {
        return texture;
    }
            
    BodyAnimation *animation = [[BodyAnimation alloc] initWithId:animationId];
    BodyAnimationFrame *frame = animation.frameData[frameIndex];
    
    texture = [self createTexture:frame.data width:frame.width height:frame.height];
    
    if (texture == nil) {
        return nil;
    }
    
    [_textureCache setObject:texture forKey:cacheLookup];
            
    return texture;
}

-(id<MTLTexture>)textureForCharacter:(Character *)character {
    NSString *cacheLookup = [NSString stringWithFormat:@"%c-unicode-%d", character.value, 0];
    id<MTLTexture> texture = [_textTextureCache objectForKey:cacheLookup];
    
    if (texture) {
        return texture;
    }
    
    MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];
    textureDescriptor.pixelFormat = MTLPixelFormatBGRA8Unorm;
    
    textureDescriptor.width = character.width + character.kerning;
    textureDescriptor.height = character.height + character.baseline;
        
    texture  = [_device newTextureWithDescriptor:textureDescriptor];
    
    MTLRegion region = {
        {character.kerning, character.baseline, 0},
        {character.width, character.height, 1}
    };
    
    [texture replaceRegion:region mipmapLevel:0 withBytes:character.data.bytes bytesPerRow:4 * character.width];
    
    [_textTextureCache setObject:texture forKey:cacheLookup];
    
    return texture;
}

- (id<MTLTexture>)texturesForUnicodeText:(NSString *)text withFont:(NSUInteger)fontId {
    NSMutableArray<id<MTLTexture>> *textures = [NSMutableArray array];
    
    UnicodeFont *font = _unicodeFonts[fontId - 1];
    NSArray<Character *> *characters = [font text:text];
    
    for (int i = 0; i < characters.count; ++i) {
        Character *character = characters[i];

        [textures addObject:[self textureForCharacter:character]];
    }

    return [textures copy];
}

- (id<MTLTexture>)texturesForAsciiText:(NSString *)text withFont:(NSUInteger)fontId {
    NSMutableArray<id<MTLTexture>> *textures = [NSMutableArray array];
    
    AsciiFont *font = _asciiFonts[fontId - 1];
    NSArray<Character *> *characters = [font text:text];
    
    for (int i = 0; i < characters.count; ++i) {
        Character *character = characters[i];

        [textures addObject:[self textureForCharacter:character]];
    }

    return [textures copy];
}

- (id<MTLTexture>)textureForTile:(uint16_t)tileId {
    NSString *cacheLookup = [NSString stringWithFormat:@"tile-%d", tileId];
    id<MTLTexture> texture = [_textureCache objectForKey:cacheLookup];
    
    if (texture) {
        return texture;
    }
        
    ItemArt *art = [[ItemArt alloc] initLandWithId:tileId];
    texture = [self createTexture:art.data width:art.width height:art.height];
    
    if (texture == nil) {
        return nil;
    }
    
    [_textureCache setObject:texture forKey:cacheLookup];
            
    return texture;
}

- (id<MTLTexture>)textureForStatic:(uint16_t)itemId {
    NSString *cacheLookup = [NSString stringWithFormat:@"static-%d", itemId];
    id<MTLTexture> texture = [_textureCache objectForKey:cacheLookup];
    
    if (texture) {
        return texture;
    }
    
    ItemArt *art = [[ItemArt alloc] initStaticWithItemId:itemId];
    
    texture = [self createTexture:art.data width:art.width height:art.height];
    
    if (texture == nil) {
        return nil;
    }
    
    [_textureCache setObject:texture forKey:cacheLookup];
        
    return texture;
}

- (id<MTLTexture>)textureForLand:(uint16_t)tileId {
    NSString *cacheLookup = [NSString stringWithFormat:@"land-%d", tileId];
    id<MTLTexture> texture = [_textureCache objectForKey:cacheLookup];
    
    if (texture) {
        return texture;
    }
        
    LandArt *art = [[LandArt alloc] initWithTextureId:tileId];
    texture = [self createTexture:art.data width:art.width height:art.height];
    
    if (texture == nil) {
        return nil;
    }
    
    [_textureCache setObject:texture forKey:cacheLookup];
        
    return texture;
}

- (id<MTLTexture>)createTexture:(NSData *)data width:(NSUInteger)width height:(NSUInteger)height {
    if (width == 0 || height == 0) {
        return nil;
    }
    
    MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];
    textureDescriptor.pixelFormat = MTLPixelFormatBGRA8Unorm;
    
    textureDescriptor.width = width;
    textureDescriptor.height = height;
        
    id<MTLTexture> texture  = [_device newTextureWithDescriptor:textureDescriptor];
    
    NSUInteger bytesPerRow = 4 * width;
    
    MTLRegion region = {
        {0, 0, 0},
        {width, height, 1}
    };
    
    [texture replaceRegion:region mipmapLevel:0 withBytes:data.bytes bytesPerRow:bytesPerRow];
        
    return texture;
}

@end
