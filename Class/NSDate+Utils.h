//
//  NSDate+Utils.h
//  UUChatTableView
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Utils)

+ (nullable NSDate *)dateFromString:(NSString *)string;
+ (nullable NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;
+ (NSInteger)daysOffsetBetweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

- (NSInteger)year;
- (NSInteger)hour;
- (NSInteger)minute;

- (NSString *)stringMonthDay;
- (NSString *)stringYearMonthDay;
- (NSString *)stringYearMonthDayCompareToday;
- (NSString *)stringYearMonthDayHourMinuteSecond;

@end

NS_ASSUME_NONNULL_END
