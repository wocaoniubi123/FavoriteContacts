// 桩头文件：仅用于 libclang 语法/语义检查，不含实现。
#pragma once

#include <stddef.h>
#include <stdint.h>

#pragma mark - 基础类型

typedef signed char BOOL;
#define YES ((BOOL)1)
#define NO ((BOOL)0)
#ifndef nil
#define nil ((id)0)
#endif
#ifndef Nil
#define Nil ((Class)0)
#endif

typedef long NSInteger;
typedef unsigned long NSUInteger;
typedef double CGFloat;
typedef unsigned short unichar;
typedef unsigned long UTF32Char;

#define NS_ENUM(_type, _name) _type _name; enum
#define NS_OPTIONS(_type, _name) _type _name; enum
#define NS_ASSUME_NONNULL_BEGIN
#define NS_ASSUME_NONNULL_END
#define FOUNDATION_EXPORT extern
#ifndef __unused
#define __unused __attribute__((unused))
#endif

@class NSString, NSArray, NSDictionary, NSData, NSNumber, NSError, NSURL;
@class NSURLSession, NSURLSessionDataTask, NSURLResponse, NSIndexPath, NSIndexSet;
@class NSUserDefaults, NSNotification, NSNotificationCenter, NSCache, NSException;
@class NSFileManager, NSScanner, NSValue, NSCharacterSet, NSBundle, NSDate;
#define NS_SWIFT_NAME(x)
#define API_AVAILABLE(...)
#define API_UNAVAILABLE(...)
#define NS_REFINED_FOR_SWIFT
#define NS_DESIGNATED_INITIALIZER
#define NS_UNAVAILABLE
#define NS_TYPED_EXTENSIBLE_ENUM

#ifndef MIN
#define MIN(a, b) ((a) < (b) ? (a) : (b))
#endif
#ifndef MAX
#define MAX(a, b) ((a) > (b) ? (a) : (b))
#endif
#ifndef ABS
#define ABS(a) ((a) < 0 ? -(a) : (a))
#endif

#pragma mark - 几何

typedef struct CGPoint { CGFloat x; CGFloat y; } CGPoint;
typedef struct CGSize { CGFloat width; CGFloat height; } CGSize;
typedef struct CGRect { CGPoint origin; CGSize size; } CGRect;
typedef struct CGVector { CGFloat dx; CGFloat dy; } CGVector;
typedef struct CGAffineTransform { CGFloat a, b, c, d, tx, ty; } CGAffineTransform;
typedef struct UIEdgeInsets { CGFloat top, left, bottom, right; } UIEdgeInsets;

extern const CGPoint CGPointZero;
extern const CGSize CGSizeZero;
extern const CGRect CGRectZero;
extern const UIEdgeInsets UIEdgeInsetsZero;

static inline CGPoint CGPointMake(CGFloat x, CGFloat y) { CGPoint p; p.x = x; p.y = y; return p; }
static inline CGSize CGSizeMake(CGFloat w, CGFloat h) { CGSize s; s.width = w; s.height = h; return s; }
static inline CGRect CGRectMake(CGFloat x, CGFloat y, CGFloat w, CGFloat h) {
    CGRect r; r.origin.x = x; r.origin.y = y; r.size.width = w; r.size.height = h; return r;
}
static inline UIEdgeInsets UIEdgeInsetsMake(CGFloat t, CGFloat l, CGFloat b, CGFloat r) {
    UIEdgeInsets i; i.top = t; i.left = l; i.bottom = b; i.right = r; return i;
}
static inline CGFloat CGRectGetMinX(CGRect r) { return r.origin.x; }
static inline CGFloat CGRectGetMinY(CGRect r) { return r.origin.y; }
static inline CGFloat CGRectGetMaxX(CGRect r) { return r.origin.x + r.size.width; }
static inline CGFloat CGRectGetMaxY(CGRect r) { return r.origin.y + r.size.height; }
static inline CGFloat CGRectGetWidth(CGRect r) { return r.size.width; }
static inline CGFloat CGRectGetHeight(CGRect r) { return r.size.height; }
static inline CGFloat CGRectGetMidX(CGRect r) { return r.origin.x + r.size.width / 2.0; }
static inline CGFloat CGRectGetMidY(CGRect r) { return r.origin.y + r.size.height / 2.0; }
static inline BOOL CGRectEqualToRect(CGRect a, CGRect b) { return NO; }

