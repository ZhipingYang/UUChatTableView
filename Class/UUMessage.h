#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, UUMessageContentType) {
    UUMessageTypeText     = 0 , // 文字
    UUMessageTypePicture  = 1 , // 图片
    UUMessageTypeVoice    = 2   // 语音
};

typedef NS_ENUM(NSInteger, UUMessageSender) {
    UUMessageFromMe    = 0,   // 自己发的
    UUMessageFromOther = 1    // 别人发得
};

typedef UUMessageContentType MessageType;
typedef UUMessageSender MessageFrom;

@interface UUMessage : NSObject

@property (nonatomic, copy, nullable) NSString *strIcon;
@property (nonatomic, copy, nullable) NSString *strId;
@property (nonatomic, copy, nullable) NSString *strTime;
@property (nonatomic, copy, nullable) NSString *strName;

@property (nonatomic, copy, nullable) NSString *strContent;
@property (nonatomic, strong, nullable) UIImage *picture;
@property (nonatomic, strong, nullable) NSData *voice;
@property (nonatomic, copy, nullable) NSString *strVoiceTime;
@property (nonatomic, strong, nullable) UIImage *iconImage;
@property (nonatomic, strong, nullable) NSDate *timestamp;

@property (nonatomic, assign) UUMessageContentType type;
@property (nonatomic, assign) UUMessageSender from;

@property (nonatomic, assign) BOOL showDateLabel;

@property (nonatomic, copy, nullable) NSString *avatarIdentifier;
@property (nonatomic, copy, nullable) NSString *senderIdentifier;
@property (nonatomic, copy, nullable) NSString *displayTimeText;
@property (nonatomic, copy, nullable) NSString *displayName;
@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, strong, nullable) NSData *voiceData;
@property (nonatomic, copy, nullable) NSString *voiceDurationText;
@property (nonatomic, strong, nullable) UIImage *avatarImage;
@property (nonatomic, assign) UUMessageContentType contentType;
@property (nonatomic, assign) UUMessageSender sender;
@property (nonatomic, assign) BOOL showsDateLabel;

- (void)configureWithDictionary:(NSDictionary<NSString *, id> *)dictionary;
- (void)setWithDict:(NSDictionary<NSString *, id> *)dict;
- (void)updateShowsDateLabelFromStartTimeString:(nullable NSString *)start endTimeString:(nullable NSString *)end;
- (void)minuteOffSetStart:(nullable NSString *)start end:(nullable NSString *)end;
- (void)updateShowsDateLabelComparedToDate:(nullable NSDate *)date;
- (void)updateShowDateLabelComparedToDate:(nullable NSDate *)date;

@end

NS_ASSUME_NONNULL_END
