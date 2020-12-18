#import <Foundation/Foundation.h>
#import "BodyAnimation.h"
#import "BodyConversion.h"

@implementation BodyAnimation {
    NSArray<BodyAnimationFrame *> *_frameData;
    NSFileHandle *_dataHandle;
    NSFileHandle *_indexHandle;
}

- (nullable instancetype)initWithId:(uint32_t)animationId {
    self = [super init];
        
    if (self) {
        // TODO: NOT THIS HERE
        BodyConversion *bodyConv = [[BodyConversion alloc] init];
        NSString *filename = [bodyConv getFileForBody:animationId];
        uint32_t convertedBody = [bodyConv getOffsetForBody:animationId];
                
        NSMutableArray<BodyAnimationFrame *> *frames = [NSMutableArray array];
                
        IndexedMULReader *mulReader = [[IndexedMULReader alloc] initWithDataFilename:filename ofType:@"mul" indexFilename:filename ofType:@"idx"];
        IndexedMULEntry entry = [mulReader getEntryForId:convertedBody];
        int16_t *header = (int16_t *)entry.data.bytes;
                        
        if (entry.metadata.offset == -1 || entry.metadata.length == -1) {
            return nil;
        }
                                
        int16_t palette[0x100];
        
        for (int i = 0; i < 0x100; ++i) {
            palette[i] = *header++;
        }
        
        uint32_t *frameOffsets = (uint32_t *)header;
        uint32_t frameCount = *frameOffsets++;
        
        for (int i = 0; i < frameCount; ++i) {
            uint32_t frameOffset = frameOffsets[i];
            
            [mulReader.dataHandle seekToOffset:entry.metadata.offset + 0x200 + frameOffset error:nil];
            NSData *frameData = [mulReader.dataHandle readDataOfLength:8];
            int offset = 8;

            uint16_t *frameDataReader = (uint16_t *)frameData.bytes;
            
            int16_t centerX = *frameDataReader++;
            int16_t centerY = *frameDataReader++;
            uint16_t width = *frameDataReader++;
            uint16_t height = *frameDataReader;
                        
            int xBase = centerX - 0x200;
            int yBase = (centerY + height) - 0x200;
            
            NSMutableData *mutableData = [[NSMutableData alloc] initWithLength: width * height * sizeof(uint32_t)];
            uint32_t *writePointer = (uint32_t *)mutableData.bytes;
            
            writePointer += xBase;
            writePointer += yBase * width;

            while (true) {
                [mulReader.dataHandle seekToOffset:entry.metadata.offset + 0x200 + frameOffset + offset error:nil];
                NSData *chunkHeaderData = [mulReader.dataHandle readDataOfLength:4];
                offset += 4;
                uint32_t chunkHeader = *(uint32_t *)chunkHeaderData.bytes;

                if (chunkHeader == 0x07FFF7FFF) {
                    break;
                }
                
                chunkHeader ^= (0x200 << 22) | (0x200 << 12);
                
                uint32_t* cur = writePointer + ((((chunkHeader >> 12) & 0x3FF) * width) + ((chunkHeader >> 22) & 0x3FF));
                uint32_t* end = cur + (chunkHeader & 0xFFF);

                while (cur < end) {
                    [mulReader.dataHandle seekToOffset:entry.metadata.offset + 0x200 + frameOffset + offset error:nil];
                    
                    NSData *runData = [mulReader.dataHandle readDataOfLength:1];
                    uint8_t *runDataPointer = (uint8_t *)runData.bytes;
                    offset += 1;
                    
                    uint16_t color = palette[*runDataPointer++];

                    uint16_t r = ((color >> 10) & 0x1F) * 0xFF / 0x1F;
                    uint16_t g = ((color >> 5) & 0x1F) * 0xFF / 0x1F;
                    uint16_t b = (color & 0x1F) * 0xFF / 0x1F;
                    uint16_t a = UINT16_MAX;

                    *cur++ = b | (g << 8) | (r << 16) | (a << 24);
                }
            }
            
            BodyAnimationFrame *frame = [[BodyAnimationFrame alloc] initWithData:[mutableData copy] width:width height:height animationId:animationId index:i];
            [frames addObject:frame];
        }
        
        _frameData = [frames copy];
    }
    
    return self;
}
@end
