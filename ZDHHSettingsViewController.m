//
//  ZDHHSettingsViewController.m
//

#import "ZDHHSettingsViewController.h"
#import "ZDHHMembersViewController.h"
#import "ZDHHFavoriteBar.h"
#import "ZDHHCommon.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSInteger, ZDHHSettingRowType) {
    ZDHHSettingRowTypeSwitch = 0,
    ZDHHSettingRowTypeSlider,
    ZDHHSettingRowTypeDisclosure,
    ZDHHSettingRowTypeColor,
};

@interface ZDHHSettingRow : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy, nullable) NSString *subtitle;
@property (nonatomic, assign) ZDHHSettingRowType type;
@property (nonatomic, assign) double minValue;
@property (nonatomic, assign) double maxValue;
@property (nonatomic, assign) double step;
@property (nonatomic, copy, nullable) void (^action)(void);
@property (nonatomic, copy, nullable) BOOL (^getBool)(void);
@property (nonatomic, copy, nullable) void (^setBool)(BOOL);
@property (nonatomic, copy, nullable) double (^getDouble)(void);
@property (nonatomic, copy, nullable) void (^setDouble)(double);
@property (nonatomic, copy, nullable) UIColor *(^getColor)(void);
@property (nonatomic, copy, nullable) void (^setColor)(UIColor *);
+ (instancetype)rowWithTitle:(NSString *)title type:(ZDHHSettingRowType)type;
@end

@implementation ZDHHSettingRow
+ (instancetype)rowWithTitle:(NSString *)title type:(ZDHHSettingRowType)type {
    ZDHHSettingRow *r = [[ZDHHSettingRow alloc] init];
    r.title = title;
    r.type = type;
    return r;
}
@end

@interface ZDHHSettingSection : NSObject
@property (nonatomic, copy, nullable) NSString *header;
@property (nonatomic, copy, nullable) NSString *footer;
@property (nonatomic, strong) NSMutableArray<ZDHHSettingRow *> *rows;
@end

@implementation ZDHHSettingSection
- (instancetype)init {
    if ((self = [super init])) _rows = [NSMutableArray array];
    return self;
}
@end

#pragma mark - 自定义 cell

@interface ZDHHSwitchCell : UITableViewCell
@property (nonatomic, strong) UISwitch *toggle;
@end

@implementation ZDHHSwitchCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
        _toggle = [[UISwitch alloc] init];
        self.accessoryView = _toggle;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.font = [UIFont systemFontOfSize:16];
    }
    return self;
}
@end

@interface ZDHHSliderCell : UITableViewCell
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *valueLabel;
@end

