#import "UUInputFunctionView.h"
#import "UUChatCategory.h"
#import "UUVoiceRecordingHUDView.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>

typedef void (^UUAccessRequestCompletion)(BOOL granted);

static NSString * const UUMicrophonePermissionTitle = @"Microphone Access Needed";
static NSString * const UUMicrophonePermissionMessage = @"Enable microphone access in Settings to record and send voice messages.";
static NSString * const UUPhotoPermissionTitle = @"Photo Access Needed";
static NSString * const UUPhotoPermissionMessage = @"Enable photo library access in Settings to pick images for the chat.";
static NSString * const UUCameraPermissionTitle = @"Camera Access Needed";
static NSString * const UUCameraPermissionMessage = @"Enable camera access in Settings to take photos for the chat.";
static NSString * const UUInputActionIdentifierPhotoLibrary = @"photo_library";
static NSString * const UUInputActionIdentifierCamera = @"camera";
static CGFloat const UUInputBarPadding = 12.0;
static CGFloat const UUInputPrimaryControlHeight = 44.0;
static CGFloat const UUInputActionRowSpacing = 10.0;
static CGFloat const UUInputActionCardHeight = 92.0;

@interface UUInputActionButton : UIControl

@property (nonatomic, strong, readonly) UUInputActionItem *actionItem;

- (instancetype)initWithActionItem:(UUInputActionItem *)actionItem;
- (CGFloat)preferredWidth;

@end

@interface UUInputActionItem ()

@property (nonatomic, copy, readwrite) NSString *identifier;
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *systemImageName;

@end

@implementation UUInputActionItem

+ (instancetype)actionItemWithIdentifier:(NSString *)identifier
                                   title:(NSString *)title
                         systemImageName:(NSString *)systemImageName
{
    UUInputActionItem *item = [[self alloc] init];
    item.identifier = identifier;
    item.title = title;
    item.systemImageName = systemImageName;
    return item;
}

@end

@interface UUInputActionButton ()

@property (nonatomic, strong) UUInputActionItem *actionItem;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *actionTitleLabel;

@end

@implementation UUInputActionButton

- (instancetype)initWithActionItem:(UUInputActionItem *)actionItem
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _actionItem = actionItem;
        self.backgroundColor = [UIColor colorWithRed:1.0 green:0.99 blue:0.97 alpha:0.92];
        self.layer.cornerRadius = 20.0;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [UIColor colorWithRed:0.83 green:0.80 blue:0.76 alpha:1.0].CGColor;

        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        if (@available(iOS 13.0, *)) {
            _iconImageView.image = [UIImage uu_symbolImageNamed:actionItem.systemImageName
                                                      pointSize:28.0
                                                         weight:UIImageSymbolWeightMedium
                                                      tintColor:[UIColor colorWithRed:0.16 green:0.32 blue:0.66 alpha:1.0]];
        }
        [self addSubview:_iconImageView];

        _actionTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _actionTitleLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightSemibold];
        _actionTitleLabel.textColor = [UIColor colorWithRed:0.16 green:0.18 blue:0.24 alpha:1.0];
        _actionTitleLabel.textAlignment = NSTextAlignmentCenter;
        _actionTitleLabel.text = actionItem.title;
        [self addSubview:_actionTitleLabel];
    }
    return self;
}

- (CGFloat)preferredWidth
{
    CGFloat titleWidth = ceil([self.actionItem.title uu_sizeWithFont:self.actionTitleLabel.font].width);
    return MAX(96.0, titleWidth + 34.0);
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat iconSize = 30.0;
    CGFloat iconY = 16.0;
    self.iconImageView.frame = CGRectMake(floor((CGRectGetWidth(self.bounds) - iconSize) / 2.0), iconY, iconSize, iconSize);

    CGFloat titleY = CGRectGetMaxY(self.iconImageView.frame) + 8.0;
    self.actionTitleLabel.frame = CGRectMake(12.0, titleY, CGRectGetWidth(self.bounds) - 24.0, 18.0);
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.alpha = highlighted ? 0.74 : 1.0;
}

@end

@interface UUInputFunctionView () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate, PHPickerViewControllerDelegate>

