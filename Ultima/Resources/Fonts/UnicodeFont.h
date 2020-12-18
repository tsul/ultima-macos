#import <Foundation/Foundation.h>
#include <simd/simd.h>
#import "Character.h"

@interface UnicodeFont : NSObject
-(nullable instancetype)initWithId:(uint32_t)fontId;
-(nullable NSArray<Character *> *)text:(nonnull NSString *)text;
-(nullable Character *)character:(unichar)character;


@property (nonatomic, readonly) uint32_t fontId;
@end


