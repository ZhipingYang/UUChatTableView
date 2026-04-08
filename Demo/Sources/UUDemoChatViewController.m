#import "UUDemoChatViewController.h"
#import "UUDemoChatDataSource.h"
#import <UUChatTableView/UUInputFunctionView.h>
#import <UUChatTableView/UUMessage.h>
#import <UUChatTableView/UUMessageCell.h>
#import <UUChatTableView/UUMessageFrame.h>
#import <UUChatTableView/UUVoiceRecordingHUDView.h>

@interface UUDemoChatViewController () <UUInputFunctionViewDelegate, UUMessageCellDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *chatTableView;
@property (nonatomic, strong) UUInputFunctionView *inputFuncView;
@property (nonatomic, strong) NSLayoutConstraint *inputBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *inputHeightConstraint;
@property (nonatomic, strong) UUDemoChatDataSource *chatDataSource;
@property (nonatomic, strong) UIView *headerCardView;
@property (nonatomic, strong) UILabel *eyebrowLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UISegmentedControl *modeSegmentControl;
@property (nonatomic, strong) UIView *accentOrbView;
@property (nonatomic, strong) UIView *secondaryOrbView;
@property (nonatomic, strong) CAGradientLayer *backgroundGradientLayer;
@property (nonatomic, assign) CGFloat lastKnownLayoutWidth;
@property (nonatomic, assign) BOOL didExportDebugSnapshot;
@property (nonatomic, assign) BOOL didPrepareSnapshotVariant;
@property (nonatomic, strong) UUVoiceRecordingHUDView *documentationRecordingHUDView;

@end

@implementation UUDemoChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.93 blue:0.89 alpha:1.0];
    self.lastKnownLayoutWidth = 0;

    [self setupBackground];
    [self setupHeader];
    [self setupTableView];
    [self setupInputView];
    [self setupNotifications];

    self.chatDataSource = [[UUDemoChatDataSource alloc] initWithLayoutWidth:CGRectGetWidth(self.view.bounds)];
    [self refreshHeaderCopy];
    [self.chatTableView reloadData];
    [self scrollToBottomAnimated:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    self.backgroundGradientLayer.frame = self.view.bounds;

    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    self.accentOrbView.frame = CGRectMake(width - 156.0, 32.0, 216.0, 216.0);
    self.secondaryOrbView.frame = CGRectMake(-74.0, height - 286.0, 244.0, 244.0);
    self.accentOrbView.layer.cornerRadius = CGRectGetWidth(self.accentOrbView.bounds) / 2.0;
    self.secondaryOrbView.layer.cornerRadius = CGRectGetWidth(self.secondaryOrbView.bounds) / 2.0;

    self.headerCardView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.headerCardView.bounds
                                                                       cornerRadius:self.headerCardView.layer.cornerRadius].CGPath;

    CGFloat widthDelta = fabs(CGRectGetWidth(self.chatTableView.bounds) - self.lastKnownLayoutWidth);
    if (widthDelta < 0.5) {
        return;
    }

    self.lastKnownLayoutWidth = CGRectGetWidth(self.chatTableView.bounds);
    self.chatDataSource.layoutWidth = self.lastKnownLayoutWidth;
    [self.chatTableView reloadData];
    [self scrollToBottomAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self prepareSnapshotVariantIfNeeded];
    [self exportDebugSnapshotIfNeeded];
}

- (void)setupBackground
{
    self.backgroundGradientLayer = [CAGradientLayer layer];
    self.backgroundGradientLayer.colors = @[
        (__bridge id)[UIColor colorWithRed:0.96 green:0.93 blue:0.88 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithRed:0.90 green:0.93 blue:0.96 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithRed:0.98 green:0.97 blue:0.95 alpha:1.0].CGColor
    ];
    self.backgroundGradientLayer.startPoint = CGPointMake(0.05, 0.0);
    self.backgroundGradientLayer.endPoint = CGPointMake(0.95, 1.0);
    [self.view.layer insertSublayer:self.backgroundGradientLayer atIndex:0];

    self.accentOrbView = [[UIView alloc] init];
    self.accentOrbView.userInteractionEnabled = NO;
    self.accentOrbView.backgroundColor = [UIColor colorWithRed:0.89 green:0.57 blue:0.44 alpha:0.18];
    [self.view addSubview:self.accentOrbView];

    self.secondaryOrbView = [[UIView alloc] init];
    self.secondaryOrbView.userInteractionEnabled = NO;
    self.secondaryOrbView.backgroundColor = [UIColor colorWithRed:0.28 green:0.48 blue:0.78 alpha:0.12];
    [self.view addSubview:self.secondaryOrbView];
}