@property (nonatomic, strong) UILabel *placeHold;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, weak, readonly) UIViewController *superVC;
@property (nonatomic, strong) NSDate *recordStartDate;
@property (nonatomic, copy) NSString *recordFilePath;
@property (nonatomic, assign, getter=isVoiceModeEnabled) BOOL voiceModeEnabled;
@property (nonatomic, assign) BOOL didCancelCurrentRecording;
@property (nonatomic, strong) NSTimer *recordingMeterTimer;
@property (nonatomic, strong) UUVoiceRecordingHUDView *recordingHUDView;
@property (nonatomic, strong) UIScrollView *actionScrollView;
@property (nonatomic, copy) NSArray<UUInputActionItem *> *displayedActionItems;
@property (nonatomic, copy) NSArray<UUInputActionButton *> *actionButtons;
@property (nonatomic, assign) BOOL actionsVisible;

@end

@implementation UUInputFunctionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.99 green:0.98 blue:0.96 alpha:0.88];
        self.isAbleToSendTextMessage = NO;
        self.layer.cornerRadius = 28.0;
        self.layer.masksToBounds = NO;
        self.layer.shadowColor = [UIColor colorWithRed:0.18 green:0.20 blue:0.27 alpha:1.0].CGColor;
        self.layer.shadowOpacity = 0.14;
        self.layer.shadowRadius = 24.0;
        self.layer.shadowOffset = CGSizeMake(0, 14);
        if (@available(iOS 13.0, *)) {
            self.layer.cornerCurve = kCACornerCurveContinuous;
        }

        self.recordingHUDView = [[UUVoiceRecordingHUDView alloc] initWithFrame:CGRectZero];

        self.btnSendMessage = [UIButton buttonWithType:UIButtonTypeSystem];
        self.btnSendMessage.layer.cornerRadius = 22.0;
        self.btnSendMessage.layer.masksToBounds = YES;
        [self.btnSendMessage addTarget:self action:@selector(handlePrimaryActionTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btnSendMessage];

        self.voiceModeEnabled = NO;
        self.btnChangeVoiceState = [UIButton buttonWithType:UIButtonTypeSystem];
        self.btnChangeVoiceState.layer.cornerRadius = 22.0;
        self.btnChangeVoiceState.layer.masksToBounds = YES;
        [self.btnChangeVoiceState addTarget:self action:@selector(toggleVoiceInputMode:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btnChangeVoiceState];

        self.btnVoiceRecord = [UIButton buttonWithType:UIButtonTypeSystem];
        self.btnVoiceRecord.hidden = YES;
        self.btnVoiceRecord.backgroundColor = [UIColor colorWithRed:0.97 green:0.95 blue:0.92 alpha:0.96];
        self.btnVoiceRecord.layer.cornerRadius = 22.0;
        self.btnVoiceRecord.layer.borderWidth = 1.0;
        self.btnVoiceRecord.layer.borderColor = [UIColor colorWithRed:0.83 green:0.80 blue:0.76 alpha:1.0].CGColor;
        [self.btnVoiceRecord setTitleColor:[UIColor colorWithRed:0.16 green:0.18 blue:0.24 alpha:1.0] forState:UIControlStateNormal];
        [self.btnVoiceRecord addTarget:self action:@selector(beginVoiceRecording:) forControlEvents:UIControlEventTouchDown];
        [self.btnVoiceRecord addTarget:self action:@selector(finishVoiceRecording:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnVoiceRecord addTarget:self action:@selector(cancelVoiceRecording:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];
        [self.btnVoiceRecord addTarget:self action:@selector(handleVoiceRecordDragExit:) forControlEvents:UIControlEventTouchDragExit];
        [self.btnVoiceRecord addTarget:self action:@selector(handleVoiceRecordDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
        [self addSubview:self.btnVoiceRecord];

        self.textViewInput = [[UITextView alloc] init];
        self.textViewInput.layer.cornerRadius = 22.0;
        self.textViewInput.layer.masksToBounds = YES;
        self.textViewInput.delegate = self;
        self.textViewInput.layer.borderWidth = 1;
        self.textViewInput.layer.borderColor = [UIColor colorWithRed:0.83 green:0.80 blue:0.76 alpha:1.0].CGColor;
        self.textViewInput.backgroundColor = [UIColor colorWithRed:1.0 green:0.99 blue:0.97 alpha:0.98];
        self.textViewInput.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        self.textViewInput.textColor = [UIColor colorWithRed:0.16 green:0.18 blue:0.24 alpha:1.0];
        self.textViewInput.textContainerInset = UIEdgeInsetsMake(12, 14, 12, 44);
        self.textViewInput.showsVerticalScrollIndicator = NO;
        [self addSubview:self.textViewInput];

        self.placeHold = [[UILabel alloc] init];
        self.placeHold.text = @"Type a message";
        self.placeHold.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        self.placeHold.textColor = [UIColor colorWithRed:0.55 green:0.56 blue:0.60 alpha:1.0];
        [self.textViewInput addSubview:self.placeHold];

        self.actionScrollView = [[UIScrollView alloc] init];
        self.actionScrollView.showsHorizontalScrollIndicator = NO;
        self.actionScrollView.alwaysBounceHorizontal = NO;
        self.actionScrollView.backgroundColor = UIColor.clearColor;
        self.actionScrollView.alpha = 0.0;
        [self addSubview:self.actionScrollView];

        self.customActionItems = @[];
        [self refreshIcons];
        [self updatePrimaryActionForEmptyTextState:YES];
        [self updateVoiceRecordButtonTitle:@"Hold to Talk"];
    }
    return self;
}

- (void)dealloc
{
    [self stopRecordingMeterUpdates];
    [self.recordingHUDView dismissAnimated:NO];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat padding = UUInputBarPadding;
    CGFloat buttonSide = UUInputPrimaryControlHeight;
    CGFloat contentHeight = UUInputPrimaryControlHeight;
    CGFloat textX = padding + buttonSide + 10.0;
    CGFloat trailingWidth = buttonSide + 8.0;
    CGFloat textWidth = CGRectGetWidth(self.bounds) - textX - trailingWidth - padding;
    BOOL showsActions = self.actionsVisible && self.displayedActionItems.count > 0;
    CGFloat actionRowHeight = showsActions ? UUInputActionCardHeight : 0.0;
    CGFloat actionRowTop = padding + contentHeight + (showsActions ? UUInputActionRowSpacing : 0.0);

    self.btnChangeVoiceState.frame = CGRectMake(padding, padding, buttonSide, buttonSide);
    self.btnSendMessage.frame = CGRectMake(CGRectGetWidth(self.bounds) - padding - buttonSide, padding, buttonSide, buttonSide);
    self.textViewInput.frame = CGRectMake(textX, padding, textWidth, contentHeight);
    self.btnVoiceRecord.frame = self.textViewInput.frame;
    self.placeHold.frame = CGRectMake(16, 12, CGRectGetWidth(self.textViewInput.bounds) - 32, 22);
    self.actionScrollView.frame = CGRectMake(padding, actionRowTop, CGRectGetWidth(self.bounds) - padding * 2.0, actionRowHeight);
    self.actionScrollView.alpha = showsActions ? 1.0 : 0.0;
    [self layoutActionButtons];

    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, self.preferredHeight);
}

- (CGFloat)preferredHeight
{
    if (!self.actionsVisible || self.displayedActionItems.count == 0) {
        return (UUInputBarPadding * 2.0) + UUInputPrimaryControlHeight;
    }

    return (UUInputBarPadding * 2.0) + UUInputPrimaryControlHeight + UUInputActionRowSpacing + UUInputActionCardHeight;
}

- (UIViewController *)superVC
{
    return [self uu_findNextResponderInClass:[UIViewController class]];
}

- (void)beginVoiceRecording:(UIButton *)button
{
    (void)button;
    [self requestMicrophoneAccessIfNeededWithCompletion:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!granted) {
                return;
            }

            [self startVoiceRecording];
        });
    }];
}

