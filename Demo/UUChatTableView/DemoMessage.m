//
//  DemoMessage.m
//  UUChatTableView
//
//  Created by XcodeYang on 10/01/2018.
//  Copyright © 2018 uyiuyao. All rights reserved.
//

#import "DemoMessage.h"
#import "NSDate+Utils.h"

@interface DemoMessage()

@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, strong, nullable) UIImage *avatar;
@property (nonatomic, copy, nullable) NSString *date;

@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, strong, nullable) NSData *voiceData;
@property (nonatomic, copy, nullable) NSString *voiceText;

@property (nonatomic) MessageType type;
@property (nonatomic) MessageFrom from;

@end

@implementation DemoMessage

- (void)setDict:(NSDictionary *)dict
{
	_dict = dict;
	
//	self.avatar = dict[@"strIcon"];
	self.nickName = dict[@"strName"];
	self.userId = dict[@"strId"];
	self.date = [self changeTheDateString:dict[@"strTime"]];
	self.from = [dict[@"from"] intValue];
	
	switch ([dict[@"type"] integerValue]) {
			
		case 0:
			self.type = UUMessageTypeText;
			self.text = dict[@"strContent"];
			break;
			
		case 1:
			self.type = UUMessageTypePicture;
			self.image = dict[@"picture"];
			break;
			
		case 2:
			self.type = UUMessageTypeVoice;
			self.voiceData = dict[@"voice"];
			self.voiceText = dict[@"strVoiceTime"];
			break;
			
		default:
			break;
	}

}

//"08-10 晚上08:09:41.0" ->
//"昨天 上午10:09"或者"2012-08-10 凌晨07:09"
- (NSString *)changeTheDateString:(NSString *)Str
{
	NSString *subString = [Str substringWithRange:NSMakeRange(0, 19)];
	NSDate *lastDate = [NSDate dateFromString:subString withFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSTimeZone *zone = [NSTimeZone systemTimeZone];
	NSInteger interval = [zone secondsFromGMTForDate:lastDate];
	lastDate = [lastDate dateByAddingTimeInterval:interval];
	
	NSString *dateStr;  //年月日
	NSString *period;   //时间段
	NSString *hour;     //时
	
	if ([lastDate year]==[[NSDate date] year]) {
		NSInteger days = [NSDate daysOffsetBetweenStartDate:lastDate endDate:[NSDate date]];
		if (days <= 2) {
			dateStr = [lastDate stringYearMonthDayCompareToday];
		}else{
			dateStr = [lastDate stringMonthDay];
		}
	}else{
		dateStr = [lastDate stringYearMonthDay];
	}
	
	
	if ([lastDate hour]>=5 && [lastDate hour]<12) {
		period = @"AM";
		hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]];
	}else if ([lastDate hour]>=12 && [lastDate hour]<=18){
		period = @"PM";
		hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]-12];
	}else if ([lastDate hour]>18 && [lastDate hour]<=23){
		period = @"Night";
		hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]-12];
	} else {
		period = @"Dawn";
		hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]];
	}
	return [NSString stringWithFormat:@"%@ %@ %@:%02d",dateStr,period,hour,(int)[lastDate minute]];
}

- (void)minuteOffSetStart:(NSString *)start end:(NSString *)end
{
	NSString *subStart = [start substringWithRange:NSMakeRange(0, 19)];
	NSDate *startDate = [NSDate dateFromString:subStart withFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	NSString *subEnd = [end substringWithRange:NSMakeRange(0, 19)];
	NSDate *endDate = [NSDate dateFromString:subEnd withFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	//这个是相隔的秒数
	NSTimeInterval timeInterval = [startDate timeIntervalSinceDate:endDate];
	
	//相距5分钟显示时间Label
	if (fabs (timeInterval) <= 5*60) {
		self.date = nil;
	}
}
@end
