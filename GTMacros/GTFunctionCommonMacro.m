//
//  GTFunctionCommonMacro.m
//  GTCategories
//
//  Created by liuxc on 2018/11/17.
//

#import "GTFunctionCommonMacro.h"

#pragma mark - dispatch 线程队列

/**
 Returns a dispatch_time delay from now.
 */
GT_EXTERN dispatch_time_t dispatch_time_delay(NSTimeInterval second) {
    return dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC));
}

/**
 Returns a dispatch_wall_time delay from now.
 */
GT_EXTERN dispatch_time_t dispatch_walltime_delay(NSTimeInterval second) {
    return dispatch_walltime(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC));
}

/**
 Returns a dispatch_wall_time from NSDate.
 */
GT_EXTERN dispatch_time_t dispatch_walltime_date(NSDate *date) {
    NSTimeInterval interval;
    double second, subsecond;
    struct timespec time;
    dispatch_time_t milestone;

    interval = [date timeIntervalSince1970];
    subsecond = modf(interval, &second);
    time.tv_sec = second;
    time.tv_nsec = subsecond * NSEC_PER_SEC;
    milestone = dispatch_walltime(&time, 0);
    return milestone;
}

/**
 Whether in main queue/thread.
 */
GT_EXTERN bool dispatch_is_main_queue() {
    return pthread_main_np() != 0;
}

/**
 Submits a block for asynchronous execution on a main queue and returns immediately.
 */
GT_EXTERN void dispatch_async_on_main_queue(void (^block)(void)) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

/**
 Submits a block for execution on a main queue and waits until the block completes.
 */
GT_EXTERN void dispatch_sync_on_main_queue(void (^block)(void)) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

/**
 Initialize a pthread mutex.
 */
GT_EXTERN void pthread_mutex_init_recursive(pthread_mutex_t *mutex, bool recursive) {
#define GTMUTEX_ASSERT_ON_ERROR(x_) do { \
__unused volatile int res = (x_); \
assert(res == 0); \
} while (0)
    assert(mutex != NULL);
    if (!recursive) {
        GTMUTEX_ASSERT_ON_ERROR(pthread_mutex_init(mutex, NULL));
    } else {
        pthread_mutexattr_t attr;
        GTMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_init (&attr));
        GTMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_settype (&attr, PTHREAD_MUTEX_RECURSIVE));
        GTMUTEX_ASSERT_ON_ERROR(pthread_mutex_init (mutex, &attr));
        GTMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_destroy (&attr));
    }
#undef GTMUTEX_ASSERT_ON_ERROR
}

#pragma mark - 其他方法
/**
 Convert CFRange to NSRange
 @param range CFRange @return NSRange
 */
GT_EXTERN NSRange GTNSRangeFromCFRange(CFRange range) {
    return NSMakeRange(range.location, range.length);
}

/**
 Convert NSRange to CFRange
 @param range NSRange @return CFRange
 */
GT_EXTERN CFRange GTCFRangeFromNSRange(NSRange range) {
    return CFRangeMake(range.location, range.length);
}

/**
 Same as CFAutorelease(), compatible for iOS6
 @param arg CFObject @return same as input
 */
GT_EXTERN CFTypeRef GTCFAutorelease(CFTypeRef CF_RELEASES_ARGUMENT arg) {
    if (((long)CFAutorelease + 1) != 1) {
        return CFAutorelease(arg);
    } else {
        id __autoreleasing obj = CFBridgingRelease(arg);
        return (__bridge CFTypeRef)obj;
    }
}

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
GT_EXTERN void GTBenchmark(void (^block)(void), void (^complete)(double ms)) {
    // <QuartzCore/QuartzCore.h> version
    /*
     extern double CACurrentMediaTime (void);
     double begin, end, ms;
     begin = CACurrentMediaTime();
     block();
     end = CACurrentMediaTime();
     ms = (end - begin) * 1000.0;
     complete(ms);
     */

    // <sys/time.h> version
    struct timeval t0, t1;
    gettimeofday(&t0, NULL);
    block();
    gettimeofday(&t1, NULL);
    double ms = (double)(t1.tv_sec - t0.tv_sec) * 1e3 + (double)(t1.tv_usec - t0.tv_usec) * 1e-3;
    complete(ms);
}

