//
//  UUProgressHUD.m
//  1111
//
//  Created by shake on 14-8-6.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUProgressHUD.h"

@interface UUProgressHUD ()
{
    NSTimer *myTimer;
    int angle;
}

@property (nonatomic, strong) UIImageView *edgeImageView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *centerLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic, strong, readonly) UIWindow *overlayWindow;

@end

@implementation UUProgressHUD

@synthesize overlayWindow;

+ (instancetype)sharedView {
    static dispatch_once_t once;
    static UUProgressHUD *sharedView;
    dispatch_once(&once, ^ {
        sharedView = [[UUProgressHUD alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        sharedView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    });
    return sharedView;
}

+ (void)show {
    [[UUProgressHUD sharedView] show];
}

- (void)show {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!self.superview)
            [self.overlayWindow addSubview:self];
        
        if (!_centerLabel){
            _centerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 40)];
            _centerLabel.backgroundColor = [UIColor clearColor];
        }
        
        if (!self.subTitleLabel){
            self.subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 20)];
            self.subTitleLabel.backgroundColor = [UIColor clearColor];
        }
        if (!self.titleLabel){
            self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 20)];
            self.titleLabel.backgroundColor = [UIColor clearColor];
        }
        if (!_edgeImageView)
            _edgeImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"UUChatTableView.bundle/image/Chat_record_circle"]];
        
        self.subTitleLabel.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2,[[UIScreen mainScreen] bounds].size.height/2 + 30);
        self.subTitleLabel.text = @"Slide up to cancel";
        self.subTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.subTitleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.subTitleLabel.textColor = [UIColor whiteColor];
        
        self.titleLabel.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2,[[UIScreen mainScreen] bounds].size.height/2 - 30);
        self.titleLabel.text = @"Time Limit";
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        self.titleLabel.textColor = [UIColor whiteColor];
        
        _centerLabel.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2,[[UIScreen mainScreen] bounds].size.height/2);
        _centerLabel.text = @"60";
        _centerLabel.textAlignment = NSTextAlignmentCenter;
        _centerLabel.font = [UIFont systemFontOfSize:30];
        _centerLabel.textColor = [UIColor yellowColor];

        
        _edgeImageView.frame = CGRectMake(0, 0, 154, 154);
        _edgeImageView.center = _centerLabel.center;
        [self addSubview:_edgeImageView];
        [self addSubview:_centerLabel];
        [self addSubview:self.subTitleLabel];
        [self addSubview:self.titleLabel];

        if (myTimer)
            [myTimer invalidate];
        myTimer = nil;
        myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                   target:self
                                                 selector:@selector(startAnimation)
                                                 userInfo:nil
                                                  repeats:YES];
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.alpha = 1;
                         }
                         completion:^(BOOL finished){
                         }];
        [self setNeedsDisplay];
    });
}
-(void)startAnimation
{
    angle -= 3;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.09];
    UIView.AnimationRepeatAutoreverses = YES;
    _edgeImageView.transform = CGAffineTransformMakeRotation(angle * (M_PI / 180.0f));
    float second = [_centerLabel.text floatValue];
    if (second <= 10.0f) {
        _centerLabel.textColor = [UIColor redColor];
    }else{
        _centerLabel.textColor = [UIColor yellowColor];
    }
    _centerLabel.text = [NSString stringWithFormat:@"%.1f",second-0.1];
    [UIView commitAnimations];
}

+ (void)changeSubTitle:(NSString *)str
{
    [[UUProgressHUD sharedView] setState:str];
}

- (void)setState:(NSString *)str
{
    self.subTitleLabel.text = str;
}

+ (void)dismissWithSuccess:(NSString *)str {
	[[UUProgressHUD sharedView] dismiss:str];
}

+ (void)dismissWithError:(NSString *)str {
	[[UUProgressHUD sharedView] dismiss:str];
}

- (void)dismiss:(NSString *)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [myTimer invalidate];
        myTimer = nil;
        self.subTitleLabel.text = nil;
        self.titleLabel.text = nil;
        _centerLabel.text = state;
        _centerLabel.textColor = [UIColor whiteColor];
        
        CGFloat timeLonger;
        if ([state isEqualToString:@"TooShort"]) {
            timeLonger = 1;
        }else{
            timeLonger = 0.6;
        }
        [UIView animateWithDuration:timeLonger
                              delay:0
                            options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             if(self.alpha == 0) {
                                 [_centerLabel removeFromSuperview];
                                 _centerLabel = nil;
                                 [_edgeImageView removeFromSuperview];
                                 _edgeImageView = nil;
                                 [self.subTitleLabel removeFromSuperview];
                                 self.subTitleLabel = nil;

                                 NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:[UIApplication sharedApplication].windows];
                                 [windows removeObject:overlayWindow];
                                 overlayWindow = nil;
                                 
                                 [windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *window, NSUInteger idx, BOOL *stop) {
                                     if([window isKindOfClass:[UIWindow class]] && window.windowLevel == UIWindowLevelNormal) {
                                         [window makeKeyWindow];
                                         *stop = YES;
                                     }
                                 }];
                             }
                         }];
    });
}

- (UIWindow *)overlayWindow {
    return [UIApplication sharedApplication].delegate.window;
}


@end
