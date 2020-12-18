#import "LandArt.h"
#import "IndexedMULReader.h"
#include <simd/simd.h>

@implementation LandArt

IndexedMULEntry _indexCache[0x8000];

-(nullable instancetype)initWithTextureId:(uint32_t)textureId {
    self = [super init];
    
    if (self) {
        IndexedMULEntry mulData;
        
        if (_indexCache[textureId].metadata.length != 0) {
            mulData = _indexCache[textureId];
        } else {
            IndexedMULReader *reader = [[IndexedMULReader alloc] initWithDataFilename:@"texmaps" indexFilename:@"texidx"];
            mulData = [reader getEntryForId:textureId];
            _indexCache[textureId] = mulData;
        }

        _width = mulData.metadata.extra == 1 ? 128 : 64;
        _height = _width;
        
        if (mulData.metadata.length == -1) {
            return nil;
        }
                
        NSMutableData *mutableData = [[NSMutableData alloc] initWithLength: mulData.metadata.length * 2];
        
        uint16_t *dataPointer = (uint16_t *)mulData.data.bytes;
        uint32_t *outputPointer = mutableData.mutableBytes;
        
        for (int i = 0; i < mulData.metadata.length / sizeof(uint16_t); ++i) {
            uint16_t color = *dataPointer++;
            
            uint16_t r = ((color >> 10) & 0x1F) * 7;
            uint16_t g = ((color >> 5) & 0x1F) * 7;
            uint16_t b = (color & 0x1F) * 7;
            uint16_t a = UINT16_MAX;

            *outputPointer++ = b | (g << 8) | (r << 16) | (a << 24);
        }
        
        _data = mutableData;
    }
        
    return self;
}

@end