- (void)setupHeader
{
    self.headerCardView = [[UIView alloc] init];
    self.headerCardView.translatesAutoresizingMaskIntoConstraints = NO;
    self.headerCardView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.74];
    self.headerCardView.layer.cornerRadius = 30.0;
    self.headerCardView.layer.masksToBounds = NO;
    self.headerCardView.layer.shadowColor = [UIColor colorWithRed:0.17 green:0.20 blue:0.26 alpha:1.0].CGColor;
    self.headerCardView.layer.shadowOpacity = 0.09;
    self.headerCardView.layer.shadowRadius = 24.0;
    self.headerCardView.layer.shadowOffset = CGSizeMake(0, 14);
    if (@available(iOS 13.0, *)) {
        self.headerCardView.layer.cornerCurve = kCACornerCurveContinuous;
    }
    [self.view addSubview:self.headerCardView];

    self.eyebrowLabel = [[UILabel alloc] init];
    self.eyebrowLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.eyebrowLabel.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightSemibold];
    self.eyebrowLabel.textColor = [UIColor colorWithRed:0.47 green:0.50 blue:0.56 alpha:1.0];
    [self.headerCardView addSubview:self.eyebrowLabel];

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = [self roundedFontWithSize:28.0 weight:UIFontWeightHeavy];
    self.titleLabel.textColor = [UIColor colorWithRed:0.14 green:0.16 blue:0.23 alpha:1.0];
    [self.headerCardView addSubview:self.titleLabel];

    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.subtitleLabel.numberOfLines = 0;
    self.subtitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.subtitleLabel.textColor = [UIColor colorWithRed:0.39 green:0.42 blue:0.48 alpha:1.0];
    [self.headerCardView addSubview:self.subtitleLabel];

    self.modeSegmentControl = [[UISegmentedControl alloc] initWithItems:@[@"Private", @"Group"]];
    self.modeSegmentControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.modeSegmentControl.selectedSegmentIndex = 0;
    self.modeSegmentControl.backgroundColor = [UIColor colorWithRed:0.95 green:0.92 blue:0.88 alpha:0.92];
    self.modeSegmentControl.selectedSegmentTintColor = [UIColor colorWithRed:0.16 green:0.32 blue:0.66 alpha:1.0];
    [self.modeSegmentControl setTitleTextAttributes:@{
        NSFontAttributeName : [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold],
        NSForegroundColorAttributeName : [UIColor colorWithRed:0.20 green:0.22 blue:0.28 alpha:1.0]
    } forState:UIControlStateNormal];
    [self.modeSegmentControl setTitleTextAttributes:@{
        NSFontAttributeName : [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold],
        NSForegroundColorAttributeName : UIColor.whiteColor
    } forState:UIControlStateSelected];
    [self.modeSegmentControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    [self.headerCardView addSubview:self.modeSegmentControl];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.headerCardView.topAnchor constraintEqualToAnchor:safeArea.topAnchor constant:14.0],
        [self.headerCardView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16.0],
        [self.headerCardView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16.0],

        [self.eyebrowLabel.topAnchor constraintEqualToAnchor:self.headerCardView.topAnchor constant:16.0],
        [self.eyebrowLabel.leadingAnchor constraintEqualToAnchor:self.headerCardView.leadingAnchor constant:20.0],
        [self.eyebrowLabel.trailingAnchor constraintEqualToAnchor:self.headerCardView.trailingAnchor constant:-20.0],

        [self.titleLabel.topAnchor constraintEqualToAnchor:self.eyebrowLabel.bottomAnchor constant:6.0],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.headerCardView.leadingAnchor constant:20.0],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.headerCardView.trailingAnchor constant:-20.0],

        [self.subtitleLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:6.0],
        [self.subtitleLabel.leadingAnchor constraintEqualToAnchor:self.headerCardView.leadingAnchor constant:20.0],
        [self.subtitleLabel.trailingAnchor constraintEqualToAnchor:self.headerCardView.trailingAnchor constant:-20.0],

        [self.modeSegmentControl.topAnchor constraintEqualToAnchor:self.subtitleLabel.bottomAnchor constant:14.0],
        [self.modeSegmentControl.leadingAnchor constraintEqualToAnchor:self.headerCardView.leadingAnchor constant:20.0],
        [self.modeSegmentControl.trailingAnchor constraintEqualToAnchor:self.headerCardView.trailingAnchor constant:-20.0],
        [self.modeSegmentControl.heightAnchor constraintEqualToConstant:34.0],
        [self.modeSegmentControl.bottomAnchor constraintEqualToAnchor:self.headerCardView.bottomAnchor constant:-16.0]
    ]];
}

