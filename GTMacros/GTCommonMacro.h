//
//  GTCommonMacro.h
//  Pods
//
//  Created by liuxc on 2018/11/17.
//
//  通用宏

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - C语言

#ifdef __cplusplus
#define GT_EXTERN_C_BEGIN  extern "C" {
#define GT_EXTERN_C_END  }
#else
#define GT_EXTERN_C_BEGIN
#define GT_EXTERN_C_END
#endif

GT_EXTERN_C_BEGIN

#ifndef GT_CLAMP // return the clamped value
#define GT_CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))
#endif

#ifndef GT_SWAP // swap two value
#define GT_SWAP(_a_, _b_)  do { __typeof__(_a_) _tmp_ = (_a_); (_a_) = (_b_); (_b_) = _tmp_; } while (0)
#endif

#pragma mark - 日志打印
// 日志打印 DLog
#ifdef DEBUG
#       define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#       define DLog(...)
#endif

#pragma mark - Extern and Inline  functions 内联函数  外联函数
/*／EXTERN 外联函数*/
#if !defined(GT_EXTERN)
#  if defined(__cplusplus)
#   define GT_EXTERN extern "C"
#  else
#   define GT_EXTERN extern
#  endif
#endif

/*INLINE 内联函数*/
#if !defined(GT_INLINE)
# if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
#  define GT_INLINE static inline
# elif defined(__cplusplus)
#  define GT_INLINE static inline
# elif defined(__GNUC__)
#  define GT_INLINE static __inline__
# else
#  define GT_INLINE static
# endif
#endif

#pragma mark - Assert functions Assert 断言
//iAssert 断言
#define GTAssert(expression, ...) \
do { if(!(expression)) { \
DLog(@"%@", \
[NSString stringWithFormat: @"Assertion failure: %s in %s on line %s:%d. %@",\
#expression, \
__PRETTY_FUNCTION__, \
__FILE__, __LINE__,  \
[NSString stringWithFormat:@"" __VA_ARGS__]]); \
abort(); } \
} while(0)

#define GTAssertNil(condition, description, ...) NSAssert(!(condition), (description), ##__VA_ARGS__)
#define GTCAssertNil(condition, description, ...) NSCAssert(!(condition), (description), ##__VA_ARGS__)

#define GTAssertNotNil(condition, description, ...) NSAssert((condition), (description), ##__VA_ARGS__)
#define GTCAssertNotNil(condition, description, ...) NSCAssert((condition), (description), ##__VA_ARGS__)

#define GTAssertMainThread() NSAssert([NSThread isMainThread], @"This method must be called on the main thread")
#define GTCAssertMainThread() NSCAssert([NSThread isMainThread], @"This method must be called on the main thread")

#pragma mark - 方法禁用提示
#undef GTDeprecated
#define GTDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

#pragma mark - weak / strong

#define kWeakSelf        @kWeakify(self);
#define kStrongSelf      @kStrongify(self);

/*！
 * 强弱引用转换，用于解决代码块（block）与强引用self之间的循环引用问题
 * 调用方式: `@GTKit_Weakify`实现弱引用转换，`@GTKit_Strongify`实现强引用转换
 *
 * 示例：
 * @kWeakify
 * [obj block:^{
 * @kStrongify
 * self.property = something;
 * }];
 */
#ifndef kWeakify
#if DEBUG
#if __has_feature(objc_arc)
#define kWeakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define kWeakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define kWeakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define kWeakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

/*！
 * 强弱引用转换，用于解决代码块（block）与强引用对象之间的循环引用问题
 * 调用方式: `@GTKit_Weakify(object)`实现弱引用转换，`@GTKit_Strongify(object)`实现强引用转换
 *
 * 示例：
 * @kWeakify(object)
 * [obj block:^{
 * @kStrongify(object)
 * strong_object = something;
 * }];
 */
#ifndef kStrongify
#if DEBUG
#if __has_feature(objc_arc)
#define kStrongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define kStrongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define kStrongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define kStrongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#pragma mark - 懒加载
#define kLazy(object, assignment) (object = object ?: assignment)

#pragma mark - Runtime
/**
 Synthsize a dynamic object property in @implementation scope.
 It allows us to add custom properties to existing classes in categories.

 @param association  ASSIGN / RETAIN / COPY / RETAIN_NONATOMIC / COPY_NONATOMIC
 @warning #import <objc/runtime.h>
 *******************************************************************************
 Example:
 @interface NSObject (MyAdd)
 @property (nonatomic, retain) UIColor *myColor;
 @end

 #import <objc/runtime.h>
 @implementation NSObject (MyAdd)
 GTSYNTH_DYNAMIC_PROPERTY_OBJECT(myColor, setMyColor, RETAIN, UIColor *)
 @end
 */
#ifndef GTSYNTH_DYNAMIC_PROPERTY_OBJECT
#define GTSYNTH_DYNAMIC_PROPERTY_OBJECT(_getter_, _setter_, _association_, _type_) \
- (void)_setter_ : (_type_)object { \
[self willChangeValueForKey:@#_getter_]; \
objc_setAssociatedObject(self, _cmd, object, OBJC_ASSOCIATION_ ## _association_); \
[self didChangeValueForKey:@#_getter_]; \
} \
- (_type_)_getter_ { \
return objc_getAssociatedObject(self, @selector(_setter_:)); \
}
#endif

GT_EXTERN_C_END
