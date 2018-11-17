//
//  UIColor+GTModify.h
//  GTCategories
//
//  Created by liuxc on 2018/11/16.
//

#import <UIKit/UIKit.h>

@interface UIColor (GTModify)

- (UIColor *)gt_invertedColor;
- (UIColor *)gt_colorForTranslucency;
- (UIColor *)gt_lightenColor:(CGFloat)lighten;
- (UIColor *)gt_darkenColor:(CGFloat)darken;

@end
