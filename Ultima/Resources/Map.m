#import "Map.h"
#import "IndexedMULReader.h"

@implementation UltimaStatic
    - (nullable instancetype)initWithStaticData:(StaticData)data {
        self = [super init];
        
        if (self) {
            _itemId = data.itemId;
            _x = data.x;
            _y = data.y;
            _z = data.z;
            _unknown = data.unknown;
        }
        
        return self;
    }

@end

@implementation Map {
    NSFileHandle *_dataHandle;
    IndexedMULReader *_staticsReader;
    
    MapBlock _blockCache[0x60000];
    NSArray<UltimaStatic *> *_staticsCache[0x60000];
}

- (nullable instancetype)initMapWithId:(NSUInteger)mapId {
    self = [super init];
        
    if (self) {
        NSBundle* mainBundle = [NSBundle mainBundle];
        NSString* dataPath = [mainBundle pathForResource:[NSString stringWithFormat:@"map%d", (int)mapId] ofType:@"mul"];
        NSFileHandle* dataHandle = [NSFileHandle fileHandleForReadingAtPath:dataPath];
        
        NSAssert(dataHandle, @"Could not acquire file handles");

        _dataHandle = dataHandle;
        
        _staticsReader = [[IndexedMULReader alloc]
                          initWithDataFilename:[NSString stringWithFormat:@"statics%d", (int)mapId]
                          indexFilename:[NSString stringWithFormat:@"staidx%d", (int)mapId]];

    }
    
    return self;
}

- (NSArray<UltimaStatic *> *)readStaticsAtPosition:(vector_uint2)position {
    NSUInteger xBlock = position.x / 8;
    NSUInteger yBlock = position.y / 8;
    NSUInteger blockIndex = (xBlock * 512) + yBlock;
    
    NSUInteger blockXStart = xBlock * 8;
    NSUInteger blockYStart = yBlock * 8;
    
    NSArray<UltimaStatic *> *statics;
    
    if (_staticsCache[blockIndex] != nil) {
        statics = _staticsCache[blockIndex];
    } else {
        IndexedMULEntry staticsIndex = [_staticsReader getEntryForId:blockIndex];
        StaticData *staticData = (StaticData *)staticsIndex.data.bytes;
        NSMutableArray *mutableArray = [NSMutableArray array];
                
        if (staticsIndex.metadata.length > -1) {
            for (int i = 0; i < staticsIndex.metadata.length / sizeof(StaticData); ++i) {
                [mutableArray addObject:[[UltimaStatic alloc] initWithStaticData:*staticData]];
                staticData++;
            }
        }
        
        statics = [mutableArray copy];
        _staticsCache[blockIndex] = statics;
    }
    
    NSMutableArray<UltimaStatic *> *staticsForTile = [NSMutableArray array];
    
    for (int i = 0; i < statics.count; ++i) {
        if (statics[i].x + blockXStart == position.x && statics[i].y + blockYStart == position.y) {
            [staticsForTile addObject:statics[i]];
        }
    }
    
    return staticsForTile;
}

- (MapCell)readCellAtPosition:(vector_uint2)position {
    MapBlock block;
    
    NSUInteger xBlock = position.x / 8;
    NSUInteger yBlock = position.y / 8;
    NSUInteger blockIndex = (xBlock * 512) + yBlock;
    
    if (_blockCache[blockIndex].header != 0) {
        block = _blockCache[blockIndex];
    } else {
        [_dataHandle seekToOffset:blockIndex * sizeof(MapBlock) error:nil];
        
        NSData *blockData = [_dataHandle readDataUpToLength:sizeof(MapBlock) error:nil];
        [blockData getBytes:&block length:sizeof(MapBlock)];
        
        block.header = 420;
        _blockCache[blockIndex] = block;
    }
    
    NSUInteger blockXStart = xBlock * 8;
    NSUInteger blockYStart = yBlock * 8;
            
    return block.cells[(position.x - blockXStart) + 8 * (position.y - blockYStart)];
}

@end
