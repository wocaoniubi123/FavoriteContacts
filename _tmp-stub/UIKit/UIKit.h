// 桩头文件：仅用于 libclang 语法/语义检查。
#pragma once

#import <Foundation/Foundation.h>

#pragma mark - 前置类型（必须早于使用）

typedef struct CGContext *CGContextRef;
typedef struct CGColor *CGColorRef;
typedef struct CGPath *CGPathRef;
typedef struct CGImage *CGImageRef;

@class UIColor, UIFont, UIImage, UITraitCollection, UILayoutGuide, UIView;
@class NSLayoutXAxisAnchor, NSLayoutYAxisAnchor, NSLayoutDimension, NSLayoutConstraint;
@class UIViewController, UITableView, UITableViewCell, UIGestureRecognizer;
@class UIPopoverPresentationController, UIBarButtonItem, UINavigationBar;
@class UINavigationController, UITabBarController, UIWindow, UIScene, UIWindowScene;
@class UIGraphicsImageRenderer, UIGraphicsImageRendererContext, UIGraphicsImageRendererFormat;
@class UILabel, UIImageView, UISwitch, UISlider, UITextField, UIButton, UIScrollView;
@class UINavigationItem, UIAlertController, UIAlertAction, UIScreen, UIApplication;
@class CALayer, CAAnimation, CABasicAnimation, CAMediaTimingFunction;
@class UIBezierPath, UIImpactFeedbackGenerator, UIColorPickerViewController;

#pragma mark - 枚举

typedef NS_ENUM(NSInteger, UIViewAnimationOptions) {
    UIViewAnimationOptionLayoutSubviews = 1 << 0,
    UIViewAnimationOptionAllowUserInteraction = 1 << 1,
    UIViewAnimationOptionBeginFromCurrentState = 1 << 2,
    UIViewAnimationOptionRepeat = 1 << 3,
    UIViewAnimationOptionAutoreverse = 1 << 4,
    UIViewAnimationOptionOverrideInheritedDuration = 1 << 5,
    UIViewAnimationOptionOverrideInheritedCurve = 1 << 6,
    UIViewAnimationOptionAllowAnimatedContent = 1 << 7,
    UIViewAnimationOptionShowHideTransitionViews = 1 << 8,
    UIViewAnimationOptionCurveEaseInOut = 0 << 16,
    UIViewAnimationOptionCurveEaseIn = 1 << 16,
    UIViewAnimationOptionCurveEaseOut = 2 << 16,
    UIViewAnimationOptionCurveLinear = 3 << 16
};

typedef NS_OPTIONS(NSUInteger, UIViewAutoresizing) {
    UIViewAutoresizingNone = 0,
    UIViewAutoresizingFlexibleLeftMargin = 1 << 0,
    UIViewAutoresizingFlexibleWidth = 1 << 1,
    UIViewAutoresizingFlexibleRightMargin = 1 << 2,
    UIViewAutoresizingFlexibleTopMargin = 1 << 3,
    UIViewAutoresizingFlexibleHeight = 1 << 4,
    UIViewAutoresizingFlexibleBottomMargin = 1 << 5
};

typedef NS_ENUM(NSInteger, UIViewContentMode) {
    UIViewContentModeScaleToFill,
    UIViewContentModeScaleAspectFit,
    UIViewContentModeScaleAspectFill,
    UIViewContentModeRedraw,
    UIViewContentModeCenter
};

typedef NS_ENUM(NSInteger, UIUserInterfaceStyle) {
    UIUserInterfaceStyleUnspecified = 0,
    UIUserInterfaceStyleLight = 1,
    UIUserInterfaceStyleDark = 2
};

typedef NS_ENUM(NSInteger, NSTextAlignment) {
    NSTextAlignmentLeft = 0,
    NSTextAlignmentCenter = 1,
    NSTextAlignmentRight = 2,
    NSTextAlignmentJustified = 3,
    NSTextAlignmentNatural = 4
};

typedef NS_ENUM(NSInteger, UITableViewStyle) {
    UITableViewStylePlain = 0,
    UITableViewStyleGrouped = 1,
    UITableViewStyleInsetGrouped = 2
};

