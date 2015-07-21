#import "WatchKitHelper.h"

@implementation WatchKitHelper

+ (void) openParent:(NSString*)action {
  [WKInterfaceController openParentApplication:@{@"action" : action} reply:nil];
}

+ (void) openParent:(NSString*)action withParams:(NSString*)params {
  [WKInterfaceController openParentApplication:@{@"action" : action, @"params" : params} reply:nil];
}

+ (void) logError:(NSString*) message {
  NSLog(@"Error: %@", message);
  [self openParent:@"applewatch.callback.onError" withParams:message];
}

@end
