//
//  GTCGCommonMacro.h
//  Pods-GTMacros_Example
//
//  Created by liuxc on 2018/11/17.
//

/*
 *  关于frame通用方法
 */

#import <Foundation/Foundation.h>
#import "GTCommonMacro.h"

#pragma mark 屏幕 缩放比例
GT_EXTERN CGFloat kScreenScale(void);


#pragma mark 屏幕 bounds
GT_EXTERN CGRect kScrentBounds(void);

#pragma mark 屏幕 Size
GT_EXTERN CGSize kScreenSize(void);

#pragma mark 屏幕 width
GT_EXTERN CGFloat kScreenWidth(void);

#pragma mark 屏幕 height
GT_EXTERN CGFloat kScreenHeight(void);

#pragma mark 不同屏幕尺寸字体适配（375，667是因为效果图为IPHONE6 如果不是则根据实际情况修改）
GT_EXTERN CGFloat kScreenWidthRatio(void);
GT_EXTERN CGFloat kScreenHeightRatio(void);
GT_EXTERN CGFloat kAdaptedWidth(CGFloat width);
GT_EXTERN CGFloat kAdaptedHeight(CGFloat height);
GT_EXTERN UIFont *kAdaptedFontSize(CGFloat fontSize);

#pragma mark 导航栏高度
GT_EXTERN CGFloat kNaviBarHeight(void);

#pragma mark 状态栏高度
GT_EXTERN CGFloat kStatusBarHeight(void);

#pragma mark 导航栏与状态栏高度
GT_EXTERN CGFloat kStatusBarAndNavigationBarHeight(void);

#pragma mark Tabbar高度
GT_EXTERN CGFloat kTabbarHeight(void);

#pragma mark iOS 11 以后 的 view.safeAreaInsets
GT_EXTERN UIEdgeInsets kViewSafeAreaInsets(UIView *view);

#pragma mark iOS 11 一下的 scrollview 的适配
GT_EXTERN void kAdjustsScrollViewInsetNever(UIViewController *controller, UIScrollView *view);

