//
//  GTSystemCommonMacro.m
//  Pods-GTMacros_Example
//
//  Created by liuxc on 2018/11/17.
//

#import "GTSystemCommonMacro.h"
#import "UIColor+GTHEX.h"
#import "UIColor+GTRandom.h"

#pragma mark App版本号
GT_EXTERN void kAppVersion() {
    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

#pragma mark 系统版本
GT_EXTERN float kFSystemVersion() {
    return ([[[UIDevice currentDevice] systemVersion] floatValue]);
}

GT_EXTERN double kDSystemVersion(void) {
    return ([[[UIDevice currentDevice] systemVersion] doubleValue]);
}

GT_EXTERN NSString* kSSystemVersion(void) {
    return [[UIDevice currentDevice] systemVersion];
}

#pragma mark 当前系统是否大于某个版本
GT_EXTERN BOOL isIOS6(void) {
    return ([[[UIDevice currentDevice]systemVersion]floatValue] < 7.0);
}
GT_EXTERN BOOL isIOS7(void) {
    return ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0);
}
GT_EXTERN BOOL isIOS8(void) {
    return ([[[UIDevice currentDevice]systemVersion]floatValue] >= 8.0);
}
GT_EXTERN BOOL isIOS9(void) {
    return ([[[UIDevice currentDevice]systemVersion]floatValue] >= 9.0);
}
GT_EXTERN BOOL isIOS10(void) {
    return ([[[UIDevice currentDevice]systemVersion]floatValue] >= 10.0);
}
GT_EXTERN BOOL isIOS11(void) {
    return ([[[UIDevice currentDevice]systemVersion]floatValue] >= 11.0);
}
GT_EXTERN BOOL isIOS12(void) {
    return ([[[UIDevice currentDevice]systemVersion]floatValue] >= 12.0);
}

GT_EXTERN BOOL isIPhoneX(void) {
    // 判断是否是iPhone X
    //    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO);
    return CGRectGetHeight(kApplication().statusBarFrame) == 44.0f;
}
GT_EXTERN BOOL isIPad(void) {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}


#pragma mark AppDelegate对象
GT_EXTERN id kAppDelegateInstance(void) {
    return [[UIApplication sharedApplication] delegate];
}

#pragma mark - Application
GT_EXTERN UIApplication *kApplication(void) {
    return [UIApplication sharedApplication];
}

#pragma mark - KeyWindow
GT_EXTERN UIWindow *kKeyWindow(void) {
    return [UIApplication sharedApplication].keyWindow;
}

#pragma mark - NotiCenter
GT_EXTERN NSNotificationCenter *kNotificationCenter(void) {
    return [NSNotificationCenter defaultCenter];
}

#pragma mark - NSUserDefault
GT_EXTERN NSUserDefaults *kNSUserDefaults(void) {
    return [NSUserDefaults standardUserDefaults];
}

#pragma mark 获取当前语言
GT_EXTERN NSString *kCurrentLanguage(void) {
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

#pragma mark Library/Caches 文件路径
GT_EXTERN NSURL *kFilePath(void) {
    return [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
}

#pragma mark 获取temp路径
GT_EXTERN NSString *kPathTemp(void) {
    return NSTemporaryDirectory();
}

#pragma mark 获取沙盒 Document路径
GT_EXTERN NSString *kPathDocument(void) {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

#pragma mark 获取沙盒 Cache
GT_EXTERN NSString *kPathCache(void) {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

#pragma mark 获取沙盒 home 目录路径
GT_EXTERN NSString *kPathHome(void) {
    return NSHomeDirectory();
}

GT_EXTERN void kOpenURL(NSString *url) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

#pragma mark 复制文字内容
GT_EXTERN void kCopyContent(NSString *content) {
    [[UIPasteboard generalPasteboard] setString:content];
}

#pragma mark 复制文字内容
GT_EXTERN void kCopyContent(NSString *content);

#pragma mark 中文字体
GT_EXTERN UIFont *kCHINESE_SYSTEM(CGFloat fontSize) {
    return [UIFont fontWithName:@"Heiti SC" size:fontSize];
}

GT_EXTERN UIFont *kSystemFont(CGFloat fontSize) {
    return [UIFont systemFontOfSize:fontSize];
}

GT_EXTERN UIFont *kBoldSystemFont(CGFloat fontSize) {
    return [UIFont boldSystemFontOfSize:fontSize];
}

GT_EXTERN UIFont *kItalicSystemFont(CGFloat fontSize) {
    return [UIFont italicSystemFontOfSize:fontSize];
}

GT_EXTERN UIFont *kFont(NSString *name,CGFloat fontSize) {
    return [UIFont fontWithName:name size:fontSize];
}


#pragma mark - 图片
GT_EXTERN UIImage *kImageNamed(NSString *imageName) {
    return [UIImage imageNamed:imageName];
}

GT_EXTERN UIImage *kImageNamedAndRenderingMode(NSString *imageName, UIImageRenderingMode renderingMode) {
    return [[UIImage imageNamed:imageName] imageWithRenderingMode:renderingMode];
}

GT_EXTERN NSIndexPath *kIndexPath(NSInteger section, NSInteger row) {
    return [NSIndexPath indexPathForRow:row inSection:section];
}


#pragma mark - 根据raba获取颜色
GT_EXTERN UIColor* kColorRGBA(float r,float g,float b, float a) {
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
}

#pragma mark - 根据hexString获取颜色
GT_EXTERN UIColor* kColorHEXString(NSString *hexString) {
    return [UIColor gt_colorWithHexString:hexString];
}

GT_EXTERN UIColor* kRandomColor(void) {
    return [UIColor gt_randomColor];
}
