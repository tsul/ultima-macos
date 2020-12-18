#import "AsciiFont.h"

@implementation AsciiFont {
    NSFileHandle *_dataHandle;
    NSArray<Character *> *_characters;
}

+(NSArray<AsciiFont *> *)loadAll {
    NSMutableArray<AsciiFont *> *fonts = [NSMutableArray array];
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *dataPath = [mainBundle pathForResource:@"fonts" ofType:@"mul"];
    NSFileHandle *dataHandle = [NSFileHandle fileHandleForReadingAtPath:dataPath];
    
    NSAssert(dataHandle, @"Could not acquire file handle");
    
    int position = 1;
    int fontId = 1;
    
    while (true) {
        NSUInteger remainingLength = dataHandle.availableData.length;

        if (remainingLength < 200) {
            break;
        }
        
        [dataHandle seekToOffset:position error:nil];

        NSMutableArray<Character *> *characters = [NSMutableArray array];

        for (int i = 0; i < 224; ++i) {
            NSData *header = [dataHandle readDataOfLength:2];
            uint8_t *reader = (uint8_t *)header.bytes;
            
            uint8_t width = *reader++;
            uint8_t height = *reader++;
            
            if (width == 0 || height == 0) {
                continue;
            }
                            
            NSMutableData *output = [[NSMutableData alloc] initWithLength:sizeof(uint32_t) * width * height];
            uint32_t *writer = (uint32_t *)output.bytes;
            
            position += 3;
            [dataHandle seekToOffset:position error:nil];

            NSData *colorData = [dataHandle readDataOfLength:sizeof(uint16) * width * height];
            uint16_t *colors = (uint16_t *)colorData.bytes;
            
            for (int i = 0; i < width * height; ++i) {
                uint16_t color = *colors++;
                
                if (color == 0) {
                    writer++;
                } else {
                    uint16_t r = ((color >> 10) & 0x1F) * 0xFF / 0x1F;
                    uint16_t g = ((color >> 5) & 0x1F) * 0xFF / 0x1F;
                    uint16_t b = (color & 0x1F) * 0xFF / 0x1F;
                    uint16_t a = UINT16_MAX;
                    
                    *writer++ = b | (g << 8) | (r << 16) | (a << 24);
                }
            }
            
            position += width * height * sizeof(uint16_t);
            
            Character *asciiChar = [[Character alloc] initWithWidth:width
                                                  height:height
                                                 kerning:0
                                                baseline:0
                                                    data:[output copy]
                                                   value:i];
            
            [characters insertObject:asciiChar atIndex:i];
        }
        
        AsciiFont *font = [[AsciiFont alloc]initWithId:fontId characters:[characters copy]];
        [fonts addObject:font];
        fontId++;
        position += 1;
    }
        
    return [fonts copy];
}

-(instancetype)initWithId:(uint32_t)fontId characters:characters {
    self = [super init];
    
    if (self) {
        _fontId = fontId;
        _characters = characters;
    }
    
    return self;
}

-(Character *)character:(unichar)character {
    return _characters[character - 32];

}

-(NSArray<Character *> *)text:(NSString *)text {
    NSUInteger length = [text length];
    unichar buffer[length + 1];
    [text getCharacters:buffer range:NSMakeRange(0, length)];
    
    NSMutableArray<Character *> *characters = [NSMutableArray array];
    
    for (int i = 0; i < length; ++i) {
        [characters addObject:[self character:buffer[i]]];
    }
    
    return [characters copy];
}

@end
