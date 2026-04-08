#import "UUDemoChatDataSource.h"
#import <math.h>
#import <string.h>
#import <UUChatTableView/UUMessage.h>
#import <UUChatTableView/UUMessageFrame.h>

@interface UUDemoParticipant : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, assign) NSInteger avatarSeed;

+ (instancetype)participantWithIdentifier:(NSString *)identifier
                              displayName:(NSString *)displayName
                               avatarSeed:(NSInteger)avatarSeed;

@end

@implementation UUDemoParticipant

+ (instancetype)participantWithIdentifier:(NSString *)identifier
                              displayName:(NSString *)displayName
                               avatarSeed:(NSInteger)avatarSeed
{
    UUDemoParticipant *participant = [[self alloc] init];
    participant.identifier = identifier;
    participant.displayName = displayName;
    participant.avatarSeed = avatarSeed;
    return participant;
}

@end

@interface UUDemoChatDataSource ()

@property (nonatomic, strong) NSMutableArray<UUMessage *> *messages;
@property (nonatomic, copy) NSArray<UUMessageFrame *> *dataSource;
@property (nonatomic, assign, getter=isGroupConversation) BOOL groupConversation;
@property (nonatomic, copy) NSArray<UUDemoParticipant *> *participants;
@property (nonatomic, copy) NSArray<NSString *> *sampleTexts;
@property (nonatomic, strong) NSMutableDictionary<NSString *, UIImage *> *avatarCache;

@end

@implementation UUDemoChatDataSource

- (instancetype)initWithLayoutWidth:(CGFloat)layoutWidth
{
    self = [super init];
    if (self) {
        _layoutWidth = layoutWidth;
        _messages = [NSMutableArray array];
        _avatarCache = [NSMutableDictionary dictionary];
        _participants = @[
            [UUDemoParticipant participantWithIdentifier:@"mia" displayName:@"Mia" avatarSeed:0],
            [UUDemoParticipant participantWithIdentifier:@"leo" displayName:@"Leo" avatarSeed:1],
            [UUDemoParticipant participantWithIdentifier:@"iris" displayName:@"Iris" avatarSeed:2],
            [UUDemoParticipant participantWithIdentifier:@"noa" displayName:@"Noa" avatarSeed:3]
        ];
        _sampleTexts = @[
            @"The clean path ships faster than the clever path. 🚀",
            @"One repo, one demo, one validation loop. 🧩",
            @"Text, photo, and voice are enough to prove the chat core. 🎯",
            @"Pull to load more history and check the spacing rhythm. ⏳",
            @"The podspec and demo still share the same release path. 📦",
            @"Once the foundation feels calm, polishing gets fun again. ✨"
        ];
        [self reloadConversationWithGroupMode:NO];
    }
    return self;
}

- (void)setLayoutWidth:(CGFloat)layoutWidth
{
    if (fabs(_layoutWidth - layoutWidth) < 0.5) {
        return;
    }

    _layoutWidth = layoutWidth;
    [self rebuildFrames];
}

- (void)reloadConversationWithGroupMode:(BOOL)isGroupMode
{
    self.groupConversation = isGroupMode;
    [self.messages removeAllObjects];

    NSDate *cursor = [NSDate dateWithTimeIntervalSinceNow:-70 * 60];
    for (NSInteger index = 0; index < 14; index++) {
        [self.messages addObject:[self timelineMessageForIndex:index timestamp:cursor]];
        cursor = [cursor dateByAddingTimeInterval:90 + (index % 4) * 120];
    }

    [self rebuildFrames];
}

- (void)prependHistoryMessages:(NSInteger)count
{
    if (count <= 0) {
        return;
    }

    NSDate *anchorDate = self.messages.firstObject.timestamp ?: [NSDate dateWithTimeIntervalSinceNow:-2 * 60 * 60];
    NSMutableArray<UUMessage *> *historyMessages = [NSMutableArray arrayWithCapacity:(NSUInteger)count];

    for (NSInteger index = count - 1; index >= 0; index--) {
        NSDate *timestamp = [anchorDate dateByAddingTimeInterval:-((index + 1) * 180 + (index % 3) * 60)];
        [historyMessages addObject:[self historyMessageForIndex:index timestamp:timestamp]];
    }

    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, historyMessages.count)];
    [self.messages insertObjects:historyMessages atIndexes:indexes];
    [self rebuildFrames];
}

- (void)appendTextMessage:(NSString *)text
{
    [self.messages addObject:[self messageWithType:UUMessageTypeText
                                              text:text
                                             image:nil
                                             voice:nil
                                          duration:nil
                                            fromMe:YES
                                       participant:nil
                                         timestamp:[self nextOutgoingTimestamp]]];
    [self rebuildFrames];
}

