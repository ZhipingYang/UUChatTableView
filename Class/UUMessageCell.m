#import "UUMessageCell.h"
#import "UUMessage.h"
#import "UUMessageFrame.h"
#import "UUAVAudioPlayer.h"
#import "UUImageAvatarBrowser.h"

static NSString * const UUVoicePlayHasInterruptNotification = @"UUVoicePlayHasInterruptNotification";

@interface UUMessageCell () <UUAVAudioPlayerDelegate>

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *headImageButton;
@property (nonatomic, strong) UUMessageContentButton *btnContent;
@property (nonatomic, strong) NSURLSessionDataTask *avatarTask;
@property (nonatomic, copy) NSString *representedAvatarIdentifier;
@property (nonatomic, strong) NSData *voiceData;
@property (nonatomic, strong) UUAVAudioPlayer *audioPlayer;
@property (nonatomic, assign, getter=isContentVoicePlaying) BOOL contentVoicePlaying;

@end

@implementation UUMessageCell

+ (NSCache<NSString *, UIImage *> *)avatarImageCache
{
    static NSCache<NSString *, UIImage *> *avatarCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        avatarCache = [[NSCache alloc] init];
    });
    return avatarCache;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = UIColor.clearColor;
        self.audioPlayer = [UUAVAudioPlayer sharedInstance];

        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        self.dateLabel.textColor = [UIColor colorWithRed:0.42 green:0.45 blue:0.51 alpha:1.0];
        self.dateLabel.font = ChatTimeFont;
        self.dateLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.62];
        self.dateLabel.layer.masksToBounds = YES;
        [self.contentView addSubview:self.dateLabel];

        self.headImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.headImageButton.layer.cornerRadius = ChatIconWH / 2.0;
        self.headImageButton.layer.masksToBounds = YES;
        self.headImageButton.layer.borderWidth = 2.0;
        self.headImageButton.layer.borderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.72].CGColor;
        self.headImageButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        [self.headImageButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [self.headImageButton addTarget:self action:@selector(handleAvatarButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.headImageButton];

        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textColor = [UIColor colorWithRed:0.39 green:0.43 blue:0.50 alpha:0.92];
        self.nameLabel.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightSemibold];
        self.nameLabel.numberOfLines = 1;
        [self.contentView addSubview:self.nameLabel];

        self.btnContent = [UUMessageContentButton buttonWithType:UIButtonTypeCustom];
        self.btnContent.titleLabel.font = ChatContentFont;
        self.btnContent.titleLabel.numberOfLines = 0;
        [self.btnContent addTarget:self action:@selector(handleContentButtonTap) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnContent];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleVoicePlaybackInterrupted:)
                                                     name:UUVoicePlayHasInterruptNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:)
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    [self cancelAvatarLoading];
    [self stopVoicePlaybackIfNeeded];
    [self resetAvatarView];
    [self resetContentState];

    self.dateLabel.text = nil;
    self.dateLabel.frame = CGRectZero;
    self.dateLabel.hidden = YES;

    self.nameLabel.text = nil;
    self.nameLabel.frame = CGRectZero;
    self.nameLabel.hidden = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleAvatarButtonTap:(UIButton *)button
{
    (void)button;
    NSString *userIdentifier = self.messageFrame.message.senderIdentifier ?: @"";
    if ([self.delegate respondsToSelector:@selector(messageCell:didTapAvatarForUserIdentifier:)]) {
        [self.delegate messageCell:self didTapAvatarForUserIdentifier:userIdentifier];
        return;
    }

    if ([self.delegate respondsToSelector:@selector(chatCell:headImageDidClick:)]) {
        [self.delegate chatCell:self headImageDidClick:userIdentifier];
    }
}

- (void)handleContentButtonTap
{
    switch (self.messageFrame.message.contentType) {
        case UUMessageTypeVoice:
            [self toggleVoicePlayback];
            return;
        case UUMessageTypePicture:
            [self showPicturePreview];
            return;
        case UUMessageTypeText:
        default:
            [self showCopyMenu];
            return;
    }
}

- (void)audioPlayerDidBeginLoadingVoice:(UUAVAudioPlayer *)audioPlayer
{
    (void)audioPlayer;
    [self.btnContent benginLoadVoice];
}

- (void)audioPlayerDidBeginPlayback:(UUAVAudioPlayer *)audioPlayer
{
    (void)audioPlayer;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [self.btnContent didLoadVoice];
}