- (void)setupTableView
{
    self.chatTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.chatTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.chatTableView.backgroundColor = UIColor.clearColor;
    self.chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chatTableView.delegate = self;
    self.chatTableView.dataSource = self;
    self.chatTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.chatTableView.showsVerticalScrollIndicator = NO;
    self.chatTableView.contentInset = UIEdgeInsetsMake(10.0, 0, 26.0, 0);
    self.chatTableView.scrollIndicatorInsets = UIEdgeInsetsMake(10.0, 0, 26.0, 0);
    [self.chatTableView registerClass:UUMessageCell.class forCellReuseIdentifier:NSStringFromClass(UUMessageCell.class)];
    [self.view addSubview:self.chatTableView];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor colorWithRed:0.16 green:0.32 blue:0.66 alpha:1.0];
    [refreshControl addTarget:self action:@selector(loadMoreHistory:) forControlEvents:UIControlEventValueChanged];
    self.chatTableView.refreshControl = refreshControl;
}

- (void)setupInputView
{
    self.inputFuncView = [[UUInputFunctionView alloc] initWithFrame:CGRectZero];
    self.inputFuncView.translatesAutoresizingMaskIntoConstraints = NO;
    self.inputFuncView.delegate = self;
    [self.view addSubview:self.inputFuncView];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    self.inputBottomConstraint = [self.inputFuncView.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor constant:-12.0];
    self.inputHeightConstraint = [self.inputFuncView.heightAnchor constraintEqualToConstant:self.inputFuncView.preferredHeight];
    [NSLayoutConstraint activateConstraints:@[
        [self.chatTableView.topAnchor constraintEqualToAnchor:self.headerCardView.bottomAnchor constant:12.0],
        [self.chatTableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.chatTableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.chatTableView.bottomAnchor constraintEqualToAnchor:self.inputFuncView.topAnchor constant:-12.0],

        [self.inputFuncView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16.0],
        [self.inputFuncView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16.0],
        self.inputHeightConstraint,
        self.inputBottomConstraint
    ]];
}

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (UIFont *)roundedFontWithSize:(CGFloat)size weight:(UIFontWeight)weight
{
    UIFont *baseFont = [UIFont systemFontOfSize:size weight:weight];
    UIFontDescriptor *descriptor = [baseFont.fontDescriptor fontDescriptorWithDesign:UIFontDescriptorSystemDesignRounded];
    return descriptor ? [UIFont fontWithDescriptor:descriptor size:size] : baseFont;
}

- (void)refreshHeaderCopy
{
    BOOL isGroupMode = self.modeSegmentControl.selectedSegmentIndex == 1;
    self.eyebrowLabel.text = isGroupMode ? @"PURE CODE / GROUP DEMO" : @"PURE CODE / PRIVATE DEMO";
    self.titleLabel.text = isGroupMode ? @"Shiproom" : @"Mia + You";
    self.subtitleLabel.text = isGroupMode
        ? @"Four participants, fake history, and just enough media to exercise the core chat states."
        : @"Pure code chat core with text, image and voice states, minus the old project clutter.";
}

