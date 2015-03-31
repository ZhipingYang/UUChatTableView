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
            if (_player) {
                [self.delegate UUAVAudioPlayerDidFinishPlay];
                [_player stop];
                _player.delegate = nil;
                _player = nil;
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:@"VoicePlayHasInterrupt" object:nil];
            NSError *playerError;
            _player = [[AVAudioPlayer alloc]initWithData:data error:&playerError];
            _player.volume = 1.0f;
            if (_player == nil){
                NSLog(@"ERror creating player: %@", [playerError description]);
            }
            [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategorySoloAmbient error: nil];
            _player.delegate = self;
            [_player play];
            [self.delegate UUAVAudioPlayerBeiginPlay];
        });
    });
}

-(void)playSongWithData:(NSData *)songData
{
    [self.delegate UUAVAudioPlayerDidFinishPlay];

    if (_player) {
        [_player stop];
        _player.delegate = nil;
        _player = nil;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"VoicePlayHasInterrupt" object:nil];
    NSError *playerError;
    _player = [[AVAudioPlayer alloc]initWithData:songData error:&playerError];
    _player.volume = 1.0f;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategorySoloAmbient error: nil];
    _player.delegate = self;
    [_player play];
    [self.delegate UUAVAudioPlayerBeiginPlay];

}



- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.delegate UUAVAudioPlayerDidFinishPlay];
}

- (void)stopSound
{
    if (_player && _player.isPlaying) {
        [_player stop];
    }
}

@end