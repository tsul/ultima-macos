#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import "Map.h"
#import "World.h"
#import "ItemAnimation.h"


typedef NS_ENUM(NSUInteger, ObjectType) {
    otLand,
    otStatic
};

@interface Object : NSObject

- (nonnull instancetype)initWithObjectType:(ObjectType)type artId:(uint16_t)artId hue:(int8_t)hue flags:(uint64_t)flags z:(int8_t)z height:(uint8_t)height position:(vector_uint2)position world:(nonnull World *)world;

@property (nonatomic, readonly) ObjectType objectType;
@property (nonatomic, readonly) uint16_t artId;
@property (nonatomic, readonly) int8_t hue;
@property (nonatomic, readonly) uint64_t flags;
@property (nonatomic, readonly) int8_t z;
@property (nonatomic, readonly) uint8_t height;
@property (nonatomic, readonly) vector_uint2 position;
@property (nonnull, nonatomic, readonly) World *world;
@property (nullable, nonatomic, readonly) ItemAnimation *itemAnimation;


- (int8_t)sortZ;
- (int)threshold;
- (int)tiebreaker;

@end
