//
//  ZDHHFavoriteBar.m
//

#import "ZDHHFavoriteBar.h"
#import "ZDHHCommon.h"
#import <objc/message.h>
#import <math.h>

static const NSInteger kZDHHBarTag        = 0x5A444848;  // 'ZDHH'
static const NSInteger kZDHHBadgeTag      = 0x5A444842;  // 'ZDHB'
static const CGFloat   kZDHHBarHPadding   = 12.0;
static const CGFloat   kZDHHBarAvatarGap  = 10.0;
static const CGFloat   kZDHHBarVPadding   = 10.0;   // 原版实测：上下各 10
static const CGFloat   kZDHHBarBottomGap  = 8.0;    // 原版实测：双行时底部额外 8
static const CGFloat   kZDHHBarRowGap     = 10.0;   // 原版实测：两行之间 10

#pragma mark - 头像缓存

@interface ZDHHAvatarCache : NSObject
+ (instancetype)shared;
- (nullable UIImage *)memoryImageForKey:(NSString *)key;
- (void)setMemoryImage:(UIImage *)img forKey:(NSString *)key;
- (nullable UIImage *)diskImageForKey:(NSString *)key;
- (void)storeImage:(UIImage *)img forKey:(NSString *)key;
@end

@implementation ZDHHAvatarCache {
    NSCache<NSString *, UIImage *> *_mem;
    NSString *_dir;
}

+ (instancetype)shared {
    static ZDHHAvatarCache *o = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ o = [[ZDHHAvatarCache alloc] init]; });
    return o;
}

- (instancetype)init {
    if ((self = [super init])) {
        _mem = [[NSCache alloc] init];
        _mem.countLimit = 200;
        NSString *caches = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        _dir = [caches stringByAppendingPathComponent:@"ZDHHFavoriteContacts"];
        [[NSFileManager defaultManager] createDirectoryAtPath:_dir
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:NULL];
    }
    return self;
}

- (NSString *)safeNameForKey:(NSString *)key {
    NSMutableString *s = [NSMutableString string];
    for (NSUInteger i = 0; i < key.length; i++) {
        unichar c = [key characterAtIndex:i];
        if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') ||
            (c >= '0' && c <= '9') || c == '_' || c == '-') {
            [s appendFormat:@"%C", c];
        } else {
            [s appendFormat:@"_%04x", c];
        }
    }
    return s.length ? s : @"empty";
}

- (NSString *)pathForKey:(NSString *)key {
    return [_dir stringByAppendingPathComponent:[[self safeNameForKey:key] stringByAppendingString:@".png"]];
}

- (UIImage *)memoryImageForKey:(NSString *)key {
    return key.length ? [_mem objectForKey:key] : nil;
}

- (void)setMemoryImage:(UIImage *)img forKey:(NSString *)key {
    if (img && key.length) [_mem setObject:img forKey:key];
}

- (UIImage *)diskImageForKey:(NSString *)key {
    if (!key.length) return nil;
    NSString *path = [self pathForKey:key];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return nil;
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    if (img) [_mem setObject:img forKey:key];
    return img;
}

- (void)storeImage:(UIImage *)img forKey:(NSString *)key {
    if (!img || !key.length) return;
    [_mem setObject:img forKey:key];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        NSData *data = UIImagePNGRepresentation(img);
        if (data) [data writeToFile:[self pathForKey:key] atomically:YES];
    });
}

@end

#pragma mark - 头像单元格

@interface ZDHHAvatarCell : UIControl
@property (nonatomic, copy) NSString *wxid;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong, nullable) UIView *badgeView;   // 微信 MMBadgeView 或自绘容器
@property (nonatomic, strong, nullable) UILabel *badgeLabel;
@property (nonatomic, strong, nullable) UIView *badgeDot;
@property (nonatomic, assign) BOOL muted;
@end

