//
//  ZDHHCommon.m
//

#import "ZDHHCommon.h"
#import <objc/runtime.h>
#import <objc/message.h>

NSString *const kZDHHKeyEnabled             = @"ZDHHFavoriteContactsEnabled";
NSString *const kZDHHKeyContacts            = @"ZDHHFavoriteContacts";
NSString *const kZDHHKeyAvatarSize          = @"ZDHHFavoriteAvatarSize";
NSString *const kZDHHKeyAvatarCorner        = @"ZDHHFavoriteAvatarCornerRadius";
NSString *const kZDHHKeyBadgeVOffset        = @"ZDHHFavoriteBadgeVerticalOffset";
NSString *const kZDHHKeyBadgeHOffset        = @"ZDHHFavoriteBadgeHorizontalOffset";
NSString *const kZDHHKeyShowNormalBadge     = @"ZDHHFavoriteShowNormalBadge";
NSString *const kZDHHKeyShowMuteBadge       = @"ZDHHFavoriteShowMuteBadge";
NSString *const kZDHHKeyBreathing           = @"ZDHHFavoriteAvatarBreathing";
NSString *const kZDHHKeyBreathingOnlyUnread = @"ZDHHFavoriteBreathingOnlyUnread";
NSString *const kZDHHKeyShadow              = @"ZDHHFavoriteAvatarShadow";
NSString *const kZDHHKeyShadowColorLight    = @"ZDHHFavoriteShadowBackgroundColor";
NSString *const kZDHHKeyShadowColorDark     = @"ZDHHFavoriteShadowBackgroundColorDark";
NSString *const kZDHHKeyBarPositionTop      = @"ZDHHFavoriteBarPositionTop";
NSString *const kZDHHKeySecondaryEnabled    = @"ZDHHFavoriteSecondaryBarEnabled";
NSString *const kZDHHKeySecondaryContacts   = @"ZDHHFavoriteSecondaryContacts";
NSString *const kZDHHKeyShowOnlyUnread      = @"ZDHHFavoriteShowOnlyUnread";

NSString *const ZDHHConfigChangedNotification = @"com.zdhh.favoritecontacts.changed";

#pragma mark - 安全取值

id ZDHHSafeValue(id obj, NSString *key) {
    if (!obj || !key) return nil;
    @try {
        return [obj valueForKey:key];
    } @catch (__unused NSException *e) {
        return nil;
    }
}

BOOL ZDHHSafeBool(id obj, NSString *key, BOOL fallback) {
    id v = ZDHHSafeValue(obj, key);
    if ([v respondsToSelector:@selector(boolValue)]) return [v boolValue];
    return fallback;
}

#pragma mark - 颜色

NSString *ZDHHHexFromColor(UIColor *color) {
    if (!color) return nil;
    CGFloat r = 0, g = 0, b = 0, a = 0;
    if (![color getRed:&r green:&g blue:&b alpha:&a]) {
        CGFloat w = 0;
        if ([color getWhite:&w alpha:&a]) { r = g = b = w; }
    }
    return [NSString stringWithFormat:@"%02X%02X%02X",
            (unsigned)(r * 255.0 + 0.5), (unsigned)(g * 255.0 + 0.5), (unsigned)(b * 255.0 + 0.5)];
}

UIColor *ZDHHColorFromHex(NSString *hex) {
    if (hex.length != 6) return nil;
    unsigned int v = 0;
    if (![[NSScanner scannerWithString:hex] scanHexInt:&v]) return nil;
    return [UIColor colorWithRed:((v >> 16) & 0xFF) / 255.0
                           green:((v >> 8) & 0xFF) / 255.0
                            blue:(v & 0xFF) / 255.0
                           alpha:1.0];
}

UIImage *ZDHHPlaceholderAvatarImage(NSString *name, CGFloat size) {
    if (size <= 0) size = 44.0;
    if (![name isKindOfClass:[NSString class]]) name = @"";

    UIGraphicsImageRendererFormat *fmt = [UIGraphicsImageRendererFormat defaultFormat];
    fmt.opaque = NO;
    UIGraphicsImageRenderer *renderer =
        [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(size, size) format:fmt];

    NSUInteger h = name.length ? name.hash : 0;
    CGFloat hue = (h % 360) / 360.0;
    UIColor *bg = [UIColor colorWithHue:hue saturation:0.35 brightness:0.85 alpha:1.0];

    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        [bg setFill];
        [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size, size)
                                        cornerRadius:size / 2.0] fill];

        NSString *initial = name.length ? [[name substringToIndex:1] uppercaseString] : @"?";
        NSDictionary *attrs = @{
            NSFontAttributeName: [UIFont systemFontOfSize:size * 0.42 weight:UIFontWeightSemibold],
            NSForegroundColorAttributeName: [UIColor whiteColor]
        };
        CGSize textSize = [initial sizeWithAttributes:attrs];
        [initial drawAtPoint:CGPointMake((size - textSize.width) / 2.0,
                                         (size - textSize.height) / 2.0)
              withAttributes:attrs];
    }];
}

