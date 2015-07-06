#import "WatchKitUIHelper.h"

@implementation WatchKitUIHelper

- (void)awakeWithContext:(id)context {
}

+ (NSAttributedString*) getAttributedStringFrom:(NSDictionary*)dic {
  NSString* value = [dic valueForKey:@"value"];
  if (value == nil) {
    value = @"";
    [WatchKitHelper logError:@"No 'value' specified, using '' as default"];
  }
  NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:value];

  NSString *hexColor = [dic valueForKey:@"color"];
  // default white
  UIColor *color = hexColor == nil ? [UIColor whiteColor] : [self colorFromHexString:hexColor];
  [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, value.length)];

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
      [attrString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, value.length)];
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

+ (void) setGroup:(WKInterfaceGroup*)group fromDic:(NSDictionary*)dic {
  NSString *hexColor = [dic valueForKey:@"backgroundColor"];
  if (hexColor != nil) {
    [group setBackgroundColor:[self colorFromHexString:hexColor]];
  }

  NSNumber *cornerRadius = [dic valueForKey:@"cornerRadius"];
  if (cornerRadius != nil) {
    [group setCornerRadius:[cornerRadius floatValue]];
  }

  [self setCommonPropertiesAndShow:group fromDic:dic];
}

+ (void) setImage:(WKInterfaceImage*)image fromDic:(NSDictionary*)dic {
  if (dic == nil) {
    [image setHidden:YES];
  } else {
    [image setImageData:[dic valueForKey:@"src"]];
    [self setCommonPropertiesAndShow:image fromDic:dic];
  }
}

+ (void) setMap:(WKInterfaceMap*)map fromDic:(NSDictionary*)dic {
  if (dic == nil) {
    [map setHidden:YES];
  } else {
    CLLocationCoordinate2D coordinate = [self makeCoordinate:[dic valueForKey:@"center"]];
    NSNumber *zoom = [dic valueForKey:@"zoom"];
    if (zoom == nil) {
      [WatchKitHelper logError:@"No 'zoom' specified, using '0.1' by default"];
      zoom = [NSNumber numberWithFloat:0.1];
    }
    MKCoordinateSpan span = MKCoordinateSpanMake([zoom floatValue], [zoom floatValue]);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    [map setRegion:region];

    [map removeAllAnnotations];
    NSArray *annotations = [dic valueForKey:@"annotations"];
    for (int i = 0; i < annotations.count; i++) {
      NSDictionary* anDef = annotations[i];
      [map addAnnotation:[self makeCoordinate:anDef] withPinColor:[self WKInterfaceMapPinColorFromString:[anDef valueForKey:@"pinColor"]]];
    }
    [self setCommonPropertiesAndShow:map fromDic:dic];
  }
}

+ (CLLocationCoordinate2D) makeCoordinate:(NSDictionary*) dic {
  NSNumber *lat = [dic valueForKey:@"lat"];
  NSNumber *lng = [dic valueForKey:@"lng"];
  if (lat == nil || lng == nil) {
    [WatchKitHelper logError:@"Please specify 'lat' and 'lng', using defaults (0)"];
  }
  return CLLocationCoordinate2DMake([lat floatValue], [lng floatValue]);
}

+ (void) setButton:(WKInterfaceButton*)button fromDic:(NSDictionary*)dic {
  if (dic == nil) {
    [button setHidden:YES];
  } else {
    [button setAttributedTitle:[self getAttributedStringFrom:[dic valueForKey:@"title"]]];

    NSString *hexColor = [dic valueForKey:@"backgroundColor"];
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

      if ([rowTypes[i] isEqualToString:@"SelectableImageLabelRowType"]) {
        SelectableImageLabelRowType* row = [table rowControllerAtIndex:i];
        // TODO images
        [self setLabel:row.label fromDic:[rowDef objectForKey:@"label"]];
        [self setGroup:row.group fromDic:[rowDef objectForKey:@"group"]];

      } else if ([rowTypes[i] isEqualToString:@"ImageLabelRowType"]) {
        ImageLabelRowType* row = [table rowControllerAtIndex:i];
        // TODO images
        [self setLabel:row.label fromDic:[rowDef objectForKey:@"label"]];
        [self setGroup:row.group fromDic:[rowDef objectForKey:@"group"]];

      } else if ([rowTypes[i] isEqualToString:@"TwoColumnsRowType"]) {
        TwoColumnsRowType* row = [table rowControllerAtIndex:i];
        [self setLabel:row.col1label fromDic:[rowDef objectForKey:@"col1label"]];
        [self setLabel:row.col2label fromDic:[rowDef objectForKey:@"col2label"]];
        [self setGroup:row.group fromDic:[rowDef objectForKey:@"group"]];
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
  else {
    [WatchKitHelper logError:@"No 'iconNamed' specified, using 'info' by default"];
    return WKMenuItemIconInfo;
  }
}

+ (WKInterfaceMapPinColor) WKInterfaceMapPinColorFromString:(NSString*)str {
       if ([str isEqualToString:@"green"])   return WKInterfaceMapPinColorGreen;
  else if ([str isEqualToString:@"purple"])  return WKInterfaceMapPinColorPurple;
  else if ([str isEqualToString:@"red"])     return WKInterfaceMapPinColorRed;
  else {
    [WatchKitHelper logError:@"No 'pinColor' specified, using 'red' by default"];
    return WKInterfaceMapPinColorRed;
  }
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