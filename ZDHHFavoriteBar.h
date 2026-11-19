//
//  ZDHHFavoriteBar.h
//  首页顶栏 / 底栏 头像条
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZDHHFavoriteBar;

@protocol ZDHHFavoriteBarDelegate <NSObject>
@optional
- (void)favoriteBar:(ZDHHFavoriteBar *)bar didTapWxid:(NSString *)wxid;
@end

@interface ZDHHFavoriteBar : NSObject

+ (instancetype)shared;

@property (nonatomic, weak, nullable) id<ZDHHFavoriteBarDelegate> delegate;

/// 当前需要的高度（未启用 / 无成员返回 0）
- (CGFloat)height;

/// 构造 header 视图。未启用 / 无成员返回 nil。
- (nullable UIView *)headerViewForWidth:(CGFloat)width;

/// 配置变更后重建
- (void)reload;

/// 把头像条挂到首页控制器上（在 tableView 没有走 section header 时兜底）
/// vc 仅作上下文，可为 nil
- (void)attachToControllerIfNeeded:(nullable UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
