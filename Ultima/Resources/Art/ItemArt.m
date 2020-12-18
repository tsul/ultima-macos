#import "ItemArt.h"
#import "IndexedMULReader.h"
#include <simd/simd.h>

@implementation ItemArt

- (nullable instancetype)initLandWithId:(uint32_t)tileId {
    self = [super init];
        
    if (self) {
        IndexedMULReader *reader = [[IndexedMULReader alloc] initWithDataFilename:@"art" indexFilename:@"artidx"];
        IndexedMULEntry mulData = [reader getEntryForId:tileId];
        
        if (mulData.metadata.offset == -1) {
            return nil;
        }
        
        _width = 44;
        _height = 44;
        
        NSMutableData *mutableData = [[NSMutableData alloc] initWithLength: _width * _height * sizeof(uint32_t)];
        
        uint16_t *readPointer = (uint16_t *)mulData.data.bytes;
        uint32_t *writePointer = (uint32_t *)mutableData.bytes;
                    
        NSUInteger x = 21;
        NSUInteger y = 0;
        NSUInteger lineWidth = 2;
                    
        for (; y < _height / 2; ++y, x -= 1, lineWidth += 2) {
            for (uint16_t lineOfset = 0; lineOfset < lineWidth; ++lineOfset) {
                uint16_t color = *readPointer++;
                                    
                uint16_t r = ((color >> 10) & 0x1F) * 0xFF / 0x1F;
                uint16_t g = ((color >> 5) & 0x1F) * 0xFF / 0x1F;
                uint16_t b = (color & 0x1F) * 0xFF / 0x1F;
                uint16_t a = UINT16_MAX;
                
                *(writePointer + x + lineOfset + (_width * y)) = b | (g << 8) | (r << 16) | (a << 24);
            }
        }
        
        lineWidth = 44;
        
        for (; y < _height; ++y, x +=1, lineWidth -= 2) {
            for (uint16_t lineOffset = 0; lineOffset < lineWidth; ++lineOffset) {
                uint16_t color = *readPointer++;
                                    
                uint16_t r = ((color >> 10) & 0x1F) * 0xFF / 0x1F;
                uint16_t g = ((color >> 5) & 0x1F) * 0xFF / 0x1F;
                uint16_t b = (color & 0x1F) * 0xFF / 0x1F;
                uint16_t a = UINT16_MAX;
                
                *(writePointer + x + lineOffset + (_width * y)) = b | (g << 8) | (r << 16) | (a << 24);
            }
        }
        
        _data = mutableData;
    }
    
    return self;
}

- (nullable instancetype)initStaticWithItemId:(uint32_t)itemId {
    self = [super init];
        
    if (self) {
        IndexedMULReader *reader = [[IndexedMULReader alloc] initWithDataFilename:@"art" indexFilename:@"artidx"];
        IndexedMULEntry mulData = [reader getEntryForId:itemId + 0x4000];

        typedef struct __attribute__ ((packed)) StaticHeader {
            uint32_t header;
            uint16_t width;
            uint16_t height;
        } StaticHeader;
            
        StaticHeader *header = (StaticHeader *)mulData.data.bytes;
        
        _width = header->width;
        _height = header->height;
        
        NSMutableData *mutableData = [[NSMutableData alloc] initWithLength: _width * _height * sizeof(uint32_t)];
        
        uint16_t *lookup = (uint16_t *)mulData.data.bytes + (sizeof(StaticHeader) / sizeof(uint16_t));
        uint16_t *readPointer = lookup + _height + *lookup;
        uint32_t *writePointer = (uint32_t *)mutableData.bytes;

        uint16_t x = 0;
        uint16_t y = 0;
            
        while (y < _height) {
            uint16_t xOffset = *readPointer++;
            uint16_t run = *readPointer++;
            
            if (xOffset + run != 0) {
                x += xOffset;
                for (NSUInteger i = 0; i < run; ++i) {
                    uint16_t color = *readPointer++;
                    
                    uint16_t r = ((color >> 10) & 0x1F) * 0xFF / 0x1F;
                    uint16_t g = ((color >> 5) & 0x1F) * 0xFF / 0x1F;
                    uint16_t b = (color & 0x1F) * 0xFF / 0x1F;
                    uint16_t a = UINT16_MAX;
                    
                    *(writePointer + x + i + (_width * y)) = b | (g << 8) | (r << 16) | (a << 24);
                }
                
                x += run;
            } else {
                x = 0;
                y++;
                readPointer = lookup + _height + *(lookup + y);
            }
        }
        
        _data = mutableData;
    }
    
    return self;
}

@end
