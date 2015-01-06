//
//  UUMessageCell.m
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUMessageCell.h"
#import "UUMessage.h"
#import "UUMessageFrame.h"
#import "UUAVAudioPlayer.h"
#import "UIImageView+AFNetworking.h"
#import "UIButton+AFNetworking.h"
#import "SJAvatarBrowser.h"

@interface UUMessageCell ()<UUAVAudioPlayerDelegate>
{
    NSString *voiceURL;
    AVAudioPlayer *player;
    
    UUAVAudioPlayer *audio;
    
    UILabel *fiveMessageRemind;
    
    UIView *headImageBackView;
}
@end

@implementation UUMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        // 1、创建时间
        self.labelTime = [[UILabel alloc] init];
        self.labelTime.textColor = [UIColor grayColor];
        self.labelTime.font = ChatTimeFont;
        [self.contentView addSubview:self.labelTime];
        
        // 2、创建头像
        headImageBackView = [[UIView alloc]init];
        headImageBackView.layer.cornerRadius = 22;
        headImageBackView.layer.masksToBounds = YES;
        headImageBackView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
        [self.contentView addSubview:headImageBackView];
        self.btnHeadImage = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnHeadImage.layer.cornerRadius = 20;
        self.btnHeadImage.layer.masksToBounds = YES;
        [self.btnHeadImage addTarget:self action:@selector(btnHeadImageClick:)  forControlEvents:UIControlEventTouchUpInside];
        [headImageBackView addSubview:self.btnHeadImage];
        
        // 3、创建头像下标
        self.labelNum = [[UILabel alloc] init];
        self.labelNum.textColor = [UIColor grayColor];
        self.labelNum.textAlignment = NSTextAlignmentCenter;
        self.labelNum.font = ChatTimeFont;
        [self.contentView addSubview:self.labelNum];
        
        // 4、创建内容
        self.btnContent = [UUMessageContentButton buttonWithType:UIButtonTypeCustom];
        [self.btnContent setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.btnContent.titleLabel.font = ChatContentFont;
        self.btnContent.titleLabel.numberOfLines = 0;
        [self.btnContent addTarget:self action:@selector(btnContentClick)  forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnContent];
        
        // 5.创建line细线
        self.lineView = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.lineView.image = [UIImage imageNamed:@"chat_fiveChatLimit"];
        [self.contentView addSubview:self.lineView];
        
        fiveMessageRemind = [[UILabel alloc]init];
        fiveMessageRemind.textColor = [UIColor lightGrayColor];
        fiveMessageRemind.textAlignment = NSTextAlignmentCenter;
        fiveMessageRemind.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:fiveMessageRemind];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(UUAVAudioPlayerDidFinishPlay) name:@"VoicePlayHasInterrupt" object:nil];

    }
    return self;
}

//头像点击
- (void)btnHeadImageClick:(UIButton *)button{
    if (self.messageFrame.message.from == UUMessageFromOther) {
        [self.delegate headImageDidClick:self userId:self.messageFrame.message.strId];
    }
}


- (void)btnContentClick{
    //语音点击
    if (self.messageFrame.message.type == UUMessageTypeVoice) {
        
        audio = [UUAVAudioPlayer sharedInstance];
        audio.delegate = self;
        [audio playSong:voiceURL];
    }
    //图片点击
    else if (self.messageFrame.message.type == UUMessageTypePicture)
    {
        if (self.btnContent.backImageView) {
            [SJAvatarBrowser showImage:self.btnContent.backImageView];
        }
#warning 注意添加该功能时设置的代理要为Controller(一般都是Controller)，否则不要下面的功能
        [[(UIViewController *)self.delegate view] endEditing:YES];
    }
    //文字点击
    else if (self.messageFrame.message.type == UUMessageTypeText)
    {
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
    [self.btnContent didLoadVoice];
}
- (void)UUAVAudioPlayerDidFinishPlay
{
    [self.btnContent stopPlay];
    [[UUAVAudioPlayer sharedInstance]stopSound];
}


//内容及Frame设置
- (void)setMessageFrame:(UUMessageFrame *)messageFrame{

    _messageFrame = messageFrame;
    UUMessage *message = messageFrame.message;
    
    // 1、设置时间
    self.labelTime.text = message.strTime;
    self.labelTime.frame = messageFrame.timeF;
    
    // 2、设置头像
    headImageBackView.frame = messageFrame.iconF;
    self.btnHeadImage.frame = CGRectMake(2, 2, ChatIconWH-4, ChatIconWH-4);
    if (message.from == UUMessageFromMe) {
        
//        [self.btnHeadImage setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",RESOURCE_URL_HOST,[CommonMethods getDataFromUserDefaultsWithKey:KEY_HEAD_ICON]]] placeholderImage:[UIImage imageNamed:@"chatfrom_doctor_icon"]];
    }else{
        [self.btnHeadImage setBackgroundImage:[UIImage imageNamed:@"chatfrom_patinet_icon"] forState:UIControlStateNormal];
    }
    
    // 3、设置下标
    self.labelNum.text = message.strName;
    if (messageFrame.idF.origin.x > 160) {
        self.labelNum.frame = CGRectMake(messageFrame.idF.origin.x - 50, messageFrame.idF.origin.y + 3, 100, messageFrame.idF.size.height);
        self.labelNum.textAlignment = UITextAlignmentRight;
    }else{
        self.labelNum.frame = CGRectMake(messageFrame.idF.origin.x, messageFrame.idF.origin.y + 3, 80, messageFrame.idF.size.height);
        self.labelNum.textAlignment = UITextAlignmentLeft;
    }
    
    self.lineView.frame = messageFrame.lineF;
    

    // 4、设置内容
    
    //清除cell复用
    [self.btnContent setTitle:@"" forState:UIControlStateNormal];
    self.btnContent.voiceBackView.hidden = YES;
    self.btnContent.backImageView.hidden = YES;

    self.btnContent.frame = messageFrame.contentF;
    
    if (message.from == UUMessageFromMe) {
        self.btnContent.isMyMessage = YES;
        [self.btnContent setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.btnContent.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentRight, ChatContentBottom, ChatContentLeft);
    }else{
        self.btnContent.isMyMessage = NO;
        [self.btnContent setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.btnContent.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentLeft, ChatContentBottom, ChatContentRight);
    }

    switch (message.type) {
        case UUMessageTypeText:
            [self.btnContent setTitle:message.strContent forState:UIControlStateNormal];
            break;
        case UUMessageTypePicture:
        {
            self.btnContent.backImageView.hidden = NO;
//            [self.btnContent.backImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",RESOURCE_URL_HOST,message.strPicture]]];
        }
            break;
        case UUMessageTypeVoice:
        {
            self.btnContent.voiceBackView.hidden = NO;
            self.btnContent.second.text = [NSString stringWithFormat:@"%@'s语音",message.strVoiceTime];
//            voiceURL = [NSString stringWithFormat:@"%@%@",RESOURCE_URL_HOST,message.strVoice];
        }
            break;
            
        default:
            break;
    }
    
    //背景气泡图
    UIImage *normal;
    if (message.from == UUMessageFromMe) {
        normal = [UIImage imageNamed:@"chatto_bg_normal"];
        normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 10, 10, 22)];
    }
    else{
        normal = [UIImage imageNamed:@"chatfrom_bg_normal"];
        normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 22, 10, 10)];
    }
    
    [self.btnContent setBackgroundImage:normal forState:UIControlStateNormal];
    [self.btnContent setBackgroundImage:normal forState:UIControlStateHighlighted];
}

@end



