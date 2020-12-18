#import <Foundation/Foundation.h>

@interface LandArt : NSObject

-(nullable instancetype) initWithTextureId:(uint32_t)textureId;

@property (nonatomic, readonly) NSUInteger width;
@property (nonatomic, readonly) NSUInteger height;

@property (nonatomic, readonly, nonnull) NSData *data;

@end
