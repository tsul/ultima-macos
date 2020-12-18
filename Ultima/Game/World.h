#import <Foundation/Foundation.h>
#import "Map.h"

@class Object;

@interface World : NSObject

-(void)move:(vector_int2)direction;
-(nonnull NSArray<Object *> *)objectsForPosition:(vector_uint2)position;

@property (nonnull, nonatomic, readonly) Map *map;
@property (nonnull, nonatomic, readonly) NSArray<NSArray<Object *> *> *objects;
@property (nonatomic, readonly) vector_uint2 position;
@property (nonatomic, readonly) int range;

@end
