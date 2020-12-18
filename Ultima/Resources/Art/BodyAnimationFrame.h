#import <Foundation/Foundation.h>

@interface BodyAnimationFrame : NSObject
-(nullable instancetype)initWithData:(nonnull NSData *)data width:(NSUInteger)width height:(NSUInteger)height animationId:(uint32_t)animationId index:(NSUInteger)index;

@property (nonnull, nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSUInteger width;
@property (nonatomic, readonly) NSUInteger height;
@property (nonatomic, readonly) NSUInteger animationId;
@property (nonatomic, readonly) NSUInteger index;

@end
