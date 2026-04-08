#import "UUVoiceRecordingHUDView.h"
#import "UUChatCategory.h"

@interface UUVoiceRecordingHUDView ()

@property (nonatomic, strong) UIVisualEffectView *backgroundView;
@property (nonatomic, strong) UIImageView *microphoneImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timerLabel;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) NSArray<UIView *> *levelBars;
@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *levelBarHeightConstraints;
@property (nonatomic, strong) NSArray<NSNumber *> *levelBarBaseHeights;
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, assign, getter=isCancelling) BOOL cancelling;

@end

@implementation UUVoiceRecordingHUDView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = UIColor.clearColor;

        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterialDark];
        self.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundView.layer.cornerRadius = 28.0;
        self.backgroundView.layer.masksToBounds = YES;
        [self addSubview:self.backgroundView];

        UIView *contentView = self.backgroundView.contentView;
        contentView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.18];

        self.microphoneImageView = [[UIImageView alloc] init];
        self.microphoneImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.microphoneImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.microphoneImageView.image = [UIImage uu_symbolImageNamed:@"mic.fill"
                                                            pointSize:24.0
                                                               weight:UIImageSymbolWeightSemibold
                                                            tintColor:UIColor.whiteColor];
        [contentView addSubview:self.microphoneImageView];

        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightSemibold];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = UIColor.whiteColor;
        [contentView addSubview:self.titleLabel];

        self.timerLabel = [[UILabel alloc] init];
        self.timerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.timerLabel.font = [UIFont monospacedDigitSystemFontOfSize:28.0 weight:UIFontWeightBold];
        self.timerLabel.textAlignment = NSTextAlignmentCenter;
        self.timerLabel.textColor = UIColor.whiteColor;
        [contentView addSubview:self.timerLabel];

        UIStackView *waveformStackView = [[UIStackView alloc] init];
        waveformStackView.translatesAutoresizingMaskIntoConstraints = NO;
        waveformStackView.axis = UILayoutConstraintAxisHorizontal;
        waveformStackView.alignment = UIStackViewAlignmentBottom;
        waveformStackView.distribution = UIStackViewDistributionEqualSpacing;
        waveformStackView.spacing = 6.0;
        [contentView addSubview:waveformStackView];

        NSMutableArray<UIView *> *bars = [NSMutableArray array];
        NSMutableArray<NSLayoutConstraint *> *heightConstraints = [NSMutableArray array];
        NSArray<NSNumber *> *baseHeights = @[ @10.0, @16.0, @22.0, @30.0, @22.0, @16.0, @10.0 ];
        for (NSNumber *heightNumber in baseHeights) {
            UIView *barView = [[UIView alloc] init];
            barView.translatesAutoresizingMaskIntoConstraints = NO;
            barView.backgroundColor = [UIColor colorWithRed:0.41 green:0.79 blue:0.98 alpha:1.0];
            barView.layer.cornerRadius = 3.0;
            [waveformStackView addArrangedSubview:barView];

            NSLayoutConstraint *widthConstraint = [barView.widthAnchor constraintEqualToConstant:6.0];
            NSLayoutConstraint *heightConstraint = [barView.heightAnchor constraintEqualToConstant:heightNumber.doubleValue];
            [NSLayoutConstraint activateConstraints:@[ widthConstraint, heightConstraint ]];

            [bars addObject:barView];
            [heightConstraints addObject:heightConstraint];
        }
        self.levelBars = bars.copy;
        self.levelBarHeightConstraints = heightConstraints.copy;
        self.levelBarBaseHeights = baseHeights;

        self.hintLabel = [[UILabel alloc] init];
        self.hintLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.hintLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightMedium];
        self.hintLabel.numberOfLines = 0;
        self.hintLabel.textAlignment = NSTextAlignmentCenter;
        self.hintLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.hintLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        [contentView addSubview:self.hintLabel];

        [NSLayoutConstraint activateConstraints:@[
            [self.backgroundView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [self.backgroundView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [self.backgroundView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [self.backgroundView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],

            [self.microphoneImageView.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:18.0],
            [self.microphoneImageView.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],
            [self.microphoneImageView.widthAnchor constraintEqualToConstant:30.0],
            [self.microphoneImageView.heightAnchor constraintEqualToConstant:30.0],

            [self.titleLabel.topAnchor constraintEqualToAnchor:self.microphoneImageView.bottomAnchor constant:10.0],
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:16.0],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-16.0],

            [self.timerLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:8.0],
            [self.timerLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:16.0],
            [self.timerLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-16.0],

            [waveformStackView.topAnchor constraintEqualToAnchor:self.timerLabel.bottomAnchor constant:12.0],
            [waveformStackView.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],
            [waveformStackView.heightAnchor constraintEqualToConstant:34.0],

            [self.hintLabel.topAnchor constraintEqualToAnchor:waveformStackView.bottomAnchor constant:14.0],
            [self.hintLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:16.0],
            [self.hintLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-16.0],
            [self.hintLabel.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-18.0]
        ]];

        [self setCancelling:NO];
        [self updateWithDuration:0 level:0];
    }
    return self;
}

