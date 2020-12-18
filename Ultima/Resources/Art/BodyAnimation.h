#import <Foundation/Foundation.h>
#import "IndexedMULReader.h"
#import "BodyAnimationFrame.h"

@interface BodyAnimation : NSObject
- (nullable instancetype)initWithId:(uint32_t)animationId;

@property (nonnull, nonatomic, readonly) NSArray<BodyAnimationFrame *> *frameData;

@end
