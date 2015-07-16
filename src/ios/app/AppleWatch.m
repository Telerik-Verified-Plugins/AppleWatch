#import "Cordova/CDV.h"
#import "Cordova/CDVViewController.h"
#import "AppleWatch.h"
#import "MMWormhole.h"

static NSString *const AWPlugin_Page_Glance = @"Glance";
static NSString *const AWPlugin_Page_AppMain = @"AppMain";
static NSString *const AWPlugin_Page_AppDetail = @"AppDetail";

@interface AppleWatch ()

@property (nonatomic, strong) MMWormhole* wormhole;

@end

@implementation AppleWatch

- (void) init:(CDVInvokedUrlCommand*)command {
    NSString *appGroup = [NSString stringWithFormat:@"group.%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];

    self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:appGroup optionalDirectory:@"wormhole"];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];

    self.initDone = YES;
}

- (void) registerNotifications:(CDVInvokedUrlCommand*)command;
{
    CDVPluginResult* pluginResult = nil;

    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];

    if ([[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone)
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:(true)];
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsBool:(false)];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) loadGlance:(CDVInvokedUrlCommand*)command {
  [self sendMessage:command forPage:AWPlugin_Page_Glance];
}

- (void) loadApp:(CDVInvokedUrlCommand*)command {
  [self sendMessage:command forPage:AWPlugin_Page_AppMain];
}

- (void) loadAppDetail:(CDVInvokedUrlCommand*)command {
  [self sendMessage:command forPage:AWPlugin_Page_AppDetail];
}

- (void) sendMessage:(CDVInvokedUrlCommand*)command {
  NSDictionary *args = [command.arguments objectAtIndex:0];
  NSMutableDictionary *dic = [args objectForKey:@"payload"];
  
  NSString *pageID = [dic objectForKey:@"id"];
  if (pageID == nil) {
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"id is mandatory"] callbackId:command.callbackId];
    return;
  }
  
  [self sendMessage:command forPage:pageID];
}

- (void) sendMessage:(CDVInvokedUrlCommand*)command forPage:(NSString*)pageID {
  NSDictionary *args = [command.arguments objectAtIndex:0];
  NSMutableDictionary *dic = [args objectForKey:@"payload"];

  NSString* queueName = [@"fromjstowatchapp-" stringByAppendingString:pageID];
  
  // TODO add support for non-local images by downloading them here from the interwebs
  [self bundleImage:[dic valueForKey:@"image"] withCallbackId:command.callbackId];
  [self bundleImage:[dic valueForKey:@"image2"] withCallbackId:command.callbackId];
  NSDictionary* table = [dic valueForKey:@"table"];
  if (table != nil) {
    NSArray *rows = [table valueForKey:@"rows"];
    for (NSInteger i = 0; i < rows.count; i++) {
      NSMutableDictionary* rowDef = rows[i];
      [self bundleImage:[rowDef valueForKey:@"imageLeft"] withCallbackId:command.callbackId];
      [self bundleImage:[rowDef valueForKey:@"imageRight"] withCallbackId:command.callbackId];
      [self bundleImage:[rowDef valueForKey:@"col1image"] withCallbackId:command.callbackId];
      [self bundleImage:[rowDef valueForKey:@"col2image"] withCallbackId:command.callbackId];
    }
  }

  [self.wormhole passMessageObject:dic identifier:queueName];
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void) bundleImage:(NSMutableDictionary*)imageDic withCallbackId:(NSString*)callbackId {
  if (imageDic != nil) {
    NSString *imageSrc = [imageDic valueForKey:@"src"];
    if (imageSrc == nil) {
      [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"missing src attribute for image"] callbackId:callbackId];
    } else {
      // NOTE: this expects a path like 'www/img/img.png'
      UIImage *image = [UIImage imageNamed:imageSrc];
      // create NSData so it can be passed through the wormhole
      NSData *imageData = UIImagePNGRepresentation(image);
      [imageDic setObject:imageData forKey:@"src"];
    }
  }
}

- (void) navigateToAppDetail:(CDVInvokedUrlCommand*)command {
  [self navigate:command toPage:AWPlugin_Page_AppDetail];
}

- (void) navigateToAppMain:(CDVInvokedUrlCommand*)command {
  [self navigate:command toPage:AWPlugin_Page_AppMain];
}

- (void) navigate:(CDVInvokedUrlCommand*)command toPage:(NSString*)id {
  NSDictionary *args = [command.arguments objectAtIndex:0];
  NSMutableDictionary *dic = [args objectForKey:@"payload"];
  if (dic == nil) {
    dic = [[NSMutableDictionary alloc] init];
  }
  if ([dic valueForKey:@"id"] == nil) {
    [dic setObject:id forKey:@"id"];
  }

  NSString* queueName = @"fromjstowatchapp-navigation";
  
  [self.wormhole passMessageObject:dic identifier:queueName];
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

// TODO: this doesn't work in the sim, so perhaps return an error in that case (see calendar plugin)
// -- OR BETTER YET in that case: reroute to remote notification which does work in sim
- (void) sendNotification:(CDVInvokedUrlCommand*)command;
{
    NSMutableDictionary *args = [command.arguments objectAtIndex:0];

    UILocalNotification *localNotification = [[UILocalNotification alloc] init];

    if ([localNotification respondsToSelector:@selector(alertTitle)])
    {
        localNotification.alertTitle = [args objectForKey:@"title"];
    }

    if ([localNotification respondsToSelector:@selector(category)])
    {
        localNotification.category = [args objectForKey:@"category"];
    }

    localNotification.alertBody = [args objectForKey:@"body"];
    localNotification.applicationIconBadgeNumber = [[args objectForKey:@"badge"] intValue];

    // enable this if you want a delay
    // NSDate *in5seconds = [NSDate dateWithTimeIntervalSinceNow:5];
    // localNotification.fireDate = in5seconds; // [NSDate date];
    localNotification.fireDate = [NSDate date];
    localNotification.soundName = UILocalNotificationDefaultSoundName;

    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}
@end
