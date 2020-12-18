#import <Foundation/Foundation.h>
#include <simd/simd.h>

@interface Character : NSObject
- (nullable instancetype)initWithWidth:(int8_t)width height:(int8_t)height kerning:(int8_t)kerning baseline:(int8_t)baseline data:(nonnull NSData *)data value:(unichar)value;
@property (nonatomic, readonly) uint8_t kerning;
@property (nonatomic, readonly) uint8_t baseline;
@property (nonatomic, readonly) uint8_t width;
@property (nonatomic, readonly) uint8_t height;
@property (nonatomic, readonly) unichar value;
@property (nonnull, atomic, readonly) NSData *data;
@end