- (void)finishVoiceRecording:(UIButton *)button
{
    (void)button;
    if (!self.recorder.isRecording) {
        return;
    }

    [self.recordingHUDView setCancelling:NO];
    [self updateVoiceRecordButtonTitle:@"Finishing..."];
    [self.recorder stop];
}

- (void)cancelVoiceRecording:(UIButton *)button
{
    (void)button;
    [self stopRecordingIfNeededCancelled:YES];
}

- (void)handleVoiceRecordDragExit:(UIButton *)button
{
    (void)button;
    [self.recordingHUDView setCancelling:YES];
    [self updateVoiceRecordButtonTitle:@"Release to Cancel"];
}

- (void)handleVoiceRecordDragEnter:(UIButton *)button
{
    (void)button;
    [self.recordingHUDView setCancelling:NO];
    [self updateVoiceRecordButtonTitle:@"Recording..."];
}

- (void)toggleVoiceInputMode:(UIButton *)sender
{
    (void)sender;
    if (self.isVoiceModeEnabled) {
        [self stopRecordingIfNeededCancelled:YES];
        [self setVoiceModeEnabled:NO];
        [self.textViewInput becomeFirstResponder];
        return;
    }

    [self requestMicrophoneAccessIfNeededWithCompletion:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!granted) {
                [self setVoiceModeEnabled:NO];
                return;
            }

            [self setVoiceModeEnabled:YES];
            [self updateVoiceRecordButtonTitle:@"Hold to Talk"];
            [self.textViewInput resignFirstResponder];
        });
    }];
}

