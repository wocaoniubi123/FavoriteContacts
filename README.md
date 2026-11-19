# 常用会话 · 重写版

对 `FavoriteContacts.dylib`（"常用会话" 1.0.0，微信 iOS 越狱插件）的完整重写。

---

## 一、原版为什么"经常失效"

逆向 `E:\desk-ai\常用会话1.0.0.dylib`（fat binary，arm64 + arm64e，745584 字节，
`LC_ID_DYLIB = /Library/MobileSubstrate/DynamicLibraries/FavoriteContacts.dylib`）后确认，
顶栏消失是三条独立的链，任意一条断掉都表现为"加载了但没头像栏"。

### 链 1 · `class_addMethod` 覆盖已存在的方法会静默失败

`_logosLocalInit`（`0x6ddc`）里对 `NewMainFrameViewController` 做了 12 次 `class_addMethod`：

| selector | IMP |
|---|---|
| `tableView:heightForHeaderInSection:` | `0x7a20` |
| `tableView:viewForHeaderInSection:` | `0x7ad0` |
| `wp_favoriteContactsHeaderHeight` | `0x7e84` |
| `wp_favoriteContactsHeaderView` | `0x8628` |
| `wp_updateFavoriteContactsBar` | `0x8fac` |
| `wp_getUnreadCountForWxid:` | `0xb390` |
| `wp_updateBadgeForWxid:containerView:` | `0xb95c` |
| `wp_loadAvatarForView:withWxid:` | `0xcbd4` |
| `wp_handleFavoriteAvatarTap:` | `0xcd94` |
| `wp_openFavoriteContactWithWxid:` | `0xd3a4` |
| `wp_applyBreathingAnimationToAvatar:withUnreadCount:` | `0xdb9c` |
| `wp_applyShadowToContainer:cornerRadius:` | `0xe0e8` |

前两个是 `UITableViewDelegate` 的方法。`class_addMethod` 的语义是"**仅当类自己没有这个方法时才添加**"，
一旦微信自己在 `NewMainFrameViewController` 上实现了 `tableView:viewForHeaderInSection:`（或继承链上已有），
`class_addMethod` 返回 `NO` 且**不覆盖**，插件的实现从此永远不被调用 —— 而顶栏的整个渲染入口正是这两个方法。

微信在不同版本里是否自己实现这两个方法会变，这就是"有时能用、有时不能用"的机械原因。

**重写版**：方法存在就 `MSHookMessageEx`，不存在才 `class_addMethod`，两条路都通。

### 链 2 · 公众号关注校验是硬闸门

`wp_favoriteContactsHeaderHeight`（`0x7e84`）与 `wp_favoriteContactsHeaderView`（`0x8628`）开头都有：

```objc
if (![[ZDHHGroupManager sharedManager] isFavoriteContactsEnabled]) return nil / 0;
if (![[ZDHHGroupManager sharedManager] checkOfficialAccountFollowed]) return nil / 0;
```

`checkOfficialAccountFollowed`（`ZDHHGroupManager` 元类，`0x26754`）的实现是：

```objc
Class MMContext = NSClassFromString(@"MMContext");
id ctx = [MMContext currentContext];       // 失败则试 activeUserContext
id mgr = [ctx getService:[CContactMgr class]];
if ([mgr respondsToSelector:@selector(getAllBrandContacts)]) {
    for (id c in [mgr performSelector:@selector(getAllBrandContacts)]) {
        if ([[c valueForKey:@"..."] isEqualToString:@"gh_c56fce57caa3"]) return YES;
    }
}
return NO;
```

即：**遍历公众号列表，找 `gh_c56fce57caa3`（拾光札札记）**。
取关、公众号迁移、`getAllBrandContacts` 改名、`MMContext` 换 API、列表未加载 —— 任意一种，
返回 `NO`，顶栏高度归 0、视图返回 nil，**整个栏消失且没有任何提示**。

**重写版**：不设任何远程/半远程闸门。

### 链 3 · 头像靠裸 URL 下载，无缓存、无兜底

`wp_loadAvatarForView:withWxid:`（`0xcbd4`）拿到 `CContact.m_nsHeadImgUrl` 后
直接 `NSURLSession dataTaskWithURL:` 拉图，失败就什么都不做 —— cell 上是一片空白。
微信新版头像可能走 CDN 鉴权或本地缓存，URL 为空/失效时头像就永远空白。

**重写版**：内存 + 磁盘两级缓存，下载前先铺首字占位图，失败也不留空白。

### 链 4 · `showOnlyUnread` 开启后，全员无未读则高度归零

`wp_favoriteContactsHeaderHeight`（`0x7e84`）在 `getFavoriteShowOnlyUnread` 为真时，
会先遍历 `contacts`（`0x80b0`–`0x8168`），逐个调 `wp_getUnreadCountForWxid:`，
只要有一个 `> 0` 就置 `hasVisibleInMain = YES` 并跳出。

