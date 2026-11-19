//
//  ZDHHMembersViewController.m
//

#import "ZDHHMembersViewController.h"
#import "ZDHHCommon.h"
#import "ZDHHFavoriteBar.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface ZDHHMemberCell : UITableViewCell
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *wxidLabel;
@end

@implementation ZDHHMemberCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.translatesAutoresizingMaskIntoConstraints = NO;
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarView.clipsToBounds = YES;
        _avatarView.layer.cornerRadius = 20;
        _avatarView.backgroundColor = [UIColor tertiarySystemFillColor];
        [self.contentView addSubview:_avatarView];

        _nameLabel = [[UILabel alloc] init];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        _nameLabel.textColor = [UIColor labelColor];
        [self.contentView addSubview:_nameLabel];

        _wxidLabel = [[UILabel alloc] init];
        _wxidLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _wxidLabel.font = [UIFont systemFontOfSize:12];
        _wxidLabel.textColor = [UIColor secondaryLabelColor];
        [self.contentView addSubview:_wxidLabel];

        [NSLayoutConstraint activateConstraints:@[
            [_avatarView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
            [_avatarView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [_avatarView.widthAnchor constraintEqualToConstant:40],
            [_avatarView.heightAnchor constraintEqualToConstant:40],

            [_nameLabel.leadingAnchor constraintEqualToAnchor:_avatarView.trailingAnchor constant:12],
            [_nameLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
            [_nameLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:10],

            [_wxidLabel.leadingAnchor constraintEqualToAnchor:_nameLabel.leadingAnchor],
            [_wxidLabel.trailingAnchor constraintEqualToAnchor:_nameLabel.trailingAnchor],
            [_wxidLabel.topAnchor constraintEqualToAnchor:_nameLabel.bottomAnchor constant:2],
        ]];
    }
    return self;
}

@end

@interface ZDHHMembersViewController ()
@property (nonatomic, assign) ZDHHMembersMode mode;
@property (nonatomic, strong) NSMutableArray<NSString *> *items;

- (void)reloadItems;
- (void)updateClearButton;
- (void)clearTapped;
- (void)persist;
- (void)addTapped;
- (void)presentManualInput;
- (void)presentSessionSelectController;
- (void)appendWxids:(NSArray<NSString *> *)wxids;
@end

@implementation ZDHHMembersViewController

- (instancetype)initWithMode:(ZDHHMembersMode)mode {
    if ((self = [super initWithStyle:UITableViewStyleInsetGrouped])) {
        _mode = mode;
        self.title = (mode == ZDHHMembersModePrimary) ? @"常用会话成员" : @"副行成员";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];

    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                        target:self
                                                                        action:@selector(addTapped)];
    self.navigationItem.rightBarButtonItem = add;
    [self reloadItems];
}

- (void)reloadItems {
    ZDHHConfig *cfg = [ZDHHConfig shared];
    self.items = [(self.mode == ZDHHMembersModePrimary ? cfg.contacts : cfg.secondaryContacts) mutableCopy];
    [self updateClearButton];
    [self.tableView reloadData];
}

/// 原版有 clearAllMembers（0x1e80 / 0x1eecc），对应文案「清空所有 %ld 个成员」
- (void)updateClearButton {
    if (self.items.count > 0) {
        self.navigationItem.leftBarButtonItem =
            [[UIBarButtonItem alloc] initWithTitle:@"清空"
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:@selector(clearTapped)];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)clearTapped {
    NSString *message = [NSString stringWithFormat:@"确定要清空所有 %lu 个成员吗？",
                         (unsigned long)self.items.count];
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"清空成员"
                                                                message:message
                                                         preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [ac addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [ac addAction:[UIAlertAction actionWithTitle:@"清空" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) {
        __strong typeof(weakSelf) self = weakSelf;
        [self.items removeAllObjects];
        [self persist];
        [self updateClearButton];
        [self.tableView reloadData];
    }]];
    [self presentViewController:ac animated:YES completion:nil];
}

#pragma mark 数据

- (void)persist {
    ZDHHConfig *cfg = [ZDHHConfig shared];
    if (self.mode == ZDHHMembersModePrimary) {
        cfg.contacts = self.items;
    } else {
        cfg.secondaryContacts = self.items;
    }
    [[ZDHHFavoriteBar shared] reload];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return self.items.count ? @"左滑可删除成员" : @"还没有成员，点右上角 + 添加。";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZDHHMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"m"];
    if (!cell) cell = [[ZDHHMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"m"];

    NSString *wxid = self.items[indexPath.row];
    NSString *name = [ZDHHWeChat displayNameForWxid:wxid];
    cell.nameLabel.text = name;
    cell.wxidLabel.text = wxid;
    cell.avatarView.image = ZDHHPlaceholderAvatarImage(name, 40);

    // 头像异步补全
    __weak typeof(cell) weakCell = cell;
    NSString *urlStr = [ZDHHWeChat headImageURLForWxid:wxid];
    if (urlStr.length) {
        NSURL *url = [NSURL URLWithString:urlStr];
        if (url) {
            [[[NSURLSession sharedSession] dataTaskWithURL:url
                                        completionHandler:^(NSData *data, NSURLResponse *r, NSError *e) {
                if (!data.length || e) return;
                UIImage *img = [UIImage imageWithData:data];
                if (!img) return;
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(weakCell) c = weakCell;
                    if (c.wxidLabel.text.length && [c.wxidLabel.text isEqualToString:wxid]) {
                        c.avatarView.image = img;
                    }
                });
            }] resume];
        }
    }
    return cell;
}