- (void)startVoiceRecording
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [audioSession setActive:YES error:&error];
    if (error) {
        [self presentTransientAlertWithTitle:@"Microphone Unavailable"
                                     message:error.localizedDescription ?: @"Unable to activate the microphone right now."];
        return;
    }

    self.recordFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"uuchat-%@.m4a", NSUUID.UUID.UUIDString]];
    NSDictionary *settings = @{
        AVFormatIDKey : @(kAudioFormatMPEG4AAC),
        AVSampleRateKey : @44100,
        AVNumberOfChannelsKey : @1,
        AVEncoderAudioQualityKey : @(AVAudioQualityMedium)
    };
    self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.recordFilePath] settings:settings error:&error];
    if (!self.recorder || error) {
        [self presentTransientAlertWithTitle:@"Recording Failed"
                                     message:error.localizedDescription ?: @"Unable to create the recorder for this voice message."];
        return;
    }

    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    self.didCancelCurrentRecording = NO;
    self.recordStartDate = NSDate.date;

    if (![self.recorder prepareToRecord] || ![self.recorder record]) {
        [self presentTransientAlertWithTitle:@"Recording Failed"
                                     message:@"The microphone did not start recording. Please try again."];
        self.recorder = nil;
        self.recordStartDate = nil;
        self.recordFilePath = nil;
        return;
    }

    [self.recordingHUDView setCancelling:NO];
    [self.recordingHUDView presentInView:[self recordingHUDPresentationView]];
    [self startRecordingMeterUpdates];
    [self refreshRecordingMeters:nil];
    [self updateVoiceRecordButtonTitle:@"Recording..."];
}

- (void)stopRecordingIfNeededCancelled:(BOOL)cancelled
{
    if (!self.recorder) {
        [self deactivateAudioSession];
        [self resetRecorderState];
        return;
    }

    self.didCancelCurrentRecording = cancelled;
    [self.recordingHUDView setCancelling:cancelled];
    [self stopRecordingMeterUpdates];
    [self.recorder stop];
    if (cancelled) {
        [self.recorder deleteRecording];
    }
}

- (void)handlePrimaryActionTap:(UIButton *)sender
{
    (void)sender;
    if (!self.isAbleToSendTextMessage) {
        [self.textViewInput resignFirstResponder];
        [self setActionsVisible:!self.actionsVisible animated:YES notifyDelegate:YES];
        return;
    }

    NSString *resultString = [self.textViewInput.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (resultString.length == 0) {
        return;
    }

    [self notifyDelegateDidSendText:resultString];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self setActionsVisible:NO animated:YES notifyDelegate:YES];
    self.placeHold.hidden = textView.text.length > 0;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updatePrimaryActionForEmptyTextState:textView.text.length == 0];
    self.placeHold.hidden = textView.text.length > 0;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.placeHold.hidden = textView.text.length > 0;
}

- (void)updatePrimaryActionForEmptyTextState:(BOOL)isTextEmpty
{
    self.isAbleToSendTextMessage = !isTextEmpty;
    if (!isTextEmpty) {
        [self setActionsVisible:NO animated:YES notifyDelegate:YES];
    }
    [self refreshIcons];
}

- (void)changeSendBtnWithPhoto:(BOOL)isPhoto
{
    [self updatePrimaryActionForEmptyTextState:isPhoto];
}

- (void)clearTextInput
{
    self.textViewInput.text = @"";
    self.placeHold.hidden = NO;
    [self setActionsVisible:NO animated:NO notifyDelegate:YES];
    [self updatePrimaryActionForEmptyTextState:YES];
}

