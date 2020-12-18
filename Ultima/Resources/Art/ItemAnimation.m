#import "ItemAnimation.h"

@implementation ItemAnimation

-(instancetype)initWithItemId:(uint16_t)itemId {
    self = [super init];
    
    if (self) {
        NSBundle* mainBundle = [NSBundle mainBundle];
        NSString* dataPath = [mainBundle pathForResource:@"animdata" ofType:@"mul"];
        NSFileHandle* dataHandle = [NSFileHandle fileHandleForReadingAtPath:dataPath];
        
        NSAssert(dataHandle, @"Could not acquire file handle");
        
        uint32_t offset = (itemId >> 3) * 548 + ( itemId & 15 ) * 68 + 4;
                
        [dataHandle seekToOffset:offset error:nil];
        
        NSData *data = [dataHandle readDataOfLength:68];
        int8_t *reader = (int8_t *)data.bytes;
        
        for (int i = 0; i < 64; ++i) {
            _frames[i] = *reader++;
        }

        reader++;
        
        _frameCount = *reader++;
        _frameInterval = *reader++;
        _startInterval = *reader++;
    }
    
    return self;
}

- (int8_t *)frames {
    return _frames;
}

@end
