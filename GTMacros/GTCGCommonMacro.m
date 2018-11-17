//
//  GTCGCommonMacro.m
//  Pods-GTMacros_Example
//
//  Created by liuxc on 2018/11/17.
//

#import "GTCGCommonMacro.h"
#import "GTSystemCommonMacro.h"

GT_EXTERN CGFloat kScreenScale() {
    static CGFloat scale;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scale = [UIScreen mainScreen].scale;
    });
    return scale;
}

GT_EXTERN CGRect kScrentBounds(void) {
    return [[UIScreen mainScreen] bounds];
}

GT_EXTERN CGSize kScreenSize() {
    static CGSize size;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        size = [UIScreen mainScreen].bounds.size;
        if (size.height < size.width) {
            CGFloat tmp = size.height;
            size.height = size.width;
            size.width = tmp;
        }
    });
    return size;
}


GT_EXTERN CGFloat kScreenWidth(void) {
    return (([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height;
}
GT_EXTERN CGFloat kScreenHeight(void) {
    return ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width);
}


GT_EXTERN CGFloat kScreenWidthRatio(void) {
    return kScreenWidth() / 414.0;
}

GT_EXTERN CGFloat kScreenHeightRatio(void) {
    return kScreenHeight() / 736.0;
}

GT_EXTERN CGFloat kAdaptedWidth(CGFloat width) {
    return (CGFloat)ceilf(width) * kScreenWidthRatio();
}

GT_EXTERN CGFloat kAdaptedHeight(CGFloat height) {
    return (CGFloat)ceilf(height) * kScreenHeightRatio();
}


GT_EXTERN UIFont *kAdaptedFontSize(CGFloat fontSize) {
    return kCHINESE_SYSTEM(kAdaptedWidth(fontSize));
}


//导航栏高度
GT_EXTERN CGFloat kNaviBarHeight(void) {
    return 44.0;
}

//状态栏高度
GT_EXTERN CGFloat kStatusBarHeight(void) {
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}

//导航栏与状态栏高度
GT_EXTERN CGFloat kStatusBarAndNavigationBarHeight(void) {
    return kNaviBarHeight() + kStatusBarHeight();
}

//tabbar高度
GT_EXTERN CGFloat kTabbarHeight(void) {
    return [[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? 83 : 49;
}


// iOS 11.0 的 view.safeAreaInsets
GT_EXTERN UIEdgeInsets kViewSafeAreaInsets(UIView *view) {
    UIEdgeInsets i;
    if(@available(iOS 11.0, *)) {
        i = view.safeAreaInsets;
    } else {
        i = UIEdgeInsetsZero;
    }
    return i;
}

// iOS 11 一下的 scrollview 的适配
GT_EXTERN void kAdjustsScrollViewInsetNever(UIViewController *controller, UIScrollView *view) {
    if(@available(iOS 11.0, *)) {
        view.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else if([controller isKindOfClass:[UIViewController class]]) {
        controller.automaticallyAdjustsScrollViewInsets = false;
    }
}
