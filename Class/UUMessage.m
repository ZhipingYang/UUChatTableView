#import "UUMessage.h"
#import "NSDate+Utils.h"

@implementation UUMessage

- (void)configureWithDictionary:(NSDictionary<NSString *, id> *)dictionary
{
    [self applyIdentityFromDictionary:dictionary];

    self.timestamp = [self timestampFromDictionary:dictionary] ?: NSDate.date;
    NSString *displayTimeOverride = [self stringObjectFromDictionary:dictionary keys:@[@"displayTimeText"]];
    self.strTime = displayTimeOverride ?: [self displayDateStringFromDate:self.timestamp];

    [self resetPayload];
    [self applyPayloadFromDictionary:dictionary];
}

- (void)setWithDict:(NSDictionary<NSString *, id> *)dict
{
    [self configureWithDictionary:dict];
}

- (NSString *)displayDateStringFromDate:(NSDate *)date
{
    NSString *dateString;
    if (date.year == NSDate.date.year) {
        NSInteger days = [NSDate daysOffsetBetweenStartDate:date endDate:NSDate.date];
        if (labs((int)days) <= 1) {
            dateString = date.stringYearMonthDayCompareToday;
        } else {
            dateString = date.stringMonthDay;
        }
    } else {
        dateString = date.stringYearMonthDay;
    }

    NSString *period = @"Dawn";
    NSInteger displayHour = date.hour;
    if (date.hour >= 5 && date.hour < 12) {
        period = @"AM";
    } else if (date.hour >= 12 && date.hour <= 18) {
        period = @"PM";
        displayHour = MAX(1, date.hour - 12);
    } else if (date.hour > 18 && date.hour <= 23) {
        period = @"Night";
        displayHour = MAX(1, date.hour - 12);
    }
    return [NSString stringWithFormat:@"%@ %@ %02ld:%02ld",
                                      dateString,
                                      period,
                                      (long)displayHour,
                                      (long)date.minute];
}

- (void)updateShowsDateLabelFromStartTimeString:(NSString *)start endTimeString:(NSString *)end
{
    (void)end;
    NSDate *startDate = start.length >= 19 ? [NSDate dateFromString:[start substringToIndex:19] withFormat:@"yyyy-MM-dd HH:mm:ss"] : nil;
    [self updateShowsDateLabelComparedToDate:startDate];
}

- (void)minuteOffSetStart:(NSString *)start end:(NSString *)end
{
    [self updateShowsDateLabelFromStartTimeString:start endTimeString:end];
}

- (void)updateShowsDateLabelComparedToDate:(NSDate *)date
{
    if (!date) {
        self.showDateLabel = YES;
        return;
    }

    NSTimeInterval interval = [self.timestamp timeIntervalSinceDate:date];
    self.showDateLabel = fabs(interval) > 5 * 60.0;
}

- (void)updateShowDateLabelComparedToDate:(NSDate *)date
{
    [self updateShowsDateLabelComparedToDate:date];
}

- (void)applyIdentityFromDictionary:(NSDictionary<NSString *, id> *)dict
{
    self.strIcon = [self stringObjectFromDictionary:dict keys:@[@"avatarIdentifier", @"strIcon"]];
    self.strName = [self stringObjectFromDictionary:dict keys:@[@"displayName", @"strName"]];
    self.strId = [self stringObjectFromDictionary:dict keys:@[@"senderIdentifier", @"strId"]];
    self.iconImage = [self imageObjectFromDictionary:dict keys:@[@"avatarImage", @"iconImage"]];
    self.from = (UUMessageSender)[self integerObjectFromDictionary:dict keys:@[@"sender", @"from"] defaultValue:UUMessageFromOther];
}

- (nullable NSDate *)timestampFromDictionary:(NSDictionary<NSString *, id> *)dict
{
    id timestampValue = dict[@"timestamp"];
    if ([timestampValue isKindOfClass:[NSDate class]]) {
        return timestampValue;
    }

    id timeStringValue = [self firstObjectFromDictionary:dict keys:@[@"strTime", @"displayTimeText"]];
    if (![timeStringValue isKindOfClass:[NSString class]]) {
        return nil;
    }

    NSString *timestampString = (NSString *)timeStringValue;
    NSString *normalizedString = timestampString.length >= 19 ? [timestampString substringToIndex:19] : timestampString;
    return [NSDate dateFromString:normalizedString withFormat:@"yyyy-MM-dd HH:mm:ss"];
}

- (void)resetPayload
{
    self.strContent = nil;
    self.picture = nil;
    self.voice = nil;
    self.strVoiceTime = nil;
}