- (void)audioPlayerDidFinishPlayback:(UUAVAudioPlayer *)audioPlayer successfully:(BOOL)success
{
    (void)audioPlayer;
    (void)success;
    [self stopVoicePlaybackIfNeeded];
}

- (void)handleVoicePlaybackInterrupted:(NSNotification *)notification
{
    (void)notification;
    [self stopVoicePlaybackIfNeeded];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.dateLabel.layer.cornerRadius = CGRectGetHeight(self.dateLabel.bounds) / 2.0;
}

- (void)setMessageFrame:(UUMessageFrame *)messageFrame
{
    _messageFrame = messageFrame;
    UUMessage *message = messageFrame.message;

    [self configureDateLabelWithFrame:messageFrame message:message];
    [self configureAvatarFrameWithFrame:messageFrame message:message];
    [self configureNameLabelWithFrame:messageFrame message:message];
    [self configureContentWithFrame:messageFrame message:message];
}

- (void)configureAvatarForMessage:(UUMessage *)message
{
    [self cancelAvatarLoading];

    if (message.avatarImage) {
        [self applyAvatarImage:message.avatarImage];
        return;
    }

    NSString *identifier = message.avatarIdentifier ?: @"";
    if (identifier.length > 0) {
        UIImage *localImage = [UIImage imageNamed:identifier];
        if (localImage) {
            [self applyAvatarImage:localImage];
            return;
        }

        NSURL *url = [NSURL URLWithString:identifier];
        if (url.scheme.length > 0) {
            [self applyPlaceholderAvatarWithName:message.displayName];
            [self loadRemoteAvatarWithURL:url identifier:identifier];
            return;
        }
    }

    [self applyPlaceholderAvatarWithName:message.displayName];
}

- (void)loadRemoteAvatarWithURL:(NSURL *)url identifier:(NSString *)identifier
{
    UIImage *cachedImage = [[[self class] avatarImageCache] objectForKey:identifier];
    if (cachedImage) {
        [self applyAvatarImage:cachedImage];
        return;
    }

    self.representedAvatarIdentifier = identifier;
    __weak typeof(self) weakSelf = self;
    self.avatarTask = [[NSURLSession sharedSession] dataTaskWithURL:url
                                                  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || data.length == 0) {
            return;
        }

        UIImage *image = [UIImage imageWithData:data];
        if (!image) {
            return;
        }

        [[[weakSelf class] avatarImageCache] setObject:image forKey:identifier];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![weakSelf.representedAvatarIdentifier isEqualToString:identifier]) {
                return;
            }

            [weakSelf applyAvatarImage:image];
        });
    }];
    [self.avatarTask resume];
}

- (void)toggleVoicePlayback
{
    if (self.voiceData.length == 0) {
        return;
    }

    if (self.isContentVoicePlaying) {
        [self stopVoicePlaybackIfNeeded];
        return;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:UUVoicePlayHasInterruptNotification object:nil];
    self.contentVoicePlaying = YES;
    self.audioPlayer.delegate = self;
    [self.audioPlayer playAudioData:self.voiceData];
}

- (void)showPicturePreview
{
    [UUImageAvatarBrowser showImage:self.btnContent.backImageView];
    if ([self.delegate isKindOfClass:[UIViewController class]]) {
        [[(UIViewController *)self.delegate view] endEditing:YES];
    }
}

- (void)showCopyMenu
{
    [self.btnContent becomeFirstResponder];
    UIMenuController *menuController = UIMenuController.sharedMenuController;
    [menuController showMenuFromView:self.btnContent.superview rect:self.btnContent.frame];
}

- (void)configureDateLabelWithFrame:(UUMessageFrame *)messageFrame message:(UUMessage *)message
{
    self.dateLabel.text = message.displayTimeText;
    self.dateLabel.frame = messageFrame.timeF;
    self.dateLabel.hidden = CGRectEqualToRect(messageFrame.timeF, CGRectZero);
}

- (void)configureAvatarFrameWithFrame:(UUMessageFrame *)messageFrame message:(UUMessage *)message
{
    self.headImageButton.frame = messageFrame.iconF;
    self.headImageButton.hidden = CGRectEqualToRect(messageFrame.iconF, CGRectZero);
    if (!self.headImageButton.hidden) {
        [self configureAvatarForMessage:message];
    }
}

