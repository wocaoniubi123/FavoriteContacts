//
//  ZDHHMembersViewController.h
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ZDHHMembersMode) {
    ZDHHMembersModePrimary = 0,
    ZDHHMembersModeSecondary,
};

@interface ZDHHMembersViewController : UITableViewController
- (instancetype)initWithMode:(ZDHHMembersMode)mode;
@end

NS_ASSUME_NONNULL_END
