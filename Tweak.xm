//
//  Tweak.xm
//  常用会话 · 重写版 · hook 安装层
//
//  与原版 1.0.0 的三个结构性差异：
//
//  1) 原版用 Logos 的 new 语法（class_addMethod）去"添加" tableView:viewForHeaderInSection:。
//     一旦微信自己实现了这个方法，class_addMethod 直接返回 NO 且不覆盖，
//     插件从此静默失效 —— 这是"有时能用有时不能用"的头号原因。
//     这里改成：方法存在就 MSHookMessageEx，不存在才 class_addMethod，两条路都通。
//
//  2) 原版 headerView 开头有 checkOfficialAccountFollowed 闸门，
//     公众号没关注 / 公众号列表接口变了 → 返回 nil，顶栏整个消失。
//     重写版不设任何远程闸门。
//
//  3) 原版只在 updateMainSessionList / updateMainSessionListNotify: 上刷新，
//     微信某些版本这两个方法在子线程或不再被调用，角标就停在旧值。
//     这里额外挂 viewDidAppear: 与配置变更通知作为第二、第三条刷新冗余。
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <substrate.h>
#include <stdlib.h>

#import "ZDHHCommon.h"
#import "ZDHHFavoriteBar.h"
#import "ZDHHSettingsViewController.h"

#pragma mark - 刷新

static void ZDHHRebuildBar(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ZDHHFavoriteBar shared] reload];
    });
}

#pragma mark - NewMainFrameViewController

static void (*orig_viewDidLoad)(id, SEL);
static void hook_viewDidLoad(id self, SEL _cmd) {
    if (orig_viewDidLoad) orig_viewDidLoad(self, _cmd);

    // tableView 在 viewDidLoad 之后才成形
    dispatch_async(dispatch_get_main_queue(), ^{
        ZDHHRebuildBar();
    });
}

static void (*orig_viewDidAppear)(id, SEL, BOOL);
static void hook_viewDidAppear(id self, SEL _cmd, BOOL animated) {
    if (orig_viewDidAppear) orig_viewDidAppear(self, _cmd, animated);

    // 兜底：若微信没有走 section header 路径，把头像条直接挂到 tableView 顶部
    [[ZDHHFavoriteBar shared] attachToControllerIfNeeded:self];
    ZDHHRebuildBar();
}

static double (*orig_heightForHeader)(id, SEL, UITableView *, NSInteger);
static double hook_heightForHeader(id self, SEL _cmd, UITableView *tv, NSInteger section) {
    if (section == 0) {
        double h = [[ZDHHFavoriteBar shared] height];
        if (h > 0) return h;
    }
    return orig_heightForHeader ? orig_heightForHeader(self, _cmd, tv, section) : 0.0;
}

static UIView *(*orig_viewForHeader)(id, SEL, UITableView *, NSInteger);
static UIView *hook_viewForHeader(id self, SEL _cmd, UITableView *tv, NSInteger section) {
    if (section == 0) {
        UIView *bar = [[ZDHHFavoriteBar shared] headerViewForWidth:CGRectGetWidth(tv.bounds)];
        if (bar) return bar;
    }
    return orig_viewForHeader ? orig_viewForHeader(self, _cmd, tv, section) : nil;
}

static void (*orig_traitCollectionDidChange)(id, SEL, UITraitCollection *);
static void hook_traitCollectionDidChange(id self, SEL _cmd, UITraitCollection *previous) {
    if (orig_traitCollectionDidChange) orig_traitCollectionDidChange(self, _cmd, previous);

    // 暗色模式切换后阴影颜色要跟着换
    dispatch_async(dispatch_get_main_queue(), ^{
        ZDHHRebuildBar();
    });
}

#pragma mark - MMNewSessionMgr

static void (*orig_updateMainSessionList)(id, SEL);
static void hook_updateMainSessionList(id self, SEL _cmd) {
    if (orig_updateMainSessionList) orig_updateMainSessionList(self, _cmd);
    ZDHHRebuildBar();
}

static void (*orig_updateMainSessionListNotify)(id, SEL, id);
static void hook_updateMainSessionListNotify(id self, SEL _cmd, id arg) {
    if (orig_updateMainSessionListNotify) orig_updateMainSessionListNotify(self, _cmd, arg);
    ZDHHRebuildBar();
}

#pragma mark - 安装器

