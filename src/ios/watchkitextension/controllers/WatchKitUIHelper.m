#import <Foundation/Foundation.h>
#import "WatchKitUIHelper.h"
#import "ImageLabelRowType.h"
#import "TwoColumnsRowType.h"

@implementation WatchKitUIHelper

- (void)awakeWithContext:(id)context {
}

+ (NSAttributedString*) getAttributedStringFrom:(NSDictionary*)dic {
  NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[dic valueForKey:@"value"]];

  NSString *hexColor = [dic valueForKey:@"color"];
  UIColor *color = hexColor == nil ? [UIColor whiteColor] : [self colorFromHexString:hexColor];
  [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, attrString.string.length)];

  NSDictionary *fontdef = [dic valueForKey:@"font"];
  if (fontdef != nil && [fontdef valueForKey:@"size"] != nil) {
    //NSString *fontface = [fontdef valueForKey:@"face"];
    NSNumber *fontsize = [fontdef valueForKey:@"size"];
    //if (fontface == nil && fontsize != nil) {
    //  fontface = @"HelveticaNeue-Bold"; // default (set defaults in JS?)
    //}
    int fsize = 11;
    if (fontsize != nil) {
      fsize = fontsize.intValue;
    }
//    UIFont *font = [UIFont fontWithName:fontface size:fsize];
    UIFont *font = [UIFont systemFontOfSize:fsize];
    if (font != nil) {
      // range can be used to apply the style to a substring of the label
      [attrString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attrString.string.length)];
    }
  }
  return attrString;
}

+ (void) setLabel:(WKInterfaceLabel*)label fromDic:(NSDictionary*)dic {
  if (dic == nil) {
    [label setHidden:YES];
  } else {
    [label setAttributedText:[self getAttributedStringFrom:dic]];
    [self setCommonPropertiesAndShow:label fromDic:dic];
  }
}

+ (void) setImage:(WKInterfaceImage*)image fromDic:(NSDictionary*)dic {
  if (dic == nil) {
    [image setHidden:YES];
  } else {
    [image setImageData:[dic valueForKey:@"src"]];
    
    NSNumber *width = [dic valueForKey:@"width"];
    [image setWidth:width == nil ? 0 /* natural size */ : width.doubleValue];
    
    NSNumber *height = [dic valueForKey:@"height"];
    [image setHeight:height == nil ? 0 /* natural size */ : height.doubleValue];
    
    [self setCommonPropertiesAndShow:image fromDic:dic];
  }
}

+ (void) setMap:(WKInterfaceMap*)map fromDic:(NSDictionary*)dic {
  if (dic == nil) {
    [map setHidden:YES];
  } else {
    CLLocationCoordinate2D coordinate = [self makeCoordinate:[dic valueForKey:@"center"]];
    NSNumber *zoom = [dic valueForKey:@"zoom"];
    MKCoordinateSpan span = MKCoordinateSpanMake([zoom floatValue], [zoom floatValue]);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    [map setRegion:region];

    [map removeAllAnnotations];
    NSArray *annotations = [dic valueForKey:@"annotations"];
    for (int i = 0; i < annotations.count; i++) {
      NSDictionary* annotationDef = annotations[i];
      [self addAnnotation:annotationDef forItemAtIndex:i toMap:map];
    }

    [self setCommonPropertiesAndShow:map fromDic:dic];
  }
}

+ (void) addAnnotation:(NSDictionary*)annotation forItemAtIndex:(int)index toMap:(WKInterfaceMap*)map {
  WKInterfaceMapPinColor color = [self WKInterfaceMapPinColorFromString:[annotation valueForKey:@"pinColor"]];
  [map addAnnotation:[self makeCoordinate:annotation] withPinColor:color];
}

+ (CLLocationCoordinate2D) makeCoordinate:(NSDictionary*) dic {
  NSNumber *lat = [dic valueForKey:@"lat"];
  NSNumber *lng = [dic valueForKey:@"lng"];
  CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([lat floatValue], [lng floatValue]);
  return coordinate;
}

