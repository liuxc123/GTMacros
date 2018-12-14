//
//  GTSystemCommonMacro.h
//  Pods-GTMacros_Example
//
//  Created by liuxc on 2018/11/17.
//

/*
 *  系统通用方法
 */
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GTCommonMacro.h"

GT_EXTERN_C_BEGIN

#pragma mark App版本号
GT_EXTERN NSString* kAppVersion(void);

#pragma mark 系统版本
GT_EXTERN float kFSystemVersion(void);
GT_EXTERN double kDSystemVersion(void);
GT_EXTERN NSString* kSSystemVersion(void);

#pragma mark 当前系统是否大于某个版本
GT_EXTERN BOOL isIOS6(void);
GT_EXTERN BOOL isIOS7(void);
GT_EXTERN BOOL isIOS8(void);
GT_EXTERN BOOL isIOS9(void);
GT_EXTERN BOOL isIOS10(void);
GT_EXTERN BOOL isIOS11(void);
GT_EXTERN BOOL isIOS12(void);

GT_EXTERN BOOL isIPhoneX(void);
GT_EXTERN BOOL isIPad(void);

#pragma mark AppDelegate对象
GT_EXTERN id kAppDelegateInstance(void);

#pragma mark - Application
GT_EXTERN UIApplication *kApplication(void);

#pragma mark - KeyWindow
GT_EXTERN UIWindow *kKeyWindow(void);

#pragma mark - NotiCenter
GT_EXTERN NSNotificationCenter *kNotificationCenter(void);

#pragma mark - NSUserDefault
GT_EXTERN NSUserDefaults *kNSUserDefaults(void);

#pragma mark 获取当前语言
GT_EXTERN NSString *kCurrentLanguage(void);

#pragma mark Library/Caches 文件路径
GT_EXTERN NSURL *kFilePath(void);

#pragma mark 获取temp路径
GT_EXTERN NSString *kPathTemp(void);

#pragma mark 获取沙盒 Document路径
GT_EXTERN NSString *kPathDocument(void);

#pragma mark 获取沙盒 Cache
GT_EXTERN NSString *kPathCache(void);

#pragma mark 获取沙盒 home 目录路径
GT_EXTERN NSString *kPathHome(void);

#pragma mark 用safari打开URL
GT_EXTERN BOOL kOpenURL(NSString *url);

#pragma mark 复制文字内容
GT_EXTERN void kCopyContent(NSString *content);

#pragma mark 中文字体
GT_EXTERN UIFont *kCHINESE_SYSTEM(CGFloat fontSize);
GT_EXTERN UIFont *kSystemFont(CGFloat fontSize);
GT_EXTERN UIFont *kBoldSystemFont(CGFloat fontSize);
GT_EXTERN UIFont *kItalicSystemFont(CGFloat fontSize);
GT_EXTERN UIFont *kFont(NSString *name,CGFloat fontSize);


#pragma mark - 图片
GT_EXTERN UIImage *kImageNamed(NSString *imageName);
GT_EXTERN UIImage *kImageNamedAndRenderingMode(NSString *imageName, UIImageRenderingMode renderingMode);

#pragma mark - NSIndexPath
GT_EXTERN NSIndexPath *kIndexPath(NSInteger section, NSInteger row);

#pragma mark - 根据raba获取颜色
GT_EXTERN UIColor *kColorRGBA(float r,float g,float b, float a);

#pragma mark - 根据hexString获取颜色
GT_EXTERN UIColor* kColorHEXString(NSString *hexString);

#pragma mark - 获取随机颜色
GT_EXTERN UIColor *kRandomColor(void);

GT_EXTERN_C_END