- (void)exportDebugSnapshotIfNeeded
{
    if (self.didExportDebugSnapshot) {
        return;
    }

    NSString *snapshotDirectory = NSProcessInfo.processInfo.environment[@"UUCHAT_EXPORT_SNAPSHOT_DIR"];
    if (snapshotDirectory.length == 0) {
        return;
    }

    self.didExportDebugSnapshot = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view layoutIfNeeded];
        [self.chatTableView reloadData];
        [self.chatTableView layoutIfNeeded];
        [self scrollToBottomAnimated:NO];

        UIWindow *window = self.view.window;
        if (!window) {
            return;
        }

        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithBounds:window.bounds];
        UIImage *snapshot = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        }];
        NSData *imageData = UIImagePNGRepresentation(snapshot);
        if (imageData.length == 0) {
            return;
        }

        NSError *directoryError = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:snapshotDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&directoryError];
        if (directoryError) {
            return;
        }

        NSString *filePath = [snapshotDirectory stringByAppendingPathComponent:[self snapshotFileNameForCurrentVariant]];
        [imageData writeToFile:filePath atomically:YES];

        NSString *metadata = [NSString stringWithFormat:@"variant=%@\nwindow=%@\nscreen=%@\nrows=%ld\ncontentSize=%@\ncontentOffset=%@\nvisibleCells=%lu\nidiom=%ld\n",
                              [self snapshotVariant],
                              NSStringFromCGRect(window.bounds),
                              NSStringFromCGRect(UIScreen.mainScreen.bounds),
                              (long)self.chatDataSource.dataSource.count,
                              NSStringFromCGSize(self.chatTableView.contentSize),
                              NSStringFromCGPoint(self.chatTableView.contentOffset),
                              (unsigned long)self.chatTableView.visibleCells.count,
                              (long)self.traitCollection.userInterfaceIdiom];
        NSString *metadataPath = [snapshotDirectory stringByAppendingPathComponent:@"uuchat-demo-debug.txt"];
        [metadata writeToFile:metadataPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    });
}

- (NSString *)snapshotVariant
{
    NSString *variant = NSProcessInfo.processInfo.environment[@"UUCHAT_EXPORT_VARIANT"];
    if (variant.length == 0) {
        return @"copy-menu";
    }
    if ([variant isEqualToString:@"private"]) {
        return @"copy-menu";
    }
    if ([variant isEqualToString:@"group"]) {
        return @"media-actions";
    }
    return variant;
}

- (NSString *)snapshotFileNameForCurrentVariant
{
    NSString *variant = [self snapshotVariant];
    if ([variant isEqualToString:@"media-actions"]) {
        return @"media-actions.png";
    }
    if ([variant isEqualToString:@"recording-hud"]) {
        return @"recording-hud.png";
    }
    if ([variant isEqualToString:@"recording-hud-cancel"]) {
        return @"recording-hud-cancel.png";
    }
    return @"copy-menu.png";
}

- (void)prepareSnapshotVariantIfNeeded
{
    if (self.didPrepareSnapshotVariant) {
        return;
    }

    NSString *snapshotDirectory = NSProcessInfo.processInfo.environment[@"UUCHAT_EXPORT_SNAPSHOT_DIR"];
    if (snapshotDirectory.length == 0) {
        return;
    }

    self.didPrepareSnapshotVariant = YES;

    NSString *variant = [self snapshotVariant];
    BOOL groupMode = [variant isEqualToString:@"media-actions"];
    self.modeSegmentControl.selectedSegmentIndex = groupMode ? 1 : 0;
    [self.chatDataSource reloadConversationWithGroupMode:groupMode];
    [self refreshHeaderCopy];
    [self.chatTableView reloadData];
    [self scrollToBottomAnimated:NO];

    if ([variant isEqualToString:@"recording-hud"] || [variant isEqualToString:@"recording-hud-cancel"]) {
        [self configureInputViewForRecordingSnapshot];
        [self showDocumentationRecordingHUDCancelling:[variant isEqualToString:@"recording-hud-cancel"]];
        return;
    }

    if ([variant isEqualToString:@"media-actions"]) {
        [self configureMediaActionsSnapshot];
        return;
    }

    [self configureCopyMenuSnapshot];
}

- (void)configureInputViewForRecordingSnapshot
{
    [self.inputFuncView clearTextInput];
    [self.inputFuncView setValue:@YES forKey:@"voiceModeEnabled"];
    [self.inputFuncView.btnVoiceRecord setTitle:@"Recording..." forState:UIControlStateNormal];
    [self.inputFuncView.btnVoiceRecord setTitle:@"Release to Send" forState:UIControlStateHighlighted];
    self.inputFuncView.btnVoiceRecord.highlighted = NO;
    [self.inputFuncView setNeedsLayout];
    [self.inputFuncView layoutIfNeeded];
}