+ (void) setButton:(WKInterfaceButton*)button fromDic:(NSDictionary*)dic {
  if (dic == nil) {
    [button setHidden:YES];
  } else {
    [button setAttributedTitle:[self getAttributedStringFrom:[dic valueForKey:@"title"]]];

    NSString *hexColor = [dic valueForKey:@"color"];
    if (hexColor != nil) {
      UIColor *theColor = [self colorFromHexString:hexColor];
      [button setBackgroundColor:theColor];
    }

    [self setCommonPropertiesAndShow:button fromDic:dic];
  }
}

+ (NSString*) setButtonWithCallback:(WKInterfaceButton*)button fromDic:(NSDictionary*)dic {
  [self setButton:button fromDic:dic];
  return dic == nil ? nil : [dic valueForKey:@"callback"];
}

+ (NSDictionary*) setUserInputButton:(WKInterfaceButton*)button fromDic:(NSDictionary*)dic {
  [self setButton:button fromDic:dic];
  return dic;
}

+ (NSString*) setSwitch:(WKInterfaceSwitch*)switch1 fromDic:(NSDictionary*)dic {
  if (dic == nil) {
    [switch1 setHidden:YES];
    return nil;
  } else {
    [switch1 setTitle:[dic valueForKey:@"title"]];
    NSNumber *on = (NSNumber *)[dic objectForKey: @"on"];
    [switch1 setOn:[on boolValue]];

    NSString *hexColor = [dic valueForKey:@"color"];
    if (hexColor != nil) {
      UIColor *theColor = [self colorFromHexString:hexColor];
      [switch1 setColor:theColor];
    }
    [self setCommonPropertiesAndShow:switch1 fromDic:dic];
    return [dic valueForKey:@"callback"];
  }
}

+ (NSString*) setSlider:(WKInterfaceSlider*)slider withLabel:(WKInterfaceLabel*)label inGroup:(WKInterfaceGroup*)group fromDic:(NSDictionary*)dic {
  if (dic == nil) {
    [group setHidden:YES];
    [slider setHidden:YES];
    [label setHidden:YES];
    return nil;
  } else {
    NSNumber* value = [dic objectForKey: @"value"];
    [slider setValue:[value floatValue]];
    
    NSNumber* steps = [dic objectForKey: @"steps"];
    [slider setNumberOfSteps:[steps integerValue]];
    
    NSString *hexColor = [dic valueForKey:@"color"];
    if (hexColor != nil) {
      UIColor *theColor = [self colorFromHexString:hexColor];
      [slider setColor:theColor];
    }

    NSNumber *hideValue = (NSNumber *)[dic objectForKey: @"hideValue"];
    if (![hideValue boolValue]) {
      [label setHidden:NO];
      [label setText:[NSString stringWithFormat:@"%.f", [value floatValue]]];
    }

    [self setCommonPropertiesAndShow:slider fromDic:dic];
    [group setHidden:NO];
    return [dic valueForKey:@"callback"];
  }
}

+ (void) setTable:(WKInterfaceTable*)table fromDic:(NSDictionary*)dic {
  if (dic == nil) {
    [table setHidden:YES];
  } else {
    NSMutableArray *rowTypes = [NSMutableArray arrayWithCapacity:2];
    NSArray *rows = [dic valueForKey:@"rows"];
    for (NSInteger i = 0; i < rows.count; i++) {
      NSDictionary* rowDef = rows[i];
      NSString* rowType = [rowDef objectForKey:@"type"];
      [rowTypes addObject:rowType];
    }
    [table setRowTypes:rowTypes];

    for (NSInteger i = 0; i < rows.count; i++) {
      NSDictionary* rowDef = rows[i];

      if ([rowTypes[i] isEqualToString:@"ImageLabelRowType"]) {
        ImageLabelRowType* row = [table rowControllerAtIndex:i];
        [row.label setText:[rowDef objectForKey:@"label"]];
      }
      
      // See this for clickable rows: http://blog.numerousapp.com/2014/12/09/watch-dev-2.html
      if ([rowTypes[i] isEqualToString:@"TwoColumnsRowType"]) {
        TwoColumnsRowType* row = [table rowControllerAtIndex:i];
        [self setLabel:row.col1label fromDic:[rowDef objectForKey:@"col1label"]];
        [self setLabel:row.col2label fromDic:[rowDef objectForKey:@"col2label"]];
      }
    }
    [self setCommonPropertiesAndShow:table fromDic:dic];
  }
}