#pragma mark - 运行时（objc/runtime.h 的桩在这里一并声明）

typedef struct objc_object *id;
typedef struct objc_selector *SEL;
typedef struct objc_class *Class;
typedef id (*IMP)(id, SEL, ...);
typedef struct objc_method *Method;
typedef struct objc_ivar *Ivar;
typedef struct objc_property *objc_property_t;
typedef struct objc_category *Category;

struct objc_object { Class isa; };

Class objc_getClass(const char *name);
id objc_getMetaClass(const char *name);
Class NSClassFromString(NSString *aClassName);
NSString *NSStringFromClass(Class aClass);
SEL NSSelectorFromString(NSString *aSelectorName);
NSString *NSStringFromSelector(SEL aSelector);
void NSLog(NSString *format, ...);
void NSLogv(NSString *format, void *args);
Class object_getClass(id obj);
const char *class_getName(Class cls);
Class class_getSuperclass(Class cls);
Method class_getInstanceMethod(Class cls, SEL name);
Method class_getClassMethod(Class cls, SEL name);
IMP class_getMethodImplementation(Class cls, SEL name);
IMP class_getMethodImplementation_stret(Class cls, SEL name);
Method *class_copyMethodList(Class cls, unsigned int *outCount);
BOOL class_addMethod(Class cls, SEL name, IMP imp, const char *types);
BOOL class_addIvar(Class cls, const char *name, size_t size, uint8_t alignment, const char *types);
Ivar class_getInstanceVariable(Class cls, const char *name);
objc_property_t *class_copyPropertyList(Class cls, unsigned int *outCount);
SEL method_getName(Method m);
IMP method_getImplementation(Method m);
const char *method_getTypeEncoding(Method m);
IMP method_setImplementation(Method m, IMP imp);
void method_exchangeImplementations(Method m1, Method m2);
const char *property_getName(objc_property_t p);
const char *property_getAttributes(objc_property_t p);
id objc_msgSend(id self, SEL op, ...);
SEL sel_registerName(const char *str);
const char *sel_getName(SEL sel);
BOOL sel_isEqual(SEL lhs, SEL rhs);
id objc_getAssociatedObject(id object, const void *key);
void objc_setAssociatedObject(id object, const void *key, id value, uintptr_t policy);
void objc_removeAssociatedObjects(id object);
Class objc_allocateClassPair(Class superclass, const char *name, size_t extraBytes);
void objc_registerClassPair(Class cls);
id objc_retain(id obj);
void objc_release(id obj);
id objc_autorelease(id obj);
id objc_autoreleaseReturnValue(id obj);
id objc_retainAutorelease(id obj);
id objc_retainAutoreleaseReturnValue(id obj);
id objc_retainAutoreleasedReturnValue(id obj);
void objc_storeStrong(id *object, id value);
void objc_destroyWeak(id *object);
id objc_loadWeakRetained(id *object);
id objc_initWeak(id *object, id value);
id objc_storeWeak(id *object, id value);
id objc_copyWeak(id *to, id *from);
void objc_enumerationMutation(id obj);
void objc_begin_catch(void *exc_buf);
void objc_end_catch(void);
void objc_exception_throw(id exception);

typedef NS_ENUM(uintptr_t, objc_AssociationPolicy) {
    OBJC_ASSOCIATION_ASSIGN = 0,
    OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1,
    OBJC_ASSOCIATION_COPY_NONATOMIC = 3,
    OBJC_ASSOCIATION_RETAIN = 01401,
    OBJC_ASSOCIATION_COPY = 01403
};

#define OBJC_ASSOCIATION_RETAIN_NONATOMIC_ OBJC_ASSOCIATION_RETAIN_NONATOMIC

#pragma mark - dispatch

typedef struct dispatch_queue_s *dispatch_queue_t;
typedef struct dispatch_time_s *dispatch_time_t;
typedef long dispatch_once_t;
typedef void (^dispatch_block_t)(void);
extern dispatch_queue_t dispatch_get_main_queue(void);
extern dispatch_queue_t dispatch_get_global_queue(long identifier, unsigned long flags);
extern void dispatch_async(dispatch_queue_t queue, dispatch_block_t block);
extern void dispatch_sync(dispatch_queue_t queue, dispatch_block_t block);
extern void dispatch_once(dispatch_once_t *predicate, dispatch_block_t block);
extern dispatch_time_t dispatch_time(dispatch_time_t when, int64_t delta);
extern void dispatch_after(dispatch_time_t when, dispatch_queue_t queue, dispatch_block_t block);
#define DISPATCH_TIME_NOW 0ull
#define NSEC_PER_SEC 1000000000ull
#define QOS_CLASS_UTILITY 0x11
#define QOS_CLASS_DEFAULT 0x15