- (void)configureCopyMenuSnapshot
{
    [self.inputFuncView clearTextInput];
    [self.view endEditing:YES];
    [self.view layoutIfNeeded];
    [self.chatTableView layoutIfNeeded];
    [self scrollToBottomAnimated:NO];

    NSIndexPath *indexPath = [self snapshotIndexPathForLastTextMessage];
    if (!indexPath) {
        return;
    }

    UUMessageCell *cell = [self.chatTableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        [self.chatTableView scrollToRowAtIndexPath:indexPath
                                  atScrollPosition:UITableViewScrollPositionBottom
                                          animated:NO];
        [self.chatTableView layoutIfNeeded];
        cell = [self.chatTableView cellForRowAtIndexPath:indexPath];
    }

    if (!cell) {
        return;
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL selector = NSSelectorFromString(@"showCopyMenu");
    if ([cell respondsToSelector:selector]) {
        [cell performSelector:selector];
    }
#pragma clang diagnostic pop
}

- (void)configureMediaActionsSnapshot
{
    [self.inputFuncView clearTextInput];
    [self.view endEditing:YES];
    [self.chatDataSource appendPictureMessage:[self documentationSnapshotImage]];
    [self.chatTableView reloadData];
    [self.chatTableView layoutIfNeeded];
    [self scrollToBottomAnimated:NO];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL selector = NSSelectorFromString(@"handlePrimaryActionTap:");
    if ([self.inputFuncView respondsToSelector:selector]) {
        [self.inputFuncView performSelector:selector withObject:self.inputFuncView.btnSendMessage];
    }
#pragma clang diagnostic pop
}

- (NSIndexPath *)snapshotIndexPathForLastTextMessage
{
    NSArray<UUMessageFrame *> *frames = self.chatDataSource.dataSource;
    for (NSInteger index = (NSInteger)frames.count - 1; index >= 0; index--) {
        UUMessageFrame *frame = frames[(NSUInteger)index];
        if (frame.message.contentType == UUMessageTypeText) {
            return [NSIndexPath indexPathForRow:index inSection:0];
        }
    }

    return nil;
}

- (UIImage *)documentationSnapshotImage
{
    CGSize canvasSize = CGSizeMake(240.0, 160.0);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:canvasSize];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGContextRef context = rendererContext.CGContext;
        UIColor *startColor = [UIColor colorWithRed:0.91 green:0.58 blue:0.38 alpha:1.0];
        UIColor *endColor = [UIColor colorWithRed:0.53 green:0.80 blue:0.93 alpha:1.0];
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        NSArray *colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, NULL);
        CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(canvasSize.width, canvasSize.height), 0);
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);

        CGRect cardRect = CGRectInset((CGRect){CGPointZero, canvasSize}, 18.0, 18.0);
        [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.18] setFill];
        [[UIBezierPath bezierPathWithRoundedRect:cardRect cornerRadius:30.0] fill];

        [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.22] setFill];
        [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(CGRectGetMinX(cardRect) + 20.0,
                                                           CGRectGetMinY(cardRect) + 20.0,
                                                           52.0,
                                                           52.0)] fill];

        NSDictionary<NSAttributedStringKey, id> *titleAttributes = @{
            NSFontAttributeName : [UIFont systemFontOfSize:24.0 weight:UIFontWeightHeavy],
            NSForegroundColorAttributeName : UIColor.whiteColor
        };
        [@"Photo + Actions" drawAtPoint:CGPointMake(CGRectGetMinX(cardRect) + 20.0,
                                                    CGRectGetMidY(cardRect) - 4.0)
                         withAttributes:titleAttributes];

        NSDictionary<NSAttributedStringKey, id> *eyebrowAttributes = @{
            NSFontAttributeName : [UIFont monospacedSystemFontOfSize:11.0 weight:UIFontWeightSemibold],
            NSForegroundColorAttributeName : [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.80]
        };
        [@"README SNAPSHOT" drawAtPoint:CGPointMake(CGRectGetMinX(cardRect) + 20.0,
                                                    CGRectGetMinY(cardRect) + 80.0)
                         withAttributes:eyebrowAttributes];
    }];
}