#pragma mark - ZDHHConfig

@interface ZDHHConfig ()
@property (nonatomic, strong) NSUserDefaults *defaults;

- (BOOL)boolForKey:(NSString *)key fallback:(BOOL)fallback;
- (CGFloat)floatForKey:(NSString *)key fallback:(CGFloat)fallback;
- (void)notifyChanged;
@end

@implementation ZDHHConfig

+ (instancetype)shared {
    static ZDHHConfig *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ instance = [[ZDHHConfig alloc] init]; });
    return instance;
}

- (instancetype)init {
    if ((self = [super init])) {
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (BOOL)boolForKey:(NSString *)key fallback:(BOOL)fallback {
    id v = [self.defaults objectForKey:key];
    return v ? [self.defaults boolForKey:key] : fallback;
}

- (CGFloat)floatForKey:(NSString *)key fallback:(CGFloat)fallback {
    id v = [self.defaults objectForKey:key];
    return v ? [self.defaults floatForKey:key] : fallback;
}

#pragma mark 标量

- (BOOL)enabled              { return [self boolForKey:kZDHHKeyEnabled fallback:NO]; }
- (void)setEnabled:(BOOL)v   { [self.defaults setBool:v forKey:kZDHHKeyEnabled]; }

- (BOOL)showOnlyUnread       { return [self boolForKey:kZDHHKeyShowOnlyUnread fallback:NO]; }
- (void)setShowOnlyUnread:(BOOL)v { [self.defaults setBool:v forKey:kZDHHKeyShowOnlyUnread]; }

- (BOOL)showNormalBadge      { return [self boolForKey:kZDHHKeyShowNormalBadge fallback:YES]; }
- (void)setShowNormalBadge:(BOOL)v { [self.defaults setBool:v forKey:kZDHHKeyShowNormalBadge]; }

- (BOOL)showMuteBadge        { return [self boolForKey:kZDHHKeyShowMuteBadge fallback:YES]; }
- (void)setShowMuteBadge:(BOOL)v { [self.defaults setBool:v forKey:kZDHHKeyShowMuteBadge]; }

- (BOOL)breathing            { return [self boolForKey:kZDHHKeyBreathing fallback:NO]; }
- (void)setBreathing:(BOOL)v { [self.defaults setBool:v forKey:kZDHHKeyBreathing]; }

- (BOOL)breathingOnlyUnread  { return [self boolForKey:kZDHHKeyBreathingOnlyUnread fallback:YES]; }
- (void)setBreathingOnlyUnread:(BOOL)v { [self.defaults setBool:v forKey:kZDHHKeyBreathingOnlyUnread]; }

- (BOOL)shadow               { return [self boolForKey:kZDHHKeyShadow fallback:NO]; }
- (void)setShadow:(BOOL)v    { [self.defaults setBool:v forKey:kZDHHKeyShadow]; }

- (BOOL)barPositionTop       { return [self boolForKey:kZDHHKeyBarPositionTop fallback:YES]; }
- (void)setBarPositionTop:(BOOL)v { [self.defaults setBool:v forKey:kZDHHKeyBarPositionTop]; }

- (BOOL)secondaryEnabled     { return [self boolForKey:kZDHHKeySecondaryEnabled fallback:NO]; }
- (void)setSecondaryEnabled:(BOOL)v { [self.defaults setBool:v forKey:kZDHHKeySecondaryEnabled]; }

- (CGFloat)avatarSize        { return [self floatForKey:kZDHHKeyAvatarSize fallback:44.0]; }
- (void)setAvatarSize:(CGFloat)v { [self.defaults setFloat:v forKey:kZDHHKeyAvatarSize]; }

- (CGFloat)avatarCorner      { return [self floatForKey:kZDHHKeyAvatarCorner fallback:-1.0]; }
- (void)setAvatarCorner:(CGFloat)v { [self.defaults setFloat:v forKey:kZDHHKeyAvatarCorner]; }

- (CGFloat)badgeVOffset      { return [self floatForKey:kZDHHKeyBadgeVOffset fallback:0.0]; }
- (void)setBadgeVOffset:(CGFloat)v { [self.defaults setFloat:v forKey:kZDHHKeyBadgeVOffset]; }

- (CGFloat)badgeHOffset      { return [self floatForKey:kZDHHKeyBadgeHOffset fallback:0.0]; }
- (void)setBadgeHOffset:(CGFloat)v { [self.defaults setFloat:v forKey:kZDHHKeyBadgeHOffset]; }

/// 圆角未设置（-1）时按头像半径自动算
- (CGFloat)effectiveCorner {
    CGFloat c = self.avatarCorner;
    return c < 0 ? self.avatarSize / 2.0 : MIN(c, self.avatarSize / 2.0);
}

- (UIColor *)shadowColorLight {
    return ZDHHColorFromHex([self.defaults objectForKey:kZDHHKeyShadowColorLight]) ?: [UIColor whiteColor];
}
- (void)setShadowColorLight:(UIColor *)c {
    [self.defaults setObject:ZDHHHexFromColor(c) forKey:kZDHHKeyShadowColorLight];
}

- (UIColor *)shadowColorDark {
    return ZDHHColorFromHex([self.defaults objectForKey:kZDHHKeyShadowColorDark]) ?: [UIColor blackColor];
}
- (void)setShadowColorDark:(UIColor *)c {
    [self.defaults setObject:ZDHHHexFromColor(c) forKey:kZDHHKeyShadowColorDark];
}

#pragma mark 数组成员

- (NSArray<NSString *> *)contacts {
    id v = [self.defaults arrayForKey:kZDHHKeyContacts];
    return [v isKindOfClass:[NSArray class]] ? v : @[];
}

- (void)setContacts:(NSArray<NSString *> *)arr {
    [self.defaults setObject:(arr ?: @[]) forKey:kZDHHKeyContacts];
    [self notifyChanged];
}

- (void)addContact:(NSString *)wxid {
    if (!wxid.length) return;
    NSMutableArray *m = [self.contacts mutableCopy];
    if (![m containsObject:wxid]) {
        [m addObject:wxid];
        [self.defaults setObject:m forKey:kZDHHKeyContacts];
        [self notifyChanged];
    }
}

- (void)removeContact:(NSString *)wxid {
    if (!wxid.length) return;
    NSMutableArray *m = [self.contacts mutableCopy];
    if ([m containsObject:wxid]) {
        [m removeObject:wxid];
        [self.defaults setObject:m forKey:kZDHHKeyContacts];
        [self notifyChanged];
    }
}

- (BOOL)hasContact:(NSString *)wxid {
    return wxid.length && [self.contacts containsObject:wxid];
}

- (NSArray<NSString *> *)secondaryContacts {
    id v = [self.defaults arrayForKey:kZDHHKeySecondaryContacts];
    return [v isKindOfClass:[NSArray class]] ? v : @[];
}

- (void)setSecondaryContacts:(NSArray<NSString *> *)arr {
    [self.defaults setObject:(arr ?: @[]) forKey:kZDHHKeySecondaryContacts];
    [self notifyChanged];
}

- (void)addSecondaryContact:(NSString *)wxid {
    if (!wxid.length) return;
    NSMutableArray *m = [self.secondaryContacts mutableCopy];
    if (![m containsObject:wxid]) {
        [m addObject:wxid];
        [self.defaults setObject:m forKey:kZDHHKeySecondaryContacts];
        [self notifyChanged];
    }
}

- (void)removeSecondaryContact:(NSString *)wxid {
    if (!wxid.length) return;
    NSMutableArray *m = [self.secondaryContacts mutableCopy];
    if ([m containsObject:wxid]) {
        [m removeObject:wxid];
        [self.defaults setObject:m forKey:kZDHHKeySecondaryContacts];
        [self notifyChanged];
    }
}

- (void)notifyChanged {
    [self.defaults synchronize];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:ZDHHConfigChangedNotification object:nil];
    });
}