typedef NS_ENUM(NSInteger, UITableViewCellStyle) {
    UITableViewCellStyleDefault = 0,
    UITableViewCellStyleValue1 = 1,
    UITableViewCellStyleValue2 = 2,
    UITableViewCellStyleSubtitle = 3
};

typedef NS_ENUM(NSInteger, UITableViewCellSelectionStyle) {
    UITableViewCellSelectionStyleNone = 0,
    UITableViewCellSelectionStyleBlue = 1,
    UITableViewCellSelectionStyleGray = 2,
    UITableViewCellSelectionStyleDefault = 3
};

typedef NS_ENUM(NSInteger, UITableViewCellAccessoryType) {
    UITableViewCellAccessoryNone = 0,
    UITableViewCellAccessoryDisclosureIndicator = 1,
    UITableViewCellAccessoryDetailDisclosureButton = 2,
    UITableViewCellAccessoryCheckmark = 3,
    UITableViewCellAccessoryDetailButton = 4
};

typedef NS_ENUM(NSInteger, UITableViewCellEditingStyle) {
    UITableViewCellEditingStyleNone = 0,
    UITableViewCellEditingStyleDelete = 1,
    UITableViewCellEditingStyleInsert = 2
};

typedef NS_ENUM(NSInteger, UITableViewRowAnimation) {
    UITableViewRowAnimationFade = 0,
    UITableViewRowAnimationRight = 1,
    UITableViewRowAnimationLeft = 2,
    UITableViewRowAnimationTop = 3,
    UITableViewRowAnimationBottom = 4,
    UITableViewRowAnimationNone = 5,
    UITableViewRowAnimationMiddle = 6,
    UITableViewRowAnimationAutomatic = 100
};

typedef NS_ENUM(NSInteger, UIAlertControllerStyle) {
    UIAlertControllerStyleActionSheet = 0,
    UIAlertControllerStyleAlert = 1
};

typedef NS_ENUM(NSInteger, UIAlertActionStyle) {
    UIAlertActionStyleDefault = 0,
    UIAlertActionStyleCancel = 1,
    UIAlertActionStyleDestructive = 2
};

typedef NS_ENUM(NSInteger, UIBarButtonSystemItem) {
    UIBarButtonSystemItemDone = 0,
    UIBarButtonSystemItemCancel = 1,
    UIBarButtonSystemItemAdd = 4,
    UIBarButtonSystemItemFlexibleSpace = 5,
    UIBarButtonSystemItemFixedSpace = 6,
    UIBarButtonSystemItemEdit = 8
};

typedef NS_ENUM(NSInteger, UIBarButtonItemStyle) {
    UIBarButtonItemStylePlain = 0,
    UIBarButtonItemStyleBordered = 1,
    UIBarButtonItemStyleDone = 2
};

typedef NS_ENUM(NSInteger, UIImpactFeedbackStyle) {
    UIImpactFeedbackStyleLight = 0,
    UIImpactFeedbackStyleMedium = 1,
    UIImpactFeedbackStyleHeavy = 2,
    UIImpactFeedbackStyleSoft = 3,
    UIImpactFeedbackStyleRigid = 4
};

typedef NS_ENUM(NSInteger, UITextAutocapitalizationType) {
    UITextAutocapitalizationTypeNone = 0,
    UITextAutocapitalizationTypeWords = 1,
    UITextAutocapitalizationTypeSentences = 2,
    UITextAutocapitalizationTypeAllCharacters = 3
};

typedef NS_ENUM(NSInteger, UITextFieldViewMode) {
    UITextFieldViewModeNever = 0,
    UITextFieldViewModeWhileEditing = 1,
    UITextFieldViewModeUnlessEditing = 2,
    UITextFieldViewModeAlways = 3
};

