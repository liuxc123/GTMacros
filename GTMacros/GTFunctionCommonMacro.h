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
