#import <Foundation/Foundation.h>

@interface BodyConversion : NSObject
-(NSString *)getFileForBody:(uint32_t)bodyId;
-(uint32_t)getOffsetForBody:(uint32_t)bodyId;
@end
