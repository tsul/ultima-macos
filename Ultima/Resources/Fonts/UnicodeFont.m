#import "UnicodeFont.h"

@implementation UnicodeFont {
    NSFileHandle *_dataHandle;
    Character *_charCache[0x10000];
}

-(instancetype)initWithId:(uint32_t)fontId {
    self = [super init];
    
    if (self) {
        _fontId = fontId;
        
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *dataPath = [mainBundle pathForResource:[NSString stringWithFormat:@"unifont%d", fontId]
                                                  ofType:@"mul"];
        NSFileHandle *dataHandle = [NSFileHandle fileHandleForReadingAtPath:dataPath];
        
        NSAssert(dataHandle, @"Could not acquire file handle");

        _dataHandle = dataHandle;
    }
    
    return self;
}

-(Character *)character:(unichar)character {
    if (_charCache[character]) {
        return _charCache[character];
    }
    
    Character *unicodeChar;
    
    if (character == 32) {
        NSMutableData *output = [[NSMutableData alloc] initWithLength:sizeof(uint32_t) * 8 * 10];
        
        unicodeChar = [[Character alloc] initWithWidth:8
                                                  height:10
                                                 kerning:0
                                                baseline:0
                                                    data:[output copy]
                                                   value:character];
    } else {
        int32_t lookup;
        
        [_dataHandle seekToOffset:(character) * 4 error:nil];
        NSData *lookupData = [_dataHandle readDataOfLength:sizeof(uint32_t)];
        lookup = *(int32_t *)lookupData.bytes;

        [_dataHandle seekToOffset:lookup error:nil];
        NSData *headerData = [_dataHandle readDataOfLength:sizeof(uint8_t) * 4];
        int8_t *reader = (int8_t *)headerData.bytes;
        
        int8_t kerning = *reader++;
        int8_t baseline = *reader++;
        int8_t width = *reader++;
        int8_t height = *reader++;
        
        int32_t scanlineWidth = ((width - 1) / 8) + 1;
        
        [_dataHandle seekToOffset:lookup + sizeof(uint32_t) error:nil];
        NSData *characterData = [_dataHandle readDataOfLength:scanlineWidth * height];
        reader = (int8_t *)characterData.bytes;
        
        NSMutableData *output = [[NSMutableData alloc] initWithLength:sizeof(uint32_t) * width * height];
        uint32_t *writer = (uint32_t *)output.bytes;
        
        for (int y = 0; y < height; ++y) {
            for (int x = 0; x < width; ++x) {
                int offset = x / 8 + y * ((width + 7) / 8);

                if((*(reader + offset) & (1 << (7 - (x % 8)))) != 0) {
                    *writer++ = UINT32_MAX;
                } else {
                    writer++;
                }
            }
        }
        
        unicodeChar = [[Character alloc] initWithWidth:width
                                                  height:height
                                                 kerning:kerning
                                                baseline:baseline
                                                    data:[output copy]
                                                 value:character];
    }
    
    _charCache[character] = unicodeChar;
    
    return unicodeChar;
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