- (void)appendPictureMessage:(UIImage *)image
{
    [self.messages addObject:[self messageWithType:UUMessageTypePicture
                                              text:nil
                                             image:image
                                             voice:nil
                                          duration:nil
                                            fromMe:YES
                                       participant:nil
                                         timestamp:[self nextOutgoingTimestamp]]];
    [self rebuildFrames];
}

- (void)appendVoiceMessage:(NSData *)voice duration:(NSInteger)duration
{
    [self.messages addObject:[self messageWithType:UUMessageTypeVoice
                                              text:nil
                                             image:nil
                                             voice:voice
                                          duration:@(MAX(duration, 1))
                                            fromMe:YES
                                       participant:nil
                                         timestamp:[self nextOutgoingTimestamp]]];
    [self rebuildFrames];
}

- (UUMessage *)timelineMessageForIndex:(NSInteger)index timestamp:(NSDate *)timestamp
{
    BOOL isFromMe = index % 4 == 3;
    UUDemoParticipant *participant = [self participantForIndex:index fromMe:isFromMe];

    switch (index % 5) {
        case 2:
            return [self messageWithType:UUMessageTypePicture
                                    text:nil
                                   image:[self demoPictureWithSeed:index]
                                   voice:nil
                                duration:nil
                                  fromMe:isFromMe
                             participant:participant
                               timestamp:timestamp];
        case 4:
            return [self messageWithType:UUMessageTypeVoice
                                    text:nil
                                   image:nil
                                   voice:[self demoVoiceDataForDuration:2 + (index % 4)]
                                duration:@(2 + (index % 4))
                                  fromMe:isFromMe
                             participant:participant
                               timestamp:timestamp];
        default:
            return [self messageWithType:UUMessageTypeText
                                    text:self.sampleTexts[index % self.sampleTexts.count]
                                   image:nil
                                   voice:nil
                                duration:nil
                                  fromMe:isFromMe
                             participant:participant
                               timestamp:timestamp];
    }
}

- (UUMessage *)historyMessageForIndex:(NSInteger)index timestamp:(NSDate *)timestamp
{
    BOOL fromMe = index % 5 == 0;
    UUDemoParticipant *participant = [self participantForIndex:index fromMe:fromMe];
    NSString *text = self.sampleTexts[(index + 2) % self.sampleTexts.count];
    return [self messageWithType:UUMessageTypeText
                            text:text
                           image:nil
                           voice:nil
                        duration:nil
                          fromMe:fromMe
                     participant:participant
                       timestamp:timestamp];
}

- (nullable UUDemoParticipant *)participantForIndex:(NSInteger)index fromMe:(BOOL)fromMe
{
    if (fromMe) {
        return nil;
    }

    NSInteger participantIndex = self.isGroupConversation ? index % self.participants.count : 0;
    return self.participants[participantIndex];
}

- (UUMessage *)messageWithType:(MessageType)type
                          text:(nullable NSString *)text
                         image:(nullable UIImage *)image
                         voice:(nullable NSData *)voice
                      duration:(nullable NSNumber *)duration
                        fromMe:(BOOL)fromMe
                   participant:(nullable UUDemoParticipant *)participant
                     timestamp:(NSDate *)timestamp
{
    NSString *displayName = fromMe ? @"You" : participant.displayName;
    NSInteger avatarSeed = fromMe ? 99 : participant.avatarSeed;
    NSMutableDictionary<NSString *, id> *dictionary = [NSMutableDictionary dictionary];
    dictionary[@"timestamp"] = timestamp;
    dictionary[@"sender"] = @(fromMe ? UUMessageFromMe : UUMessageFromOther);
    dictionary[@"displayName"] = fromMe ? @"" : (self.isGroupConversation ? displayName : @"");
    dictionary[@"senderIdentifier"] = fromMe ? @"me" : participant.identifier;
    dictionary[@"avatarImage"] = [self avatarImageForName:displayName seed:avatarSeed fromMe:fromMe];
    dictionary[@"contentType"] = @(type);

    switch (type) {
        case UUMessageTypePicture:
            dictionary[@"image"] = image ?: [self demoPictureWithSeed:avatarSeed];
            break;
        case UUMessageTypeVoice:
            dictionary[@"voiceData"] = voice ?: [self demoVoiceDataForDuration:duration.integerValue];
            dictionary[@"voiceDurationText"] = duration.stringValue ?: @"1";
            break;
        case UUMessageTypeText:
        default:
            dictionary[@"text"] = text ?: @"";
            break;
    }

    UUMessage *message = [[UUMessage alloc] init];
    [message configureWithDictionary:dictionary];
    return message;
}

