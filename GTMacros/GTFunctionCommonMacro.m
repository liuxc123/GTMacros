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
GT_EXTERN bool kObjc_ReplaceMethodInTwoClasses(Class _fromClass, SEL _originSelector, Class _toClass, SEL _newSelector) {
    if (!_fromClass || !_toClass) {
        return NO;
    }

    Method oriMethod = class_getInstanceMethod(_fromClass, _originSelector);
    Method newMethod = class_getInstanceMethod(_toClass, _newSelector);
    if (!newMethod) {
        return NO;
    }

    Class superclass = class_getSuperclass(_fromClass);
    BOOL tryToExchangeSuperclassMethod = [superclass instancesRespondToSelector:_originSelector] && (class_getInstanceMethod(superclass, _originSelector) == class_getInstanceMethod(_fromClass, _originSelector));
    if (tryToExchangeSuperclassMethod) {
        NSLog(@"注意，%@ 准备替换方法 %@, 但这个方法来自于父类 %@", NSStringFromClass(_fromClass), NSStringFromSelector(_originSelector), NSStringFromClass(superclass));
    }

    BOOL isAddedMethod = class_addMethod(_fromClass, _originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        // 如果 class_addMethod 成功了，说明之前 fromClass 里并不存在 originSelector，所以要用一个空的方法代替它，以避免 class_replaceMethod 后，后续 toClass 的这个方法被调用时可能会 crash
        IMP oriMethodIMP = method_getImplementation(oriMethod) ?: imp_implementationWithBlock(^(id selfObject) {});
        const char *oriMethodTypeEncoding = method_getTypeEncoding(oriMethod) ?: "v@:";
        class_replaceMethod(_toClass, _newSelector, oriMethodIMP, oriMethodTypeEncoding);
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
    return YES;
}

#pragma mark runtime method A -> B
/// 交换同一个 class 里的 originSelector 和 newSelector 的实现，如果原本不存在 originSelector，则相当于给 class 新增一个叫做 originSelector 的方法
GT_EXTERN bool kObjc_ReplaceMethod(Class _class, SEL _originSelector, SEL _newSelector) {
    return kObjc_ReplaceMethodInTwoClasses(_class, _originSelector, _class, _newSelector);
}


/**
 *  用 block 重写某个 class 的指定方法
 *  @param targetClass 要重写的 class
 *  @param targetSelector 要重写的 class 里的实例方法，注意如果该方法不存在于 targetClass 里，则什么都不做
 *  @param implementationBlock 该 block 必须返回一个 block，返回的 block 将被当成 targetSelector 的新实现，所以要在内部自己处理对 super 的调用，以及对当前调用方法的 self 的 class 的保护判断（因为如果 targetClass 的 targetSelector 是继承自父类的，targetClass 内部并没有重写这个方法，则我们这个函数最终重写的其实是父类的 targetSelector，所以会产生预期之外的 class 的影响，例如 targetClass 传进来  UIButton.class，则最终可能会影响到 UIView.class），implementationBlock 的参数里第一个为你要修改的 class，也即等同于 targetClass，第二个参数为你要修改的 selector，也即等同于 targetSelector，第三个参数是 targetSelector 原本的实现，由于 IMP 可以直接当成 C 函数调用，所以可利用它来实现“调用 super”的效果，但由于 targetSelector 的参数个数、参数类型、返回值类型，都会影响 IMP 的调用写法，所以这个调用只能由业务自己写。
 */
GT_EXTERN bool kObjc_OverrideImplementation(Class targetClass, SEL targetSelector, id (^implementationBlock)(Class originClass, SEL originCMD, IMP originIMP)) {
    Method originMethod = class_getInstanceMethod(targetClass, targetSelector);
    if (!originMethod) {
        return NO;
    }
    IMP originIMP = method_getImplementation(originMethod);
    method_setImplementation(originMethod, imp_implementationWithBlock(implementationBlock(targetClass, targetSelector, originIMP)));
    return YES;
}

/**
 *  用 block 重写某个 class 的某个无参数且返回值为 void 的方法，会自动在调用 block 之前先调用该方法原本的实现。
 *  @param targetClass 要重写的 class
 *  @param targetSelector 要重写的 class 里的实例方法，注意如果该方法不存在于 targetClass 里，则什么都不做，注意该方法必须无参数，返回值为 void
 *  @param implementationBlock targetSelector 的自定义实现，直接将你的实现写进去即可，不需要管 super 的调用。参数 selfObject 代表当前正在调用这个方法的对象，也即 self 指针。
 */
GT_EXTERN BOOL kObjc_ExtendImplementationOfVoidMethodWithoutArguments(Class targetClass, SEL targetSelector, void (^implementationBlock)(__kindof NSObject *selfObject)) {
    return kObjc_OverrideImplementation(targetClass, targetSelector, ^id(Class originClass, SEL originCMD, IMP originIMP) {
        return ^(__kindof NSObject *selfObject) {

            void (*originSelectorIMP)(id, SEL);
            originSelectorIMP = (void (*)(id, SEL))originIMP;
            originSelectorIMP(selfObject, originCMD);

            if (![selfObject isKindOfClass:originClass]) return;

            implementationBlock(selfObject);
        };
    });
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