GT_EXTERN NSDate *_GTCompileTime(const char *data, const char *time) {
    NSString *timeStr = [NSString stringWithFormat:@"%s %s",data,time];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd yyyy HH:mm:ss"];
    [formatter setLocale:locale];
    return [formatter dateFromString:timeStr];
}


#pragma mark - 随机数
GT_EXTERN NSInteger kRandomNumber(NSInteger i) {
    return arc4random() % i;
}

#pragma mark 字符串是否为空
GT_EXTERN BOOL kStringIsEmpty(NSString *string) {
    return ([string isKindOfClass:[NSNull class]] || string == nil || [string length] < 1);
}

#pragma mark - 判断字符串是否含有空格
GT_EXTERN BOOL kStringIsBlank(NSString *string) {
    NSCharacterSet *blank = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSInteger i = 0; i < string.length; ++i) {
        unichar c = [string characterAtIndex:i];
        if (![blank characterIsMember:c]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark 数组是否为空
GT_EXTERN BOOL kArrayIsEmpty(NSArray *array) {
    return (array == nil || [array isKindOfClass:[NSNull class]] || array.count == 0);
}

#pragma mark 字典是否为空
GT_EXTERN BOOL kDictIsEmpty(NSDictionary *dic) {
    return (dic == nil || [dic isKindOfClass:[NSNull class]] || dic.allKeys == 0);
}

#pragma mark 字典是否为空
GT_EXTERN BOOL kObjectIsEmpty(id object) {
    return (object == nil
            || [object isKindOfClass:[NSNull class]]
            || ([object respondsToSelector:@selector(length)] && [(NSData *)object length] == 0)
            || ([object respondsToSelector:@selector(count)] && [(NSArray *)object count] == 0));
}



#pragma mark - 从本地文件读取数据
GT_EXTERN NSData* kGetDataWithContentsOfFile(NSString *fileName, NSString *type){
    return [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:type]];
}

#pragma mark - json 解析 data 数据
GT_EXTERN NSDictionary* kGetDictionaryWithData(NSData *data) {
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
}

#pragma mark json 解析 ，直接从本地文件读取 json 数据，返回 NSDictionary

GT_EXTERN NSDictionary *kGetDictionaryWithContentsOfFile(NSString *fileName, NSString *type){
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:type]];
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
}

#pragma mark json 解析 ，json string 转 NSDictionary，返回 NSDictionary
GT_EXTERN NSDictionary *kGetDictionaryWithJsonString(NSString *jsonString){
    if (jsonString == nil)
    {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err)
    {
        NSLog(@"json 解析失败：%@",dict);
        return nil;
    }
    return dict;
}












#pragma mark - Decode
GT_EXTERN NSString* kDecodeObjectFromDic(NSDictionary *dic, NSString *key)
{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    id temp = [dic objectForKey:key];
    NSString *value = @"";
    if (kObjectIsEmpty(temp))   {
        if ([temp isKindOfClass:[NSString class]]) {
            value = temp;
        }else if([temp isKindOfClass:[NSNumber class]]){
            value = [temp stringValue];
        }
        return value;
    }
    return nil;
}

GT_EXTERN NSString* kDecodeDefaultStrFromDic(NSDictionary *dic, NSString *key,NSString * defaultStr)
{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    id temp = [dic objectForKey:key];
    NSString *value = defaultStr;
    if (kObjectIsEmpty(temp))   {
        if ([temp isKindOfClass:[NSString class]]) {
            value = temp;
        }else if([temp isKindOfClass:[NSNumber class]]){
            value = [temp stringValue];
        }

        return value;
    }
    return value;
}