typedef NS_OPTIONS(NSUInteger, UIControlEvents) {
    UIControlEventTouchDown = 1 << 0,
    UIControlEventTouchUpInside = 1 << 6,
    UIControlEventValueChanged = 1 << 12,
    UIControlEventEditingDidBegin = 1 << 16,
    UIControlEventEditingChanged = 1 << 17,
    UIControlEventEditingDidEnd = 1 << 18,
    UIControlEventAllEvents = 0xFFFFFFFFFFFFFFFF
};

typedef NS_ENUM(NSInteger, UIControlState) {
    UIControlStateNormal = 0,
    UIControlStateHighlighted = 1 << 0,
    UIControlStateDisabled = 1 << 1,
    UIControlStateSelected = 1 << 2
};

typedef NS_ENUM(NSInteger, UIControlContentHorizontalAlignment) {
    UIControlContentHorizontalAlignmentCenter = 0,
    UIControlContentHorizontalAlignmentLeft = 1,
    UIControlContentHorizontalAlignmentRight = 2,
    UIControlContentHorizontalAlignmentFill = 3
};

typedef NS_ENUM(NSInteger, UIControlContentVerticalAlignment) {
    UIControlContentVerticalAlignmentCenter = 0,
    UIControlContentVerticalAlignmentTop = 1,
    UIControlContentVerticalAlignmentBottom = 2,
    UIControlContentVerticalAlignmentFill = 3
};

typedef NS_ENUM(NSInteger, UIButtonType) {
    UIButtonTypeCustom = 0,
    UIButtonTypeSystem = 1
};

typedef NS_OPTIONS(NSUInteger, UIAccessibilityTraits) {
    UIAccessibilityTraitNone = 0,
    UIAccessibilityTraitButton = 1 << 0,
    UIAccessibilityTraitSelected = 1 << 6
};

typedef NS_ENUM(NSInteger, UILayoutConstraintAxis) {
    UILayoutConstraintAxisHorizontal = 0,
    UILayoutConstraintAxisVertical = 1
};

#pragma mark - CALayer（QuartzCore 桩内联）

@interface CALayer : NSObject
@property CGFloat cornerRadius;
@property BOOL masksToBounds;
@property CGRect bounds;
@property CGRect frame;
@property CGPoint position;
@property CGFloat borderWidth;
@property CGColorRef borderColor;
@property float opacity;
@property float shadowOpacity;
@property CGColorRef shadowColor;
@property CGSize shadowOffset;
@property CGFloat shadowRadius;
@property CGPathRef shadowPath;
@property BOOL allowsEdgeAntialiasing;
- (void)addAnimation:(id)anim forKey:(NSString *)key;
- (id)animationForKey:(NSString *)key;
- (void)removeAnimationForKey:(NSString *)key;
- (void)removeAllAnimations;
- (void)setNeedsDisplay;
@end

@interface CAMediaTimingFunction : NSObject
+ (instancetype)functionWithName:(NSString *)name;
@end

extern NSString *const kCAMediaTimingFunctionDefault;
extern NSString *const kCAMediaTimingFunctionEaseInEaseOut;
extern NSString *const kCAMediaTimingFunctionLinear;

@interface CAAnimation : NSObject
@property double duration;
@property double beginTime;
@property (copy) NSString *removedOnCompletion;
@end

@interface CABasicAnimation : CAAnimation
+ (instancetype)animationWithKeyPath:(NSString *)path;
@property (strong) id fromValue;
@property (strong) id toValue;
@property (strong) id byValue;
@property BOOL autoreverses;
@property float repeatCount;
@property double repeatDuration;
@property (strong) CAMediaTimingFunction *timingFunction;
@end

#pragma mark - UIGraphics

typedef struct UIGraphicsImageRendererFormat *UIGraphicsImageRendererFormatRef;

@interface UIGraphicsImageRendererFormat : NSObject
+ (instancetype)defaultFormat;
@property BOOL opaque;
@property CGFloat scale;
@end

@interface UIGraphicsImageRendererContext : NSObject
@property (readonly) CGContextRef CGContext;
@end

@interface UIGraphicsImageRenderer : NSObject
- (instancetype)initWithSize:(CGSize)size;
- (instancetype)initWithSize:(CGSize)size format:(UIGraphicsImageRendererFormat *)format;
- (UIImage *)imageWithActions:(void (^)(UIGraphicsImageRendererContext *ctx))actions;
@end