- (void)refreshIcons
{
    if (@available(iOS 13.0, *)) {
        UIColor *warmNeutral = [UIColor colorWithRed:0.94 green:0.90 blue:0.86 alpha:1.0];
        UIColor *deepInk = [UIColor colorWithRed:0.16 green:0.18 blue:0.24 alpha:1.0];
        UIColor *accentBlue = [UIColor colorWithRed:0.16 green:0.32 blue:0.66 alpha:1.0];
        UIColor *accentCoral = [UIColor colorWithRed:0.90 green:0.54 blue:0.41 alpha:1.0];

        self.btnChangeVoiceState.backgroundColor = self.isVoiceModeEnabled ? accentCoral : warmNeutral;
        self.btnChangeVoiceState.tintColor = self.isVoiceModeEnabled ? UIColor.whiteColor : deepInk;
        BOOL showsExpandedState = !self.isAbleToSendTextMessage && self.actionsVisible;
        self.btnSendMessage.backgroundColor = self.isAbleToSendTextMessage || showsExpandedState ? accentBlue : warmNeutral;
        self.btnSendMessage.tintColor = self.isAbleToSendTextMessage || showsExpandedState ? UIColor.whiteColor : deepInk;
        self.btnSendMessage.enabled = YES;

        NSString *sendSymbol = self.isAbleToSendTextMessage ? @"arrow.up" : (self.actionsVisible ? @"xmark" : @"plus");
        [self.btnSendMessage setImage:[UIImage uu_symbolImageNamed:sendSymbol
                                                         pointSize:18
                                                            weight:UIImageSymbolWeightSemibold
                                                         tintColor:self.btnSendMessage.tintColor]
                              forState:UIControlStateNormal];

        NSString *toggleSymbol = self.isVoiceModeEnabled ? @"keyboard.fill" : @"waveform";
        [self.btnChangeVoiceState setImage:[UIImage uu_symbolImageNamed:toggleSymbol
                                                              pointSize:18
                                                                 weight:UIImageSymbolWeightSemibold
                                                              tintColor:self.btnChangeVoiceState.tintColor]
                                   forState:UIControlStateNormal];
    }
}

- (void)updateVoiceRecordButtonTitle:(NSString *)title
{
    [self.btnVoiceRecord setTitle:title forState:UIControlStateNormal];
    [self.btnVoiceRecord setTitle:@"Release to Send" forState:UIControlStateHighlighted];
}

- (NSArray<UUInputActionItem *> *)defaultActionItems
{
    return @[
        [UUInputActionItem actionItemWithIdentifier:UUInputActionIdentifierPhotoLibrary
                                              title:@"Photo"
                                    systemImageName:@"photo.on.rectangle.angled"],
        [UUInputActionItem actionItemWithIdentifier:UUInputActionIdentifierCamera
                                              title:@"Camera"
                                    systemImageName:@"camera"]
    ];
}

- (void)setCustomActionItems:(NSArray<UUInputActionItem *> *)customActionItems
{
    _customActionItems = [customActionItems copy] ?: @[];
    self.displayedActionItems = [[self defaultActionItems] arrayByAddingObjectsFromArray:_customActionItems];
    [self rebuildActionButtons];
    if (self.displayedActionItems.count == 0) {
        [self setActionsVisible:NO animated:NO notifyDelegate:YES];
    }
}

- (void)rebuildActionButtons
{
    for (UUInputActionButton *button in self.actionButtons) {
        [button removeFromSuperview];
    }

    NSMutableArray<UUInputActionButton *> *buttons = [NSMutableArray arrayWithCapacity:self.displayedActionItems.count];
    [self.displayedActionItems enumerateObjectsUsingBlock:^(UUInputActionItem *item, NSUInteger idx, BOOL *stop) {
        (void)stop;
        UUInputActionButton *button = [[UUInputActionButton alloc] initWithActionItem:item];
        button.tag = idx;
        [button addTarget:self action:@selector(handleActionButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.actionScrollView addSubview:button];
        [buttons addObject:button];
    }];

    self.actionButtons = buttons.copy;
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)layoutActionButtons
{
    CGFloat availableWidth = CGRectGetWidth(self.actionScrollView.bounds);
    CGFloat availableHeight = CGRectGetHeight(self.actionScrollView.bounds);
    if (availableWidth <= 0 || availableHeight <= 0) {
        self.actionScrollView.contentSize = CGSizeZero;
        return;
    }

    CGFloat spacing = 12.0;
    CGFloat totalWidth = 0.0;
    NSMutableArray<NSNumber *> *buttonWidths = [NSMutableArray arrayWithCapacity:self.actionButtons.count];
    for (UUInputActionButton *button in self.actionButtons) {
        CGFloat buttonWidth = [button preferredWidth];
        [buttonWidths addObject:@(buttonWidth)];
        totalWidth += buttonWidth;
    }

    if (buttonWidths.count > 1) {
        totalWidth += spacing * (buttonWidths.count - 1);
    }

    CGFloat x = totalWidth < availableWidth ? floor((availableWidth - totalWidth) / 2.0) : 0.0;
    for (NSUInteger idx = 0; idx < self.actionButtons.count; idx++) {
        UUInputActionButton *button = self.actionButtons[idx];
        CGFloat buttonWidth = buttonWidths[idx].doubleValue;
        button.frame = CGRectMake(x, 0.0, buttonWidth, availableHeight);
        x += buttonWidth + spacing;
    }

    self.actionScrollView.contentSize = CGSizeMake(MAX(totalWidth, availableWidth), availableHeight);
}

- (void)handleActionButtonTap:(UUInputActionButton *)button
{
    NSUInteger index = (NSUInteger)button.tag;
    if (index >= self.displayedActionItems.count) {
        return;
    }

    [self.textViewInput resignFirstResponder];
    [self setActionsVisible:NO animated:YES notifyDelegate:YES];

    UUInputActionItem *actionItem = self.displayedActionItems[index];
    if ([actionItem.identifier isEqualToString:UUInputActionIdentifierPhotoLibrary]) {
        [self presentPhotoLibraryPicker];
        return;
    }

    if ([actionItem.identifier isEqualToString:UUInputActionIdentifierCamera]) {
        [self presentCameraPicker];
        return;
    }

    if ([self.delegate respondsToSelector:@selector(inputFunctionView:didSelectCustomActionItem:)]) {
        [self.delegate inputFunctionView:self didSelectCustomActionItem:actionItem];
    }
}

- (void)presentCameraPicker
{
    if (!self.superVC) {
        return;
    }

    [self requestCameraAccessIfNeededWithCompletion:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!granted) {
                return;
            }

            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = NO;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self.superVC presentViewController:picker animated:YES completion:nil];
                return;
            }

            [self presentTransientAlertWithTitle:@"Camera Unavailable"
                                         message:@"This device does not have an available camera."];
        });
    }];
}

