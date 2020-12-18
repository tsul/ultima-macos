#import "BodyAnimationFrame.h"

@implementation BodyAnimationFrame

-(instancetype)initWithData:(NSData *)data width:(NSUInteger)width height:(NSUInteger)height animationId:(uint32_t)animationId index:(NSUInteger)index {
    self = [super init];
    
    if (self) {
        _data = data;
        _width = width;
        _height = height;
        _animationId = animationId;
        _index = index;
    }
    
    return self;
}

@end