#pragma mark - UIImage

@interface UIImage : NSObject
@property (readonly) CGSize size;
@property (readonly) CGFloat scale;
+ (instancetype)imageWithData:(NSData *)data;
+ (instancetype)imageNamed:(NSString *)name;
+ (instancetype)imageWithContentsOfFile:(NSString *)path;
+ (instancetype)imageWithCGImage:(CGImageRef)cgImage;
@property (readonly) CGImageRef CGImage;
@end

extern NSData *UIImagePNGRepresentation(UIImage *image);
extern NSData *UIImageJPEGRepresentation(UIImage *image, CGFloat quality);

@interface UIImageSymbolConfiguration : NSObject
+ (instancetype)configurationWithPointSize:(CGFloat)pointSize weight:(CGFloat)weight;
+ (instancetype)configurationWithTextStyle:(NSString *)style;
@end

@interface UIFont : NSObject
+ (UIFont *)systemFontOfSize:(CGFloat)size;
+ (UIFont *)systemFontOfSize:(CGFloat)size weight:(CGFloat)weight;
+ (UIFont *)boldSystemFontOfSize:(CGFloat)size;
+ (UIFont *)monospacedDigitSystemFontOfSize:(CGFloat)size weight:(CGFloat)weight;
+ (UIFont *)fontWithName:(NSString *)name size:(CGFloat)size;
@property (readonly) CGFloat pointSize;
extern NSString *const NSFontAttributeName;
extern NSString *const NSForegroundColorAttributeName;
extern NSString *const NSBackgroundColorAttributeName;
extern NSString *const NSParagraphStyleAttributeName;
extern const CGFloat UIFontWeightRegular;
extern const CGFloat UIFontWeightMedium;
extern const CGFloat UIFontWeightSemibold;
extern const CGFloat UIFontWeightBold;
@end

#pragma mark - UIColor

@interface UIColor : NSObject <NSCopying>
+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
+ (UIColor *)colorWithWhite:(CGFloat)white alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;
+ (UIColor *)clearColor;
+ (UIColor *)whiteColor;
+ (UIColor *)blackColor;
+ (UIColor *)redColor;
+ (UIColor *)blueColor;
+ (UIColor *)greenColor;
+ (UIColor *)grayColor;
+ (UIColor *)systemRedColor;
+ (UIColor *)systemBlueColor;
+ (UIColor *)systemGreenColor;
+ (UIColor *)systemYellowColor;
+ (UIColor *)systemOrangeColor;
+ (UIColor *)systemPurpleColor;
+ (UIColor *)systemTealColor;
+ (UIColor *)systemPinkColor;
+ (UIColor *)systemIndigoColor;
+ (UIColor *)systemCyanColor;
+ (UIColor *)systemGrayColor;
+ (UIColor *)systemGray2Color;
+ (UIColor *)systemGray3Color;
+ (UIColor *)systemGray4Color;
+ (UIColor *)systemGray5Color;
+ (UIColor *)systemGray6Color;
+ (UIColor *)labelColor;
+ (UIColor *)secondaryLabelColor;
+ (UIColor *)tertiaryLabelColor;
+ (UIColor *)separatorColor;
+ (UIColor *)systemGroupedBackgroundColor;
+ (UIColor *)secondarySystemGroupedBackgroundColor;
+ (UIColor *)tertiarySystemGroupedBackgroundColor;
+ (UIColor *)systemBackgroundColor;
+ (UIColor *)secondarySystemBackgroundColor;
+ (UIColor *)tertiarySystemFillColor;
+ (UIColor *)systemFillColor;
- (BOOL)getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha;
- (BOOL)getWhite:(CGFloat *)white alpha:(CGFloat *)alpha;
- (void)set;
- (void)setFill;
- (void)setStroke;
@property (readonly) CGColorRef CGColor;
@end

#pragma mark - UIResponder / UIView

