//
//  UUMessageContentButton.h
//  BloodSugarForDoc
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UUMessageFrame.h"

@interface UUMessageContentButton : UIButton

//bubble imgae
@property (nonatomic, strong) UIImageView *backImageView;

//audio
@property (nonatomic, strong) UIView *voiceBackView;
@property (nonatomic, strong) UILabel *second;
@property (nonatomic, strong) UIImageView *voice;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@property (nonatomic, strong) UUMessageFrame *messageFrame;


- (void)benginLoadVoice;

- (void)didLoadVoice;

-(void)stopPlay;

@end