@implementation ZDHHSliderCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.minimumScaleFactor = 0.8;

        _slider = [[UISlider alloc] init];
        _slider.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_slider];

        _valueLabel = [[UILabel alloc] init];
        _valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _valueLabel.font = [UIFont monospacedDigitSystemFontOfSize:14 weight:UIFontWeightRegular];
        _valueLabel.textColor = [UIColor secondaryLabelColor];
        _valueLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_valueLabel];

        // 给左侧标题留固定宽度，避免和滑块重叠
        [NSLayoutConstraint activateConstraints:@[
            [_slider.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:132],
            [_slider.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [_valueLabel.leadingAnchor constraintEqualToAnchor:_slider.trailingAnchor constant:10],
            [_valueLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
            [_valueLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [_valueLabel.widthAnchor constraintEqualToConstant:48],
        ]];
    }
    return self;
}
@end

#pragma mark - 设置页

@interface ZDHHSettingsViewController () <UIColorPickerViewControllerDelegate>
@property (nonatomic, strong) NSMutableArray<ZDHHSettingSection *> *sections;
@property (nonatomic, copy, nullable) void (^colorPickHandler)(UIColor *);

- (void)buildSections;
- (void)toggleChanged:(UISwitch *)sender;
- (void)sliderChanged:(UISlider *)sender;
@end

@implementation ZDHHSettingsViewController

- (instancetype)init {
    if ((self = [super initWithStyle:UITableViewStyleInsetGrouped])) {
        self.title = @"常用会话";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    [self buildSections];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self buildSections];
    [self.tableView reloadData];
}

#pragma mark 构建

- (void)buildSections {
    ZDHHConfig *cfg = [ZDHHConfig shared];
    NSMutableArray *sections = [NSMutableArray array];

    // 0 · 总开关
    {
        ZDHHSettingSection *s = [[ZDHHSettingSection alloc] init];
        s.footer = @"开启后在首页顶部显示头像栏，点击头像直接进入聊天。";

        ZDHHSettingRow *r = [ZDHHSettingRow rowWithTitle:@"启用常用会话" type:ZDHHSettingRowTypeSwitch];
        r.getBool = ^BOOL { return cfg.enabled; };
        r.setBool = ^(BOOL v) { cfg.enabled = v; [[ZDHHFavoriteBar shared] reload]; };
        [s.rows addObject:r];

        [sections addObject:s];
    }

    // 1 · 成员
    {
        ZDHHSettingSection *s = [[ZDHHSettingSection alloc] init];
        s.header = @"成员";
        s.footer = [NSString stringWithFormat:@"当前 %lu 位常用会话。", (unsigned long)cfg.contacts.count];

        ZDHHSettingRow *r = [ZDHHSettingRow rowWithTitle:@"常用会话成员" type:ZDHHSettingRowTypeDisclosure];
        r.subtitle = [NSString stringWithFormat:@"%lu 位", (unsigned long)cfg.contacts.count];
        __weak typeof(self) weakSelf = self;
        r.action = ^{
            __strong typeof(weakSelf) self = weakSelf;
            ZDHHMembersViewController *vc = [[ZDHHMembersViewController alloc] initWithMode:ZDHHMembersModePrimary];
            [self.navigationController pushViewController:vc animated:YES];
        };
        [s.rows addObject:r];

        ZDHHSettingRow *r2 = [ZDHHSettingRow rowWithTitle:@"副行栏" type:ZDHHSettingRowTypeSwitch];
        r2.getBool = ^BOOL { return cfg.secondaryEnabled; };
        r2.setBool = ^(BOOL v) { cfg.secondaryEnabled = v; [[ZDHHFavoriteBar shared] reload]; };
        [s.rows addObject:r2];

        if (cfg.secondaryEnabled) {
            ZDHHSettingRow *r3 = [ZDHHSettingRow rowWithTitle:@"副行成员" type:ZDHHSettingRowTypeDisclosure];
            r3.subtitle = [NSString stringWithFormat:@"%lu 位", (unsigned long)cfg.secondaryContacts.count];
            r3.action = ^{
                __strong typeof(weakSelf) self = weakSelf;
                ZDHHMembersViewController *vc = [[ZDHHMembersViewController alloc] initWithMode:ZDHHMembersModeSecondary];
                [self.navigationController pushViewController:vc animated:YES];
            };
            [s.rows addObject:r3];
        }

        ZDHHSettingRow *r4 = [ZDHHSettingRow rowWithTitle:@"仅显示未读" type:ZDHHSettingRowTypeSwitch];
        r4.getBool = ^BOOL { return cfg.showOnlyUnread; };
        r4.setBool = ^(BOOL v) { cfg.showOnlyUnread = v; [[ZDHHFavoriteBar shared] reload]; };
        [s.rows addObject:r4];

        [sections addObject:s];
    }

    // 2 · 外观
    {
        ZDHHSettingSection *s = [[ZDHHSettingSection alloc] init];
        s.header = @"外观";

        ZDHHSettingRow *size = [ZDHHSettingRow rowWithTitle:@"头像大小" type:ZDHHSettingRowTypeSlider];
        size.minValue = 30; size.maxValue = 80; size.step = 1;
        size.getDouble = ^double { return cfg.avatarSize; };
        size.setDouble = ^(double v) { cfg.avatarSize = v; [[ZDHHFavoriteBar shared] reload]; };
        [s.rows addObject:size];

        ZDHHSettingRow *corner = [ZDHHSettingRow rowWithTitle:@"头像圆角" type:ZDHHSettingRowTypeSlider];
        corner.minValue = 0; corner.maxValue = 40; corner.step = 1;
        corner.getDouble = ^double { return [cfg effectiveCorner]; };
        corner.setDouble = ^(double v) { cfg.avatarCorner = v; [[ZDHHFavoriteBar shared] reload]; };
        [s.rows addObject:corner];

        ZDHHSettingRow *breathing = [ZDHHSettingRow rowWithTitle:@"头像呼吸" type:ZDHHSettingRowTypeSwitch];
        breathing.getBool = ^BOOL { return cfg.breathing; };
        breathing.setBool = ^(BOOL v) { cfg.breathing = v; [[ZDHHFavoriteBar shared] reload]; };
        [s.rows addObject:breathing];

        if (cfg.breathing) {
            ZDHHSettingRow *onlyUnread = [ZDHHSettingRow rowWithTitle:@"仅未读呼吸" type:ZDHHSettingRowTypeSwitch];
            onlyUnread.getBool = ^BOOL { return cfg.breathingOnlyUnread; };
            onlyUnread.setBool = ^(BOOL v) { cfg.breathingOnlyUnread = v; [[ZDHHFavoriteBar shared] reload]; };
            [s.rows addObject:onlyUnread];
        }

        ZDHHSettingRow *shadow = [ZDHHSettingRow rowWithTitle:@"头像阴影" type:ZDHHSettingRowTypeSwitch];
        shadow.getBool = ^BOOL { return cfg.shadow; };
        shadow.setBool = ^(BOOL v) { cfg.shadow = v; [[ZDHHFavoriteBar shared] reload]; };
        [s.rows addObject:shadow];

        if (cfg.shadow) {
            ZDHHSettingRow *light = [ZDHHSettingRow rowWithTitle:@"阴影背景（浅色）" type:ZDHHSettingRowTypeColor];
            light.getColor = ^UIColor * { return cfg.shadowColorLight; };
            light.setColor = ^(UIColor *c) { cfg.shadowColorLight = c; [[ZDHHFavoriteBar shared] reload]; };
            [s.rows addObject:light];

            ZDHHSettingRow *dark = [ZDHHSettingRow rowWithTitle:@"阴影背景（深色）" type:ZDHHSettingRowTypeColor];
            dark.getColor = ^UIColor * { return cfg.shadowColorDark; };
            dark.setColor = ^(UIColor *c) { cfg.shadowColorDark = c; [[ZDHHFavoriteBar shared] reload]; };
            [s.rows addObject:dark];
        }

        [sections addObject:s];
    }

    // 3 · 角标
    {
        ZDHHSettingSection *s = [[ZDHHSettingSection alloc] init];
        s.header = @"未读角标";

        ZDHHSettingRow *normal = [ZDHHSettingRow rowWithTitle:@"普通会话角标" type:ZDHHSettingRowTypeSwitch];
        normal.getBool = ^BOOL { return cfg.showNormalBadge; };
        normal.setBool = ^(BOOL v) { cfg.showNormalBadge = v; [[ZDHHFavoriteBar shared] reload]; };
        [s.rows addObject:normal];

        ZDHHSettingRow *mute = [ZDHHSettingRow rowWithTitle:@"免打扰角标" type:ZDHHSettingRowTypeSwitch];
        mute.getBool = ^BOOL { return cfg.showMuteBadge; };
        mute.setBool = ^(BOOL v) { cfg.showMuteBadge = v; [[ZDHHFavoriteBar shared] reload]; };
        [s.rows addObject:mute];

        ZDHHSettingRow *v = [ZDHHSettingRow rowWithTitle:@"角标垂直偏移" type:ZDHHSettingRowTypeSlider];
        v.minValue = -20; v.maxValue = 20; v.step = 1;
        v.getDouble = ^double { return cfg.badgeVOffset; };
        v.setDouble = ^(double d) { cfg.badgeVOffset = d; [[ZDHHFavoriteBar shared] reload]; };
        [s.rows addObject:v];

        ZDHHSettingRow *h = [ZDHHSettingRow rowWithTitle:@"角标水平偏移" type:ZDHHSettingRowTypeSlider];
        h.minValue = -20; h.maxValue = 20; h.step = 1;
        h.getDouble = ^double { return cfg.badgeHOffset; };
        h.setDouble = ^(double d) { cfg.badgeHOffset = d; [[ZDHHFavoriteBar shared] reload]; };
        [s.rows addObject:h];

        [sections addObject:s];
    }

    // 4 · 关于
    {
        ZDHHSettingSection *s = [[ZDHHSettingSection alloc] init];
        s.header = @"关于";
        s.footer = [NSString stringWithFormat:@"重写版 2.0.0 · 微信 %@", [ZDHHWeChat weChatVersion]];

        ZDHHSettingRow *reset = [ZDHHSettingRow rowWithTitle:@"重置全部设置" type:ZDHHSettingRowTypeDisclosure];
        __weak typeof(self) weakSelf = self;
        reset.action = ^{
            __strong typeof(weakSelf) self = weakSelf;
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"重置全部设置"
                                                                       message:@"将清空所有常用会话与外观配置。"
                                                                preferredStyle:UIAlertControllerStyleAlert];
            [ac addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [ac addAction:[UIAlertAction actionWithTitle:@"重置" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) {
                NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
                for (NSString *k in @[kZDHHKeyEnabled, kZDHHKeyContacts, kZDHHKeyAvatarSize, kZDHHKeyAvatarCorner,
                                      kZDHHKeyBadgeVOffset, kZDHHKeyBadgeHOffset, kZDHHKeyShowNormalBadge,
                                      kZDHHKeyShowMuteBadge, kZDHHKeyBreathing, kZDHHKeyBreathingOnlyUnread,
                                      kZDHHKeyShadow, kZDHHKeyShadowColorLight, kZDHHKeyShadowColorDark,
                                      kZDHHKeyBarPositionTop, kZDHHKeySecondaryEnabled, kZDHHKeySecondaryContacts,
                                      kZDHHKeyShowOnlyUnread]) {
                    [d removeObjectForKey:k];
                }
                [d synchronize];
                [[ZDHHFavoriteBar shared] reload];
                [self buildSections];
                [self.tableView reloadData];
            }]];
            [self presentViewController:ac animated:YES completion:nil];
        };
        [s.rows addObject:reset];

        [sections addObject:s];
    }

    self.sections = sections;
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].rows.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section].header;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return self.sections[section].footer;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZDHHSettingRow *row = self.sections[indexPath.section].rows[indexPath.row];

    switch (row.type) {
        case ZDHHSettingRowTypeSwitch: {
            ZDHHSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sw"];
            if (!cell) cell = [[ZDHHSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sw"];
            cell.textLabel.text = row.title;
            [cell.toggle removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            cell.toggle.on = row.getBool ? row.getBool() : NO;
            objc_setAssociatedObject(cell.toggle, "row", row, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [cell.toggle addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
            return cell;
        }
        case ZDHHSettingRowTypeSlider: {
            ZDHHSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sl"];
            if (!cell) cell = [[ZDHHSliderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sl"];
            cell.textLabel.text = row.title;
            cell.slider.minimumValue = row.minValue;
            cell.slider.maximumValue = row.maxValue;
            cell.slider.value = row.getDouble ? row.getDouble() : 0;
            cell.valueLabel.text = [NSString stringWithFormat:@"%.0f", cell.slider.value];
            objc_setAssociatedObject(cell.slider, "row", row, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [cell.slider removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            [cell.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
            return cell;
        }
        case ZDHHSettingRowTypeColor: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"color"];
            if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"color"];
            cell.textLabel.text = row.title;
            cell.detailTextLabel.text = @"";
            UIColor *c = row.getColor ? row.getColor() : nil;
            UIView *swatch = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
            swatch.backgroundColor = c;
            swatch.layer.cornerRadius = 6;
            swatch.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
            swatch.layer.borderColor = [UIColor separatorColor].CGColor;
            cell.accessoryView = swatch;
            return cell;
        }
        case ZDHHSettingRowTypeDisclosure:
        default: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dc"];
            if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"dc"];
            cell.textLabel.text = row.title;
            cell.detailTextLabel.text = row.subtitle;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZDHHSettingRow *row = self.sections[indexPath.section].rows[indexPath.row];

    if (row.type == ZDHHSettingRowTypeDisclosure && row.action) {
        row.action();
        return;
    }

    if (row.type == ZDHHSettingRowTypeColor && row.getColor) {
        if (@available(iOS 14.0, *)) {
            UIColorPickerViewController *picker = [[UIColorPickerViewController alloc] init];
            picker.selectedColor = row.getColor() ?: [UIColor whiteColor];
            picker.supportsAlpha = NO;
            picker.delegate = self;
            __weak typeof(self) weakSelf = self;
            self.colorPickHandler = ^(UIColor *c) {
                __strong typeof(weakSelf) self = weakSelf;
                if (row.setColor) row.setColor(c);
                [self.tableView reloadData];
            };
            [self presentViewController:picker animated:YES completion:nil];
        }
    }
}

#pragma mark 事件

- (void)toggleChanged:(UISwitch *)sender {
    ZDHHSettingRow *row = objc_getAssociatedObject(sender, "row");
    if (row.setBool) row.setBool(sender.isOn);
    [self buildSections];
    [self.tableView reloadData];
}

- (void)sliderChanged:(UISlider *)sender {
    ZDHHSettingRow *row = objc_getAssociatedObject(sender, "row");
    if (row.step > 0) {
        sender.value = roundf(sender.value / row.step) * row.step;
    }
    if (row.setDouble) row.setDouble(sender.value);

    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
    if ([cell isKindOfClass:[ZDHHSliderCell class]]) {
        ((ZDHHSliderCell *)cell).valueLabel.text = [NSString stringWithFormat:@"%.0f", sender.value];
    }
}

#pragma mark UIColorPickerViewControllerDelegate

- (void)colorPickerViewControllerDidSelectColor:(UIColorPickerViewController *)viewController {
    if (self.colorPickHandler) self.colorPickHandler(viewController.selectedColor);
}

- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController {
    if (self.colorPickHandler) self.colorPickHandler(viewController.selectedColor);
    self.colorPickHandler = nil;
}

@end