@implementation ZDHHAvatarCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _avatarView = [[UIImageView alloc] initWithFrame:self.bounds];
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarView.clipsToBounds = YES;
        _avatarView.userInteractionEnabled = NO;
        [self addSubview:_avatarView];

        self.accessibilityTraits = UIAccessibilityTraitButton;
        self.isAccessibilityElement = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    ZDHHConfig *cfg = [ZDHHConfig shared];
    CGFloat corner = [cfg effectiveCorner];

    self.avatarView.frame = self.bounds;
    self.avatarView.layer.cornerRadius = corner;
    self.avatarView.layer.masksToBounds = YES;

    // 容器本身不裁切，阴影才有地方投射（原版 setMasksToBounds:NO）
    self.layer.cornerRadius = corner;
    self.layer.masksToBounds = NO;

    if (self.badgeView) {
        CGSize s = self.badgeView.bounds.size;
        if (s.width <= 0 || s.height <= 0) s = CGSizeMake(16.0, 16.0);
        self.badgeView.frame = CGRectMake(
            CGRectGetMaxX(self.bounds) - s.width + cfg.badgeHOffset,
            CGRectGetMinY(self.bounds) - s.height / 2.0 + cfg.badgeVOffset,
            s.width, s.height);
    }

    if (self.badgeLabel) {
        [self.badgeLabel sizeToFit];
        CGSize s = self.badgeLabel.bounds.size;
        CGFloat w = MAX(s.width + 8.0, 16.0);
        CGFloat h = 16.0;
        self.badgeLabel.frame = CGRectMake(
            CGRectGetMaxX(self.bounds) - w + cfg.badgeHOffset,
            CGRectGetMinY(self.bounds) - h / 2.0 + cfg.badgeVOffset,
            w, h);
        self.badgeLabel.layer.cornerRadius = h / 2.0;
    }
    if (self.badgeDot) {
        CGFloat d = 10.0;
        self.badgeDot.frame = CGRectMake(
            CGRectGetMaxX(self.bounds) - d + cfg.badgeHOffset,
            CGRectGetMinY(self.bounds) - d / 2.0 + cfg.badgeVOffset,
            d, d);
        self.badgeDot.layer.cornerRadius = d / 2.0;
    }
}

@end

#pragma mark - ZDHHFavoriteBar

@interface ZDHHFavoriteBar ()
/// 原版 0x36e68：静态 UIScrollView。headerView 直接返回它本身，不是外面再包一层。
@property (nonatomic, strong, nullable) UIScrollView *bar;
@property (nonatomic, assign) CGFloat currentWidth;
@property (nonatomic, assign) BOOL installedFallback;
/// 原版 0x36c20：栏是否已经完成首次显形
@property (nonatomic, assign) BOOL didReveal;
/// 原版 0x36ea8：淡入动画进行中标志
@property (nonatomic, assign) BOOL revealAnimating;

// ARC 下必须先声明再调用（这些方法定义在调用点之后）
- (UIScrollView *)barView;
- (CGFloat)addAvatars:(NSArray<NSString *> *)wxids
         toScrollView:(UIScrollView *)sv
                    y:(CGFloat)y
                width:(CGFloat)width;
- (void)applyBadgeToCell:(ZDHHAvatarCell *)cell unread:(NSUInteger)unread;
- (void)loadAvatarForCell:(ZDHHAvatarCell *)cell wxid:(NSString *)wxid;
- (void)applyDecorationsToCell:(ZDHHAvatarCell *)cell unread:(NSUInteger)unread;
- (void)avatarTapped:(ZDHHAvatarCell *)cell;
- (nullable UIView *)makeWeChatBadgeWithNumber:(NSUInteger)number;
@end

@implementation ZDHHFavoriteBar

+ (instancetype)shared {
    static ZDHHFavoriteBar *o = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ o = [[ZDHHFavoriteBar alloc] init]; });
    return o;
}

- (instancetype)init {
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(configChanged)
                                                     name:ZDHHConfigChangedNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configChanged {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reload];
    });
}

/// 需要显示哪些 wxid（已按"仅显未读"过滤）
- (NSArray<NSString *> *)visibleWxids {
    ZDHHConfig *cfg = [ZDHHConfig shared];
    if (!cfg.enabled) return @[];

    NSMutableArray *out = [NSMutableArray array];
    for (NSString *wxid in cfg.contacts) {
        if (![wxid isKindOfClass:[NSString class]] || !wxid.length) continue;
        if (cfg.showOnlyUnread && [ZDHHWeChat unreadCountForWxid:wxid] == 0) continue;
        [out addObject:wxid];
    }
    return out;
}