#pragma mark - 基础协议

@protocol NSObject
- (BOOL)isEqual:(id)object;
@property (readonly) NSUInteger hash;
@property (readonly) Class superclass;
- (Class)class;
- (id)performSelector:(SEL)aSelector;
- (id)performSelector:(SEL)aSelector withObject:(id)object;
- (id)performSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2;
- (BOOL)isProxy;
- (BOOL)isKindOfClass:(Class)aClass;
- (BOOL)isMemberOfClass:(Class)aClass;
- (BOOL)conformsToProtocol:(id)aProtocol;
- (BOOL)respondsToSelector:(SEL)aSelector;
- (id)retain;
- (oneway void)release;
- (id)autorelease;
- (NSUInteger)retainCount;
- (id)description;
@end

@protocol NSCopying
- (id)copyWithZone:(void *)zone;
@end

@protocol NSMutableCopying
- (id)mutableCopyWithZone:(void *)zone;
@end

@protocol NSCoding
@end

@protocol NSFastEnumeration
- (NSUInteger)countByEnumeratingWithState:(void *)state
                                  objects:(id __unsafe_unretained [])buffer
                                    count:(NSUInteger)len;
@end

typedef struct {
    unsigned long state;
    id __unsafe_unretained *itemsPtr;
    unsigned long *mutationsPtr;
    unsigned long extra[5];
} NSFastEnumerationState;

#pragma mark - NSObject

@interface NSObject <NSObject>
+ (instancetype)alloc;
+ (instancetype)new;
+ (Class)class;
+ (Class)superclass;
+ (BOOL)instancesRespondToSelector:(SEL)aSelector;
+ (BOOL)resolveInstanceMethod:(SEL)sel;
+ (BOOL)resolveClassMethod:(SEL)sel;
- (instancetype)init;
- (void)dealloc;
- (id)copy;
- (id)mutableCopy;
- (void)forwardInvocation:(id)invocation;
- (id)methodSignatureForSelector:(SEL)sel;
- (void)doesNotRecognizeSelector:(SEL)sel;
- (id)valueForKey:(NSString *)key;
- (void)setValue:(id)value forKey:(NSString *)key;
- (void)addObserver:(id)observer forKeyPath:(NSString *)kp options:(NSUInteger)opt context:(void *)ctx;
- (void)removeObserver:(id)observer forKeyPath:(NSString *)kp;
@end

#pragma mark - 字符串 / 集合

@interface NSString : NSObject <NSCopying, NSMutableCopying>
@property (readonly) NSUInteger length;
+ (instancetype)string;
+ (instancetype)stringWithFormat:(NSString *)format, ...;
+ (instancetype)stringWithUTF8String:(const char *)s;
+ (instancetype)stringWithCString:(const char *)s encoding:(NSUInteger)enc;
- (BOOL)isEqualToString:(NSString *)aString;
- (BOOL)hasSuffix:(NSString *)str;
- (BOOL)hasPrefix:(NSString *)str;
- (NSString *)stringByAppendingString:(NSString *)aString;
- (NSString *)stringByAppendingPathComponent:(NSString *)str;
- (NSString *)stringByDeletingPathExtension;
- (NSString *)stringByTrimmingCharactersInSet:(id)set;
- (NSString *)substringToIndex:(NSUInteger)to;
- (NSString *)uppercaseString;
- (NSString *)lowercaseString;
- (unichar)characterAtIndex:(NSUInteger)index;
- (double)doubleValue;
- (float)floatValue;
- (int)intValue;
- (NSInteger)integerValue;
- (long long)longLongValue;
- (NSData *)dataUsingEncoding:(NSUInteger)encoding;
- (CGSize)sizeWithAttributes:(NSDictionary *)attrs;
- (void)drawAtPoint:(CGPoint)point withAttributes:(NSDictionary *)attrs;
- (const char *)UTF8String;
@property (readonly) NSString *lastPathComponent;
- (NSUInteger)lengthOfBytesUsingEncoding:(NSUInteger)enc;
@end

@interface NSMutableString : NSString
+ (instancetype)string;
- (void)appendString:(NSString *)aString;
- (void)appendFormat:(NSString *)format, ...;
@end