- (void)presentPhotoLibraryPicker
{
    if (!self.superVC) {
        return;
    }

    if (@available(iOS 14.0, *)) {
        PHPickerConfiguration *configuration = [[PHPickerConfiguration alloc] init];
        configuration.filter = [PHPickerFilter imagesFilter];
        configuration.selectionLimit = 1;
        configuration.preferredAssetRepresentationMode = PHPickerConfigurationAssetRepresentationModeCurrent;

        PHPickerViewController *pickerViewController = [[PHPickerViewController alloc] initWithConfiguration:configuration];
        pickerViewController.delegate = self;
        [self.superVC presentViewController:pickerViewController animated:YES completion:nil];
        return;
    }

    [self requestPhotoLibraryAccessIfNeededWithCompletion:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!granted) {
                return;
            }

            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                [self presentTransientAlertWithTitle:@"Photos Unavailable"
                                             message:@"This device does not have an available photo library."];
                return;
            }

            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self.superVC presentViewController:picker animated:YES completion:nil];
        });
    }];
}

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results API_AVAILABLE(ios(14.0))
{
    __weak typeof(self) weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:nil];

    PHPickerResult *result = results.firstObject;
    if (!result) {
        return;
    }

    NSItemProvider *itemProvider = result.itemProvider;
    if (![itemProvider canLoadObjectOfClass:UIImage.class]) {
        [self presentTransientAlertWithTitle:@"Photo Load Failed"
                                     message:@"The selected photo could not be imported."];
        return;
    }

    [itemProvider loadObjectOfClass:UIImage.class completionHandler:^(id<NSItemProviderReading> object, NSError *error) {
        UIImage *selectedImage = [object isKindOfClass:UIImage.class] ? (UIImage *)object : nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!selectedImage || error) {
                [weakSelf presentTransientAlertWithTitle:@"Photo Load Failed"
                                                 message:error.localizedDescription ?: @"The selected photo could not be imported."];
                return;
            }

            [weakSelf notifyDelegateDidSendImage:selectedImage];
        });
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage] ?: info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self notifyDelegateDidSendImage:originalImage];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    (void)recorder;
    NSTimeInterval interval = self.recordStartDate ? [NSDate.date timeIntervalSinceDate:self.recordStartDate] : 0;
    NSInteger duration = MAX((NSInteger)round(interval), 1);
    NSData *audioData = [NSData dataWithContentsOfFile:self.recordFilePath];
    [self deactivateAudioSession];

    BOOL didCancelRecording = self.didCancelCurrentRecording;
    [self resetRecorderState];

    if (didCancelRecording) {
        return;
    }

    if (flag && audioData.length > 0) {
        [self notifyDelegateDidSendVoiceData:audioData duration:duration];
        return;
    }

    [self presentTransientAlertWithTitle:@"Recording Failed"
                                 message:@"The voice clip could not be saved. Please try again."];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    (void)recorder;
    [self deactivateAudioSession];
    [self resetRecorderState];
    [self presentTransientAlertWithTitle:@"Recording Error"
                                 message:error.localizedDescription ?: @"An encoding error interrupted the voice recording."];
}