- (NSArray<NSString *> *)visibleSecondaryWxids {
    ZDHHConfig *cfg = [ZDHHConfig shared];
    if (!cfg.enabled || !cfg.secondaryEnabled) return @[];
    NSMutableArray *out = [NSMutableArray array];
    for (NSString *wxid in cfg.secondaryContacts) {
        if (![wxid isKindOfClass:[NSString class]] || !wxid.length) continue;
        if (cfg.showOnlyUnread && [ZDHHWeChat unreadCountForWxid:wxid] == 0) continue;
        [out addObject:wxid];
    }
    return out;
}

// 原版 wp_favoriteContactsHeaderHeight 实测公式（0x7e84）：
//   单栏：avatarSize + 10 * 2
//   双栏：(avatarSize + 10) * 2 + 10 + 8
// 并且：showOnlyUnread 开启时会先统计"是否存在未读"，全为 0 直接返回 0（顶栏消失）。
- (CGFloat)height {
    NSArray *main = [self visibleWxids];
    if (main.count == 0) return 0.0;

    CGFloat a = [ZDHHConfig shared].avatarSize;
    NSArray *second = [self visibleSecondaryWxids];
    if (second.count > 0) {
        return (a + kZDHHBarVPadding) * 2.0 + kZDHHBarVPadding + kZDHHBarBottomGap;
    }
    return a + kZDHHBarVPadding * 2.0;
}

#pragma mark 构建

/// 原版 0x8fac / 0x8628 的真实结构：
///   · 静态 UIScrollView（bss 0x36e68），headerView 直接返回它本身
///   · 背景 clearColor（0x92c8）
///   · 两个滚动指示器都关掉（0x960 / 0x968）
///   · onlyUnread 且首次显形时，alpha 0 → 1，0.25s（0x8f00–0x8f4c）
- (UIScrollView *)barView {
    if (!_bar) {
        _bar = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _bar.showsHorizontalScrollIndicator = NO;
        _bar.showsVerticalScrollIndicator = NO;
        _bar.backgroundColor = [UIColor clearColor];
        _bar.alwaysBounceHorizontal = YES;
        _bar.clipsToBounds = YES;
    }
    return _bar;
}

- (UIView *)headerViewForWidth:(CGFloat)width {
    NSArray *main = [self visibleWxids];
    if (main.count == 0) return nil;

    if (width <= 0) width = [UIScreen mainScreen].bounds.size.width;
    self.currentWidth = width;

    UIScrollView *bar = [self barView];
    CGFloat h = [self height];

    // 0x8d0: [sBar setFrame:CGRectMake(0, 0, width, h)]
    bar.frame = CGRectMake(0, 0, width, h);

    // 原版用 bss 0x36e70 / 0x36e78 / 0x36e80 三个 NSMutableArray 做差异更新，
    // 这里等价为清空重建：头像走内存 + 磁盘缓存，重建不会触发重新下载。
    for (UIView *v in bar.subviews) {
        [v removeFromSuperview];
    }

    CGFloat a = [ZDHHConfig shared].avatarSize;
    CGFloat y = kZDHHBarVPadding;
    CGFloat maxX = width;

    maxX = MAX(maxX, [self addAvatars:main toScrollView:bar y:y width:width]);
    y += a;

    NSArray *second = [self visibleSecondaryWxids];
    if (second.count > 0) {
        y += kZDHHBarRowGap;
        maxX = MAX(maxX, [self addAvatars:second toScrollView:bar y:y width:width]);
    }

    bar.contentSize = CGSizeMake(maxX, h);

    // 0x8f00：onlyUnread 且尚未显形 → 0.25 秒淡入，避免"栏突然出现"
    if ([ZDHHConfig shared].showOnlyUnread && !self.didReveal && !self.revealAnimating) {
        bar.alpha = 0.0;
        self.revealAnimating = YES;
        self.didReveal = YES;
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
            bar.alpha = 1.0;
        } completion:^(BOOL finished) {
            self.revealAnimating = NO;
        }];
    } else if (!self.revealAnimating && bar.alpha < 1.0) {
        bar.alpha = 1.0;
    }

    // 原版 0x7ad0 后半段（0x7c84–0x7d8c）：外面再包一层 UIView
    //   wrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W, H)]
    //   [wrapper setBackgroundColor:[UIColor clearColor]]
    //   [wrapper setFrame:CGRectMake(0, 0, W, H)]
    //   [wrapper addSubview:bar]
    // 这层不能省：UITableView 会改 header 的 frame，包一层才不会推到 scrollView 自身。
    UIView *wrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, h)];
    wrapper.backgroundColor = [UIColor clearColor];
    wrapper.frame = CGRectMake(0, 0, width, h);
    [wrapper addSubview:bar];

    return wrapper;
}

