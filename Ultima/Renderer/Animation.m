#import "Animation.h"
#import "BodyConversion.h"

@implementation Animations {
    BodyConversion *_bodyConversion;
}

-(instancetype)init {
    self = [super init];
    
    if (self) {
        _bodyConversion = [[BodyConversion alloc] init];
    }
    
    return self;
}

-(void)update {
    
}

@end
