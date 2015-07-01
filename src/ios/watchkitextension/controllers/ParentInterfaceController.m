#import "ParentInterfaceController.h"
#import "WatchKitUIHelper.h"

@implementation ParentInterfaceController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  
  // hide everything initially
  [self hideAllWidgets];

  // Initialize the wormhole
  // TODO appgroupID must be dynamic
  self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.nl.xservices.applewatch"
                                                       optionalDirectory:@"wormhole"];
  
  NSString *wormholeIdentifier = [@"fromjstowatchapp-" stringByAppendingString:[self getPageID]];
  [self.wormhole listenForMessageWithIdentifier:wormholeIdentifier listener:^(id messageObject) {
    [self buildUI:messageObject];
  }];
}

// poor man's abstract method implementation
- (NSString*) getPageID {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

- (void) hideAllWidgets {
  [self.header setHidden:YES];
  [self.table setHidden:YES];
  [self.image setHidden:YES];
  [self.switch1 setHidden:YES];
  [self.sliderGroup setHidden:YES];
  [self.slider setHidden:YES];
  [self.sliderLabel setHidden:YES];
  [self.userInputButton setHidden:YES];
  [self.actionButton setHidden:YES];
  [self.pushNavButton setHidden:YES];
  [self.modalNavButton setHidden:YES];
}

- (void) buildUI:(NSDictionary*)messageObject {
  //  [WatchKitUIHelper setLabel:self.message fromDic:[messageObject valueForKey:@"message"]];

  // the page title, in case we're not showing the root page
  if ([messageObject valueForKey:@"title"] != nil) {
    [self setTitle:[messageObject valueForKey:@"title"]];
  } else {
    [self setTitle:nil];
  }

  [WatchKitUIHelper setLabel:self.header fromDic:[messageObject valueForKey:@"header"]];
  [WatchKitUIHelper setImage:self.image fromDic:[messageObject valueForKey:@"image"]];
  [WatchKitUIHelper setTable:self.table fromDic:[messageObject valueForKey:@"table"]];
  self.switchCallback = [WatchKitUIHelper setSwitch:self.switch1 fromDic:[messageObject valueForKey:@"switch"]];
  self.sliderCallback = [WatchKitUIHelper setSlider:self.slider withLabel:self.sliderLabel inGroup:self.sliderGroup fromDic:[messageObject valueForKey:@"slider"]];
  self.pushNavButtonCallback = [WatchKitUIHelper setButtonWithCallback:self.pushNavButton fromDic:[messageObject valueForKey:@"pushNavButton"]];
  self.modalNavButtonCallback = [WatchKitUIHelper setButtonWithCallback:self.modalNavButton fromDic:[messageObject valueForKey:@"modalNavButton"]];
  self.actionButtonCallback = [WatchKitUIHelper setButtonWithCallback:self.actionButton fromDic:[messageObject valueForKey:@"actionButton"]];
  self.userInputButtonDic = [WatchKitUIHelper setUserInputButton:self.userInputButton fromDic:[messageObject valueForKey:@"userInputButton"]];
}

- (void) openParent:(NSDictionary*)dic {
  [WKInterfaceController openParentApplication:dic reply:nil];
}

- (void)willActivate {
  // This method is called when watch view controller is about to be visible to the user
  [super willActivate];
}

- (void)didDeactivate {
  // This method is called when watch view controller is no longer visible
  [super didDeactivate];
  // be a good citizen.. btw, doing this here seems ugly but it's better than forgetting to do it in a subclass and leaving a mess
  if (![@"main" isEqualToString:[self getPageID]]) {
    NSString *wormholeIdentifier = [@"fromjstowatchapp-" stringByAppendingString:[self getPageID]];
    [self.wormhole stopListeningForMessageWithIdentifier:wormholeIdentifier];
  }
}

@end