若主栏全为 0，再查副栏（`0x82c8` 起）。**两边都没有未读时**：

```asm
0x00008440  tbnz  w8, 0, 0x8458   ; hasVisibleInMain
0x00008444  ldr   x8, [sp, 0x120]
0x00008448  str   xzr, [x8, 0x40] ; 返回值 = 0
```

高度直接返回 0，`tableView:viewForHeaderInSection:` 也拿不到视图 —— **顶栏整个消失，
没有任何提示**。所以"仅显未读"打开时，把所有会话都读完，栏就没了，这是设计行为而非崩溃。

**重写版**：行为与原版一致（`visibleWxids` 过滤后为空即 `height` 返回 0），
但把这条写进 README，避免误判为故障。

### 高度公式（实测）

```objc
// 单栏
height = avatarSize + 10 * 2;
// 双栏
height = (avatarSize + 10) * 2 + 10 + 8;
```

对应常量在汇编里是 `0x4024000000000000`(10.0) 与 `0x4020000000000000`(8.0)，
见 `0x84e4`–`0x8570`（双栏）与 `0x85b8`–`0x85d0`（单栏）。

### 呼吸动画（实测，`0xdb9c`）

```objc
if ([layer animationForKey:@"breathingAnimation"]) return;   // 已存在直接返回
CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
anim.duration    = 1.5;
anim.fromValue   = @(1.0);
anim.toValue     = @(0.5);
anim.autoreverses = YES;
anim.repeatCount  = INFINITY;
anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
[layer addAnimation:anim forKey:@"breathingAnimation"];
// 关闭时：removeAnimationForKey + setAlpha:1.0
```

### 阴影（实测，`0xe0e8`）

```objc
layer.shadowOffset  = CGSizeMake(2.0, 2.0);
layer.shadowRadius  = 4.0;
layer.shadowOpacity = 0.8;          // 0x3f4ccdcd
layer.masksToBounds = NO;
layer.shadowPath    = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:r].CGPath;
// 颜色：iOS 13+ 按 userInterfaceStyle 取 getFavoriteShadowBackgroundColorDark / Light
```

关闭时：`setShadowOpacity:0` + `setShadowPath:nil` + `setShadowOffset:CGSizeZero`。


---

## 二、原版 / 重写版 对照

| 项目 | 原版 1.0.0 | 重写版 2.0.0 |
|---|---|---|
| 顶栏入口 | `class_addMethod`，方法已存在则永久失效 | `MSHookMessageEx` + `class_addMethod` 双路径 |
| 使用闸门 | 公众号关注校验 | 无 |
| 头像加载 | 裸 URL，无缓存无占位 | 内存+磁盘缓存、占位图、失败保留占位 |
| 高度公式 | `a+20` / `(a+10)*2+18` | **完全一致**（实测回写） |
| 顶栏容器 | 静态 `UIScrollView`（bss `0x36e68`）+ 每次请求外包一层 `UIView` | **一致**：`-barView` 懒创建单例，`headerViewForWidth:` 返回 clearColor 包装层（`0x7ad0` 的 `0x7c84`–`0x7d8c`） |
| 顶栏背景 | `[UIColor clearColor]`（`0x92c8`） | **一致** |
| 首次显形 | `onlyUnread` 时 alpha 0→1，0.25s（`0x8f00`） | **一致** |
| 点击反馈 | `UIImpactFeedbackGenerator` style 1 + `impactOccurred` | **一致** |
| 角标 | 微信 `MMBadgeView`：`redDotWithNumber:` / `setAsSmallDot` / `sizeToFit` | **一致（优先调用原类，取不到时自绘兜底）** |
| 呼吸动画 | 1.5s，1.0→0.5，default 曲线，已有则跳过 | **完全一致**（实测回写） |
| 阴影 | offset(2,2) / radius 4.0 / opacity 0.8 | **完全一致**（实测回写） |
| 成员清空 | `clearAllMembers` | 已实现（带确认弹窗与数量文案） |
| 成员排序 | 原版无 | **已移除**（上一版误加，本轮摘掉） |
| 微信 API 适配 | 硬编码，异常直接抛 | `respondsToSelector` + `@try` 全隔离 |
| 上下文获取 | 只试 `currentContext` | `currentContext` → `activeUserContext` 双试 |
| 头像字段 | 只读 `m_nsHeadImgUrl` | `m_nsHeadImgUrl` / `LargeUrl` / `SmallUrl` 三试 |
| 刷新时机 | 2 个方法 | 4 个（+ viewDidAppear、配置变更通知） |
| 兜底渲染 | 无 | section header 失效时挂到 tableView 顶部 |
| 配置键 | `ZDHHFavorite*` | 完全沿用，老配置直接继承 |

