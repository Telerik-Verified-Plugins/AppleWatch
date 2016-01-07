#import "WatchKitHelper.h"
#import "WormholeManager.h"
#import <WatchConnectivity/WatchConnectivity.h>

NSString * const kActionKey = @"action";
NSString * const kParamsKey = @"params";

@implementation WatchKitHelper

+ (void) openParent:(NSString*)action {
    [WormholeManager.sharedInstance passMessageObject:@{kActionKey:[action dataUsingEncoding:NSUTF8StringEncoding]} identifier:kActionKey];
}

+ (void) openParent:(NSString*)action withParams:(NSString*)params {
    [WormholeManager.sharedInstance passMessageObject:@{kActionKey:action, kParamsKey:params} identifier:kActionKey];
}

+ (void) logError:(NSString*) message {
    NSLog(@"Error: %@", message);
    [self openParent:@"applewatch.callback.onError" withParams:message];
}

@end