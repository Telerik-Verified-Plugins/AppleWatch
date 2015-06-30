//
//  InterfaceController.m
//  HelloCordova WatchKit Extension
//
//  Created by Eddy Verbruggen on 17/06/15.
//
//

#import "InterfaceController.h"
#import "WatchKitUIHelper.h"

#import "MMWormhole.h"

@interface InterfaceController()

@property (nonatomic, strong) MMWormhole *wormhole;
@property (nonatomic, strong) NSString *lastmsg;

// NOTE: add only the properties of the main page here, subpage? new controller
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *header;
@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *image;
@property (weak, nonatomic) IBOutlet WKInterfaceSwitch *switch1;

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *sliderGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceSlider *slider;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *sliderLabel;

@property (weak, nonatomic) IBOutlet WKInterfaceButton *userInputButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *actionButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *pushNavButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *modalNavButton;

@property (retain, nonatomic) NSDictionary *userInputButtonDic;
@property (retain, nonatomic) NSString *actionButtonCallback;
@property (retain, nonatomic) NSString *pushNavButtonCallback; // TODO need to do this also for modal
@property (retain, nonatomic) NSString *switchCallback;
@property (retain, nonatomic) NSString *sliderCallback;

@end

// TODO superclass to keep it a bit more DRY (with DetailsInterfaceController)
@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

  self.lastmsg = @"nothing appy";
  
  // hide everything initially
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

  // Initialize the wormhole
  self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.nl.xservices.applewatch"
                                                       optionalDirectory:@"wormhole"];
  
  [self.wormhole listenForMessageWithIdentifier:@"fromjstowatchapp" listener:^(id messageObject) {
    [self buildUI:messageObject];
  }];

  [WKInterfaceController openParentApplication:@{@"action" : @"onAppRequestsUpdate"} reply:nil];
}

- (void) buildUI:(NSDictionary*)messageObject {
//  [WatchKitUIHelper setLabel:self.message fromDic:[messageObject valueForKey:@"message"]];

  [WatchKitUIHelper setLabel:self.header fromDic:[messageObject valueForKey:@"header"]];
  [WatchKitUIHelper setImage:self.image fromDic:[messageObject valueForKey:@"image"]];
  [WatchKitUIHelper setTable:self.table fromDic:[messageObject valueForKey:@"table"]];
  self.switchCallback = [WatchKitUIHelper setSwitch:self.switch1 fromDic:[messageObject valueForKey:@"switch"]];
  self.sliderCallback = [WatchKitUIHelper setSlider:self.slider withLabel:self.sliderLabel inGroup:self.sliderGroup fromDic:[messageObject valueForKey:@"slider"]];
  self.pushNavButtonCallback = [WatchKitUIHelper setButtonWithCallback:self.pushNavButton fromDic:[messageObject valueForKey:@"pushNavButton"]];
  self.actionButtonCallback = [WatchKitUIHelper setButtonWithCallback:self.actionButton fromDic:[messageObject valueForKey:@"actionButton"]];
  self.userInputButtonDic = [WatchKitUIHelper setUserInputButton:self.userInputButton fromDic:[messageObject valueForKey:@"userInputButton"]];
}



# pragma callback actions
- (IBAction)buttonAction {
  [self openParent:@{@"action" : self.actionButtonCallback}];
}

- (IBAction)userInputButtonAction {
  NSArray *suggestionsDef = [self.userInputButtonDic valueForKey:@"suggestions"];
  NSMutableArray *suggestions = [NSMutableArray arrayWithCapacity:suggestionsDef.count];
  for (NSInteger i = 0; i < suggestionsDef.count; i++) {
    [suggestions addObject:suggestionsDef[i]];
  }
  long inputMode;
  NSString *inputModeDef = [self.userInputButtonDic valueForKey:@"inputMode"];
  if ([inputModeDef isEqualToString:@"WKTextInputModeAllowAnimatedEmoji"]) {
    inputMode = WKTextInputModeAllowAnimatedEmoji;
  } else  if ([inputModeDef isEqualToString:@"WKTextInputModeAllowEmoji"]) {
    inputMode = WKTextInputModeAllowEmoji;
  } else {
    inputMode = WKTextInputModePlain;
  }
  [self presentTextInputControllerWithSuggestions:suggestions allowedInputMode:inputMode completion:^(NSArray *results) {
    // will be nil if dismissed
    if (results != nil) {
      // results is usually a String, but can be NSData (emoji image), see http://www.fiveminutewatchkit.com/blog/2015/3/15/how-to-get-text-input-from-the-user
      [self openParent:@{@"action" : [self.userInputButtonDic objectForKey:@"callback"], @"params" : results[0]}];
    }
  }];
}

- (IBAction)switch1Action:(BOOL)on {
  [self openParent:@{@"action" : self.switchCallback, @"params" : @(on ? "true" : "false")}];
}

- (IBAction)sliderAction:(float)value {
  NSString *str = [NSString stringWithFormat:@"%.f", value];
  [self.sliderLabel setText:str];
  [self openParent:@{@"action" : self.sliderCallback, @"params" : str}];
}

//- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {}



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
}

# pragma notification callbacks
// when the app is launched from a notification. If launched from app icon in notification UI, identifier will be empty
- (void)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)remoteNotification {
//  int i=0; // eg. "firstButtonAction"
}

// when the app is launched from a notification. If launched from app icon in notification UI, identifier will be empty
- (void)handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)localNotification {
//  int i=0;
}

@end