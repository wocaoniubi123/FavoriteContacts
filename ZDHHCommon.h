//
//  ZDHHCommon.h
//  常用会话 · 重写版
//
//  设计原则：
//  1. 所有微信私有 API 一律运行时探测（respondsToSelector / class 存在性），
//     探测不到返回安全默认值，不抛异常、不崩、不静默失效。
//  2. 配置键名与原版完全一致，老用户设置可直接继承。
//  3. 不引入任何"关注公众号"之类的远程/半远程闸门。
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 配置键（与原版 1.0.0 保持一致）

extern NSString *const kZDHHKeyEnabled;              // ZDHHFavoriteContactsEnabled
extern NSString *const kZDHHKeyContacts;             // ZDHHFavoriteContacts
extern NSString *const kZDHHKeyAvatarSize;           // ZDHHFavoriteAvatarSize
extern NSString *const kZDHHKeyAvatarCorner;         // ZDHHFavoriteAvatarCornerRadius
extern NSString *const kZDHHKeyBadgeVOffset;         // ZDHHFavoriteBadgeVerticalOffset
extern NSString *const kZDHHKeyBadgeHOffset;         // ZDHHFavoriteBadgeHorizontalOffset
extern NSString *const kZDHHKeyShowNormalBadge;      // ZDHHFavoriteShowNormalBadge
extern NSString *const kZDHHKeyShowMuteBadge;        // ZDHHFavoriteShowMuteBadge
extern NSString *const kZDHHKeyBreathing;            // ZDHHFavoriteAvatarBreathing
extern NSString *const kZDHHKeyBreathingOnlyUnread;  // ZDHHFavoriteBreathingOnlyUnread
extern NSString *const kZDHHKeyShadow;               // ZDHHFavoriteAvatarShadow
extern NSString *const kZDHHKeyShadowColorLight;     // ZDHHFavoriteShadowBackgroundColor
extern NSString *const kZDHHKeyShadowColorDark;      // ZDHHFavoriteShadowBackgroundColorDark
extern NSString *const kZDHHKeyBarPositionTop;       // ZDHHFavoriteBarPositionTop
extern NSString *const kZDHHKeySecondaryEnabled;     // ZDHHFavoriteSecondaryBarEnabled
extern NSString *const kZDHHKeySecondaryContacts;    // ZDHHFavoriteSecondaryContacts
extern NSString *const kZDHHKeyShowOnlyUnread;       // ZDHHFavoriteShowOnlyUnread

#pragma mark - 配置读写

/// 配置变更通知（主线程投递）
FOUNDATION_EXPORT NSString *const ZDHHConfigChangedNotification;

@interface ZDHHConfig : NSObject

+ (instancetype)shared;

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL showOnlyUnread;
@property (nonatomic, assign) BOOL showNormalBadge;
@property (nonatomic, assign) BOOL showMuteBadge;
@property (nonatomic, assign) BOOL breathing;
@property (nonatomic, assign) BOOL breathingOnlyUnread;
@property (nonatomic, assign) BOOL shadow;
@property (nonatomic, assign) BOOL barPositionTop;      // YES = 顶栏，NO = 底栏
@property (nonatomic, assign) BOOL secondaryEnabled;

@property (nonatomic, assign) CGFloat avatarSize;       // 24...56
@property (nonatomic, assign) CGFloat avatarCorner;     // 0...avatarSize/2，-1 = 自动
@property (nonatomic, assign) CGFloat badgeVOffset;     // -20...20
@property (nonatomic, assign) CGFloat badgeHOffset;     // -20...20

/// avatarCorner 未显式设置（-1）时按头像半径自动计算
@property (nonatomic, readonly) CGFloat effectiveCorner;

@property (nonatomic, strong, nullable) UIColor *shadowColorLight;
@property (nonatomic, strong, nullable) UIColor *shadowColorDark;

- (NSArray<NSString *> *)contacts;
- (void)setContacts:(NSArray<NSString *> *)arr;
- (void)addContact:(NSString *)wxid;
- (void)removeContact:(NSString *)wxid;
- (BOOL)hasContact:(NSString *)wxid;

- (NSArray<NSString *> *)secondaryContacts;
- (void)setSecondaryContacts:(NSArray<NSString *> *)arr;
- (void)addSecondaryContact:(NSString *)wxid;
- (void)removeSecondaryContact:(NSString *)wxid;

/// 触发首页刷新（跨进程内通知，主线程）
- (void)notifyChanged;

@end

#pragma mark - 微信私有 API 适配层

@interface ZDHHWeChat : NSObject

/// MMContext 的 currentContext / activeUserContext，两者都试
+ (nullable id)context;

/// [context getService:cls]，cls 不存在返回 nil
+ (nullable id)serviceOfClassNamed:(NSString *)clsName;

/// 取 CContactMgr
+ (nullable id)contactManager;

/// 按 wxid 取联系人对象（CContact）
+ (nullable id)contactForWxid:(NSString *)wxid;

/// 取联系人头像 URL
+ (nullable NSString *)headImageURLForWxid:(NSString *)wxid;

/// 取联系人显示名（备注 > 昵称 > wxid）
+ (NSString *)displayNameForWxid:(NSString *)wxid;

/// 会话未读数
+ (NSUInteger)unreadCountForWxid:(NSString *)wxid;

/// 会话是否免打扰
+ (BOOL)isMutedForWxid:(NSString *)wxid;

/// 打开与某人的聊天；vc 可为 nil（会自动找顶层导航控制器）
+ (BOOL)openChatWithWxid:(NSString *)wxid fromController:(nullable UIViewController *)vc;

/// 当前顶层可用的 UINavigationController
+ (nullable UINavigationController *)topNavigationController;

/// 从根控制器定位首页 NewMainFrameViewController 的 tableView
+ (nullable UITableView *)mainTableView;

/// 微信版本号字符串，例如 "8.0.49"
+ (NSString *)weChatVersion;

@end

/// 安全地取 KVC 值：对象/类不支持 key 时返回 nil，不抛异常
FOUNDATION_EXPORT id _Nullable ZDHHSafeValue(id _Nullable obj, NSString *key);

/// 安全地读 BOOL
FOUNDATION_EXPORT BOOL ZDHHSafeBool(id _Nullable obj, NSString *key, BOOL fallback);

/// 颜色 <-> hex 字符串（0xRRGGBB 存 NSUserDefaults，跨版本稳定）
FOUNDATION_EXPORT NSString *ZDHHHexFromColor(UIColor *color);
FOUNDATION_EXPORT UIColor *_Nullable ZDHHColorFromHex(NSString *_Nullable hex);

/// 首字占位头像（下载失败 / 无 URL / 列表页复用）
FOUNDATION_EXPORT UIImage *ZDHHPlaceholderAvatarImage(NSString *_Nullable name, CGFloat size);

NS_ASSUME_NONNULL_END
