//
//  UUAVAudioPlayer.m
//  BloodSugarForDoc
//
//  Created by shake on 14-9-1.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import "UUImageAvatarBrowser.h"

static UIImageView *_uuOrginImageView;

@implementation UUImageAvatarBrowser

+ (void)showImage:(UIImageView *)avatarImageView {
	
    UIImage *image = avatarImageView.image;
	if (!image) { return; }
	
    _uuOrginImageView = avatarImageView;
    _uuOrginImageView.alpha = 0;
	
	CGFloat const screenWidth = [UIScreen mainScreen].bounds.size.width;
	CGFloat const screenHeight = [UIScreen mainScreen].bounds.size.height;
	
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
	backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:[avatarImageView convertRect:avatarImageView.bounds toView:window]];
    imageView.image = image;
    imageView.tag = 1;
    imageView.contentMode = avatarImageView.contentMode;
    imageView.clipsToBounds = YES;
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer:tap];
    
    [UIView animateWithDuration:0.3 animations:^{
		CGFloat rate = screenWidth / image.size.width;
        imageView.frame = CGRectMake(0, (screenHeight - image.size.height * rate)/2, screenWidth, image.size.height * rate);
		backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    }];
}

+ (void)hideImage:(UITapGestureRecognizer *)tap {
	
    UIView *backgroundView = tap.view;
    UIImageView *imageView = [tap.view viewWithTag:1];
	
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = [_uuOrginImageView convertRect:_uuOrginImageView.bounds
												  toView:[UIApplication sharedApplication].keyWindow];
		backgroundView.backgroundColor = [UIColor clearColor];
		
	} completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
        _uuOrginImageView.alpha = 1;
    }];
}
@end