- (void)setVoiceModeEnabled:(BOOL)enabled
{
    if (_voiceModeEnabled == enabled) {
        return;
    }

    _voiceModeEnabled = enabled;
    self.btnVoiceRecord.hidden = !enabled;
    self.textViewInput.hidden = enabled;
    [self refreshIcons];
}

- (void)setActionsVisible:(BOOL)actionsVisible animated:(BOOL)animated notifyDelegate:(BOOL)notifyDelegate
{
    BOOL resolvedVisibility = actionsVisible && self.displayedActionItems.count > 0;
    if (_actionsVisible == resolvedVisibility) {
        return;
    }

    _actionsVisible = resolvedVisibility;
    [self refreshIcons];
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];

    if (notifyDelegate && [self.delegate respondsToSelector:@selector(inputFunctionView:didChangePreferredHeight:animated:)]) {
        [self.delegate inputFunctionView:self didChangePreferredHeight:self.preferredHeight animated:animated];
    }
}

- (void)resetRecorderState
{
    [self stopRecordingMeterUpdates];
    [self.recordingHUDView dismissAnimated:YES];
    self.recorder = nil;
    self.recordStartDate = nil;
    self.recordFilePath = nil;
    self.didCancelCurrentRecording = NO;
    [self updateVoiceRecordButtonTitle:@"Hold to Talk"];
}

- (void)startRecordingMeterUpdates
{
    [self stopRecordingMeterUpdates];
    self.recordingMeterTimer = [NSTimer timerWithTimeInterval:0.05
                                                       target:self
                                                     selector:@selector(refreshRecordingMeters:)
                                                     userInfo:nil
                                                      repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.recordingMeterTimer forMode:NSRunLoopCommonModes];
}

- (void)stopRecordingMeterUpdates
{
    [self.recordingMeterTimer invalidate];
    self.recordingMeterTimer = nil;
}

- (void)refreshRecordingMeters:(NSTimer *)timer
{
    (void)timer;
    if (!self.recorder.isRecording) {
        return;
    }

    [self.recorder updateMeters];
    NSTimeInterval duration = self.recordStartDate ? [NSDate.date timeIntervalSinceDate:self.recordStartDate] : 0;
    float peakPower = [self.recorder peakPowerForChannel:0];
    CGFloat normalizedLevel = [self normalizedAudioLevelFromPower:peakPower];
    [self.recordingHUDView updateWithDuration:duration level:normalizedLevel];
}

- (CGFloat)normalizedAudioLevelFromPower:(float)power
{
    if (power <= -80.0f) {
        return 0.02;
    }

    CGFloat normalizedLevel = powf(10.0f, power / 20.0f);
    return MIN(MAX(normalizedLevel, 0.02), 1.0);
}

- (UIView *)recordingHUDPresentationView
{
    return self.superVC.view ?: self.window ?: self;
}

- (void)deactivateAudioSession
{
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)notifyDelegateDidSendText:(NSString *)text
{
    if ([self.delegate respondsToSelector:@selector(inputFunctionView:didSendText:)]) {
        [self.delegate inputFunctionView:self didSendText:text];
        return;
    }

    if ([self.delegate respondsToSelector:@selector(UUInputFunctionView:sendMessage:)]) {
        [self.delegate UUInputFunctionView:self sendMessage:text];
    }
}

- (void)notifyDelegateDidSendImage:(UIImage *)image
{
    if (!image) {
        return;
    }

    if ([self.delegate respondsToSelector:@selector(inputFunctionView:didSendImage:)]) {
        [self.delegate inputFunctionView:self didSendImage:image];
        return;
    }

    if ([self.delegate respondsToSelector:@selector(UUInputFunctionView:sendPicture:)]) {
        [self.delegate UUInputFunctionView:self sendPicture:image];
    }
}

- (void)notifyDelegateDidSendVoiceData:(NSData *)voiceData duration:(NSInteger)duration
{
    if ([self.delegate respondsToSelector:@selector(inputFunctionView:didSendVoiceData:duration:)]) {
        [self.delegate inputFunctionView:self didSendVoiceData:voiceData duration:duration];
        return;
    }

    if ([self.delegate respondsToSelector:@selector(UUInputFunctionView:sendVoice:time:)]) {
        [self.delegate UUInputFunctionView:self sendVoice:voiceData time:duration];
    }
}

