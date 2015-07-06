#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface TwoColumnsRowType : NSObject

@property (weak, nonatomic) IBOutlet WKInterfaceGroup* group;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel* col1label;
@property (weak, nonatomic) IBOutlet WKInterfaceImage* col1image;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel* col2label;
@property (weak, nonatomic) IBOutlet WKInterfaceImage* col2image;

@end
