//
//  UIColor+GTHEX.h
//  GTCategories
//
//  Created by liuxc on 2018/11/16.
//

#import <UIKit/UIKit.h>

@interface UIColor (GTHEX)

+ (UIColor *)gt_colorWithHex:(UInt32)hex;
+ (UIColor *)gt_colorWithHex:(UInt32)hex andAlpha:(CGFloat)alpha;
+ (UIColor *)gt_colorWithHexString:(NSString *)hexString;
- (NSString *)gt_HEXString;
///值不需要除以255.0
+ (UIColor *)gt_colorWithWholeRed:(CGFloat)red
                            green:(CGFloat)green
                             blue:(CGFloat)blue
                            alpha:(CGFloat)alpha;
///值不需要除以255.0
+ (UIColor *)gt_colorWithWholeRed:(CGFloat)red
                            green:(CGFloat)green
                             blue:(CGFloat)blue;

@end