- (void)presentInView:(UIView *)view
{
    if (!view) {
        return;
    }

    if (self.superview != view) {
        [self removeFromSuperview];
        [view addSubview:self];
        self.widthConstraint = [self.widthAnchor constraintEqualToConstant:190.0];
        self.heightConstraint = [self.heightAnchor constraintEqualToConstant:196.0];
        [NSLayoutConstraint activateConstraints:@[
            [self.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
            [self.centerYAnchor constraintEqualToAnchor:view.centerYAnchor constant:-36.0],
            self.widthConstraint,
            self.heightConstraint
        ]];
    }

    [self updatePreferredSizeAnimated:NO];
    self.alpha = 0.0;
    self.transform = CGAffineTransformMakeScale(0.92, 0.92);
    [UIView animateWithDuration:0.18
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.alpha = 1.0;
        self.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)updateWithDuration:(NSTimeInterval)duration level:(CGFloat)level
{
    NSInteger totalSeconds = MAX((NSInteger)floor(duration), 0);
    NSInteger minutes = totalSeconds / 60;
    NSInteger seconds = totalSeconds % 60;
    self.timerLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    [self updateWaveformWithLevel:level];
}

- (void)setCancelling:(BOOL)cancelling
{
    _cancelling = cancelling;

    UIColor *accentColor = cancelling
        ? [UIColor colorWithRed:0.99 green:0.45 blue:0.38 alpha:1.0]
        : [UIColor colorWithRed:0.41 green:0.79 blue:0.98 alpha:1.0];
    self.titleLabel.text = cancelling ? @"Cancel Recording" : @"Recording";
    self.hintLabel.text = cancelling ? @"Release now to discard\nthe voice message" : @"Slide out to cancel,\nrelease to send";

    for (UIView *barView in self.levelBars) {
        barView.backgroundColor = accentColor;
    }

    [self updatePreferredSizeAnimated:YES];
}

- (void)dismissAnimated:(BOOL)animated
{
    void (^removeBlock)(void) = ^{
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.92, 0.92);
    };
    void (^completionBlock)(BOOL) = ^(BOOL finished) {
        (void)finished;
        [self removeFromSuperview];
        self.transform = CGAffineTransformIdentity;
    };

    if (!animated || self.superview == nil) {
        removeBlock();
        completionBlock(YES);
        return;
    }

    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                     animations:removeBlock
                     completion:completionBlock];
}