#pragma mark 删除

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) return;
    [self.items removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self persist];
    [self updateClearButton];
}

#pragma mark 添加

- (void)addTapped {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];

    __weak typeof(self) weakSelf = self;
    [sheet addAction:[UIAlertAction actionWithTitle:@"从会话列表选择"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *a) {
        __strong typeof(weakSelf) self = weakSelf;
        [self presentSessionSelectController];
    }]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"手动输入微信号"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *a) {
        __strong typeof(weakSelf) self = weakSelf;
        [self presentManualInput];
    }]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

    sheet.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)presentManualInput {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"输入微信号"
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac addTextFieldWithConfigurationHandler:^(UITextField *tf) {
        tf.placeholder = @"微信ID";
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }];
    __weak typeof(self) weakSelf = self;
    [ac addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [ac addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        __strong typeof(weakSelf) self = weakSelf;
        NSString *wxid = [ac.textFields.firstObject.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (!wxid.length) return;
        [self appendWxids:@[wxid]];
    }]];
    [self presentViewController:ac animated:YES completion:nil];
}

/// 调微信原生会话选择器；调不到就退回手动输入
- (void)presentSessionSelectController {
    Class SSC = NSClassFromString(@"SessionSelectController");
    if (!SSC) {
        [self presentManualInput];
        return;
    }

    UIViewController *picker = nil;
    @try {
        picker = [[SSC alloc] init];
    } @catch (__unused NSException *e) {
        picker = nil;
    }
    if (!picker) {
        [self presentManualInput];
        return;
    }

    // 这些键名来自原版二进制里实际用过的 KVC key
    @try {
        [picker setValue:@(YES) forKey:@"m_bMultiSelect"];
        [picker setValue:@(YES) forKey:@"m_bIgnoreChatRoom"];
        [picker setValue:@(YES) forKey:@"ignoreMaxSelectionLimit"];
        [picker setValue:@"选择会话" forKey:@"customTitle"];
        [picker setValue:self forKey:@"m_delegate"];
    } @catch (__unused NSException *e) {
        // 某个 key 不存在时忽略，选择器仍可打开
    }

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
    [self presentViewController:nav animated:YES completion:nil];
}

/// 原版 SessionSelectController 的回调签名，保持完全一致才能被调用
- (void)OnSelectSessions:(id)sessions SessionSelectController:(id)controller {
    NSMutableArray *wxids = [NSMutableArray array];

    if ([sessions isKindOfClass:[NSArray class]]) {
        for (id item in (NSArray *)sessions) {
            NSString *wxid = nil;
            if ([item isKindOfClass:[NSString class]]) {
                wxid = item;
            } else {
                id v = ZDHHSafeValue(item, @"m_nsUserName");
                if ([v isKindOfClass:[NSString class]]) wxid = v;
            }
            if (wxid.length) [wxids addObject:wxid];
        }
    }

    [self dismissViewControllerAnimated:YES completion:^{
        [self appendWxids:wxids];
    }];
}

- (void)OnSelectSessionCancel:(id)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)appendWxids:(NSArray<NSString *> *)wxids {
    NSInteger added = 0;
    for (NSString *wxid in wxids) {
        if (![self.items containsObject:wxid]) {
            [self.items addObject:wxid];
            added++;
        }
    }
    if (added) {
        [self persist];
        [self updateClearButton];
        [self.tableView reloadData];
    }
}

@end
