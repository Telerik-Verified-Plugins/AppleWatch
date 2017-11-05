#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "WatchKitHelper.h"
#import "WatchKitUIHelper.h"
#import "MMWormholeUmbrella.h"

@interface ParentInterfaceController : WKInterfaceController

@property (nonatomic, strong) MMWormhole *wormhole;
@property (nonatomic, strong) MMWormholeSession *listeningWormhole;

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *wrapper;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *label;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *label2;

@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;

@property (weak, nonatomic) IBOutlet WKInterfaceImage *image;

@property (weak, nonatomic) IBOutlet WKInterfaceSwitch *switch1; // 'switch' is a reserved keyword
@property (weak, nonatomic) IBOutlet WKInterfaceSwitch *switch2;

@property (weak, nonatomic) IBOutlet WKInterfaceMap *map;

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *sliderGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceSlider *slider;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *sliderLabel;

@property (weak, nonatomic) IBOutlet WKInterfaceButton *userInputButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *actionButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *pushNavButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *modalNavButton;

@property (retain, nonatomic) NSDictionary *userInputButtonDic;
@property (retain, nonatomic) NSString *actionButtonCallback;
@property (retain, nonatomic) NSString *pushNavButtonCallback;
@property (retain, nonatomic) NSString *modalNavButtonCallback;
@property (retain, nonatomic) NSString *tableCallback;
@property (retain, nonatomic) NSString *switchCallback;
@property (retain, nonatomic) NSString *switch2Callback;
@property (retain, nonatomic) NSString *sliderCallback;

@property (retain, nonatomic) NSString *contextMenuButton1Callback;
@property (retain, nonatomic) NSString *contextMenuButton2Callback;
@property (retain, nonatomic) NSString *contextMenuButton3Callback;
@property (retain, nonatomic) NSString *contextMenuButton4Callback;

@end