- (void)updateWaveformWithLevel:(CGFloat)level
{
    CGFloat clampedLevel = MIN(MAX(level, 0.02), 1.0);
    CGFloat middleIndex = (CGFloat)(self.levelBars.count - 1) / 2.0;

    [self.levelBars enumerateObjectsUsingBlock:^(UIView *barView, NSUInteger idx, BOOL *stop) {
        (void)stop;
        CGFloat distanceFromCenter = fabs((CGFloat)idx - middleIndex);
        CGFloat emphasis = 1.0 - (distanceFromCenter / MAX(middleIndex, 1.0));
        CGFloat scale = 0.32 + clampedLevel * (0.42 + emphasis * 0.48);
        CGFloat baseHeight = self.levelBarBaseHeights[idx].doubleValue;
        self.levelBarHeightConstraints[idx].constant = MAX(8.0, round(baseHeight * scale));
        barView.alpha = self.isCancelling ? 0.70 : MIN(1.0, 0.45 + clampedLevel * 0.75);
    }];

    [self layoutIfNeeded];
}

- (NSArray<NSString *> *)allHintTexts
{
    return @[
        @"Slide out to cancel,\nrelease to send",
        @"Release now to discard\nthe voice message"
    ];
}

- (NSArray<NSString *> *)allTitleTexts
{
    return @[
        @"Recording",
        @"Cancel Recording"
    ];
}

- (CGFloat)widestLineWidthForTexts:(NSArray<NSString *> *)texts font:(UIFont *)font
{
    CGFloat widestWidth = 0.0;
    for (NSString *text in texts) {
        NSArray<NSString *> *lines = [text componentsSeparatedByString:@"\n"];
        for (NSString *line in lines) {
            widestWidth = MAX(widestWidth, ceil([line uu_sizeWithFont:font].width));
        }
    }
    return widestWidth;
}

- (CGFloat)maxHeightForTexts:(NSArray<NSString *> *)texts font:(UIFont *)font constrainedToWidth:(CGFloat)width
{
    CGFloat maxHeight = 0.0;
    NSDictionary *attributes = @{ NSFontAttributeName : font };
    for (NSString *text in texts) {
        CGRect boundingRect = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                              attributes:attributes
                                                 context:nil];
        maxHeight = MAX(maxHeight, ceil(CGRectGetHeight(boundingRect)));
    }
    return maxHeight;
}

- (CGSize)preferredHUDSize
{
    CGFloat availableWidth = self.superview ? CGRectGetWidth(self.superview.bounds) - 48.0 : UIScreen.mainScreen.bounds.size.width - 48.0;
    CGFloat maxWidth = MAX(190.0, MIN(availableWidth, 260.0));

    CGFloat contentPadding = 32.0;
    CGFloat titleWidth = [self widestLineWidthForTexts:[self allTitleTexts] font:self.titleLabel.font];
    CGFloat hintWidth = [self widestLineWidthForTexts:[self allHintTexts] font:self.hintLabel.font];
    CGFloat preferredWidth = MIN(MAX(190.0, MAX(titleWidth, hintWidth) + contentPadding), maxWidth);

    CGFloat textWidth = preferredWidth - contentPadding;
    CGFloat titleHeight = ceil(self.titleLabel.font.lineHeight);
    CGFloat timerHeight = ceil(self.timerLabel.font.lineHeight);
    CGFloat hintHeight = [self maxHeightForTexts:[self allHintTexts] font:self.hintLabel.font constrainedToWidth:textWidth];
    CGFloat preferredHeight = ceil(18.0 + 30.0 + 10.0 + titleHeight + 8.0 + timerHeight + 12.0 + 34.0 + 14.0 + hintHeight + 18.0);

    return CGSizeMake(preferredWidth, MAX(196.0, preferredHeight));
}

- (void)updatePreferredSizeAnimated:(BOOL)animated
{
    if (!self.widthConstraint || !self.heightConstraint) {
        return;
    }

    CGSize preferredSize = [self preferredHUDSize];
    if (fabs(self.widthConstraint.constant - preferredSize.width) < 0.5 &&
        fabs(self.heightConstraint.constant - preferredSize.height) < 0.5) {
        return;
    }

    self.widthConstraint.constant = preferredSize.width;
    self.heightConstraint.constant = preferredSize.height;

    if (!animated || !self.superview) {
        [self.superview layoutIfNeeded];
        return;
    }

    [UIView animateWithDuration:0.16
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        [self.superview layoutIfNeeded];
    } completion:nil];
}

@end
