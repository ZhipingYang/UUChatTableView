//
//  NSDate+Utils.m
//  UUChatTableView
//

#import "NSDate+Utils.h"

@implementation NSDate (Utils)

+ (nullable NSDate *)dateFromString:(NSString *)string
{
    return [self dateFromString:string withFormat:@"yyyy-MM-dd HH:mm:ss"];
}

+ (nullable NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format
{
    if (string.length == 0 || format.length == 0) {
        return nil;
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.timeZone = NSTimeZone.localTimeZone;
    formatter.dateFormat = format;
    return [formatter dateFromString:string];
}

+ (NSInteger)daysOffsetBetweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *normalizedStartDate = [calendar startOfDayForDate:startDate];
    NSDate *normalizedEndDate = [calendar startOfDayForDate:endDate];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay
                                               fromDate:normalizedStartDate
                                                 toDate:normalizedEndDate
                                                options:0];
    return components.day;
}

- (NSInteger)year
{
    return [[NSCalendar currentCalendar] component:NSCalendarUnitYear fromDate:self];
}

- (NSInteger)hour
{
    return [[NSCalendar currentCalendar] component:NSCalendarUnitHour fromDate:self];
}

- (NSInteger)minute
{
    return [[NSCalendar currentCalendar] component:NSCalendarUnitMinute fromDate:self];
}

- (NSString *)stringMonthDay
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.timeZone = NSTimeZone.localTimeZone;
    formatter.dateFormat = @"MM.dd";
    return [formatter stringFromDate:self];
}

- (NSString *)stringYearMonthDay
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.timeZone = NSTimeZone.localTimeZone;
    formatter.dateFormat = @"yyyy-MM-dd";
    return [formatter stringFromDate:self];
}

- (NSString *)stringYearMonthDayCompareToday
{
    NSInteger days = [NSDate daysOffsetBetweenStartDate:self endDate:NSDate.date];
    if (days == 0) {
        return @"Today";
    }
    if (days == -1) {
        return @"Yesterday";
    }
    if (days == 1) {
        return @"Tomorrow";
    }
    return self.stringYearMonthDay;
}

- (NSString *)stringYearMonthDayHourMinuteSecond
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.timeZone = NSTimeZone.localTimeZone;
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [formatter stringFromDate:self];
}

@end