/// 把一组头像按行铺进 scrollView，返回这一行的右边界
- (CGFloat)addAvatars:(NSArray<NSString *> *)wxids
         toScrollView:(UIScrollView *)sv
                    y:(CGFloat)y
                width:(CGFloat)width {
    ZDHHConfig *cfg = [ZDHHConfig shared];
    CGFloat size = cfg.avatarSize;
    CGFloat x = kZDHHBarHPadding;

    for (NSString *wxid in wxids) {
        ZDHHAvatarCell *cell = [[ZDHHAvatarCell alloc] initWithFrame:CGRectMake(x, y, size, size)];
        cell.wxid = wxid;
        cell.accessibilityLabel = [ZDHHWeChat displayNameForWxid:wxid];

        // 原版 0xbf18：tag = [wxid hash] + 1000，供 viewWithTag: 复用与外部定位
        cell.tag = (NSInteger)[wxid hash] + 1000;

        NSUInteger unread = [ZDHHWeChat unreadCountForWxid:wxid];
        cell.muted = [ZDHHWeChat isMutedForWxid:wxid];

        [self applyBadgeToCell:cell unread:unread];
        [self loadAvatarForCell:cell wxid:wxid];
        [self applyDecorationsToCell:cell unread:unread];

        [cell addTarget:self action:@selector(avatarTapped:) forControlEvents:UIControlEventTouchUpInside];
        [sv addSubview:cell];
        x += size + kZDHHBarAvatarGap;
    }
    return x + kZDHHBarHPadding;
}

#pragma mark 角标

/// 原版角标用的是微信自己的 MMBadgeView（cfstring idx 12；selref idx 81 redDotWithNumber:、
/// 87 setAsSmallDot、84 setText:、85 sizeToFit）。这里优先用它，拿不到再退回自绘。
- (nullable UIView *)makeWeChatBadgeWithNumber:(NSUInteger)number {
    Class BadgeClass = NSClassFromString(@"MMBadgeView");
    if (!BadgeClass) return nil;

    SEL redDot = NSSelectorFromString(@"redDotWithNumber:");
    if (![BadgeClass respondsToSelector:redDot]) return nil;

    UIView *badge = nil;
    @try {
        badge = ((id (*)(id, SEL, id))objc_msgSend)(BadgeClass, redDot, @(number));
    } @catch (__unused NSException *e) {
        badge = nil;
    }
    if (!badge) return nil;

    if (number == 1) {
        SEL small = NSSelectorFromString(@"setAsSmallDot");
        if ([badge respondsToSelector:small]) {
            @try {
                ((void (*)(id, SEL))objc_msgSend)(badge, small);
            } @catch (__unused NSException *e) {}
        }
    }

    [badge sizeToFit];
    return badge;
}

