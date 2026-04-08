#import "UUMessageContentButton.h"
#import "UUChatCategory.h"

@interface UUMessageContentButton ()

@property (nonatomic, strong) CAShapeLayer *bubbleLayer;
@property (nonatomic, strong) CAShapeLayer *strokeLayer;

@end

@implementation UUMessageContentButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.adjustsImageWhenHighlighted = NO;
        self.layer.masksToBounds = NO;

        self.bubbleLayer = [CAShapeLayer layer];
        [self.layer insertSublayer:self.bubbleLayer atIndex:0];

        self.strokeLayer = [CAShapeLayer layer];
        self.strokeLayer.fillColor = UIColor.clearColor.CGColor;
        [self.layer insertSublayer:self.strokeLayer above:self.bubbleLayer];

        self.backImageView = [[UIImageView alloc] init];
        self.backImageView.hidden = YES;
        self.backImageView.userInteractionEnabled = NO;
        self.backImageView.layer.cornerRadius = 20;
        self.backImageView.layer.masksToBounds = YES;
        self.backImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.backImageView.backgroundColor = UIColor.secondarySystemBackgroundColor;
        [self addSubview:self.backImageView];

        self.voiceBackView = [[UIView alloc] init];
        self.voiceBackView.hidden = YES;
        self.voiceBackView.userInteractionEnabled = NO;
        [self addSubview:self.voiceBackView];

        self.second = [[UILabel alloc] init];
        self.second.backgroundColor = UIColor.clearColor;
        self.second.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        self.second.textAlignment = NSTextAlignmentCenter;
        [self.voiceBackView addSubview:self.second];

        self.voice = [[UIImageView alloc] init];
        self.voice.contentMode = UIViewContentModeScaleAspectFit;
        [self.voiceBackView addSubview:self.voice];

        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        [self.voiceBackView addSubview:self.indicator];

        [self setNeedsLayout];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    UIBezierPath *bubblePath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:24];
    self.bubbleLayer.frame = self.bounds;
    self.bubbleLayer.path = bubblePath.CGPath;
    self.bubbleLayer.fillColor = [self bubbleColorForCurrentState].CGColor;

    self.strokeLayer.frame = self.bounds;
    self.strokeLayer.path = bubblePath.CGPath;
    self.strokeLayer.lineWidth = self.backImageView.hidden ? 1.0 : 0.0;
    self.strokeLayer.strokeColor = [self bubbleStrokeColorForCurrentState].CGColor;

    self.layer.shadowColor = [UIColor colorWithRed:0.15 green:0.18 blue:0.25 alpha:1.0].CGColor;
    self.layer.shadowOpacity = self.highlighted ? 0.08 : 0.14;
    self.layer.shadowRadius = 18.0;
    self.layer.shadowOffset = CGSizeMake(0, 10);
    self.layer.shadowPath = bubblePath.CGPath;

    self.backImageView.frame = CGRectInset(self.bounds, 4, 4);

    CGRect voiceBounds = CGRectInset(self.bounds, 14, 10);
    self.voiceBackView.frame = voiceBounds;

    CGFloat iconSide = 20;
    CGFloat spacing = 8;
    CGFloat voiceX = self.isMyMessage ? CGRectGetWidth(voiceBounds) - iconSide : 0;
    CGFloat labelX = self.isMyMessage ? 0 : iconSide + spacing;
    CGFloat labelWidth = CGRectGetWidth(voiceBounds) - iconSide - spacing;
    CGFloat centeredY = floor((CGRectGetHeight(voiceBounds) - iconSide) / 2.0);
    self.voice.frame = CGRectMake(voiceX, centeredY, iconSide, iconSide);
    self.indicator.center = CGPointMake(CGRectGetMidX(self.voice.frame), CGRectGetMidY(self.voice.frame));
    self.second.frame = CGRectMake(labelX, 0, labelWidth, CGRectGetHeight(voiceBounds));
}

- (void)setIsMyMessage:(BOOL)isMyMessage
{
    _isMyMessage = isMyMessage;

    self.second.textColor = isMyMessage ? UIColor.whiteColor : UIColor.labelColor;
    if (@available(iOS 13.0, *)) {
        UIColor *tintColor = isMyMessage ? UIColor.whiteColor : UIColor.labelColor;
        self.voice.image = [UIImage uu_symbolImageNamed:@"waveform"
                                              pointSize:18
                                                 weight:UIImageSymbolWeightSemibold
                                              tintColor:tintColor];
    }
    [self setNeedsLayout];
}

- (UIColor *)bubbleColorForCurrentState
{
    UIColor *baseColor = self.isMyMessage
        ? [UIColor colorWithRed:0.16 green:0.32 blue:0.66 alpha:1.0]
        : [UIColor colorWithRed:0.99 green:0.97 blue:0.94 alpha:0.96];
    return self.highlighted ? [baseColor colorWithAlphaComponent:0.84] : baseColor;
}

- (UIColor *)bubbleStrokeColorForCurrentState
{
    if (self.isMyMessage) {
        return [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.10];
    }

    return [UIColor colorWithRed:0.46 green:0.50 blue:0.58 alpha:0.12];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.bubbleLayer.fillColor = [self bubbleColorForCurrentState].CGColor;
    self.strokeLayer.strokeColor = [self bubbleStrokeColorForCurrentState].CGColor;
    self.layer.shadowOpacity = highlighted ? 0.08 : 0.14;
}

- (void)benginLoadVoice
{
    self.voice.hidden = YES;
    [self.indicator startAnimating];
}

- (void)didLoadVoice
{
    self.voice.hidden = NO;
    [self.indicator stopAnimating];
    [self.voice.layer removeAnimationForKey:@"uu_voice_pulse"];

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = @1.0;
    animation.toValue = @0.35;
    animation.duration = 0.45;
    animation.autoreverses = YES;
    animation.repeatCount = HUGE_VALF;
    [self.voice.layer addAnimation:animation forKey:@"uu_voice_pulse"];
}

- (void)stopPlay
{
    [self.indicator stopAnimating];
    self.voice.hidden = NO;
    [self.voice.layer removeAnimationForKey:@"uu_voice_pulse"];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return action == @selector(copy:);
}

- (void)copy:(id)sender
{
    UIPasteboard.generalPasteboard.string = self.titleLabel.text;
}

@end
