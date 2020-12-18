@import simd;

#import "World.h"
#import "Map.h"
#import "TileData.h"
#import "Object.h"
#import "TileFlags.h"

@implementation World {
    Map *_map;
    TileData *_tileData;
    
    int _range;
    vector_uint2 _position;
    
    NSArray<NSArray<Object *> *> *_objects;
}

- (nonnull instancetype)init {
    self = [super init];
    
    if (self) {
        _range = 32;
        _objects = [NSArray array];
        _map = [[Map alloc] initMapWithId:0];
        _tileData = [[TileData alloc] init];
        
        //        _position = (vector_uint2){1201, 689};
//                _position = (vector_uint2){983, 689}; // archway
//                _position = (vector_uint2){1780, 2265}; // fort
        //        _position = (vector_uint2){1816, 2309}; // beach
//                _position = (vector_uint2){1750, 1510}; //theater
        _position = (vector_uint2){1612, 1514}; // xmas
//                _position = (vector_uint2){1600, 1200}; // cute house
//                _position = (vector_uint2){1120, 1178}; // coastline
        //        _position = (vector_uint2){1112, 1136}; // coastline2
        //        _position = (vector_uint2){1542, 535}; // snow
//                _position = (vector_uint2){1572, 1006}; // mansion
//        _position = (vector_uint2){1124, 1010}; // other fort
//        _position = (vector_uint2){1223, 1240}; // watering hole
//        _position = (vector_uint2){1566, 1485}; // cathedral?
//        5819 1982 // hell
//        _position = (vector_uint2){5947, 1586}; // dungeon
        //1699 3013 trinsic style
        // 5922 2427 siq dungeon
        // 1618 2570
//        _position = (vector_uint2){1618, 2570}; // cute ass town
        // 1865 782 spooky tower
        
//        _position = (vector_uint2){6049, 1265};
        // shrine 1309 1227

//        _position = (vector_uint2){arc4random_uniform(6114), arc4random_uniform(4096)};
        
        [self update];
    }
    
    return self;
}

-(void)move:(vector_int2)direction {
    _position = (vector_uint2){_position.x + direction.x, _position.y + direction.y};
    NSLog(@"%d %d", _position.x, _position.y);
    
    [self update];
}

-(NSArray<Object *> *)objectsForPosition:(vector_uint2)position {
    NSMutableArray *objects = [NSMutableArray array];
    
    MapCell cell = [_map readCellAtPosition:position];
    LandEntry landEntry = [_tileData readLandEntry:cell.tileId];
    
    Object *land = [[Object alloc] initWithObjectType:otLand
                                                artId:cell.tileId
                                                  hue:0
                                                flags:landEntry.flags
                                                    z:cell.z
                                               height:0
                                             position:position
                                                world:self];
    [objects addObject:land];
    
    NSArray<UltimaStatic *> *statics = [_map readStaticsAtPosition:position];

    for (int i = 0; i < statics.count; ++i) {
        UltimaStatic *current = statics[i];
        StaticEntry staticEntry = [_tileData readStaticEntry:current.itemId];
        
        if (current.itemId == 1 || (current.itemId >= 0x2198 && current.itemId <= 0x21A4) || staticEntry.flags & tfIgnored || current.itemId == 0x21BC || current.itemId == 0x5690) {
            continue;
        }
                   
        Object *staticObject = [[Object alloc] initWithObjectType:otStatic
                                                            artId:current.itemId
                                                              hue:staticEntry.hue
                                                            flags:staticEntry.flags
                                                                z:current.z
                                                           height:staticEntry.height
                                                         position:position
                                                            world:self];
        [objects addObject:staticObject];
    }
    
    return [objects copy];
}

-(void)update {
    NSMutableArray *worldObjects = [NSMutableArray array];
    
    for (int x = -_range; x < _range; ++x) {
        for (int y = -_range; y < _range; ++y) {
            if ((int)_position.x + x < 0 || (int)_position.y + y < 0) {
                [worldObjects addObject:[NSArray array]];
                continue;
            }
                                                        
            NSArray *objects = [self objectsForPosition:(vector_uint2){_position.x + x, _position.y + y}];
            NSArray *sorted = [objects sortedArrayUsingSelector:@selector(compare:)];
            
            [worldObjects addObject:sorted];
        }
    }
    
    _objects = [worldObjects copy];
}

@end