- (NSDate *)nextOutgoingTimestamp
{
    NSDate *lastDate = self.messages.lastObject.timestamp ?: NSDate.date;
    NSDate *now = NSDate.date;
    if ([lastDate compare:now] == NSOrderedDescending) {
        return [lastDate dateByAddingTimeInterval:90];
    }

    return now;
}

- (void)rebuildFrames
{
    NSMutableArray<UUMessageFrame *> *frames = [NSMutableArray arrayWithCapacity:self.messages.count];
    NSDate *lastVisibleDate = nil;

    for (UUMessage *message in self.messages) {
        [message updateShowsDateLabelComparedToDate:lastVisibleDate];

        UUMessageFrame *frame = [[UUMessageFrame alloc] init];
        frame.layoutWidth = self.layoutWidth;
        frame.showTime = message.showsDateLabel;
        frame.message = message;
        [frames addObject:frame];

        if (message.showsDateLabel) {
            lastVisibleDate = message.timestamp;
        }
    }

    self.dataSource = frames.copy;
}

- (UIImage *)demoPictureWithSeed:(NSInteger)seed
{
    CGSize canvasSize = CGSizeMake(240, 160);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:canvasSize];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGContextRef context = rendererContext.CGContext;
        UIColor *startColor = [self gradientStartColorForSeed:seed];
        UIColor *endColor = [self gradientEndColorForSeed:seed];
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        NSArray *colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, NULL);
        CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(canvasSize.width, canvasSize.height), 0);
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);

        CGRect cardRect = CGRectInset((CGRect){ CGPointZero, canvasSize }, 16.0, 16.0);
        [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.18] setFill];
        [[UIBezierPath bezierPathWithRoundedRect:cardRect cornerRadius:28.0] fill];

        [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.28] setFill];
        [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(CGRectGetMinX(cardRect) + 18.0, CGRectGetMinY(cardRect) + 18.0, 46.0, 46.0)] fill];

        [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.26] setFill];
        [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(CGRectGetMinX(cardRect) + 18.0,
                                                            CGRectGetMaxY(cardRect) - 40.0,
                                                            CGRectGetWidth(cardRect) - 36.0,
                                                            10.0)
                                    cornerRadius:5.0] fill];

        NSString *caption = @[@"Pure Code", @"Voice State", @"Podspec", @"Timeline"][seed % 4];
        NSDictionary *attributes = @{
            NSFontAttributeName : [UIFont systemFontOfSize:24 weight:UIFontWeightHeavy],
            NSForegroundColorAttributeName : UIColor.whiteColor
        };
        CGSize textSize = [caption sizeWithAttributes:attributes];
        CGRect textRect = CGRectMake(CGRectGetMinX(cardRect) + 18.0,
                                     CGRectGetMidY(cardRect) - textSize.height / 2.0 + 6.0,
                                     textSize.width,
                                     textSize.height);
        [caption drawInRect:textRect withAttributes:attributes];

        NSString *eyebrow = @"DEMO SNAPSHOT";
        NSDictionary *eyebrowAttributes = @{
            NSFontAttributeName : [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightSemibold],
            NSForegroundColorAttributeName : [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.76]
        };
        [eyebrow drawAtPoint:CGPointMake(CGRectGetMinX(cardRect) + 18.0, CGRectGetMinY(cardRect) + 78.0) withAttributes:eyebrowAttributes];
    }];
}

- (UIColor *)gradientStartColorForSeed:(NSInteger)seed
{
    NSArray<UIColor *> *colors = @[
        [UIColor colorWithRed:0.93 green:0.60 blue:0.39 alpha:1.0],
        [UIColor colorWithRed:0.24 green:0.53 blue:0.79 alpha:1.0],
        [UIColor colorWithRed:0.34 green:0.67 blue:0.56 alpha:1.0],
        [UIColor colorWithRed:0.67 green:0.47 blue:0.39 alpha:1.0]
    ];
    return colors[seed % colors.count];
}

- (UIColor *)gradientEndColorForSeed:(NSInteger)seed
{
    NSArray<UIColor *> *colors = @[
        [UIColor colorWithRed:0.98 green:0.83 blue:0.59 alpha:1.0],
        [UIColor colorWithRed:0.56 green:0.81 blue:0.93 alpha:1.0],
        [UIColor colorWithRed:0.72 green:0.85 blue:0.61 alpha:1.0],
        [UIColor colorWithRed:0.88 green:0.70 blue:0.62 alpha:1.0]
    ];
    return colors[(seed + 1) % colors.count];
}

