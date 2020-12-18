#import <Foundation/Foundation.h>
#include <simd/simd.h>
#import "Character.h"

@interface AsciiFont : NSObject
+(nonnull NSArray<AsciiFont *> *)loadAll;
-(nullable instancetype)initWithId:(uint32_t)fontId characters:(nonnull NSArray<Character *> *)characters;
-(nullable NSArray<Character *> *)text:(nonnull NSString *)text;

@property (nonatomic, readonly) uint32_t fontId;
@end