@interface UIResponder : NSObject
@property (readonly) UIResponder *nextResponder;
- (BOOL)canBecomeFirstResponder;
- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;
@end

@interface UIView : UIResponder
@property CGRect frame;
@property CGRect bounds;
@property CGPoint center;
@property (copy) UIColor *backgroundColor;
@property CGFloat alpha;
@property BOOL hidden;
@property NSInteger tag;
@property BOOL clipsToBounds;
@property BOOL userInteractionEnabled;
@property BOOL opaque;
@property UIViewAutoresizing autoresizingMask;
@property (readonly) UIView *superview;
@property (readonly, copy) NSArray<UIView *> *subviews;
@property (readonly) CALayer *layer;
@property (readonly) UITraitCollection *traitCollection;
@property UIViewContentMode contentMode;
@property (copy) NSString *accessibilityIdentifier;
@property (copy) NSString *accessibilityLabel;
@property UIAccessibilityTraits accessibilityTraits;
@property BOOL isAccessibilityElement;
@property BOOL translatesAutoresizingMaskIntoConstraints;
@property (readonly) NSLayoutXAxisAnchor *leadingAnchor;
@property (readonly) NSLayoutXAxisAnchor *trailingAnchor;
@property (readonly) NSLayoutYAxisAnchor *topAnchor;
@property (readonly) NSLayoutYAxisAnchor *bottomAnchor;
@property (readonly) NSLayoutXAxisAnchor *centerXAnchor;
@property (readonly) NSLayoutYAxisAnchor *centerYAnchor;
@property (readonly) NSLayoutDimension *widthAnchor;
@property (readonly) NSLayoutDimension *heightAnchor;
@property (readonly) UILayoutGuide *safeAreaLayoutGuide;

+ (instancetype)alloc;
+ (void)animateWithDuration:(double)duration
                      delay:(double)delay
                    options:(UIViewAnimationOptions)options
                 animations:(void (^)(void))animations
                 completion:(void (^)(BOOL finished))completion;
+ (void)animateWithDuration:(double)duration animations:(void (^)(void))animations;
+ (void)animateWithDuration:(double)duration animations:(void (^)(void))animations completion:(void (^)(BOOL))completion;
+ (void)performWithoutAnimation:(void (^)(void))actions;
- (instancetype)initWithFrame:(CGRect)frame;
- (void)addSubview:(UIView *)view;
- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index;
- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview;
- (void)removeFromSuperview;
- (UIView *)viewWithTag:(NSInteger)tag;
- (void)setNeedsLayout;
- (void)layoutIfNeeded;
- (void)layoutSubviews;
- (void)setFrame:(CGRect)frame;
- (void)setBounds:(CGRect)bounds;
- (void)setBackgroundColor:(UIColor *)color;
- (void)setAlpha:(CGFloat)alpha;
- (void)setTag:(NSInteger)tag;
- (void)setHidden:(BOOL)hidden;
- (void)sizeToFit;
- (CGSize)sizeThatFits:(CGSize)size;
- (void)addGestureRecognizer:(UIGestureRecognizer *)gr;
- (void)removeGestureRecognizer:(UIGestureRecognizer *)gr;
- (void)setContentMode:(UIViewContentMode)mode;
- (void)setUserInteractionEnabled:(BOOL)enabled;
- (void)traitCollectionDidChange:(UITraitCollection *)previous;
- (UIView *)hitTest:(CGPoint)point withEvent:(id)event;
- (CGPoint)convertPoint:(CGPoint)point fromView:(UIView *)view;
- (CGRect)convertRect:(CGRect)rect fromView:(UIView *)view;
@end

@interface UIWindow : UIView
@property (strong) UIViewController *rootViewController;
@property (readonly) BOOL isKeyWindow;
- (void)makeKeyAndVisible;
@end

@interface UILayoutGuide : NSObject
@end

