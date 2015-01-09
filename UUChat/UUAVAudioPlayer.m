//
//  UUAVAudioPlayer.m
//  BloodSugarForDoc
//
//  Created by shake on 14-9-1.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import "UUAVAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>


@interface UUAVAudioPlayer ()<AVAudioPlayerDelegate>
{
    AVAudioPlayer *player;
}
@end

@implementation UUAVAudioPlayer

+ (UUAVAudioPlayer *)sharedInstance
{
    static UUAVAudioPlayer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });    
    return sharedInstance;
}

-(void)playSongWithUrl:(NSString *)songUrl
{
    dispatch_async(dispatch_queue_create("dfsfe", NULL), ^{
        
        [self.delegate UUAVAudioPlayerBeiginLoadVoice];
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:songUrl]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (player) {
                [self.delegate UUAVAudioPlayerDidFinishPlay];
                [player stop];
                player.delegate = nil;
                player = nil;
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:@"VoicePlayHasInterrupt" object:nil];
            NSError *playerError;
            player = [[AVAudioPlayer alloc]initWithData:data error:&playerError];
            player.volume = 1.0f;
            if (player == nil){
                NSLog(@"ERror creating player: %@", [playerError description]);
            }
            [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategorySoloAmbient error: nil];
            player.delegate = self;
            [player play];
            [self.delegate UUAVAudioPlayerBeiginPlay];
        });
    });
}

-(void)playSongWithData:(NSData *)songData
{
    [self.delegate UUAVAudioPlayerDidFinishPlay];

    if (player) {
        [player stop];
        player.delegate = nil;
        player = nil;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"VoicePlayHasInterrupt" object:nil];
    NSError *playerError;
    player = [[AVAudioPlayer alloc]initWithData:songData error:&playerError];
    player.volume = 1.0f;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategorySoloAmbient error: nil];
    player.delegate = self;
    [player play];
    [self.delegate UUAVAudioPlayerBeiginPlay];

}



- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.delegate UUAVAudioPlayerDidFinishPlay];
}

- (void)stopSound
{
    if (player && player.isPlaying) {
        [player stop];
    }
}

@end