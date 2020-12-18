#import "Object.h"
#import "TileFlags.h"
#import "Map.h"

@implementation Object

- (nonnull instancetype)initWithObjectType:(ObjectType)type artId:(uint16_t)artId hue:(int8_t)hue flags:(uint64_t)flags z:(int8_t)z height:(uint8_t)height position:(vector_uint2)position world:(World *)world {
    self = [super init];
    
    if (self) {
        _objectType = type;
        _artId = artId;
        _hue = hue;
        _flags = flags;
        _z = z;
        _height = height;
        _position = position;
        _world = world;
        
        if (_objectType == otStatic && _flags & tfAnimation) {
            _itemAnimation = [[ItemAnimation alloc] initWithItemId:_artId];
        }
    }
    
    return self;
}

- (int)floorAverage:(int)a b:(int)b {
    int v = a + b;
    
    if ( v < 0 )
        --v;
    
    return ( v / 2 );
}

- (int8_t)sortZ {
    if (_objectType == otLand) {
        MapCell bottom = [_world.map readCellAtPosition:_position + (vector_uint2){1, 1}];
        MapCell left = [_world.map readCellAtPosition:_position + (vector_uint2){0, 1}];
        MapCell right = [_world.map readCellAtPosition:_position + (vector_uint2){1, 0}];
        
        if (abs(_z - bottom.z) > abs(right.z - left.z)) {
            return [self floorAverage:left.z b:right.z];
        } else {
            return [self floorAverage:_z b:bottom.z];
        }
    }
    
    return _z + [self threshold];
}

- (int)threshold {
    int threshold = 0;

    if (_objectType == otStatic) {
        if (!(_flags & tfBackground)) {
            threshold++;
        }
        
        if (_height > 0) {
            threshold++;
        }
    }
    
    return threshold;
}

- (int)tiebreaker {
    int tiebreaker = 0;
    
    if (_objectType == otStatic) {
        return _artId;
    }
    
    return tiebreaker;
}

- (NSComparisonResult)compare:(Object *)other {
    if ([self sortZ] > [other sortZ]) {
        return NSOrderedDescending;
    } else if ([other sortZ] > [self sortZ]) {
        return NSOrderedAscending;
    } else if (self.objectType > other.objectType) {
        return NSOrderedDescending;
    } else if (other.objectType > self.objectType) {
        return NSOrderedAscending;
    } else if ([self threshold] > [other threshold]) {
        return NSOrderedDescending;
    } else if ([other threshold] > [self threshold]) {
        return NSOrderedAscending;
    } else if ([self tiebreaker] > [other tiebreaker]) {
        return NSOrderedDescending;
    } else if ([other tiebreaker] > [self tiebreaker]) {
        return NSOrderedAscending;
    } else {
        return NSOrderedSame;
    }
}

@end
