//
//  DetailInterfaceController.m
//  HelloCordova WatchKit Extension
//
//  Created by Eddy Verbruggen on 17/06/15.
//
//

#import "DetailInterfaceController.h"
#import "WatchKitUIHelper.h"

#import "MMWormhole.h"

@interface DetailInterfaceController()

@property (nonatomic, strong) MMWormhole *wormhole;
@property (nonatomic, strong) NSString *lastmsg;

// NOTE: add only the properties of the main page here, subpage? new controller
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *header;
@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *image;
@property (weak, nonatomic) IBOutlet WKInterfaceSwitch *switch1;

@property (weak, nonatomic) IBOutlet WKInterfaceButton *actionButton;

@property (retain, nonatomic) NSString *actionButtonCallback;

@end


// TODO copy from InterfaceController when that's done, also: do some code reuse beforehand
@implementation DetailInterfaceController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  
  self.lastmsg = @"nothing appy";
  
  // TODO test this to immediately load a different interface:
  //  [WKInterfaceController reloadRootControllersWithNames:@[@"Details"]
  //                                               contexts:nil];
  
  // hide everything initially
  [self.header setHidden:YES];
  [self.table setHidden:YES];
  [self.image setHidden:YES];
  [self.switch1 setHidden:YES];
  [self.actionButton setHidden:YES];
  
  // Initialize the wormhole
  self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.nl.xservices.applewatch"
                                                       optionalDirectory:@"wormhole"];
  
  [self.wormhole listenForMessageWithIdentifier:@"fromjstowatchapp" listener:^(id messageObject) {
    [self buildUI:messageObject];
  }];
  
  [WKInterfaceController openParentApplication:@{@"action" : @"onAppDetailPageRequestsUpdate"} reply:nil];
}

- (IBAction)buttonAction {
  // TODO get action from actionButton.onButtonPressed (store in a var?)
  NSString* cb = self.actionButtonCallback;
  if (cb) {
    [WKInterfaceController openParentApplication:@{@"action" : cb} reply:nil];
  }
}

- (void) buildUI:(NSDictionary*)messageObject {
  //  [WatchKitUIHelper setLabel:self.message fromDic:[messageObject valueForKey:@"message"]];
  
  [WatchKitUIHelper setLabel:self.header fromDic:[messageObject valueForKey:@"header"]];
  [WatchKitUIHelper setImage:self.image fromDic:[messageObject valueForKey:@"image"]];
  [WatchKitUIHelper setTable:self.table fromDic:[messageObject valueForKey:@"table"]];
  self.actionButtonCallback = [WatchKitUIHelper setButtonWithCallback:self.actionButton fromDic:[messageObject valueForKey:@"actionButton"]];
}

- (IBAction)switch1Action:(BOOL)on {
}



- (void)willActivate {
  // This method is called when watch view controller is about to be visible to the user
  [super willActivate];
  
}

- (void)didDeactivate {
  // This method is called when watch view controller is no longer visible
  [super didDeactivate];
}

@end