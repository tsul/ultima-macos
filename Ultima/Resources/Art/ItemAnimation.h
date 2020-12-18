#import <Foundation/Foundation.h>

@interface ItemAnimation : NSObject {
    int8_t _frames[64];
}

-(instancetype)initWithItemId:(uint16_t)itemId;

@property (nonatomic, readonly) int8_t *frames;
@property (nonatomic, readonly) int8_t frameCount;
@property (nonatomic, readonly) int8_t frameInterval;
@property (nonatomic, readonly) int8_t startInterval;

@end
