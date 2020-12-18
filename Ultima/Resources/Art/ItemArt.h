#import <Foundation/Foundation.h>

@interface ItemArt : NSObject

-(nullable instancetype) initStaticWithItemId:(uint32_t)itemId;
-(nullable instancetype) initLandWithId:(uint32_t)tileId;

@property (nonatomic, readonly) NSUInteger width;
@property (nonatomic, readonly) NSUInteger height;

@property (nonatomic, readonly, nonnull) NSData *data;

@end
