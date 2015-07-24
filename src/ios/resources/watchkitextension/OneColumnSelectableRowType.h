#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface OneColumnSelectableRowType : NSObject

@property (weak, nonatomic) IBOutlet WKInterfaceGroup* group;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel* label;
@property (weak, nonatomic) IBOutlet WKInterfaceImage* imageLeft;
@property (weak, nonatomic) IBOutlet WKInterfaceImage* imageRight;

@end
