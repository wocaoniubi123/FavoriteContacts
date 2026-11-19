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
#include <stdlib.h>

// 不使用 CydiaSubstrate：
//   自签（非越狱）环境没有 substrate，MSHookMessageEx 会直接符号缺失。
//   ObjC 方法 hook 用 method_setImplementation 完全等价，不依赖任何注入框架。

#import "ZDHHCommon.h"
#import "ZDHHFavoriteBar.h"
#import "ZDHHSettingsViewController.h"

#pragma mark - 日志

// 设备上抓日志：
//   log stream --predicate 'eventMessage CONTAINS "[ZDHH]"'
// 或  tail -f /var/log/syslog | grep ZDHH
#define ZDHHLog(fmt, ...) NSLog(@"[ZDHH] " fmt, ##__VA_ARGS__)

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
        // 直接用 runtime 替换，等价于 MSHookMessageEx，但不依赖 CydiaSubstrate
        IMP old = method_setImplementation(inherited, replacement);
        if (original) *original = old;
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
    if (!WCPluginsMgr) {
        ZDHHLog(@"register: WCPluginsMgr NOT FOUND");
        return NO;
    }

    id mgr = nil;
    @try {
        if ([WCPluginsMgr respondsToSelector:@selector(sharedInstance)]) {
            mgr = ((id (*)(id, SEL))objc_msgSend)(WCPluginsMgr, @selector(sharedInstance));
        }
    } @catch (__unused NSException *e) {
        mgr = nil;
    }
    if (!mgr) {
        ZDHHLog(@"register: [WCPluginsMgr sharedInstance] returned nil");
        return NO;
    }

    SEL registerSel = NSSelectorFromString(@"registerControllerWithTitle:version:controller:");
    if (![mgr respondsToSelector:registerSel]) {
        ZDHHLog(@"register: selector registerControllerWithTitle:version:controller: missing");
        return NO;
    }

    @try {
        ((void (*)(id, SEL, id, id, Class))objc_msgSend)(
            mgr, registerSel, @"常用会话", @"2.1.0", [ZDHHSettingsViewController class]);
        ZDHHLog(@"register: OK");
        return YES;
    } @catch (NSException *e) {
        ZDHHLog(@"register: exception %@ - %@", e.name, e.reason);
        return NO;
    }
}

#pragma mark - 入口

__attribute__((constructor))
void ZDHHInit(void) {          // 不能加 static：未引用的 static 函数可能被 dead-strip，constructor 不执行
    @autoreleasepool {
        ZDHHLog(@"loaded v2.1.0 (no substrate), waiting for WeChat classes");
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

            // 设置页注册与 hook 安装解耦：只要 WCPluginsMgr 就绪就注册，不依赖 main/sessionMgr
            static BOOL settingsRegistered = NO;
            if (!settingsRegistered) {
                settingsRegistered = ZDHHRegisterSettingsPage();
                ZDHHLog(@"attempt %ld: main=%d sessionMgr=%d settings=%d",
                        (long)attempts, main != nil, sessionMgr != nil, settingsRegistered);
            }

            if (main && sessionMgr && settingsRegistered) {
                ZDHHLog(@"all targets installed");
                return;
            }

            if (attempts < 60) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{
                    void (^block)(void) = weakInstall;
                    if (block) block();
                });
            } else {
                ZDHHLog(@"gave up after %ld attempts (main=%d sessionMgr=%d settings=%d)",
                        (long)attempts, main != nil, sessionMgr != nil, settingsRegistered);
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
