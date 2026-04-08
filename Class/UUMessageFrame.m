#import "UUMessageFrame.h"
#import "UUMessage.h"
#import "UUChatCategory.h"

@implementation UUMessageFrame

- (instancetype)init
{
    self = [super init];
    if (self) {
        _layoutWidth = UIScreen.uu_screenWidth;
    }
    return self;
}

- (void)setMessage:(UUMessage *)message
{
    _message = message;
    [self rebuildLayout];
}

- (void)setShowTime:(BOOL)showTime
{
    _showTime = showTime;
    if (_message) {
        [self rebuildLayout];
    }
}

- (void)setLayoutWidth:(CGFloat)layoutWidth
{
    _layoutWidth = layoutWidth > 0 ? layoutWidth : UIScreen.uu_screenWidth;
    if (_message) {
        [self rebuildLayout];
    }
}

- (void)rebuildLayout
{
    CGFloat screenWidth = MAX(self.layoutWidth, 320.0);
    CGFloat horizontalGap = 12.0;
    CGFloat bubbleTop = 0.0;
    BOOL showsLeadingAvatar = self.message.sender == UUMessageFromOther;
    CGFloat iconWidth = showsLeadingAvatar ? ChatIconWH : 0.0;

    if (self.showTime) {
        CGSize timeSize = [self.message.displayTimeText uu_sizeWithFont:ChatTimeFont constrainedToSize:CGSizeMake(300, 20)];
        _timeF = CGRectMake((screenWidth - timeSize.width - 22.0) / 2.0,
                            8.0,
                            timeSize.width + 22.0,
                            24.0);
    } else {
        _timeF = CGRectZero;
    }

    CGFloat iconX = showsLeadingAvatar ? ChatMargin : (screenWidth - ChatMargin - iconWidth);
    CGFloat iconY = CGRectGetMaxY(_timeF) + (self.showTime ? 12.0 : 6.0);
    _iconF = showsLeadingAvatar ? CGRectMake(iconX, iconY, ChatIconWH, ChatIconWH) : CGRectZero;

    CGFloat maxBubbleWidth = MIN(ChatContentW, floor(screenWidth * 0.62));
    CGSize contentSize = CGSizeZero;
    CGFloat bubbleHorizontalPadding = ChatContentBiger + ChatContentSmaller;
    CGFloat bubbleVerticalPadding = ChatContentTopBottom * 2.0;
    switch (self.message.contentType) {
        case UUMessageTypeText:
            contentSize = [self.message.text ?: @""
                           uu_sizeWithFont:ChatContentFont
                           constrainedToSize:CGSizeMake(maxBubbleWidth, CGFLOAT_MAX)];
            contentSize.height = MAX(contentSize.height, 20);
            contentSize.width = MAX(contentSize.width, 28);
            break;
        case UUMessageTypePicture:
            contentSize = [self fittedImageSizeForImage:self.message.image maxWidth:ChatPicWH maxHeight:ChatPicWH];
            bubbleHorizontalPadding = 10.0;
            bubbleVerticalPadding = 10.0;
            break;
        case UUMessageTypeVoice:
        {
            NSInteger seconds = MAX(self.message.voiceDurationText.integerValue, 1);
            CGFloat width = MIN(190.0, 82.0 + seconds * 10.0);
            contentSize = CGSizeMake(width, 24);
            bubbleHorizontalPadding = 24.0;
        }
            break;
        default:
            break;
    }

    CGFloat bubbleWidth = contentSize.width + bubbleHorizontalPadding;
    CGFloat bubbleHeight = contentSize.height + bubbleVerticalPadding;
    CGFloat contentX = showsLeadingAvatar ? CGRectGetMaxX(_iconF) + horizontalGap : ChatMargin;
    if (self.message.sender == UUMessageFromMe) {
        _nameF = CGRectZero;
        contentX = screenWidth - ChatMargin - bubbleWidth;
        bubbleTop = iconY;
    } else {
        CGSize nameSize = [self.message.displayName ?: @"" uu_sizeWithFont:ChatTimeFont constrainedToSize:CGSizeMake(screenWidth * 0.45, 18)];
        CGFloat nameX = contentX + 4.0;
        CGFloat nameWidth = MIN(MAX(nameSize.width, 48.0), screenWidth - nameX - ChatMargin);
        if (self.message.displayName.length > 0) {
            _nameF = CGRectMake(nameX, iconY, nameWidth, 14.0);
            bubbleTop = CGRectGetMaxY(_nameF) + 6.0;
        } else {
            _nameF = CGRectZero;
            bubbleTop = iconY;
        }
    }

    _contentF = CGRectMake(contentX, bubbleTop, bubbleWidth, bubbleHeight);
    CGFloat bottom = MAX(CGRectGetMaxY(_contentF), CGRectGetMaxY(_iconF));
    _cellHeight = bottom + 12.0;
}

- (CGSize)fittedImageSizeForImage:(UIImage *)image maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    if (!image || image.size.width <= 0 || image.size.height <= 0) {
        return CGSizeMake(maxWidth, maxWidth);
    }

    CGFloat widthRatio = maxWidth / image.size.width;
    CGFloat heightRatio = maxHeight / image.size.height;
    CGFloat ratio = MIN(widthRatio, heightRatio);
    CGSize size = CGSizeMake(ceil(image.size.width * ratio), ceil(image.size.height * ratio));
    size.width = MAX(size.width, 96);
    size.height = MAX(size.height, 96);
    return size;
}

@end
