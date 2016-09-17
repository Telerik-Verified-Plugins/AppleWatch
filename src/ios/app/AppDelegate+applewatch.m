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
      if ([appleWatch.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
        // UIWebView
        [appleWatch.webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:function waitUntilDone:NO];
      } else if ([appleWatch.webView respondsToSelector:@selector(evaluateJavaScript:completionHandler:)]) {
        // WKWebView
        [appleWatch.webView performSelector:@selector(evaluateJavaScript:completionHandler:) withObject:function withObject:nil];
      } else {
        NSLog(@"No compatible method found to communicate Watch callback to the webview. Please notify the plugin author.");
      }
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 80 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            [self callJavascriptFunctionWhenAvailable:function];
        });
    }
}

@end