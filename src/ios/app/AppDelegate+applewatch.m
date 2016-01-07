#import "AppDelegate+applewatch.h"
#import "AppleWatch.h"
#import <objc/runtime.h>
#import "MainViewController.h"

@implementation AppDelegate (applewatch)

// check every x seconds for the phone  app to be ready, or stop from glance.didDeactivate
// TODO stop after x tries
- (void) callJavascriptFunctionWhenAvailable:(NSString*)function {
    AppleWatch *appleWatch = [self.viewController getCommandInstance:@"AppleWatch"];
    if (appleWatch.initDone) {
        [appleWatch.webView stringByEvaluatingJavaScriptFromString:function];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 80 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            [self callJavascriptFunctionWhenAvailable:function];
        });
    }
}

@end