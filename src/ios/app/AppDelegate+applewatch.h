//
//  AppDelegate+applewatch.h
//
//  Created by Eddy Verbruggen on 26/06/15.
//
//

#import "AppDelegate.h"

@interface AppDelegate (applewatch)
- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void(^)(NSDictionary *replyInfo))reply;

@property (nonatomic, retain) NSDictionary *watchKitRequest;

@end