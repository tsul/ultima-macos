@import MetalKit;

#import "World.h"

@interface Renderer : NSObject<MTKViewDelegate>

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView world:(nonnull World *)world;

@end