// Assumes input like "#00FF00" (#RRGGBB)
+ (UIColor *)colorFromHexString:(NSString *)hexString {
  unsigned rgbValue = 0;
  NSScanner *scanner = [NSScanner scannerWithString:hexString];
  [scanner setScanLocation:1]; // bypass '#' character
  [scanner scanHexInt:&rgbValue];
  return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

#pragma st00pid ObjC enums
+ (WKMenuItemIcon) WKMenuItemIconFromString:(NSString*)str {
       if ([str isEqualToString:@"accept"])  return WKMenuItemIconAccept;
  else if ([str isEqualToString:@"add"])     return WKMenuItemIconAdd;
  else if ([str isEqualToString:@"block"])   return WKMenuItemIconBlock;
  else if ([str isEqualToString:@"decline"]) return WKMenuItemIconDecline;
  else if ([str isEqualToString:@"info"])    return WKMenuItemIconInfo;
  else if ([str isEqualToString:@"maybe"])   return WKMenuItemIconMaybe;
  else if ([str isEqualToString:@"more"])    return WKMenuItemIconMore;
  else if ([str isEqualToString:@"mute"])    return WKMenuItemIconMute;
  else if ([str isEqualToString:@"pause"])   return WKMenuItemIconPause;
  else if ([str isEqualToString:@"play"])    return WKMenuItemIconPlay;
  else if ([str isEqualToString:@"repeat"])  return WKMenuItemIconRepeat;
  else if ([str isEqualToString:@"resume"])  return WKMenuItemIconResume;
  else if ([str isEqualToString:@"share"])   return WKMenuItemIconShare;
  else if ([str isEqualToString:@"shuffle"]) return WKMenuItemIconShuffle;
  else if ([str isEqualToString:@"speaker"]) return WKMenuItemIconSpeaker;
  else if ([str isEqualToString:@"trash"])   return WKMenuItemIconTrash;
  else                                       return WKMenuItemIconInfo; // default
}

+ (WKInterfaceMapPinColor) WKInterfaceMapPinColorFromString:(NSString*)str {
       if ([str isEqualToString:@"green"])   return WKInterfaceMapPinColorGreen;
  else if ([str isEqualToString:@"purple"])  return WKInterfaceMapPinColorPurple;
  else if ([str isEqualToString:@"red"])     return WKInterfaceMapPinColorRed;
  else                                       return WKInterfaceMapPinColorRed; // default
}

# pragma common methods in WKInterfaceObject
+ (void) setCommonPropertiesAndShow:(WKInterfaceObject*) obj fromDic:(NSDictionary*)dic {
  [self setAlpha:obj fromDic:dic];
  [self setWidth:obj fromDic:dic];
  [self setHeight:obj fromDic:dic];
  
  [obj setHidden:NO];
}

+ (void) setAlpha:(WKInterfaceObject*) obj fromDic:(NSDictionary*)dic {
  NSNumber *alpha = [dic valueForKey:@"alpha"];
  [obj setAlpha:alpha == nil ? 1 /* full opaque (solid) */ : alpha.doubleValue];
}

+ (void) setWidth:(WKInterfaceObject*) obj fromDic:(NSDictionary*)dic {
  NSNumber *width = [dic valueForKey:@"width"];
  if (width != nil) {
    [obj setWidth:width.doubleValue];
  }
}

+ (void) setHeight:(WKInterfaceObject*) obj fromDic:(NSDictionary*)dic {
  NSNumber *height = [dic valueForKey:@"height"];
  if (height != nil) {
    [obj setHeight:height.doubleValue];
  }
}

@end