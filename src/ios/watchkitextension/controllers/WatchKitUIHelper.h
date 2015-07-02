#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface WatchKitUIHelper : NSObject

+ (void) setLabel:(WKInterfaceLabel*)label fromDic:(NSDictionary*)dic;
+ (void) setImage:(WKInterfaceImage*)image fromDic:(NSDictionary*)dic;
+ (void) setButton:(WKInterfaceButton*)button fromDic:(NSDictionary*)dic;
+ (NSString*) setSwitch:(WKInterfaceSwitch*)switch1 fromDic:(NSDictionary*)dic;
+ (NSString*) setSlider:(WKInterfaceSlider*)slider withLabel:(WKInterfaceLabel*)label inGroup:(WKInterfaceGroup*)group fromDic:(NSDictionary*)dic;
+ (NSString*) setButtonWithCallback:(WKInterfaceButton*)button fromDic:(NSDictionary*)dic;
+ (NSDictionary*) setUserInputButton:(WKInterfaceButton*)button fromDic:(NSDictionary*)dic;
+ (void) setTable:(WKInterfaceTable*)table fromDic:(NSDictionary*)dic;
+ (WKMenuItemIcon) WKMenuItemIconFromString:(NSString*)str;
@end