---

## 三、构建

需要 macOS + [Theos](https://theos.dev)。

```bash
export THEOS=~/theos
cd FavoriteContacts-Rewrite
make package FINALPACKAGE=1
```

产物：`packages/com.zdhh.favoritecontacts_2.0.0_iphoneos-arm64.deb`

只编译不打包：

```bash
make
# .theos/obj/arm64/FavoriteContacts.dylib
```

## 四、安装

```bash
make install          # 需在 Makefile 里配 THEOS_DEVICE_IP
# 或
scp .theos/obj/arm64/FavoriteContacts.dylib root@<device>:/Library/MobileSubstrate/DynamicLibraries/
scp layout/Library/MobileSubstrate/DynamicLibraries/FavoriteContacts.plist root@<device>:/Library/MobileSubstrate/DynamicLibraries/
ssh root@<device> "killall -9 WeChat"
```

必须**卸载原版** `FavoriteContacts.dylib`，两者同时存在会互相覆盖 `NewMainFrameViewController` 的方法。

## 五、验证清单

1. 微信 → 我 → 设置 → 插件，能看到"常用会话"入口
2. 开启总开关 → 首页顶部出现头像栏
3. 点 + 添加成员 → 头像立即出现（无网络时显示首字占位图）
4. 收发消息 → 角标数字实时更新
5. 切换深色模式 → 阴影颜色跟随
6. 关掉再开启总开关 → 栏正确消失/出现（验证无残留）
7. 微信升级后重复 1–4

## 五之二、语法验证（不需要 macOS）

工程自带桩头文件与检查脚本，可在 Windows / Linux 上用 clang 做 iOS ObjC 语义检查：

```bash
pip install libclang
python tools/syntax_check.py
```

当前结果：**5 个源文件全部 `diag=0 errors=0`**。

它会抓出：未声明的方法选择器、类型不匹配、缺 `#import`、ARC 桥接错误、
定义晚于调用、桩里没有的 API 误用。

这套检查的实际战果（本轮修掉的真实问题）：
- `ZDHHMembersViewController.m` 用了 `ZDHHFavoriteBar` 却没 `#import` 对应头文件
- `ZDHHFavoriteBar.m` 用了 `HUGE_VALF` 却没引 `math.h`
- `layer.shadowPath = nil` 在 ARC 下是 `id → CGPathRef` 非法桥接，改 `NULL`

限制：桩头文件是手写的精简版，这是「语法 + 类型 + 方法声明」层面的检查，
**不等于 Theos 真机编译**。链接阶段（substrate、logos 预处理）仍需 macOS + iOS SDK。

## 六、已知限制

- `MMContext` / `CContactMgr` / `MMNewSessionMgr` / `MMMsgLogicManager` 均为微信私有 API，
  微信大版本重构时需要按本文件第一节的方法重新定位。
- **角标已接回 `MMBadgeView`**：`NSClassFromString(@"MMBadgeView")` + `redDotWithNumber:` 创建、
  数量为 1 时 `setAsSmallDot`、`sizeToFit` 后按 `badgeHOffset/badgeVOffset` 定位。
  微信改这个类时 `@try` 会吞掉异常并回退到自绘（`UILabel` / 圆点），保证有未读一定看得见。
- **顶栏容器背景色已确证**：`0x92c8` 处是 `[sBar setBackgroundColor:[UIColor clearColor]]`，
  重写版同为 `clearColor`。`systemGray5Color` 的 selref 存在于设置页路径，与顶栏无关。
- **`barPositionTop` 原版疑似空实现**：`ZDHHGroupManager` 有
  `setFavoriteBarPositionTop:` / `getFavoriteBarPositionTop`，但段表里只有
  `tableView:viewForHeaderInSection:`，没有 footer 版本，`0x7e84` / `0x8628` 里也没读到
  该 selector 的引用。重写版同样只存配置，不改变栏位置。
- **设置项拖拽排序未复刻**：原版 `ZDHHSettingItem` 有 `sortIndex` / `allowsReordering` /
  `configureDraggableItem:` 一整套，用于设置项自身排序，不影响顶栏渲染，未做。
- **成员列表排序已移除**：上一版误加，原版没有该行为，本轮已摘掉。
- 副行栏依赖 `ZDHHFavoriteSecondaryContacts`，与原版键名一致。
- 成员选择器复用微信 `SessionSelectController`，通过 KVC 写入 `m_bMultiSelect` /
  `m_bIgnoreChatRoom` / `ignoreMaxSelectionLimit` / `customTitle` / `m_delegate`；
  某个 key 在特定版本不存在时会被 `@try` 吞掉，选择器仍可打开。
- 未编译验证：本工程在 Windows 上产出，尚未过 macOS + Theos 的编译。
