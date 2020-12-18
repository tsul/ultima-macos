#import <Foundation/Foundation.h>

typedef struct __attribute__ ((packed)) Hue {
    uint16_t colorTable[32];
    uint16_t tableStart;
    uint16_t tableEnd;
    char name[20];
} Hue;

@interface Hues : NSObject

@property (nonatomic, readonly) Hue *hues;

@end
