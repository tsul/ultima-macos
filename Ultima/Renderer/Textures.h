@import MetalKit;
#import "LandArt.h"
#import "ItemArt.h"

@interface Textures : NSObject 

- (nullable instancetype)initWithDevice:(nonnull id<MTLDevice>)device;

- (nullable id<MTLTexture>)textureForTile:(uint16_t)tileId;
- (nullable id<MTLTexture>)textureForStatic:(uint16_t)itemId;
- (nullable id<MTLTexture>)textureForLand:(uint16_t)tileId;
- (nonnull NSArray<id<MTLTexture>> *)texturesForUnicodeText:(nonnull NSString *)text withFont:(NSUInteger)fontId;
- (nonnull NSArray<id<MTLTexture>> *)texturesForAsciiText:(nonnull NSString *)text withFont:(NSUInteger)fontId;
- (nullable id<MTLTexture>)textureForBodyAnimation:(uint32_t)animationId atFrame:(uint32_t)frameIndex;


@end