- (void)requestMicrophoneAccessIfNeededWithCompletion:(UUAccessRequestCompletion)completion
{
    if (@available(iOS 17.0, *)) {
        AVAudioApplicationRecordPermission permission = AVAudioApplication.sharedInstance.recordPermission;
        switch (permission) {
            case AVAudioApplicationRecordPermissionGranted:
                completion(YES);
                return;
            case AVAudioApplicationRecordPermissionDenied:
                [self presentSettingsAlertWithTitle:UUMicrophonePermissionTitle
                                            message:UUMicrophonePermissionMessage];
                completion(NO);
                return;
            case AVAudioApplicationRecordPermissionUndetermined:
                [AVAudioApplication requestRecordPermissionWithCompletionHandler:^(BOOL granted) {
                    if (!granted) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self presentSettingsAlertWithTitle:UUMicrophonePermissionTitle
                                                        message:UUMicrophonePermissionMessage];
                        });
                    }
                    completion(granted);
                }];
                return;
        }
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    AVAudioSessionRecordPermission permission = AVAudioSession.sharedInstance.recordPermission;
    switch (permission) {
        case AVAudioSessionRecordPermissionGranted:
            completion(YES);
            return;
        case AVAudioSessionRecordPermissionDenied:
            [self presentSettingsAlertWithTitle:UUMicrophonePermissionTitle
                                        message:UUMicrophonePermissionMessage];
            completion(NO);
            return;
        case AVAudioSessionRecordPermissionUndetermined:
            [AVAudioSession.sharedInstance requestRecordPermission:^(BOOL granted) {
                if (!granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentSettingsAlertWithTitle:UUMicrophonePermissionTitle
                                                    message:UUMicrophonePermissionMessage];
                    });
                }
                completion(granted);
            }];
            return;
    }
#pragma clang diagnostic pop
}

- (void)requestPhotoLibraryAccessIfNeededWithCompletion:(UUAccessRequestCompletion)completion
{
    if (@available(iOS 14.0, *)) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
        if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited) {
            completion(YES);
            return;
        }

        if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
            [self presentSettingsAlertWithTitle:UUPhotoPermissionTitle
                                        message:UUPhotoPermissionMessage];
            completion(NO);
            return;
        }

        [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus requestStatus) {
            BOOL granted = requestStatus == PHAuthorizationStatusAuthorized || requestStatus == PHAuthorizationStatusLimited;
            if (!granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentSettingsAlertWithTitle:UUPhotoPermissionTitle
                                                message:UUPhotoPermissionMessage];
                });
            }
            completion(granted);
        }];
        return;
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    PHAuthorizationStatus status = PHPhotoLibrary.authorizationStatus;
    if (status == PHAuthorizationStatusAuthorized) {
        completion(YES);
        return;
    }

    if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
        [self presentSettingsAlertWithTitle:UUPhotoPermissionTitle
                                    message:UUPhotoPermissionMessage];
        completion(NO);
        return;
    }

    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus requestStatus) {
        BOOL granted = requestStatus == PHAuthorizationStatusAuthorized;
        if (!granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentSettingsAlertWithTitle:UUPhotoPermissionTitle
                                            message:UUPhotoPermissionMessage];
            });
        }
        completion(granted);
    }];
#pragma clang diagnostic pop
}

- (void)requestCameraAccessIfNeededWithCompletion:(UUAccessRequestCompletion)completion
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusAuthorized:
            completion(YES);
            return;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            [self presentSettingsAlertWithTitle:UUCameraPermissionTitle
                                        message:UUCameraPermissionMessage];
            completion(NO);
            return;
        case AVAuthorizationStatusNotDetermined:
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (!granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentSettingsAlertWithTitle:UUCameraPermissionTitle
                                                    message:UUCameraPermissionMessage];
                    });
                }
                completion(granted);
            }];
            return;
    }
}

- (void)presentTransientAlertWithTitle:(NSString *)title message:(NSString *)message
{
    if (!NSThread.isMainThread) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentTransientAlertWithTitle:title message:message];
        });
        return;
    }

    UIViewController *presentingViewController = self.superVC;
    if (!presentingViewController.presentedViewController && presentingViewController) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [presentingViewController presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)presentSettingsAlertWithTitle:(NSString *)title message:(NSString *)message
{
    if (!NSThread.isMainThread) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentSettingsAlertWithTitle:title message:message];
        });
        return;
    }

    UIViewController *presentingViewController = self.superVC;
    if (!presentingViewController || presentingViewController.presentedViewController) {
        return;
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Not Now" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        (void)action;
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if (settingsURL && [UIApplication.sharedApplication canOpenURL:settingsURL]) {
            [UIApplication.sharedApplication openURL:settingsURL options:@{} completionHandler:nil];
        }
    }]];
    [presentingViewController presentViewController:alertController animated:YES completion:nil];
}

@end