@end

#pragma mark - ZDHHWeChat

@interface ZDHHWeChat ()
+ (nullable id)sessionForWxid:(NSString *)wxid;
+ (nullable UIViewController *)findControllerOfClass:(Class)cls in:(nullable UIViewController *)vc;
+ (nullable UINavigationController *)firstNavigationControllerIn:(nullable UIViewController *)vc;
@end

@implementation ZDHHWeChat

+ (id)context {
    Class MMContext = NSClassFromString(@"MMContext");
    if (!MMContext) return nil;

    id ctx = nil;
    @try {
        if ([MMContext respondsToSelector:@selector(currentContext)]) {
            ctx = ((id (*)(id, SEL))objc_msgSend)(MMContext, @selector(currentContext));
        }
        if (!ctx && [MMContext respondsToSelector:@selector(activeUserContext)]) {
            ctx = ((id (*)(id, SEL))objc_msgSend)(MMContext, @selector(activeUserContext));
        }
    } @catch (__unused NSException *e) {
        ctx = nil;
    }
    return ctx;
}

+ (id)serviceOfClassNamed:(NSString *)clsName {
    Class cls = NSClassFromString(clsName);
    if (!cls) return nil;
    id ctx = [self context];
    if (!ctx) return nil;
    if (![ctx respondsToSelector:@selector(getService:)]) return nil;

    id service = nil;
    @try {
        service = ((id (*)(id, SEL, Class))objc_msgSend)(ctx, @selector(getService:), cls);
    } @catch (__unused NSException *e) {
        service = nil;
    }
    return service;
}

