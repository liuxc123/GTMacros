//
//  GTFunctionCommonMacro.h
//  GTCategories
//
//  Created by liuxc on 2018/11/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <sys/time.h>
#import <pthread.h>
#import "GTCommonMacro.h"

GT_EXTERN_C_BEGIN

#pragma mark - dispatch 线程队列

/**
 Returns a dispatch_time delay from now.
 */
GT_EXTERN dispatch_time_t dispatch_time_delay(NSTimeInterval second);

/**
 Returns a dispatch_wall_time delay from now.
 */
GT_EXTERN dispatch_time_t dispatch_walltime_delay(NSTimeInterval second);

/**
 Returns a dispatch_wall_time from NSDate.
 */
GT_EXTERN dispatch_time_t dispatch_walltime_date(NSDate *date);

/**
 Whether in main queue/thread.
 */
GT_EXTERN bool dispatch_is_main_queue(void);

/**
 Submits a block for asynchronous execution on a main queue and returns immediately.
 */
GT_EXTERN void dispatch_async_on_main_queue(void (^block)(void));

/**
 Submits a block for execution on a main queue and waits until the block completes.
 */
GT_EXTERN void dispatch_sync_on_main_queue(void (^block)(void));

/**
 Initialize a pthread mutex.
 */
GT_EXTERN void pthread_mutex_init_recursive(pthread_mutex_t *mutex, bool recursive);



#pragma mark - runtime

/**
 *  如果 fromClass 里存在 originSelector，则这个函数会将 fromClass 里的 originSelector 与 toClass 里的 newSelector 交换实现。
 *  如果 fromClass 里不存在 originSelecotr，则这个函数会为 fromClass 增加方法 originSelector，并且该方法会使用 toClass 的 newSelector 方法的实现，而 toClass 的 newSelector 方法的实现则会被替换为空内容
 *  @warning 注意如果 fromClass 里的 originSelector 是继承自父类并且 fromClass 也没有重写这个方法，这会导致实际上被替换的是父类，然后父类及父类的所有子类（也即 fromClass 的兄弟类）也受影响，因此使用时请谨记这一点。
 *  @param _fromClass 要被替换的 class，不能为空
 *  @param _originSelector 要被替换的 class 的 selector，可为空，为空则相当于为 fromClass 新增这个方法
 *  @param _toClass 要拿这个 class 的方法来替换
 *  @param _newSelector 要拿 toClass 里的这个方法来替换 originSelector
 *  @return 是否成功替换（或增加）
 */
GT_EXTERN BOOL kObjc_ReplaceMethodInTwoClasses(Class _fromClass, SEL _originSelector, Class _toClass, SEL _newSelector);

#pragma mark runtime method A -> B
GT_EXTERN BOOL kObjc_ReplaceMethod(Class _class, SEL _originSelector, SEL _newSelector);

/**
 *  用 block 重写某个 class 的指定方法
 *  @param targetClass 要重写的 class
 *  @param targetSelector 要重写的 class 里的实例方法，注意如果该方法不存在于 targetClass 里，则什么都不做
 *  @param implementationBlock 该 block 必须返回一个 block，返回的 block 将被当成 targetSelector 的新实现，所以要在内部自己处理对 super 的调用，以及对当前调用方法的 self 的 class 的保护判断（因为如果 targetClass 的 targetSelector 是继承自父类的，targetClass 内部并没有重写这个方法，则我们这个函数最终重写的其实是父类的 targetSelector，所以会产生预期之外的 class 的影响，例如 targetClass 传进来  UIButton.class，则最终可能会影响到 UIView.class），implementationBlock 的参数里第一个为你要修改的 class，也即等同于 targetClass，第二个参数为你要修改的 selector，也即等同于 targetSelector，第三个参数是 targetSelector 原本的实现，由于 IMP 可以直接当成 C 函数调用，所以可利用它来实现“调用 super”的效果，但由于 targetSelector 的参数个数、参数类型、返回值类型，都会影响 IMP 的调用写法，所以这个调用只能由业务自己写。
 */
GT_EXTERN BOOL kObjc_OverrideImplementation(Class targetClass, SEL targetSelector, id (^implementationBlock)(Class originClass, SEL originCMD, IMP originIMP));

/**
 *  用 block 重写某个 class 的某个无参数且返回值为 void 的方法，会自动在调用 block 之前先调用该方法原本的实现。
 *  @param targetClass 要重写的 class
 *  @param targetSelector 要重写的 class 里的实例方法，注意如果该方法不存在于 targetClass 里，则什么都不做，注意该方法必须无参数，返回值为 void
 *  @param implementationBlock targetSelector 的自定义实现，直接将你的实现写进去即可，不需要管 super 的调用。参数 selfObject 代表当前正在调用这个方法的对象，也即 self 指针。
 */
GT_EXTERN BOOL kObjc_ExtendImplementationOfVoidMethodWithoutArguments(Class targetClass, SEL targetSelector, void (^implementationBlock)(__kindof NSObject *selfObject));

#pragma mark - 其他方法
/**
 Convert CFRange to NSRange
 @param range CFRange @return NSRange
 */
GT_EXTERN NSRange GTNSRangeFromCFRange(CFRange range);