@interface NSLayoutConstraint : NSObject
+ (void)activateConstraints:(NSArray<NSLayoutConstraint *> *)constraints;
+ (void)deactivateConstraints:(NSArray<NSLayoutConstraint *> *)constraints;
@property BOOL active;
+ (instancetype)constraintWithItem:(id)view1 attribute:(NSInteger)attr1 relatedBy:(NSInteger)relation toItem:(id)view2 attribute:(NSInteger)attr2 multiplier:(CGFloat)multiplier constant:(CGFloat)c;
@end

@interface NSLayoutAnchor<AnchorType> : NSObject
- (NSLayoutConstraint *)constraintEqualToAnchor:(AnchorType)anchor;
- (NSLayoutConstraint *)constraintEqualToAnchor:(AnchorType)anchor constant:(CGFloat)c;
- (NSLayoutConstraint *)constraintGreaterThanOrEqualToAnchor:(AnchorType)anchor constant:(CGFloat)c;
- (NSLayoutConstraint *)constraintLessThanOrEqualToAnchor:(AnchorType)anchor constant:(CGFloat)c;
@end

@interface NSLayoutXAxisAnchor : NSLayoutAnchor<NSLayoutXAxisAnchor *>
@end
@interface NSLayoutYAxisAnchor : NSLayoutAnchor<NSLayoutYAxisAnchor *>
@end
@interface NSLayoutDimension : NSLayoutAnchor<NSLayoutDimension *>
- (NSLayoutConstraint *)constraintEqualToConstant:(CGFloat)c;
- (NSLayoutConstraint *)constraintGreaterThanOrEqualToConstant:(CGFloat)c;
@end

#pragma mark - UIScrollView / UITableView

@interface UIImageView : UIView
- (instancetype)initWithImage:(UIImage *)image;
@property (strong) UIImage *image;
@property (strong) UIImage *highlightedImage;
@property (copy) UIColor *tintColor;
@end

@interface UIScrollView : UIView
@property CGSize contentSize;
@property CGPoint contentOffset;
@property UIEdgeInsets contentInset;
@property BOOL showsHorizontalScrollIndicator;
@property BOOL showsVerticalScrollIndicator;
@property BOOL alwaysBounceHorizontal;
@property BOOL alwaysBounceVertical;
@property BOOL scrollEnabled;
@property BOOL pagingEnabled;
@property (readonly) BOOL isTracking;
@end

@interface UITableViewCell : UIView
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@property (readonly) UILabel *textLabel;
@property (readonly) UILabel *detailTextLabel;
@property (readonly) UIView *contentView;
@property (readonly) UIImageView *imageView;
@property (strong) UIView *accessoryView;
@property UITableViewCellAccessoryType accessoryType;
@property UITableViewCellSelectionStyle selectionStyle;
@property (copy) NSString *reuseIdentifier;
@property (strong) UIView *backgroundView;
@property (strong) UIView *selectedBackgroundView;
@property (readonly) BOOL isEditing;
- (void)prepareForReuse;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;
@end

@class UITableView;

@protocol UITableViewDataSource <NSObject>
@required
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
@end

