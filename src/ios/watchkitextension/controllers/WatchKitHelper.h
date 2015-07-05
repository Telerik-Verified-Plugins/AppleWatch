#import <WatchKit/WatchKit.h>

@interface WatchKitHelper : NSObject

+ (void) openParent:(NSString*)action;
+ (void) openParent:(NSString*)action withParams:(NSString*)params;

+ (void) logError:(NSString*) message;

@end