@interface NSArray<__covariant T> : NSObject <NSCopying, NSMutableCopying, NSFastEnumeration>
@property (readonly) NSUInteger count;
@property (readonly) T firstObject;
@property (readonly) T lastObject;
+ (instancetype)array;
+ (instancetype)arrayWithObject:(T)obj;
+ (instancetype)arrayWithObjects:(const T [])objects count:(NSUInteger)cnt;
+ (instancetype)arrayWithArray:(NSArray<T> *)other;
- (T)objectAtIndex:(NSUInteger)index;
- (T)objectAtIndexedSubscript:(NSUInteger)idx;
- (BOOL)containsObject:(T)anObject;
- (NSUInteger)indexOfObject:(T)anObject;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained [])buffer
                                    count:(NSUInteger)len;
@end

@interface NSMutableArray<T> : NSArray<T>
+ (instancetype)arrayWithCapacity:(NSUInteger)n;
- (void)addObject:(T)anObject;
- (void)insertObject:(T)anObject atIndex:(NSUInteger)index;
- (void)removeObject:(T)anObject;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeAllObjects;
- (void)removeObjectsInRange:(void *)range;
@end

@interface NSDictionary<__covariant K, __covariant V> : NSObject <NSCopying, NSMutableCopying, NSFastEnumeration>
@property (readonly) NSUInteger count;
+ (instancetype)dictionary;
+ (instancetype)dictionaryWithObject:(V)obj forKey:(K)key;
+ (instancetype)dictionaryWithObjects:(const V [])objects forKeys:(const K [])keys count:(NSUInteger)cnt;
- (V)objectForKey:(K)aKey;
- (V)objectForKeyedSubscript:(K)key;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained [])buffer
                                    count:(NSUInteger)len;
@end

@interface NSMutableDictionary<K, V> : NSDictionary<K, V>
+ (instancetype)dictionaryWithCapacity:(NSUInteger)n;
- (void)setObject:(V)anObject forKey:(K)aKey;
- (void)setObject:(V)obj forKeyedSubscript:(K)key;
- (void)removeObjectForKey:(K)aKey;
- (void)removeAllObjects;
@end

@interface NSNumber : NSObject <NSCopying>
+ (NSNumber *)numberWithInt:(int)value;
+ (NSNumber *)numberWithUnsignedInt:(unsigned int)value;
+ (NSNumber *)numberWithInteger:(NSInteger)value;
+ (NSNumber *)numberWithUnsignedInteger:(NSUInteger)value;
+ (NSNumber *)numberWithLongLong:(long long)value;
+ (NSNumber *)numberWithDouble:(double)value;
+ (NSNumber *)numberWithFloat:(float)value;
+ (NSNumber *)numberWithBool:(BOOL)value;
- (int)intValue;
- (unsigned int)unsignedIntValue;
- (NSInteger)integerValue;
- (long long)longLongValue;
- (double)doubleValue;
- (float)floatValue;
- (BOOL)boolValue;
@end

@interface NSData : NSObject
@property (readonly) NSUInteger length;
@property (readonly) const void *bytes;
+ (instancetype)data;
+ (instancetype)dataWithBytes:(const void *)bytes length:(NSUInteger)length;
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;
+ (instancetype)dataWithContentsOfFile:(NSString *)path;
@end

@interface NSMutableData : NSData
@end

@interface NSError : NSObject
@property (readonly) NSInteger code;
@property (readonly) NSString *domain;
@end

@interface NSException : NSObject
@property (readonly, copy) NSString *name;
@property (readonly, copy) NSString *reason;
+ (NSException *)exceptionWithName:(NSString *)name reason:(NSString *)reason userInfo:(id)userInfo;
@end

@interface NSURL : NSObject
+ (instancetype)URLWithString:(NSString *)URLString;
@property (readonly, copy) NSString *absoluteString;
@property (readonly, copy) NSURL *standardizedURL;
@end

@interface NSURLResponse : NSObject
@end

@interface NSURLSessionDataTask : NSObject
- (void)resume;
- (void)cancel;
@end

@interface NSURLSession : NSObject
+ (NSURLSession *)sharedSession;
- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url
                        completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
- (NSURLSessionDataTask *)dataTaskWithRequest:(id)request
                            completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
@end

