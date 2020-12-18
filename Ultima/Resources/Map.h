#import <Foundation/Foundation.h>
#include <simd/simd.h>

typedef struct __attribute__ ((packed)) MapCell {
    uint16_t tileId;
    int8_t z;
} MapCell;

typedef struct __attribute__ ((packed)) MapBlock {
    uint32_t header;
    MapCell cells[64];
} MapBlock;

typedef struct __attribute__ ((packed)) StaticData {
    uint16_t itemId;
    uint8_t x;
    uint8_t y;
    int8_t z;
    uint16_t unknown;
} StaticData;

@interface UltimaStatic : NSObject
- (nullable instancetype)initWithStaticData:(StaticData)data;
@property (nonatomic, readonly) uint16_t itemId;
@property (nonatomic, readonly) uint8_t x;
@property (nonatomic, readonly) uint8_t y;
@property (nonatomic, readonly) int8_t z;
@property (nonatomic, readonly) uint16_t unknown;
@end

@interface Map : NSObject
-(nullable instancetype) initMapWithId:(NSUInteger)mapId;

-(MapCell) readCellAtPosition:(vector_uint2)position;
-(nonnull NSArray<UltimaStatic *> *)readStaticsAtPosition:(vector_uint2)position;

@property (nonatomic, readonly) NSUInteger width;
@property (nonatomic, readonly) NSUInteger height;

@property (nonatomic, readonly, nonnull) NSData *data;

@end
