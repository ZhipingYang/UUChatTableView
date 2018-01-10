//
//  UUMessageCell.m
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUMessageCell.h"
#import "UUMessageFrame.h"
#import "UUAVAudioPlayer.h"
#import "UIImageView+AFNetworking.h"
#import "UIButton+AFNetworking.h"
#import "UUImageAvatarBrowser.h"
#import "UUChatCategory.h"
#import "UUMessageContentButton.h"

@interface UUMessageCell ()<UUAVAudioPlayerDelegate>
{
    NSString *_voiceURL;
    NSData *_songData;
    
    UUAVAudioPlayer *_audio;
    
    UIView *_headImageBackView;
    BOOL _contentVoiceIsPlaying;
}

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *namelabel;
@property (nonatomic, strong) UIButton *headImageButton;

@property (nonatomic, strong) UUMessageContentButton *btnContent;

@end

@implementation UUMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
		
        // 1、创建时间
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        self.dateLabel.textColor = [UIColor grayColor];
        self.dateLabel.font = ChatTimeFont;
        [self.contentView addSubview:self.dateLabel];
        
        // 2、创建头像
        _headImageBackView = [[UIView alloc]init];
        _headImageBackView.layer.cornerRadius = 22;
        _headImageBackView.layer.masksToBounds = YES;
        _headImageBackView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
        [self.contentView addSubview:_headImageBackView];
		
        self.headImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.headImageButton.layer.cornerRadius = 20;
        self.headImageButton.layer.masksToBounds = YES;
        [self.headImageButton addTarget:self action:@selector(btnHeadImageClick:)  forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.headImageButton];
        
        // 3、创建头像下标
        self.namelabel = [[UILabel alloc] init];
        self.namelabel.textColor = [UIColor grayColor];
        self.namelabel.textAlignment = NSTextAlignmentCenter;
        self.namelabel.font = ChatTimeFont;
		self.namelabel.numberOfLines = 0;
        [self.contentView addSubview:self.namelabel];
        
        // 4、创建内容
        self.btnContent = [UUMessageContentButton buttonWithType:UIButtonTypeCustom];
        [self.btnContent setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.btnContent.titleLabel.font = ChatContentFont;
        self.btnContent.titleLabel.numberOfLines = 0;
        [self.btnContent addTarget:self action:@selector(btnContentClick)  forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnContent];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(UUAVAudioPlayerDidFinishPlay) name:@"VoicePlayHasInterrupt" object:nil];
        
        //红外线感应监听
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:)
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
        _contentVoiceIsPlaying = NO;
		
    }
    return self;
}

- (void)prepareForReuse
{
	[super prepareForReuse];
	// 清空内容
	[self.btnContent setTitle:@"" forState:UIControlStateNormal];
	self.btnContent.voiceBackView.hidden = YES;
	self.btnContent.backImageView.hidden = YES;

}

//头像点击
- (void)btnHeadImageClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(chatCell:headImageDidClick:)])  {
        [self.delegate chatCell:self headImageDidClick:self.messageFrame.message];
    }
}

- (void)btnContentClick {
    //play audio
    if (self.messageFrame.message.type == UUMessageTypeVoice) {
        if (!_contentVoiceIsPlaying) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VoicePlayHasInterrupt" object:nil];
            _contentVoiceIsPlaying = YES;
            _audio = [UUAVAudioPlayer sharedInstance];
            _audio.delegate = self;
//			[_audio playSongWithUrl:_voiceURL];
            [_audio playSongWithData:_songData];
        }else{
            [self UUAVAudioPlayerDidFinishPlay];
        }
    }
    //show the picture
    else if (self.messageFrame.message.type == UUMessageTypePicture) {
        if (self.btnContent.backImageView) {
            [UUImageAvatarBrowser showImage:self.btnContent.backImageView];
        }
        if ([self.delegate isKindOfClass:[UIViewController class]]) {
            [[(UIViewController *)self.delegate view] endEditing:YES];
        }
    }
    // show text and gonna copy that
    else if (self.messageFrame.message.type == UUMessageTypeText) {
        [self.btnContent becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setTargetRect:self.btnContent.frame inView:self.btnContent.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (void)UUAVAudioPlayerBeiginLoadVoice
{
    [self.btnContent benginLoadVoice];
}

- (void)UUAVAudioPlayerBeiginPlay
{
    //开启红外线感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [self.btnContent didLoadVoice];
}

- (void)UUAVAudioPlayerDidFinishPlay
{
    //关闭红外线感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    _contentVoiceIsPlaying = NO;
    [self.btnContent stopPlay];
    [[UUAVAudioPlayer sharedInstance]stopSound];
}

//内容及Frame设置
- (void)setMessageFrame:(UUMessageFrame *)messageFrame
{
    _messageFrame = messageFrame;
	id <UUMessage> message = messageFrame.message;
    // 1、设置时间
    self.dateLabel.text = message.date;
    self.dateLabel.frame = messageFrame.timeFrame;
    
    // 2、设置头像
    _headImageBackView.frame = messageFrame.iconFrame;
    self.headImageButton.frame = CGRectInset(messageFrame.iconFrame, 2, 2);
	[self.headImageButton setBackgroundImage:message.avatar ?: [UIImage uu_imageWithName:@"headImage.jpeg"] forState:UIControlStateNormal];
	
    // 3、设置下标
    self.namelabel.text = message.nickName;
	self.namelabel.frame = messageFrame.nameFrame;
	
    // 4、设置内容
	self.btnContent.messageFrame = messageFrame;
	
	if (messageFrame.message.type == UUMessageTypeVoice) {
		_songData = messageFrame.message.voiceData;
	}
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    if ([[UIDevice currentDevice] proximityState] == YES){
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else{
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

@end



