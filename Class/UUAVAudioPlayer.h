#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class UUAVAudioPlayer;

@protocol UUAVAudioPlayerDelegate <NSObject>
@optional

- (void)audioPlayerDidBeginLoadingVoice:(UUAVAudioPlayer *)audioPlayer;
- (void)audioPlayerDidBeginPlayback:(UUAVAudioPlayer *)audioPlayer;
- (void)audioPlayerDidFinishPlayback:(UUAVAudioPlayer *)audioPlayer successfully:(BOOL)success;

- (void)UUAVAudioPlayerBeiginLoadVoice;
- (void)UUAVAudioPlayerBeiginPlay;
- (void)UUAVAudioPlayerDidFinishPlay;

@end

@interface UUAVAudioPlayer : NSObject

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, weak) id<UUAVAudioPlayerDelegate> delegate;

+ (instancetype)sharedInstance;
- (void)playAudioFromURLString:(NSString *)URLString;
- (void)playAudioData:(NSData *)audioData;
- (void)stopPlayback;
- (void)playSongWithUrl:(NSString *)songUrl;
- (void)playSongWithData:(NSData *)songData;
- (void)stopSound;

@end
