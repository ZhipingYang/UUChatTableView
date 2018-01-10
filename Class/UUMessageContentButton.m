//
//  UUMessageContentButton.m
//  BloodSugarForDoc
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import "UUMessageContentButton.h"
#import "UUChatCategory.h"
#import "UUMessageFrame.h"

@implementation UUMessageContentButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //图片
        self.backImageView = [[UIImageView alloc]init];
        self.backImageView.userInteractionEnabled = YES;
        self.backImageView.layer.cornerRadius = 5;
        self.backImageView.layer.masksToBounds  = YES;
        self.backImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.backImageView.backgroundColor = [UIColor yellowColor];
        [self addSubview:self.backImageView];
        
        //语音
        self.voiceBackView = [[UIView alloc]init];
        [self addSubview:self.voiceBackView];
        self.second = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, 30)];
        self.second.textAlignment = NSTextAlignmentCenter;
        self.second.font = [UIFont systemFontOfSize:14];
        self.voice = [[UIImageView alloc]initWithFrame:CGRectMake(80, 5, 20, 20)];
        self.voice.image = [UIImage uu_imageWithName:@"chat_animation_white3"];
        self.voice.animationImages = [NSArray arrayWithObjects:
                                      [UIImage uu_imageWithName:@"chat_animation_white1"],
                                      [UIImage uu_imageWithName:@"chat_animation_white2"],
                                      [UIImage uu_imageWithName:@"chat_animation_white3"],nil];
        self.voice.animationDuration = 1;
        self.voice.animationRepeatCount = 0;
        self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.indicator.center=CGPointMake(80, 15);
        [self.voiceBackView addSubview:self.indicator];
        [self.voiceBackView addSubview:self.voice];
        [self.voiceBackView addSubview:self.second];
        
        self.backImageView.userInteractionEnabled = NO;
        self.voiceBackView.userInteractionEnabled = NO;
        self.second.userInteractionEnabled = NO;
        self.voice.userInteractionEnabled = NO;
        
        self.second.backgroundColor = [UIColor clearColor];
        self.voice.backgroundColor = [UIColor clearColor];
        self.voiceBackView.backgroundColor = [UIColor clearColor];
        
    }
    return self;
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
    [self.voice startAnimating];
}
-(void)stopPlay
{
//    if(self.voice.isAnimating){
        [self.voice stopAnimating];
//    }
}

- (void)setMessageFrame:(UUMessageFrame *)messageFrame
{
	_messageFrame = messageFrame;
	
	self.frame = messageFrame.contentFrame;
	BOOL isMyMessage = messageFrame.message.from == UUMessageFromMe;
	
	self.second.textColor = isMyMessage ? [UIColor whiteColor] : [UIColor grayColor];
	self.voiceBackView.frame = CGRectMake(isMyMessage ? 15:25, 10, 130, 35);
	[self setTitleColor:isMyMessage ? [UIColor whiteColor]:[UIColor grayColor] forState:UIControlStateNormal];
	
	//背景气泡图
	UIImage *backImage = [UIImage uu_imageWithName:isMyMessage ? @"chatto_bg_normal" : @"chatfrom_bg_normal"];
	if (isMyMessage) {
		self.titleEdgeInsets = UIEdgeInsetsMake(ChatContentTopBottom, ChatContentSmaller, ChatContentTopBottom, ChatContentBiger);
		backImage = [backImage resizableImageWithCapInsets:UIEdgeInsetsMake(35, 10, 10, 22)];
	} else {
		self.titleEdgeInsets = UIEdgeInsetsMake(ChatContentTopBottom, ChatContentBiger, ChatContentTopBottom, ChatContentSmaller);
		backImage = [backImage resizableImageWithCapInsets:UIEdgeInsetsMake(35, 22, 10, 10)];
	}
	[self setBackgroundImage:backImage forState:UIControlStateNormal];
	[self setBackgroundImage:backImage forState:UIControlStateHighlighted];

	
	switch (messageFrame.message.type) {
		case UUMessageTypeText:
			[self setTitle:messageFrame.message.text forState:UIControlStateNormal];
			break;
		case UUMessageTypePicture:
		{
			self.backImageView.hidden = NO;
			self.backImageView.image = messageFrame.message.image;
			self.backImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
			[self makeMaskView:self.backImageView withImage:backImage];
		}
			break;
		case UUMessageTypeVoice:
		{
			self.voiceBackView.hidden = NO;
			self.second.text = messageFrame.message.voiceText;
//			_songData = messageFrame.message.voiceData;
//			_voiceURL = [NSString stringWithFormat:@"%@%@",RESOURCE_URL_HOST,message.strVoice];
		}
			break;
			
		default:
			break;
	}

}

- (void)makeMaskView:(UIView *)view withImage:(UIImage *)image
{
	UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:image];
	imageViewMask.frame = CGRectInset(view.frame, 0.0f, 0.0f);
	view.layer.mask = imageViewMask.layer;
}

//添加
- (BOOL)canBecomeFirstResponder
{
    return YES;
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return (action == @selector(copy:));
}

-(void)copy:(id)sender{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.titleLabel.text;
}


@end
