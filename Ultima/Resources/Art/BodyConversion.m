#import "BodyConversion.h"

@implementation BodyConversion {
    int32_t _anim2[2048];
    int32_t _anim3[2048];
    int32_t _anim4[2048];
    int32_t _anim5[2048];
}

-(instancetype)init {
    self = [super init];
    
    if (self) {
        NSBundle* mainBundle = [NSBundle mainBundle];
        NSString* dataPath = [mainBundle pathForResource:@"Bodyconv" ofType:@"def"];

        NSString *file = [[NSString alloc]initWithContentsOfFile:dataPath encoding:NSUTF8StringEncoding error:nil];
        NSArray<NSString *> *lines = [file componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

        for (int i = 0; i < lines.count; ++i) {
            if (lines[i].length == 0 || [lines[i] characterAtIndex:0] == '#' || [lines[i] characterAtIndex:0] == '"') {
                continue;
            }
            
            NSString *lineWithoutComment = [lines[i] componentsSeparatedByString:@"#"][0];
            NSArray<NSString *> *entries = [lineWithoutComment componentsSeparatedByString:@"\t"];
                        
            NSInteger bodyId = [entries[0] integerValue];
            _anim2[bodyId] = (int32_t)[entries[1] integerValue];
            _anim3[bodyId] = (int32_t)[entries[2] integerValue];
            _anim4[bodyId] = (int32_t)[entries[3] integerValue];
            _anim5[bodyId] = (int32_t)[entries[4] integerValue];
        }

    }
    
    return self;
}

-(NSString *)getFileForBody:(uint32_t)bodyId {
    if (_anim5[bodyId] != 0 && _anim5[bodyId] != -1) {
        return @"anim5";
    }
    
    if (_anim4[bodyId] != 0 && _anim4[bodyId] != -1) {
        return @"anim4";
    }
    
    if (_anim3[bodyId] != 0 && _anim3[bodyId] != -1) {
        return @"anim3";
    }
    
    if (_anim2[bodyId] != 0 && _anim2[bodyId] != -1) {
        return @"anim2";
    }
    
    return @"anim";
}

-(uint32_t)getOffsetForBody:(uint32_t)bodyId {
    if (_anim5[bodyId] != 0 && _anim5[bodyId] != -1) {
        return _anim5[bodyId];
    }
    
    if (_anim4[bodyId] != 0 && _anim4[bodyId] != -1) {
        return _anim4[bodyId];
    }
    
    if (_anim3[bodyId] != 0 && _anim3[bodyId] != -1) {
        return _anim3[bodyId];
    }
    
    if (_anim2[bodyId] != 0 && _anim2[bodyId] != -1) {
        return _anim2[bodyId];
    }
    
    return bodyId;
}

@end
