#import "TileData.h"

@implementation TileData {
    NSFileHandle *_dataHandle;
    
    LandBlock _landCache[512];
    StaticBlock _staticCache[2048];
}

- (nullable instancetype)init {
    self = [super init];
        
    if (self) {
        NSBundle* mainBundle = [NSBundle mainBundle];
        NSString* dataPath = [mainBundle pathForResource:@"tiledata" ofType:@"mul"];
        NSFileHandle* dataHandle = [NSFileHandle fileHandleForReadingAtPath:dataPath];
        
        NSAssert(dataHandle, @"Could not acquire file handles");

        _dataHandle = dataHandle;
    }
    
    return self;
}

- (LandEntry)readLandEntry:(uint16_t)landId {
    LandBlock block;
    int blockIndex = landId / 32;
        
    if (_landCache[blockIndex].header != 0) {
        block = _landCache[blockIndex];
    } else {
        [_dataHandle seekToOffset:blockIndex * sizeof(LandBlock) error:nil];
        
        NSData *blockData = [_dataHandle readDataUpToLength:sizeof(LandBlock) error:nil];
        [blockData getBytes:&block length:sizeof(LandBlock)];
        
        block.header = 420;
        _landCache[blockIndex] = block;
    }
    
    return block.entries[landId - blockIndex * 32];
}

- (StaticEntry)readStaticEntry:(uint16_t)itemId {
    StaticBlock block;
    int blockIndex = itemId / 32;
    
    if (_staticCache[blockIndex].header != 0) {
        block = _staticCache[blockIndex];
    } else {
        int staticsOffset = 512 * sizeof(LandBlock);
        [_dataHandle seekToOffset: staticsOffset + (blockIndex * sizeof(StaticBlock)) error:nil];

        NSData *blockData = [_dataHandle readDataUpToLength:sizeof(StaticBlock) error:nil];
        [blockData getBytes:&block length:sizeof(StaticBlock)];
        
        block.header = 420;
        _staticCache[blockIndex] = block;
    }
    
    return block.entries[itemId - blockIndex * 32];
}

@end