- (void)showDocumentationRecordingHUDCancelling:(BOOL)cancelling
{
    [self.documentationRecordingHUDView dismissAnimated:NO];

    self.documentationRecordingHUDView = [[UUVoiceRecordingHUDView alloc] initWithFrame:CGRectZero];
    [self.documentationRecordingHUDView presentInView:self.view];
    [self.documentationRecordingHUDView updateWithDuration:18 level:0.72];
    [self.documentationRecordingHUDView setCancelling:cancelling];
}

- (void)segmentChanged:(UISegmentedControl *)segmentControl
{
    [self.chatDataSource reloadConversationWithGroupMode:segmentControl.selectedSegmentIndex == 1];
    [self refreshHeaderCopy];
    [self.chatTableView reloadData];
    [self scrollToBottomAnimated:NO];
}

- (void)loadMoreHistory:(UIRefreshControl *)refreshControl
{
    CGFloat oldContentHeight = self.chatTableView.contentSize.height;
    [self.chatDataSource prependHistoryMessages:8];
    [self.chatTableView reloadData];
    [self.chatTableView layoutIfNeeded];

    CGFloat delta = self.chatTableView.contentSize.height - oldContentHeight;
    CGPoint offset = self.chatTableView.contentOffset;
    offset.y += delta;
    self.chatTableView.contentOffset = offset;
    [refreshControl endRefreshing];
}

- (void)keyboardWillChange:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect endFrameInView = [self.view convertRect:endFrame fromView:nil];
    CGFloat overlap = MAX(CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(endFrameInView) - self.view.safeAreaInsets.bottom, 0);

    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
    self.inputBottomConstraint.constant = -(overlap + 12.0);

    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];

    if (overlap > 0) {
        [self scrollToBottomAnimated:NO];
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    NSInteger rowCount = self.chatDataSource.dataSource.count;
    if (rowCount == 0) {
        return;
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowCount - 1 inSection:0];
    [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

- (void)appendAndRefresh
{
    [self.chatTableView reloadData];
    [self scrollToBottomAnimated:YES];
}

- (void)inputFunctionView:(UUInputFunctionView *)inputFunctionView didSendText:(NSString *)text
{
    [self.chatDataSource appendTextMessage:text];
    [inputFunctionView clearTextInput];
    [self appendAndRefresh];
}

- (void)inputFunctionView:(UUInputFunctionView *)inputFunctionView didSendImage:(UIImage *)image
{
    (void)inputFunctionView;
    [self.chatDataSource appendPictureMessage:image];
    [self appendAndRefresh];
}

- (void)inputFunctionView:(UUInputFunctionView *)inputFunctionView didSendVoiceData:(NSData *)voiceData duration:(NSInteger)duration
{
    (void)inputFunctionView;
    [self.chatDataSource appendVoiceMessage:voiceData duration:duration];
    [self appendAndRefresh];
}

- (void)inputFunctionView:(UUInputFunctionView *)inputFunctionView didChangePreferredHeight:(CGFloat)preferredHeight animated:(BOOL)animated
{
    (void)inputFunctionView;
    if (fabs(self.inputHeightConstraint.constant - preferredHeight) < 0.5) {
        return;
    }

    self.inputHeightConstraint.constant = preferredHeight;
    void (^layoutBlock)(void) = ^{
        [self.view layoutIfNeeded];
        [self.chatTableView layoutIfNeeded];
        [self scrollToBottomAnimated:NO];
    };

    if (!animated) {
        layoutBlock();
        return;
    }

    [UIView animateWithDuration:0.24
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                     animations:layoutBlock
                     completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatDataSource.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UUMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UUMessageCell.class) forIndexPath:indexPath];
    cell.delegate = self;
    cell.messageFrame = self.chatDataSource.dataSource[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.chatDataSource.dataSource[indexPath.row].cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

- (void)messageCell:(UUMessageCell *)cell didTapAvatarForUserIdentifier:(NSString *)userIdentifier
{
    (void)userIdentifier;
    NSString *title = cell.messageFrame.message.displayName.length > 0 ? cell.messageFrame.message.displayName : @"User";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:@"Avatar tapped"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
