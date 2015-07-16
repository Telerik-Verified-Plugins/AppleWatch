#import "Foundation/Foundation.h"
#import "Cordova/CDV.h"

@interface AppleWatch : CDVPlugin

@property BOOL initDone;

- (void) init:(CDVInvokedUrlCommand*)command;
- (void) registerNotifications:(CDVInvokedUrlCommand*)command;
- (void) sendNotification:(CDVInvokedUrlCommand*)command;

- (void) loadGlance:(CDVInvokedUrlCommand*)command;
- (void) loadApp:(CDVInvokedUrlCommand*)command;
- (void) loadAppDetail:(CDVInvokedUrlCommand*)command;

- (void) navigateToAppDetail:(CDVInvokedUrlCommand*)command;
- (void) navigateToAppMain:(CDVInvokedUrlCommand*)command;

@end
