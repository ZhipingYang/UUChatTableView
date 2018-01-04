//
//  UUAVAudioPlayer.h
//  BloodSugarForDoc
//
//  Created by shake on 14-9-1.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@protocol UUAVAudioPlayerDelegate <NSObject>

- (void)UUAVAudioPlayerBeiginLoadVoice;

- (void)UUAVAudioPlayerBeiginPlay;

- (void)UUAVAudioPlayerDidFinishPlay;

@end

@interface UUAVAudioPlayer : NSObject

@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, weak) id<UUAVAudioPlayerDelegate> delegate;

+ (instancetype)sharedInstance;

-(void)playSongWithUrl:(NSString *)songUrl;

-(void)playSongWithData:(NSData *)songData;

- (void)stopSound;

@end