+ (id)contactManager {
    return [self serviceOfClassNamed:@"CContactMgr"];
}

+ (id)contactForWxid:(NSString *)wxid {
    if (!wxid.length) return nil;
    id mgr = [self contactManager];
    if (![mgr respondsToSelector:@selector(getContactByName:)]) return nil;
    id contact = nil;
    @try {
        contact = ((id (*)(id, SEL, id))objc_msgSend)(mgr, @selector(getContactByName:), wxid);
    } @catch (__unused NSException *e) {
        contact = nil;
    }
    return contact;
}

+ (NSString *)headImageURLForWxid:(NSString *)wxid {
    id contact = [self contactForWxid:wxid];
    if (!contact) return nil;

    // 新版微信把头像字段拆成多份，逐个试
    for (NSString *key in @[@"m_nsHeadImgUrl", @"m_nsHeadImgLargeUrl", @"m_nsHeadImgSmallUrl"]) {
        id v = ZDHHSafeValue(contact, key);
        if ([v isKindOfClass:[NSString class]] && [v length] > 0) return v;
    }
    return nil;
}

+ (NSString *)displayNameForWxid:(NSString *)wxid {
    id contact = [self contactForWxid:wxid];
    for (NSString *key in @[@"m_nsRemark", @"m_nsNickName", @"m_nsUserName"]) {
        id v = ZDHHSafeValue(contact, key);
        if ([v isKindOfClass:[NSString class]] && [v length] > 0) return v;
    }
    // 通讯录服务兜底
    id mgr = [self contactManager];
    if ([mgr respondsToSelector:@selector(getContactForSearchByName:)]) {
        id c = ((id (*)(id, SEL, id))objc_msgSend)(mgr, @selector(getContactForSearchByName:), wxid);
        id v = ZDHHSafeValue(c, @"m_nsNickName");
        if ([v isKindOfClass:[NSString class]] && [v length] > 0) return v;
    }
    return wxid.length ? wxid : @"";
}

+ (id)sessionForWxid:(NSString *)wxid {
    if (!wxid.length) return nil;
    id mgr = [self serviceOfClassNamed:@"MMNewSessionMgr"];
    if (!mgr) return nil;
    id sessions = ZDHHSafeValue(mgr, @"m_arrSession");
    if (![sessions isKindOfClass:[NSArray class]]) return nil;

    for (id s in (NSArray *)sessions) {
        id name = ZDHHSafeValue(s, @"m_nsUserName");
        if ([name isKindOfClass:[NSString class]] && [name isEqualToString:wxid]) return s;
    }
    return nil;
}

+ (NSUInteger)unreadCountForWxid:(NSString *)wxid {
    id s = [self sessionForWxid:wxid];
    if (!s) return 0;
    id v = ZDHHSafeValue(s, @"m_uUnReadCount");
    return [v respondsToSelector:@selector(unsignedIntValue)] ? [v unsignedIntValue] : 0;
}

+ (BOOL)isMutedForWxid:(NSString *)wxid {
    id contact = [self contactForWxid:wxid];
    if (ZDHHSafeBool(contact, @"m_bMute", NO)) return YES;
    if (ZDHHSafeBool(contact, @"m_bDisturb", NO)) return YES;

    id s = [self sessionForWxid:wxid];
    if (ZDHHSafeBool(s, @"m_bMute", NO)) return YES;
    return NO;
}

