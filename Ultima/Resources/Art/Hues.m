#import "Hues.h"

@implementation Hues {
    NSFileHandle *_dataHandle;
    Hue _hues[3000];
}

-(instancetype)init {
    self = [super init];
    
    if (self) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *dataPath = [mainBundle pathForResource:@"hues" ofType:@"mul"];
        NSFileHandle *dataHandle = [NSFileHandle fileHandleForReadingAtPath:dataPath];
        
        NSAssert(dataHandle, @"Could not acquire file handle");

        _dataHandle = dataHandle;

        int offset = 4;
        
        for (int i = 0; i < 3000; ++i) {
            if (i % 8 == 0) {
                offset += 4;
            }
            
            Hue hue;
            
            [dataHandle seekToOffset:offset error:nil];

            NSData *blockData = [_dataHandle readDataUpToLength:sizeof(Hue) error:nil];
            [blockData getBytes:&hue length:sizeof(Hue)];
            
            _hues[i] = hue;
            
            offset += sizeof(Hue);
        }
    }

    return self;
}

- (Hue *)hues {
    return _hues;
}

@end
