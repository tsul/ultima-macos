#import "Character.h"

@implementation Character

- (nullable instancetype)initWithWidth:(int8_t)width height:(int8_t)height kerning:(int8_t)kerning baseline:(int8_t)baseline data:(nonnull NSData *)data value:(unichar)value {
    self = [super init];
    
    if (self) {
        _width = width;
        _height = height;
        _kerning = kerning;
        _baseline = baseline;
        _data = data;
        _value = value;
    }
    
    return self;
}

@end