- (UIImage *)avatarImageForName:(NSString *)name seed:(NSInteger)seed fromMe:(BOOL)fromMe
{
    NSString *cacheKey = [NSString stringWithFormat:@"%@-%ld-%d", name ?: @"user", (long)seed, fromMe];
    UIImage *cachedImage = self.avatarCache[cacheKey];
    if (cachedImage) {
        return cachedImage;
    }

    CGSize canvasSize = CGSizeMake(84.0, 84.0);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:canvasSize];
    UIImage *avatar = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGRect bounds = (CGRect){ CGPointZero, canvasSize };
        [[UIBezierPath bezierPathWithOvalInRect:bounds] addClip];

        UIColor *startColor = fromMe ? [UIColor colorWithRed:0.19 green:0.36 blue:0.70 alpha:1.0] : [self gradientStartColorForSeed:seed];
        UIColor *endColor = fromMe ? [UIColor colorWithRed:0.34 green:0.61 blue:0.86 alpha:1.0] : [self gradientEndColorForSeed:seed];
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        NSArray *colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, NULL);
        CGContextDrawLinearGradient(rendererContext.CGContext,
                                    gradient,
                                    CGPointMake(0, 0),
                                    CGPointMake(canvasSize.width, canvasSize.height),
                                    0);
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);

        [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.16] setFill];
        [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(10.0, 10.0, 30.0, 30.0)] fill];

        NSString *initial = name.length > 0 ? [[name substringToIndex:1] uppercaseString] : @"U";
        NSDictionary *attributes = @{
            NSFontAttributeName : [UIFont systemFontOfSize:30 weight:UIFontWeightHeavy],
            NSForegroundColorAttributeName : UIColor.whiteColor
        };
        CGSize textSize = [initial sizeWithAttributes:attributes];
        CGRect textRect = CGRectMake((canvasSize.width - textSize.width) / 2.0,
                                     (canvasSize.height - textSize.height) / 2.0 + 1.0,
                                     textSize.width,
                                     textSize.height);
        [initial drawInRect:textRect withAttributes:attributes];
    }];

    self.avatarCache[cacheKey] = avatar;
    return avatar;
}

- (NSData *)demoVoiceDataForDuration:(NSInteger)duration
{
    const int sampleRate = 16000;
    NSUInteger sampleCount = (NSUInteger)(sampleRate * duration);
    NSMutableData *pcmData = [NSMutableData dataWithCapacity:sampleCount * sizeof(int16_t)];

    for (NSUInteger index = 0; index < sampleCount; index++) {
        double wave = sin(2.0 * M_PI * 440.0 * (double)index / (double)sampleRate);
        int16_t sample = (int16_t)(wave * 4000);
        [pcmData appendBytes:&sample length:sizeof(sample)];
    }

    NSMutableData *waveData = [NSMutableData data];
    [self appendCString:"RIFF" toData:waveData];
    uint32_t riffChunkSize = (uint32_t)(36 + pcmData.length);
    [waveData appendBytes:&riffChunkSize length:sizeof(riffChunkSize)];
    [self appendCString:"WAVE" toData:waveData];
    [self appendCString:"fmt " toData:waveData];

    uint32_t formatChunkSize = 16;
    uint16_t audioFormat = 1;
    uint16_t channelCount = 1;
    uint32_t bytesPerSecond = sampleRate * channelCount * sizeof(int16_t);
    uint16_t bytesPerFrame = channelCount * sizeof(int16_t);
    uint16_t bitsPerSample = 16;
    [waveData appendBytes:&formatChunkSize length:sizeof(formatChunkSize)];
    [waveData appendBytes:&audioFormat length:sizeof(audioFormat)];
    [waveData appendBytes:&channelCount length:sizeof(channelCount)];
    [waveData appendBytes:&sampleRate length:sizeof(sampleRate)];
    [waveData appendBytes:&bytesPerSecond length:sizeof(bytesPerSecond)];
    [waveData appendBytes:&bytesPerFrame length:sizeof(bytesPerFrame)];
    [waveData appendBytes:&bitsPerSample length:sizeof(bitsPerSample)];

    [self appendCString:"data" toData:waveData];
    uint32_t dataSize = (uint32_t)pcmData.length;
    [waveData appendBytes:&dataSize length:sizeof(dataSize)];
    [waveData appendData:pcmData];
    return waveData;
}

- (void)appendCString:(const char *)string toData:(NSMutableData *)data
{
    [data appendBytes:string length:strlen(string)];
}

@end