- (void)applyBadgeToCell:(ZDHHAvatarCell *)cell unread:(NSUInteger)unread {
    ZDHHConfig *cfg = [ZDHHConfig shared];

    // 清掉旧角标（原版靠 tag 复用，这里等价为清空重建）
    for (UIView *v in cell.subviews) {
        if (v.tag == kZDHHBadgeTag) [v removeFromSuperview];
    }
    cell.badgeView = nil;
    cell.badgeLabel = nil;
    cell.badgeDot = nil;

    BOOL show = unread > 0 && ((cell.muted && cfg.showMuteBadge) || (!cell.muted && cfg.showNormalBadge));
    if (!show) return;

    UIView *wechatBadge = [self makeWeChatBadgeWithNumber:unread];
    if (wechatBadge) {
        wechatBadge.tag = kZDHHBadgeTag;
        cell.badgeView = wechatBadge;
        [cell addSubview:wechatBadge];
        [cell setNeedsLayout];
        return;
    }

    // 兜底：微信类不可用时自绘，保证有未读就一定看得见
    if (unread == 1) {
        UIView *dot = [[UIView alloc] initWithFrame:CGRectZero];
        dot.backgroundColor = [UIColor systemRedColor];
        dot.layer.masksToBounds = YES;
        dot.userInteractionEnabled = NO;
        dot.tag = kZDHHBadgeTag;
        [cell addSubview:dot];
        cell.badgeDot = dot;
    } else {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.font = [UIFont systemFontOfSize:11 weight:UIFontWeightSemibold];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor systemRedColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = unread > 99 ? @"99+" : [NSString stringWithFormat:@"%lu", (unsigned long)unread];
        label.layer.masksToBounds = YES;
        label.userInteractionEnabled = NO;
        label.tag = kZDHHBadgeTag;
        [cell addSubview:label];
        cell.badgeLabel = label;
    }
}

#pragma mark 头像

- (void)loadAvatarForCell:(ZDHHAvatarCell *)cell wxid:(NSString *)wxid {
    ZDHHAvatarCache *cache = [ZDHHAvatarCache shared];

    UIImage *cached = [cache memoryImageForKey:wxid];
    if (!cached) cached = [cache diskImageForKey:wxid];
    if (cached) {
        cell.avatarView.image = cached;
        return;
    }

    // 先上占位图，避免空白（原版这里是一片空白，正是"头像不显示"的观感来源之一）
    cell.avatarView.image = ZDHHPlaceholderAvatarImage([ZDHHWeChat displayNameForWxid:wxid],
                                                      [ZDHHConfig shared].avatarSize);

    NSString *url = [ZDHHWeChat headImageURLForWxid:wxid];
    if (!url.length) return;

    NSURL *u = [NSURL URLWithString:url];
    if (!u) return;

    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:u
                                                            completionHandler:^(NSData *data, NSURLResponse *resp, NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        if (error || data.length == 0) return;

        UIImage *img = [UIImage imageWithData:data];
        if (!img) return;

        [[ZDHHAvatarCache shared] storeImage:img forKey:wxid];

        dispatch_async(dispatch_get_main_queue(), ^{
            cell.avatarView.image = img;
        });
    }];
    [task resume];
}

#pragma mark 呼吸 / 阴影