- (void)applyPayloadFromDictionary:(NSDictionary<NSString *, id> *)dict
{
    self.type = [self messageTypeFromDictionary:dict];

    switch (self.type) {
        case UUMessageTypePicture:
            self.picture = [self imageObjectFromDictionary:dict keys:@[@"image", @"picture"]];
            break;
        case UUMessageTypeVoice:
            self.voice = [self dataObjectFromDictionary:dict keys:@[@"voiceData", @"voice"]];
            self.strVoiceTime = [self stringObjectFromDictionary:dict keys:@[@"voiceDurationText", @"strVoiceTime"]];
            break;
        case UUMessageTypeText:
        default:
            self.strContent = [self stringObjectFromDictionary:dict keys:@[@"text", @"strContent"]];
            break;
    }
}

- (UUMessageContentType)messageTypeFromDictionary:(NSDictionary<NSString *, id> *)dict
{
    NSInteger rawType = [self integerObjectFromDictionary:dict keys:@[@"contentType", @"type"] defaultValue:UUMessageTypeText];
    switch (rawType) {
        case UUMessageTypePicture:
            return UUMessageTypePicture;
        case UUMessageTypeVoice:
            return UUMessageTypeVoice;
        case UUMessageTypeText:
        default:
            return UUMessageTypeText;
    }
}

- (nullable id)firstObjectFromDictionary:(NSDictionary<NSString *, id> *)dict keys:(NSArray<NSString *> *)keys
{
    for (NSString *key in keys) {
        id value = dict[key];
        if (value && value != [NSNull null]) {
            return value;
        }
    }
    return nil;
}

- (nullable NSString *)stringObjectFromDictionary:(NSDictionary<NSString *, id> *)dict keys:(NSArray<NSString *> *)keys
{
    id value = [self firstObjectFromDictionary:dict keys:keys];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    return value ? [value description] : nil;
}

- (NSInteger)integerObjectFromDictionary:(NSDictionary<NSString *, id> *)dict keys:(NSArray<NSString *> *)keys defaultValue:(NSInteger)defaultValue
{
    id value = [self firstObjectFromDictionary:dict keys:keys];
    return value ? [value integerValue] : defaultValue;
}

- (nullable UIImage *)imageObjectFromDictionary:(NSDictionary<NSString *, id> *)dict keys:(NSArray<NSString *> *)keys
{
    id value = [self firstObjectFromDictionary:dict keys:keys];
    return [value isKindOfClass:[UIImage class]] ? value : nil;
}

- (nullable NSData *)dataObjectFromDictionary:(NSDictionary<NSString *, id> *)dict keys:(NSArray<NSString *> *)keys
{
    id value = [self firstObjectFromDictionary:dict keys:keys];
    return [value isKindOfClass:[NSData class]] ? value : nil;
}

- (NSString *)avatarIdentifier
{
    return self.strIcon;
}

- (void)setAvatarIdentifier:(NSString *)avatarIdentifier
{
    self.strIcon = avatarIdentifier;
}

- (NSString *)senderIdentifier
{
    return self.strId;
}

- (void)setSenderIdentifier:(NSString *)senderIdentifier
{
    self.strId = senderIdentifier;
}

- (NSString *)displayTimeText
{
    return self.strTime;
}

- (void)setDisplayTimeText:(NSString *)displayTimeText
{
    self.strTime = displayTimeText;
}

- (NSString *)displayName
{
    return self.strName;
}

- (void)setDisplayName:(NSString *)displayName
{
    self.strName = displayName;
}

- (NSString *)text
{
    return self.strContent;
}

- (void)setText:(NSString *)text
{
    self.strContent = text;
}

- (UIImage *)image
{
    return self.picture;
}

- (void)setImage:(UIImage *)image
{
    self.picture = image;
}

- (NSData *)voiceData
{
    return self.voice;
}

- (void)setVoiceData:(NSData *)voiceData
{
    self.voice = voiceData;
}

- (NSString *)voiceDurationText
{
    return self.strVoiceTime;
}

- (void)setVoiceDurationText:(NSString *)voiceDurationText
{
    self.strVoiceTime = voiceDurationText;
}

- (UIImage *)avatarImage
{
    return self.iconImage;
}

- (void)setAvatarImage:(UIImage *)avatarImage
{
    self.iconImage = avatarImage;
}

- (UUMessageContentType)contentType
{
    return self.type;
}

- (void)setContentType:(UUMessageContentType)contentType
{
    self.type = contentType;
}

- (UUMessageSender)sender
{
    return self.from;
}

- (void)setSender:(UUMessageSender)sender
{
    self.from = sender;
}

- (BOOL)showsDateLabel
{
    return self.showDateLabel;
}

- (void)setShowsDateLabel:(BOOL)showsDateLabel
{
    self.showDateLabel = showsDateLabel;
}

@end