/**
 Convert NSRange to CFRange
 @param range NSRange @return CFRange
 */
GT_EXTERN CFRange GTCFRangeFromNSRange(NSRange range);

/**
 Same as CFAutorelease(), compatible for iOS6
 @param arg CFObject @return same as input
 */
GT_EXTERN CFTypeRef GTCFAutorelease(CFTypeRef CF_RELEASES_ARGUMENT arg);

/**
 Profile time cost.
 @param block    code to benchmark
 @param complete code time cost (millisecond)

 Usage:
 GTBenchmark(^{
 // code
 }, ^(double ms) {
 NSLog("time cost: %.2f ms",ms);
 });

 */
GT_EXTERN void GTBenchmark(void (^block)(void), void (^complete)(double ms));

//获取编译时间
GT_EXTERN NSDate *_GTCompileTime(const char *data, const char *time);

#pragma mark - 随机数
/*!
 *  获取一个随机整数范围在：[0,i)包括0，不包括i
 *
 *  @param i 最大的数
 *
 *  @return 获取一个随机整数范围在：[0,i)包括0，不包括i
 */
/*!
 rand()和random()实际并不是一个真正的伪随机数发生器，在使用之前需要先初始化随机种子，否则每次生成的随机数一样。
 arc4random() 是一个真正的伪随机算法，不需要生成随机种子，因为第一次调用的时候就会自动生成。而且范围是rand()的两倍。在iPhone中，RAND_MAX是0x7fffffff (2147483647)，而arc4random()返回的最大值则是 0x100000000 (4294967296)。
 精确度比较：arc4random() > random() > rand()。
 */
GT_EXTERN NSInteger kRandomNumber(NSInteger i);

#pragma mark - 判断空类型

#pragma mark 字符串是否为空
GT_EXTERN BOOL kStringIsEmpty(NSString *string);

#pragma mark 判断字符串是否含有空格
GT_EXTERN BOOL kStringIsBlank(NSString *string);

#pragma mark 数组是否为空
GT_EXTERN BOOL kArrayIsEmpty(NSArray *array);

#pragma mark 字典是否为空
GT_EXTERN BOOL kDictIsEmpty(NSDictionary *dic);

#pragma mark 字典是否为空
GT_EXTERN BOOL kObjectIsEmpty(id _object);




#pragma mark - 从本地文件读取数据
GT_EXTERN NSData *kGetDataWithContentsOfFile(NSString *fileName, NSString *type);

#pragma mark - json data

#pragma mark json 解析 data 数据
GT_EXTERN NSDictionary *kGetDictionaryWithData(NSData *data);

#pragma mark json 解析 ，直接从本地文件读取 json 数据，返回 NSDictionary
GT_EXTERN NSDictionary *kGetDictionaryWithContentsOfFile(NSString *fileName, NSString *type);

#pragma mark json 解析 ，json string 转 NSDictionary，返回 NSDictionary
GT_EXTERN NSDictionary *kGetDictionaryWithJsonString(NSString *jsonString);

#pragma mark - Encode Decode 方法
// NSDictionary -> NSString
GT_EXTERN NSString* kDecodeObjectFromDic(NSDictionary *dic, NSString *key);
// NSArray + index -> id
GT_EXTERN id        kDecodeSafeObjectAtIndex(NSArray *arr, NSInteger index);
// NSDictionary -> NSString
GT_EXTERN NSString     * kDecodeStringFromDic(NSDictionary *dic, NSString *key);
// NSDictionary -> NSString ？ NSString ： defaultStr
GT_EXTERN NSString* kDecodeDefaultStrFromDic(NSDictionary *dic, NSString *key,NSString * defaultStr);
// NSDictionary -> NSNumber
GT_EXTERN NSNumber     * kDecodeNumberFromDic(NSDictionary *dic, NSString *key);
// NSDictionary -> NSDictionary
GT_EXTERN NSDictionary *kDecodeDicFromDic(NSDictionary *dic, NSString *key);
// NSDictionary -> NSArray
GT_EXTERN NSArray      *kDecodeArrayFromDic(NSDictionary *dic, NSString *key);
GT_EXTERN NSArray      *kDecodeArrayFromDicUsingParseBlock(NSDictionary *dic, NSString *key, id(^parseBlock)(NSDictionary *innerDic));

#pragma mark - Encode Decode 方法
// (nonull Key: nonull NSString) -> NSMutableDictionary
GT_EXTERN void kEncodeUnEmptyStrObjctToDic(NSMutableDictionary *dic,NSString *object, NSString *key);
// nonull objec -> NSMutableArray
GT_EXTERN void kEncodeUnEmptyObjctToArray(NSMutableArray *arr,id object);
// (nonull (Key ? key : defaultStr) : nonull Value) -> NSMutableDictionary
GT_EXTERN void kEncodeDefaultStrObjctToDic(NSMutableDictionary *dic,NSString *object, NSString *key,NSString * defaultStr);
// (nonull Key: nonull object) -> NSMutableDictionary
GT_EXTERN void kEncodeUnEmptyObjctToDic(NSMutableDictionary *dic,NSObject *object, NSString *key);



GT_EXTERN_C_END