@interface NSUserDefaults : NSObject
+ (NSUserDefaults *)standardUserDefaults;
- (BOOL)boolForKey:(NSString *)defaultName;
- (float)floatForKey:(NSString *)defaultName;
- (double)doubleForKey:(NSString *)defaultName;
- (NSInteger)integerForKey:(NSString *)defaultName;
- (void)setBool:(BOOL)value forKey:(NSString *)defaultName;
- (void)setFloat:(float)value forKey:(NSString *)defaultName;
- (void)setDouble:(double)value forKey:(NSString *)defaultName;
- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName;
- (void)setObject:(id)value forKey:(NSString *)defaultName;
- (void)removeObjectForKey:(NSString *)defaultName;
- (id)objectForKey:(NSString *)defaultName;
- (NSArray *)arrayForKey:(NSString *)defaultName;
- (NSDictionary *)dictionaryForKey:(NSString *)defaultName;
- (BOOL)synchronize;
@end

@interface NSNotification : NSObject
@property (readonly, copy) NSString *name;
@property (readonly) id object;
@end

@interface NSNotificationCenter : NSObject
+ (NSNotificationCenter *)defaultCenter;
- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject;
- (void)removeObserver:(id)observer name:(NSString *)aName object:(id)anObject;
- (void)removeObserver:(id)observer;
- (void)postNotificationName:(NSString *)aName object:(id)anObject;
- (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(id)userInfo;
@end

@interface NSCache<__covariant KeyType, __covariant ObjectType> : NSObject
@property NSUInteger countLimit;
@property NSUInteger totalCostLimit;
- (ObjectType)objectForKey:(KeyType)key;
- (void)setObject:(ObjectType)obj forKey:(KeyType)key;
- (void)setObject:(ObjectType)obj forKey:(KeyType)key cost:(NSUInteger)g;
- (void)removeObjectForKey:(KeyType)key;
- (void)removeAllObjects;
@end

@interface NSFileManager : NSObject
+ (NSFileManager *)defaultManager;
- (BOOL)fileExistsAtPath:(NSString *)path;
- (BOOL)createDirectoryAtPath:(NSString *)path
  withIntermediateDirectories:(BOOL)createIntermediates
                   attributes:(NSDictionary *)attributes
                        error:(NSError **)error;
- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error;
@end

FOUNDATION_EXPORT NSArray<NSString *> *NSSearchPathForDirectoriesInDomains(NSUInteger directory, NSUInteger domainMask, BOOL expandTilde);
#define NSDocumentDirectory 9
#define NSCachesDirectory 13
#define NSUserDomainMask 1

@interface NSScanner : NSObject
+ (instancetype)scannerWithString:(NSString *)string;
- (BOOL)scanHexInt:(unsigned int *)result;
- (BOOL)scanInt:(int *)result;
@end

@interface NSIndexPath : NSObject
+ (instancetype)indexPathForRow:(NSInteger)row inSection:(NSInteger)section;
@property (readonly) NSInteger row;
@property (readonly) NSInteger section;
@end

@interface NSIndexSet : NSObject
+ (instancetype)indexSetWithIndex:(NSUInteger)value;
@property (readonly) NSUInteger count;
@end

@interface NSMutableIndexSet : NSIndexSet
- (void)addIndex:(NSUInteger)value;
@end

@interface NSValue : NSObject
+ (NSValue *)valueWithCGSize:(CGSize)size;
+ (NSValue *)valueWithCGRect:(CGRect)rect;
+ (NSValue *)valueWithNonretainedObject:(id)anObject;
@property (readonly) CGSize CGSizeValue;
@property (readonly) CGRect CGRectValue;
@end

@interface NSCharacterSet : NSObject
+ (NSCharacterSet *)whitespaceAndNewlineCharacterSet;
+ (NSCharacterSet *)whitespaceCharacterSet;
@end

@interface NSBundle : NSObject
+ (NSBundle *)mainBundle;
@property (readonly) NSDictionary *infoDictionary;
@property (readonly) NSString *bundlePath;
- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext;
@end

@interface NSDate : NSObject
+ (instancetype)date;
@property (readonly) double timeIntervalSince1970;
@end

#pragma mark - CoreFoundation 常用

typedef const void *CFTypeRef;
typedef const struct __CFString *CFStringRef;
typedef const struct __CFData *CFDataRef;
typedef const struct __CFDictionary *CFDictionaryRef;
typedef struct __CFAllocator *CFAllocatorRef;
extern const CFAllocatorRef kCFAllocatorNull;