/// 安装一个 hook。返回 YES 表示本次装上了。
///
/// 三种情况必须分开处理，否则顶栏会莫名其妙不出现：
///   A. 方法由 cls 自己实现  → MSHookMessageEx，orig 指向原实现
///   B. 方法只来自父类      → 在 cls 上加覆盖，orig 指向父类实现
///                            （直接 MSHookMessageEx 会污染父类，所有子类一起中招）
///   C. 完全没有            → class_addMethod，orig = NULL
static BOOL ZDHHInstallHook(Class cls, SEL sel, IMP replacement, IMP *original, const char *types) {
    if (!cls || !sel || !replacement) return NO;
    if (original) *original = NULL;

    Method inherited = class_getInstanceMethod(cls, sel);
    IMP inheritedIMP = inherited ? class_getMethodImplementation(cls, sel) : NULL;

    // 已经装上（IMP 就是我们的钩子）→ 重复调用直接返回，避免 orig 指向自己造成无限递归
    if (inheritedIMP == replacement) return YES;

    BOOL owned = NO;
    unsigned int count = 0;
    Method *list = class_copyMethodList(cls, &count);
    for (unsigned int i = 0; i < count; i++) {
        if (method_getName(list[i]) == sel) {
            owned = YES;
            break;
        }
    }
    if (list) free(list);

    if (owned) {
        MSHookMessageEx(cls, sel, replacement, original);
        return YES;
    }

    if (inherited) {
        // 父类有实现：记下来当 orig，再在 cls 上覆盖
        if (original) *original = inheritedIMP;
        class_addMethod(cls, sel, replacement, types);
        return YES;
    }

    class_addMethod(cls, sel, replacement, types);
    return YES;
}

#pragma mark - 设置页注册

static BOOL ZDHHRegisterSettingsPage(void) {
    Class WCPluginsMgr = NSClassFromString(@"WCPluginsMgr");
    if (!WCPluginsMgr) return NO;

    id mgr = nil;
    @try {
        if ([WCPluginsMgr respondsToSelector:@selector(sharedInstance)]) {
            mgr = ((id (*)(id, SEL))objc_msgSend)(WCPluginsMgr, @selector(sharedInstance));
        }
    } @catch (__unused NSException *e) {
        mgr = nil;
    }
    if (!mgr) return NO;

    SEL registerSel = NSSelectorFromString(@"registerControllerWithTitle:version:controller:");
    if (![mgr respondsToSelector:registerSel]) return NO;

    @try {
        ((void (*)(id, SEL, id, id, Class))objc_msgSend)(
            mgr, registerSel, @"常用会话", @"2.0.0", [ZDHHSettingsViewController class]);
        return YES;
    } @catch (__unused NSException *e) {
        return NO;
    }
}

#pragma mark - 入口

__attribute__((constructor))
static void ZDHHInit(void) {
    @autoreleasepool {
        // 微信可能还没把类加载完，延迟一轮再装；最多重试 10 次（共 5 秒）
        __block NSInteger attempts = 0;
        __block void (^tryInstall)(void) = nil;
        // 递归 block 必须走 __weak 中转，否则 __block 变量被 block 强捕获形成
        // retain cycle，Theos 默认 -Werror 下直接编译失败（-Warc-retain-cycles）
        __block __weak void (^weakInstall)(void) = nil;

        tryInstall = ^{
            attempts++;

            Class main = NSClassFromString(@"NewMainFrameViewController");
            Class sessionMgr = NSClassFromString(@"MMNewSessionMgr");

            if (main) {
                ZDHHInstallHook(main, @selector(viewDidLoad),
                                (IMP)hook_viewDidLoad, (IMP *)&orig_viewDidLoad, "v@:");
                ZDHHInstallHook(main, @selector(viewDidAppear:),
                                (IMP)hook_viewDidAppear, (IMP *)&orig_viewDidAppear, "v@:B");
                ZDHHInstallHook(main, NSSelectorFromString(@"tableView:heightForHeaderInSection:"),
                                (IMP)hook_heightForHeader, (IMP *)&orig_heightForHeader, "d@:@q");
                ZDHHInstallHook(main, NSSelectorFromString(@"tableView:viewForHeaderInSection:"),
                                (IMP)hook_viewForHeader, (IMP *)&orig_viewForHeader, "@@:@q");
                ZDHHInstallHook(main, @selector(traitCollectionDidChange:),
                                (IMP)hook_traitCollectionDidChange, (IMP *)&orig_traitCollectionDidChange, "v@:@");
            }

            if (sessionMgr) {
                ZDHHInstallHook(sessionMgr, NSSelectorFromString(@"updateMainSessionList"),
                                (IMP)hook_updateMainSessionList, (IMP *)&orig_updateMainSessionList, "v@:");
                ZDHHInstallHook(sessionMgr, NSSelectorFromString(@"updateMainSessionListNotify:"),
                                (IMP)hook_updateMainSessionListNotify, (IMP *)&orig_updateMainSessionListNotify, "v@:@");
            }

            if (main && sessionMgr) {
                // 类都齐了；设置页要等 WCPluginsMgr 就绪，注册不上就继续重试
                static BOOL settingsRegistered = NO;
                if (!settingsRegistered) {
                    settingsRegistered = ZDHHRegisterSettingsPage();
                }
                if (settingsRegistered) return;
            }

            if (attempts < 10) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{
                    void (^block)(void) = weakInstall;
                    if (block) block();
                });
            }
        };
        weakInstall = tryInstall;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            void (^block)(void) = weakInstall;
            if (block) block();
        });
    }
}