@protocol UITableViewDelegate <NSObject>
@optional
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface UITableView : UIScrollView
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;
@property (weak) id<UITableViewDataSource> dataSource;
@property (weak) id<UITableViewDelegate> delegate;
@property (strong) UIView *tableHeaderView;
@property (strong) UIView *tableFooterView;
@property (strong) UIView *backgroundView;
@property BOOL editing;
@property NSInteger separatorStyle;
@property CGFloat rowHeight;
@property CGFloat sectionHeaderHeight;
@property CGFloat sectionFooterHeight;
@property CGFloat estimatedRowHeight;
@property (readonly) NSInteger numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (void)reloadData;
- (void)reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)beginUpdates;
- (void)endUpdates;
- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(id)nib forCellReuseIdentifier:(NSString *)identifier;
- (__kindof UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (__kindof UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForCell:(UITableViewCell *)cell;
- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(NSInteger)position;
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;
- (void)deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
@end

#pragma mark - 控件

@interface UIControl : UIView
@property (readonly) BOOL isEnabled;
@property (readonly) BOOL isSelected;
@property (readonly) BOOL isHighlighted;
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents;
@end

@interface UIButton : UIControl
+ (instancetype)buttonWithType:(UIButtonType)buttonType;
- (void)setTitle:(NSString *)title forState:(UIControlState)state;
- (void)setImage:(UIImage *)image forState:(UIControlState)state;
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state;
- (void)setContentHorizontalAlignment:(UIControlContentHorizontalAlignment)alignment;
- (void)setContentVerticalAlignment:(UIControlContentVerticalAlignment)alignment;
@property (readonly) UILabel *titleLabel;
@property (readonly) UIImageView *imageView;
@end

@interface UILabel : UIView
@property (copy) NSString *text;
@property (strong) UIFont *font;
@property (strong) UIColor *textColor;
@property NSTextAlignment textAlignment;
@property NSInteger numberOfLines;
@property BOOL adjustsFontSizeToFitWidth;
@property CGFloat minimumScaleFactor;
@property (strong) UIColor *shadowColor;
@property CGSize shadowOffset;
@end

@interface UISwitch : UIControl
@property BOOL on;
- (void)setOn:(BOOL)on animated:(BOOL)animated;
@property (readonly) BOOL isOn;
@property (strong) UIColor *onTintColor;
@end

@interface UISlider : UIControl
@property float minimumValue;
@property float maximumValue;
@property float value;
@property (readonly) BOOL isContinuous;
- (void)setValue:(float)value animated:(BOOL)animated;
- (void)setContinuous:(BOOL)continuous;
- (void)setMinimumValue:(float)v;
- (void)setMaximumValue:(float)v;
@end

@interface UISegmentedControl : UIControl
- (instancetype)initWithItems:(NSArray *)items;
@property NSInteger selectedSegmentIndex;
@property (readonly) NSInteger numberOfSegments;
- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment;
@end

@interface UITextField : UIControl
@property (copy) NSString *text;
@property (copy) NSString *placeholder;
@property UITextFieldViewMode clearButtonMode;
@property UITextAutocapitalizationType autocapitalizationType;
@property NSInteger keyboardType;
@property NSInteger textAlignment;
@property (strong) UIFont *font;
@end

@interface UITextView : UIScrollView
@property (copy) NSString *text;
@end

@interface UIGestureRecognizer : NSObject
- (instancetype)initWithTarget:(id)target action:(SEL)action;
@property (readonly) UIView *view;
@property BOOL enabled;
- (void)addTarget:(id)target action:(SEL)action;
@end

@interface UITapGestureRecognizer : UIGestureRecognizer
@property NSUInteger numberOfTapsRequired;
@end

@interface UIImpactFeedbackGenerator : NSObject
- (instancetype)initWithStyle:(UIImpactFeedbackStyle)style;
- (void)prepare;
- (void)impactOccurred;
@end

@interface UIBezierPath : NSObject
+ (instancetype)bezierPathWithRoundedRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;
+ (instancetype)bezierPathWithOvalInRect:(CGRect)rect;
+ (instancetype)bezierPath;
- (void)fill;
- (void)stroke;
- (void)addClip;
- (void)moveToPoint:(CGPoint)point;
- (void)addLineToPoint:(CGPoint)point;
- (void)closePath;
- (void)appendPath:(UIBezierPath *)path;
@property (readonly) CGPathRef CGPath;
@end

#pragma mark - 控制器

@interface UIViewController : UIResponder
@property (strong) UIView *view;
@property (copy) NSString *title;
@property (readonly) UINavigationController *navigationController;
@property (readonly) UINavigationItem *navigationItem;
@property (readonly) UITabBarController *tabBarController;
@property (readonly) UIViewController *presentedViewController;
@property (readonly) UIViewController *presentingViewController;
@property (readonly) UIViewController *parentViewController;
@property (readonly, copy) NSArray<UIViewController *> *childViewControllers;
@property (readonly) BOOL isViewLoaded;
@property BOOL hidesBottomBarWhenPushed;
@property (readonly) BOOL isEditing;
@property (copy) NSString *navigationItemTitle;
@property (readonly) UIBarButtonItem *editButtonItem;
- (void)loadView;
- (void)viewDidLoad;
- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;
- (void)viewWillLayoutSubviews;
- (void)viewDidLayoutSubviews;
- (void)didReceiveMemoryWarning;
- (void)setTitle:(NSString *)title;
- (void)addChildViewController:(UIViewController *)child;
- (void)removeFromParentViewController;
- (void)presentViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;
- (UIBarButtonItem *)editButtonItem;
@property (readonly) UIPopoverPresentationController *popoverPresentationController;
@end

@interface UITableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
- (instancetype)initWithStyle:(UITableViewStyle)style;
- (instancetype)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle;
@property (strong) UITableView *tableView;
@property BOOL clearsSelectionOnViewWillAppear;
@end

@interface UINavigationItem : NSObject
@property (copy) NSString *title;
@property (strong) UIBarButtonItem *rightBarButtonItem;
@property (copy) NSArray<UIBarButtonItem *> *rightBarButtonItems;
@property (strong) UIBarButtonItem *leftBarButtonItem;
@property (copy) NSArray<UIBarButtonItem *> *leftBarButtonItems;
@property (copy) NSString *backButtonTitle;
- (void)setRightBarButtonItem:(UIBarButtonItem *)item;
- (void)setLeftBarButtonItem:(UIBarButtonItem *)item;
- (void)setBackButtonTitle:(NSString *)title;
@end

@interface UIBarButtonItem : NSObject
- (instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action;
- (instancetype)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;
- (instancetype)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;
@property (copy) NSString *title;
@property (copy) NSString *accessibilityLabel;
@property (readonly) UIPopoverPresentationController *popoverPresentationController;
@end

@interface UINavigationController : UIViewController
- (instancetype)initWithRootViewController:(UIViewController *)vc;
@property (readonly, copy) NSArray<UIViewController *> *viewControllers;
@property (readonly) UIViewController *topViewController;
@property (readonly) UIViewController *visibleViewController;
@property (readonly) UINavigationBar *navigationBar;
- (void)pushViewController:(UIViewController *)vc animated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;
@end

@interface UINavigationBar : UIView
@end

@interface UITabBarController : UIViewController
@property (strong) UIViewController *selectedViewController;
@property NSUInteger selectedIndex;
@property (copy) NSArray<UIViewController *> *viewControllers;
@end

@interface UIPopoverPresentationController : NSObject
@property (strong) UIBarButtonItem *barButtonItem;
@property (strong) UIView *sourceView;
@property CGRect sourceRect;
@end

@interface UIAlertAction : NSObject
+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction *action))handler;
@end

@interface UIAlertController : UIViewController
+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle;
- (void)addAction:(UIAlertAction *)action;
@property (readonly) NSArray<UITextField *> *textFields;
- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler;
@end

@interface UITraitCollection : NSObject
@property (readonly) UIUserInterfaceStyle userInterfaceStyle;
@property (readonly) NSInteger horizontalSizeClass;
@end

@interface UIScreen : NSObject
+ (UIScreen *)mainScreen;
@property (readonly) CGRect bounds;
@property (readonly) CGFloat scale;
@property (readonly) UITraitCollection *traitCollection;
@end

@class UIWindowScene;

@interface UIScene : NSObject
@property (readonly, copy) NSArray<UIWindow *> *windows;
@end

@interface UIWindowScene : UIScene
@property (readonly, copy) NSArray<UIWindow *> *windows;
@end

@interface UIApplication : NSObject
+ (UIApplication *)sharedApplication;
@property (readonly) NSArray<UIScene *> *connectedScenes;
@property (readonly, nullable) UIWindow *keyWindow;
@property (readonly) NSInteger applicationState;
@end

@interface UIColorPickerViewController : UIViewController
@property (strong) UIColor *selectedColor;
@property (weak) id delegate;
@property BOOL supportsAlpha;
@end

@protocol UIColorPickerViewControllerDelegate <NSObject>
@optional
- (void)colorPickerViewControllerDidSelectColor:(UIColorPickerViewController *)viewController;
- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController;
@end