- (void)applyDecorationsToCell:(ZDHHAvatarCell *)cell unread:(NSUInteger)unread {
    ZDHHConfig *cfg = [ZDHHConfig shared];
    CALayer *layer = cell.layer;   // 阴影加在容器上（原版签名就是 ...ToContainer:）

    // 呼吸 —— 原版 0xdb9c 实测：
    //   [layer animationForKey:@"breathingAnimation"] 已存在则直接返回
    //   keyPath = opacity, duration = 1.5, fromValue = 1.0, toValue = 0.5,
    //   autoreverses = YES, repeatCount = INFINITY, timing = kCAMediaTimingFunctionDefault
    //   关闭时：removeAnimationForKey:@"breathingAnimation" + setAlpha:1.0
    BOOL wantBreathing = cfg.breathing && (!cfg.breathingOnlyUnread || unread > 0);
    if (wantBreathing) {
        if (![layer animationForKey:@"breathingAnimation"]) {
            CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
            anim.duration = 1.5;
            anim.fromValue = @(1.0);
            anim.toValue = @(0.5);
            anim.autoreverses = YES;
            anim.repeatCount = HUGE_VALF;
            anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
            [layer addAnimation:anim forKey:@"breathingAnimation"];
        }
    } else {
        [layer removeAnimationForKey:@"breathingAnimation"];
        cell.avatarView.alpha = 1.0;
    }

    // 阴影 —— 原版 0xe0e8 实测：
    //   shadowOffset = CGSizeMake(2.0, 2.0)
    //   shadowRadius = 4.0
    //   shadowOpacity = 0.8（0x3f4ccdcd）
    //   masksToBounds = NO，shadowPath = 圆角矩形
    //   颜色：iOS 13+ 按 userInterfaceStyle 取 dark / light，否则取 light
    if (cfg.shadow) {
        layer.shadowOffset = CGSizeMake(2.0, 2.0);
        layer.shadowRadius = 4.0;
        layer.shadowOpacity = 0.8;

        BOOL dark = NO;
        if (@available(iOS 13.0, *)) {
            dark = (cell.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark);
        }
        UIColor *bg = dark ? cfg.shadowColorDark : cfg.shadowColorLight;
        layer.shadowColor = (bg ?: [UIColor whiteColor]).CGColor;
        layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:cell.bounds
                                                      cornerRadius:[cfg effectiveCorner]].CGPath;
        layer.masksToBounds = NO;
        cell.avatarView.clipsToBounds = YES;
    } else {
        layer.shadowOpacity = 0.0;
        layer.shadowPath = NULL;
        layer.shadowOffset = CGSizeZero;
    }
}

#pragma mark 交互

- (void)avatarTapped:(ZDHHAvatarCell *)cell {
    if (!cell.wxid.length) return;

    // 原版 0xcd94：[[UIImpactFeedbackGenerator alloc] initWithStyle:1] + impactOccurred
    // style 1 == UIImpactFeedbackStyleMedium
    UIImpactFeedbackGenerator *feedback =
        [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [feedback impactOccurred];

    if ([_delegate respondsToSelector:@selector(favoriteBar:didTapWxid:)]) {
        [_delegate favoriteBar:self didTapWxid:cell.wxid];
        return;
    }

    // 没有外部 delegate 时自己开聊天（原版 wp_openFavoriteContactWithWxid: 0xd3a4）
    [ZDHHWeChat openChatWithWxid:cell.wxid fromController:nil];
}

#pragma mark 刷新

- (void)reload {
    dispatch_async(dispatch_get_main_queue(), ^{
        UITableView *tv = [ZDHHWeChat mainTableView];

        // 主路径：让表格重新请求 section 0 的 header（会重新走 headerViewForWidth:）
        if (tv && tv.numberOfSections > 0) {
            [UIView performWithoutAnimation:^{
                [tv reloadSections:[NSIndexSet indexSetWithIndex:0]
                  withRowAnimation:UITableViewRowAnimationNone];
            }];
        }

        // 兜底路径：挂在 tableView 顶部的那份要摘掉重装
        if (self.installedFallback && tv) {
            self.installedFallback = NO;
            tv.contentInset = UIEdgeInsetsZero;
            UIScrollView *bar = [self barView];
            bar.tag = 0;
            [bar removeFromSuperview];
            [self attachToControllerIfNeeded:nil];
        }
    });
}

#pragma mark 兜底安装

- (void)attachToControllerIfNeeded:(UIViewController *)vc {
    ZDHHConfig *cfg = [ZDHHConfig shared];
    if (!cfg.enabled || self.installedFallback) return;

    UITableView *tv = ZDHHWeChat.mainTableView;
    if (!tv) return;

    CGFloat h = [self height];
    if (h <= 0) return;

    UIScrollView *bar = [self barView];

    // 已经被表格当成 section header 收编（有父视图），就不需要兜底
    if (bar.superview) return;

    self.installedFallback = YES;
    bar.tag = kZDHHBarTag;
    bar.frame = CGRectMake(0, -h, CGRectGetWidth(tv.bounds), h);
    bar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [tv addSubview:bar];
    tv.contentInset = UIEdgeInsetsMake(h, 0, 0, 0);
    tv.contentOffset = CGPointMake(0, -h);
}

@end
