#import "UUAVAudioPlayer.h"

@interface UUAVAudioPlayer () <AVAudioPlayerDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *currentTask;

@end

@implementation UUAVAudioPlayer

+ (instancetype)sharedInstance
{
    static UUAVAudioPlayer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)playAudioFromURLString:(NSString *)URLString
{
    NSURL *url = [NSURL URLWithString:URLString];
    if (!url) {
        return;
    }

    [self.currentTask cancel];
    self.currentTask = nil;
    [self notifyDelegateDidBeginLoading];

    __weak typeof(self) weakSelf = self;
    self.currentTask = [[NSURLSession sharedSession] dataTaskWithURL:url
                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || data.length == 0) {
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf playSoundWithData:data];
        });
    }];
    [self.currentTask resume];
}

- (void)playSongWithUrl:(NSString *)songUrl
{
    [self playAudioFromURLString:songUrl];
}

- (void)playAudioData:(NSData *)audioData
{
    [self.currentTask cancel];
    self.currentTask = nil;
    [self setupPlaySound];
    [self playSoundWithData:audioData];
}

- (void)playSongWithData:(NSData *)songData
{
    [self playAudioData:songData];
}

- (void)playSoundWithData:(NSData *)soundData
{
    if (soundData.length == 0) {
        return;
    }

    if (self.player) {
        [self.player stop];
        self.player.delegate = nil;
        self.player = nil;
    }

    NSError *playerError = nil;
    self.player = [[AVAudioPlayer alloc] initWithData:soundData error:&playerError];
    if (!self.player || playerError) {
        NSLog(@"Error creating player: %@", playerError.localizedDescription);
        return;
    }

    self.player.volume = 1.0f;
    self.player.delegate = self;
    [self.player prepareToPlay];
    [self.player play];
    [self notifyDelegateDidBeginPlayback];
}

- (void)setupPlaySound
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIApplication *application = UIApplication.sharedApplication;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:application];
    });

    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
}

- (void)stopPlayback
{
    [self.currentTask cancel];
    self.currentTask = nil;
    if (self.player.isPlaying) {
        [self.player stop];
    }
}

- (void)stopSound
{
    [self stopPlayback];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    (void)application;
    [self notifyDelegateDidFinishPlaybackSuccessfully:NO];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    (void)player;
    [self notifyDelegateDidFinishPlaybackSuccessfully:flag];
}

- (void)notifyDelegateDidBeginLoading
{
    if ([self.delegate respondsToSelector:@selector(audioPlayerDidBeginLoadingVoice:)]) {
        [self.delegate audioPlayerDidBeginLoadingVoice:self];
        return;
    }

    if ([self.delegate respondsToSelector:@selector(UUAVAudioPlayerBeiginLoadVoice)]) {
        [self.delegate UUAVAudioPlayerBeiginLoadVoice];
    }
}

- (void)notifyDelegateDidBeginPlayback
{
    if ([self.delegate respondsToSelector:@selector(audioPlayerDidBeginPlayback:)]) {
        [self.delegate audioPlayerDidBeginPlayback:self];
        return;
    }

    if ([self.delegate respondsToSelector:@selector(UUAVAudioPlayerBeiginPlay)]) {
        [self.delegate UUAVAudioPlayerBeiginPlay];
    }
}

- (void)notifyDelegateDidFinishPlaybackSuccessfully:(BOOL)success
{
    if ([self.delegate respondsToSelector:@selector(audioPlayerDidFinishPlayback:successfully:)]) {
        [self.delegate audioPlayerDidFinishPlayback:self successfully:success];
        return;
    }

    if ([self.delegate respondsToSelector:@selector(UUAVAudioPlayerDidFinishPlay)]) {
        [self.delegate UUAVAudioPlayerDidFinishPlay];
    }
}

@end