- (void)configureNameLabelWithFrame:(UUMessageFrame *)messageFrame message:(UUMessage *)message
{
    self.nameLabel.text = message.displayName.uppercaseString;
    self.nameLabel.frame = messageFrame.nameF;
    self.nameLabel.hidden = message.sender == UUMessageFromMe || CGRectEqualToRect(messageFrame.nameF, CGRectZero);
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
}

- (void)configureContentWithFrame:(UUMessageFrame *)messageFrame message:(UUMessage *)message
{
    [self resetContentState];

    self.btnContent.frame = messageFrame.contentF;
    self.btnContent.isMyMessage = message.sender == UUMessageFromMe;
    [self.btnContent setTitleColor:message.sender == UUMessageFromMe ? UIColor.whiteColor : [UIColor colorWithRed:0.12 green:0.16 blue:0.23 alpha:1.0]
                       forState:UIControlStateNormal];
    self.btnContent.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.btnContent.titleEdgeInsets = UIEdgeInsetsMake(ChatContentTopBottom, ChatContentBiger, ChatContentTopBottom, ChatContentSmaller);

    switch (message.contentType) {
        case UUMessageTypePicture:
            [self configurePictureContentWithMessage:message];
            break;
        case UUMessageTypeVoice:
            [self configureVoiceContentWithMessage:message];
            break;
        case UUMessageTypeText:
        default:
            [self configureTextContentWithMessage:message];
            break;
    }
}

- (void)configureTextContentWithMessage:(UUMessage *)message
{
    [self.btnContent setTitle:message.text ?: @"" forState:UIControlStateNormal];
}

- (void)configurePictureContentWithMessage:(UUMessage *)message
{
    self.btnContent.backImageView.hidden = NO;
    self.btnContent.backImageView.image = message.image;
}

- (void)configureVoiceContentWithMessage:(UUMessage *)message
{
    self.btnContent.voiceBackView.hidden = NO;
    self.btnContent.second.text = [NSString stringWithFormat:@"%@s", message.voiceDurationText ?: @"1"];
    self.voiceData = message.voiceData;
}

- (void)resetContentState
{
    self.contentVoicePlaying = NO;
    self.voiceData = nil;
    [self.btnContent stopPlay];
    [self.btnContent setTitle:@"" forState:UIControlStateNormal];
    self.btnContent.backImageView.hidden = YES;
    self.btnContent.backImageView.image = nil;
    self.btnContent.voiceBackView.hidden = YES;
    self.btnContent.second.text = nil;
}

- (void)stopVoicePlaybackIfNeeded
{
    if (self.isContentVoicePlaying) {
        [self.audioPlayer stopPlayback];
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    self.contentVoicePlaying = NO;
    [self.btnContent stopPlay];
}

- (void)cancelAvatarLoading
{
    [self.avatarTask cancel];
    self.avatarTask = nil;
    self.representedAvatarIdentifier = nil;
}

- (void)resetAvatarView
{
    [self.headImageButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.headImageButton setTitle:nil forState:UIControlStateNormal];
    self.headImageButton.backgroundColor = UIColor.clearColor;
    self.headImageButton.hidden = NO;
}

- (void)applyAvatarImage:(UIImage *)image
{
    self.representedAvatarIdentifier = nil;
    [self.headImageButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.headImageButton setTitle:nil forState:UIControlStateNormal];
    self.headImageButton.backgroundColor = UIColor.clearColor;
}

- (void)applyPlaceholderAvatarWithName:(NSString *)name
{
    NSString *displayName = name.length > 0 ? name : @"U";
    NSString *firstCharacter = [[displayName substringToIndex:1] uppercaseString];
    [self.headImageButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.headImageButton setTitle:firstCharacter forState:UIControlStateNormal];
    self.headImageButton.backgroundColor = [self avatarColorForSeed:displayName];
}

- (UIColor *)avatarColorForSeed:(NSString *)seed
{
    NSArray<UIColor *> *colors = @[
        [UIColor colorWithRed:0.98 green:0.47 blue:0.35 alpha:1.0],
        [UIColor colorWithRed:0.20 green:0.66 blue:0.86 alpha:1.0],
        [UIColor colorWithRed:0.44 green:0.72 blue:0.40 alpha:1.0],
        [UIColor colorWithRed:0.57 green:0.45 blue:0.85 alpha:1.0],
        [UIColor colorWithRed:0.96 green:0.68 blue:0.22 alpha:1.0]
    ];
    return colors[seed.hash % colors.count];
}

- (void)sensorStateChange:(NSNotification *)notification
{
    (void)notification;
    if ([[UIDevice currentDevice] proximityState] == YES) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

@end