GT_EXTERN id kDecodeSafeObjectAtIndex(NSArray *arr, NSInteger index)
{
    if (kArrayIsEmpty(arr)) {
        return nil;
    }

    if ([arr count]-1<index) {
        GTAssert([arr count]-1<index);
        return nil;
    }

    return [arr objectAtIndex:index];
}



GT_EXTERN NSString* kDecodeStringFromDic(NSDictionary *dic, NSString *key)
{
    if (kDictIsEmpty(dic))
    {
        return nil;
    }
    id temp = [dic objectForKey:key];
    if ([temp isKindOfClass:[NSString class]])
    {
        if ([temp isEqualToString:@"(null)"]) {
            return @"";
        }
        return temp;
    }
    else if ([temp isKindOfClass:[NSNumber class]])
    {
        return [temp stringValue];
    }
    return nil;
}

GT_EXTERN NSNumber* kDecodeNumberFromDic(NSDictionary *dic, NSString *key)
{
    if (kDictIsEmpty(dic))
    {
        return nil;
    }
    id temp = [dic objectForKey:key];
    if ([temp isKindOfClass:[NSString class]])
    {
        return [NSNumber numberWithDouble:[temp doubleValue]];
    }
    else if ([temp isKindOfClass:[NSNumber class]])
    {
        return temp;
    }
    return nil;
}

GT_EXTERN NSDictionary *kDecodeDicFromDic(NSDictionary *dic, NSString *key)
{
    if (kDictIsEmpty(dic))
    {
        return nil;
    }
    id temp = [dic objectForKey:key];
    if ([temp isKindOfClass:[NSDictionary class]])
    {
        return temp;
    }
    return nil;
}

GT_EXTERN NSArray      *kDecodeArrayFromDic(NSDictionary *dic, NSString *key)
{
    id temp = [dic objectForKey:key];
    if ([temp isKindOfClass:[NSArray class]])
    {
        return temp;
    }
    return nil;
}

GT_EXTERN NSArray      *kDecodeArrayFromDicUsingParseBlock(NSDictionary *dic, NSString *key, id(^parseBlock)(NSDictionary *innerDic))
{
    NSArray *tempList = kDecodeArrayFromDic(dic, key);
    if ([tempList count])
    {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:[tempList count]];
        for (NSDictionary *item in tempList)
        {
            id dto = parseBlock(item);
            if (dto) {
                [array addObject:dto];
            }
        }
        return array;
    }
    return nil;
}


#pragma mark - Encode

GT_EXTERN void kEncodeUnEmptyStrObjctToDic(NSMutableDictionary *dic,NSString *object, NSString *key)
{
    if (kDictIsEmpty(dic))
    {
        return;
    }

    if (kStringIsEmpty(object))
    {
        return;
    }

    if (kStringIsEmpty(key))
    {
        return;
    }

    [dic setObject:object forKey:key];
}

GT_EXTERN void kEncodeUnEmptyObjctToArray(NSMutableArray *arr,id object)
{
    if (kArrayIsEmpty(arr))
    {
        return;
    }

    if (kObjectIsEmpty(object))
    {
        return;
    }

    [arr addObject:object];
}

GT_EXTERN void kEncodeDefaultStrObjctToDic(NSMutableDictionary *dic,NSString *object, NSString *key,NSString * defaultStr)
{
    if (kDictIsEmpty(dic))
    {
        return;
    }

    if (kStringIsEmpty(object))
    {
        object = defaultStr;
    }

    if (kStringIsEmpty(key))
    {
        return;
    }

    [dic setObject:object forKey:key];
}

GT_EXTERN void kEncodeUnEmptyObjctToDic(NSMutableDictionary *dic,NSObject *object, NSString *key)
{
    if (kDictIsEmpty(dic))
    {
        return;
    }
    if (kObjectIsEmpty(object))
    {
        return;
    }
    if (kStringIsEmpty(key))
    {
        return;
    }

    [dic setObject:object forKey:key];
}
