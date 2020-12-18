#import <Foundation/Foundation.h>
#include <simd/simd.h>

typedef struct __attribute__ ((packed)) LandEntry {
    int64_t flags;
    uint16_t textureId;
    char name[20];
} LandEntry;

typedef struct __attribute__ ((packed)) LandBlock {
    uint32_t header;
    LandEntry entries[32];
} LandBlock;

typedef struct __attribute__ ((packed)) StaticEntry {
    int64_t flags;
    int8_t weight;
    int8_t quality;
    int16_t unknown1;
    int8_t unknown2;
    int8_t quantity;
    int16_t animationId;
    int8_t unknown3;
    int8_t hue;
    uint16_t unknown4;
    uint8_t height;
    char name[20];
} StaticEntry;

typedef struct __attribute__ ((packed)) StaticBlock {
    uint32_t header;
    StaticEntry entries[32];
} StaticBlock;

@interface TileData : NSObject
-(nullable instancetype) init;

-(LandEntry)readLandEntry:(uint16_t)landId;
-(StaticEntry)readStaticEntry:(uint16_t)itemId;

@end


