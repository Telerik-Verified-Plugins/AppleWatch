#import "AppDelegate.h"

@interface AppDelegate (applewatch)
- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void(^)(NSDictionary *replyInfo))reply;

@end