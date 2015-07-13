#import "Cordova/CDV.h"
#import "Cordova/CDVViewController.h"
#import "AppleWatch.h"
#import "MMWormhole.h"

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

- (void) sendMessage:(CDVInvokedUrlCommand*)command {
  NSDictionary *args = [command.arguments objectAtIndex:0];
  NSMutableDictionary *dic = [args objectForKey:@"payload"];

  NSString *pageID = [dic objectForKey:@"id"];
  if (pageID == nil) {
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"id is mandatory"] callbackId:command.callbackId];
    return;
  }

  NSString* queueName = [@"fromjstowatchapp-" stringByAppendingString:pageID];
  
  // TODO for mulitple images, add an element in the json so we can translate to nsdata here [{}, {}]
  // TODO see SocialSharing for how to download images from the interwebs
  NSMutableDictionary *imageDic = [dic valueForKey:@"image"];
  if (imageDic != nil) {
    NSString *imageSrc = [imageDic valueForKey:@"src"];
    if (imageSrc == nil) {
      [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"missing src attribute for image"] callbackId:command.callbackId];
    } else {
      // NOTE: this expects a path like 'www/img/img.png'
      UIImage *image = [UIImage imageNamed:imageSrc];
      // create NSData so it can be passed through the wormhole
      NSData *imageData = UIImagePNGRepresentation(image);
      [imageDic setObject:imageData forKey:@"src"];
    }
  }

  [self.wormhole passMessageObject:dic identifier:queueName];
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void) navigate:(CDVInvokedUrlCommand*)command {
  NSDictionary *args = [command.arguments objectAtIndex:0];
  NSMutableDictionary *dic = [args objectForKey:@"payload"];
  
  NSString *pageID = [dic objectForKey:@"id"];
  if (pageID == nil) {
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"id is mandatory"] callbackId:command.callbackId];
    return;
  }
  
  // the main page handles page navigation sa that's the page who's wormhole should be active
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

    // TODO remove delay (added it for testing purposes)
    NSDate *in5seconds = [NSDate dateWithTimeIntervalSinceNow:5];
    localNotification.fireDate = in5seconds; // [NSDate date];
    localNotification.soundName = UILocalNotificationDefaultSoundName;

    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void) sendUserDefaults:(CDVInvokedUrlCommand*)command;
{
    CDVPluginResult* pluginResult = nil;

    NSMutableDictionary *args = [command.arguments objectAtIndex:0];
    NSString *key = [args objectForKey:@"key"];
    NSString *value = [args objectForKey:@"value"];
    NSString *appGroupId = [args objectForKey:@"appGroupId"];

    if ([appGroupId length] == 0)
    {
        appGroupId = [NSString stringWithFormat:@"group.%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];
    }

    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:appGroupId];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];

    if ([[userDefaults stringForKey:key] isEqualToString:value])
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) addListener:(CDVInvokedUrlCommand*)command;
{
    NSMutableDictionary *args = [command.arguments objectAtIndex:0];
    NSString *queueName = [args objectForKey:@"queueName"];

    [self.wormhole listenForMessageWithIdentifier:queueName listener:^(id message) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
        [pluginResult setKeepCallbackAsBool:YES];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) removeListener:(CDVInvokedUrlCommand*)command;
{
    NSMutableDictionary *args = [command.arguments objectAtIndex:0];
    NSString *queueName = [args objectForKey:@"queueName"];

    [self.wormhole stopListeningForMessageWithIdentifier:queueName];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void) purgeQueue:(CDVInvokedUrlCommand*)command;
{
    NSMutableDictionary *args = [command.arguments objectAtIndex:0];
    NSString *queueName = [args objectForKey:@"queueName"];

    [self.wormhole clearMessageContentsForIdentifier:queueName];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void) purgeAllQueues:(CDVInvokedUrlCommand*)command;
{
    [self.wormhole clearAllMessageContents];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

@end