+ (BOOL)openChatWithWxid:(NSString *)wxid fromController:(UIViewController *)vc {
    if (!wxid.length) return NO;

    id contact = [self contactForWxid:wxid];
    Class Logic = NSClassFromString(@"MMMsgLogicManager");
    if (!Logic) return NO;

    id logic = nil;
    if ([Logic respondsToSelector:@selector(sharedInstance)]) {
        logic = ((id (*)(id, SEL))objc_msgSend)(Logic, @selector(sharedInstance));
    }
    if (!logic) {
        @try { logic = [[Logic alloc] init]; } @catch (__unused NSException *e) { logic = nil; }
    }
    if (!logic) return NO;
    if (![logic respondsToSelector:@selector(GenOtherBaseMsgControllerByContact:searchScene:extraInfo:)]) return NO;

    id chatVC = nil;
    @try {
        chatVC = ((id (*)(id, SEL, id, NSUInteger, id))objc_msgSend)(
            logic,
            @selector(GenOtherBaseMsgControllerByContact:searchScene:extraInfo:),
            contact, 0, nil);
    } @catch (__unused NSException *e) {
        chatVC = nil;
    }
    if (!chatVC) return NO;

    UINavigationController *nav = [self topNavigationController];
    if (nav) {
        [nav pushViewController:chatVC animated:YES];
        return YES;
    }
    [vc presentViewController:chatVC animated:YES completion:nil];
    return YES;
}

+ (UINavigationController *)topNavigationController {
    UIWindow *keyWindow = nil;
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) continue;
        for (UIWindow *w in ((UIWindowScene *)scene).windows) {
            if (w.isKeyWindow) { keyWindow = w; break; }
        }
        if (keyWindow) break;
    }
    if (!keyWindow) {
        keyWindow = [UIApplication sharedApplication].keyWindow;
    }

    UIViewController *root = keyWindow.rootViewController;
    while (root.presentedViewController) root = root.presentedViewController;

    if ([root isKindOfClass:[UINavigationController class]]) return (UINavigationController *)root;
    if ([root isKindOfClass:[UITabBarController class]]) {
        UIViewController *sel = ((UITabBarController *)root).selectedViewController;
        if ([sel isKindOfClass:[UINavigationController class]]) return (UINavigationController *)sel;
    }
    if (root.navigationController) return root.navigationController;

    // 兜底：沿子控制器找第一个导航控制器
    return [self firstNavigationControllerIn:root];
}

+ (UINavigationController *)firstNavigationControllerIn:(UIViewController *)vc {
    if (!vc) return nil;
    if ([vc isKindOfClass:[UINavigationController class]]) return (UINavigationController *)vc;
    for (UIViewController *child in vc.childViewControllers) {
        UINavigationController *found = [self firstNavigationControllerIn:child];
        if (found) return found;
    }
    return nil;
}

+ (UITableView *)mainTableView {
    Class cls = NSClassFromString(@"NewMainFrameViewController");
    if (!cls) return nil;

    UIViewController *root = [self topNavigationController].viewControllers.firstObject;
    UIViewController *target = nil;

    if ([root isKindOfClass:cls]) {
        target = root;
    } else {
        target = [self findControllerOfClass:cls in:[UIApplication sharedApplication].keyWindow.rootViewController];
    }
    if (!target) return nil;

    id tv = ZDHHSafeValue(target, @"m_tableView");
    if ([tv isKindOfClass:[UITableView class]]) return tv;

    for (UIView *v in target.view.subviews) {
        if ([v isKindOfClass:[UITableView class]]) return (UITableView *)v;
    }
    return nil;
}

+ (UIViewController *)findControllerOfClass:(Class)cls in:(UIViewController *)vc {
    if (!vc) return nil;
    if ([vc isKindOfClass:cls]) return vc;
    for (UIViewController *child in vc.childViewControllers) {
        UIViewController *f = [self findControllerOfClass:cls in:child];
        if (f) return f;
    }
    if (vc.presentedViewController) {
        return [self findControllerOfClass:cls in:vc.presentedViewController];
    }
    return nil;
}

+ (NSString *)weChatVersion {
    static NSString *cached = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        cached = info[@"CFBundleShortVersionString"] ?: @"unknown";
    });
    return cached;
}

@end
