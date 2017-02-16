//
//  CCCalendarTimeScrollView.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/08/26.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCCalendarTimeScrollView.h"
#import "CCHourTime.h"

@interface CCCalendarTimeScrollView(){
    CGPoint slotDraggingStartPoint;
    CGPoint scrollStartPoint;
    CGPoint touchStart;
    BOOL isScrollViewDragging;
    BOOL isTopDragging;
    BOOL isBottomDragging;
    BOOL is24h;
    NSMutableArray *addedSlotViews;
    CCCalendarTimeSlotView *draggedSlotView;
    CCCalendarTimeViewBorder *border;
}

@end

@implementation CCCalendarTimeScrollView

const int COLUMN_HEIGHT = 32;
const int SCROLL_VIEW_OFFSET = 20;
const int LEFT_OFFSET = 35;
const int SWIPE_MOVEMENT = 60;

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.delegate = self;
    if(self.selectedHourTimes == nil) {
        self.selectedHourTimes = [NSMutableArray array];
    }
    if(self.hourTimes == nil) {
        self.hourTimes         = [NSMutableArray array];
    }
    if(addedSlotViews == nil) {
        addedSlotViews         = [NSMutableArray array];
    }
    
    CGRect rect = [UIScreen mainScreen].bounds; ///calendarWeekScrollView.frame.size.width will be as same as screen width
    int width = rect.size.width;
    int columnHeight = COLUMN_HEIGHT*2;
    self.pagingEnabled = NO;
    self.contentSize = CGSizeMake(width, columnHeight*25-SCROLL_VIEW_OFFSET);
    self.showsHorizontalScrollIndicator = YES;
    self.showsVerticalScrollIndicator = NO;
    self.clipsToBounds = NO;
    for (int i = 0; i < 25; i++) {
        NSMutableString *num;
        NSString *timeLabelText, *topTimeLabelText, *bottomTimeLabelText;
        CCHourTime *topHourTime, *bottomHourTime;
        ///is 24h or 12h
        ///https://stackoverflow.com/questions/7448360/detect-if-time-format-is-in-12hr-or-24hr-format
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateStyle:NSDateFormatterNoStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
        NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
        is24h = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
        if (is24h) {
            num = [NSMutableString stringWithFormat:@"%d",i];
            timeLabelText = [[num stringByAppendingString:@""] copy];
            if (i == 0) {
                topTimeLabelText = @"11:30 - 12:00";
                topHourTime = [[CCHourTime alloc] initWithHourTime:@"11"
                                                         startTime:@"30"
                                                           endHour:@"12"
                                                           endTime:@"00"];
            }else{
                topTimeLabelText = [NSString stringWithFormat:@"%d:30 - %d:00",i-1,i];
                topHourTime = [[CCHourTime alloc] initWithHourTime:[NSMutableString stringWithFormat:@"%d",i-1]
                                                         startTime:@"30"
                                                           endHour:[NSMutableString stringWithFormat:@"%d",i]
                                                           endTime:@"00"];
            }
            bottomTimeLabelText = [NSString stringWithFormat:@"%d:00 - %d:30",i,i];
            bottomHourTime = [[CCHourTime alloc] initWithHourTime:num
                                                        startTime:@"00"
                                                          endHour:num
                                                          endTime:@"30"];
        }else{
            if (i < 13) {
                num = [NSMutableString stringWithFormat:@"%d",i];
                timeLabelText = [[num stringByAppendingString:@" AM"] copy];
                if (i == 0) {
                    topTimeLabelText = @"11:30 - 12:00";
                    topHourTime = [[CCHourTime alloc] initWithHourTime:@"11"
                                                             startTime:@"30"
                                                               endHour:@"12"
                                                               endTime:@"00"];
                }else{
                    topTimeLabelText = [NSString stringWithFormat:@"%d:30 - %d:00",i-1,i];
                    topHourTime = [[CCHourTime alloc] initWithHourTime:[NSMutableString stringWithFormat:@"%d",i-1]
                                                             startTime:@"30"
                                                               endHour:[NSMutableString stringWithFormat:@"%d",i]
                                                               endTime:@"00"];
                }
                bottomTimeLabelText = [NSString stringWithFormat:@"%d:00 - %d:30",i,i];
                bottomHourTime = [[CCHourTime alloc] initWithHourTime:num
                                                            startTime:@"00"
                                                              endHour:num
                                                              endTime:@"30"];
            }else{
                num = [NSMutableString stringWithFormat:@"%d",i-12];
                timeLabelText = [[num stringByAppendingString:@" PM"] copy];
                if (i == 13) {
                    topTimeLabelText = [NSString stringWithFormat:@"12:30 - %d:00",i-12];
                }else{
                    topTimeLabelText = [NSString stringWithFormat:@"%d:30 - %d:00",i-13,i-12];
                }
                topHourTime = [[CCHourTime alloc] initWithHourTime:[NSMutableString stringWithFormat:@"%d",i-1]
                                                         startTime:@"30"
                                                           endHour:[NSMutableString stringWithFormat:@"%d",i]
                                                           endTime:@"00"];
                bottomTimeLabelText = [NSString stringWithFormat:@"%d:00 - %d:30",i-12,i-12];
                bottomHourTime = [[CCHourTime alloc] initWithHourTime:[NSMutableString stringWithFormat:@"%d",i]
                                                            startTime:@"00"
                                                              endHour:[NSMutableString stringWithFormat:@"%d",i]
                                                              endTime:@"30"];
            }
        }
        CCCalendarTimeView *calendarTimeView = [[CCCalendarTimeView alloc] initWithFrameAndLabels:CGRectMake(0,columnHeight*i-SCROLL_VIEW_OFFSET,width,columnHeight)
                                                                                    timeLabelText:timeLabelText
                                                                                 topTimeLabelText:topTimeLabelText
                                                                              bottomTimeLabelText:bottomTimeLabelText
                                                                                      topHourTime:topHourTime
                                                                                   bottomHourTime:bottomHourTime
                                                                                         delegate:self];
        if (i == 0) {
            [calendarTimeView.topHourTimeButton setEnabled:NO];
        }else if(i == 24){
            [calendarTimeView.bottomHourTimeButton setEnabled:NO];
        }
        calendarTimeView.userInteractionEnabled = NO;
        [self addSubview:calendarTimeView];
        [self.hourTimes addObject:calendarTimeView];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
 */

- (void)displayCurrentLine{
    CGRect rect = [UIScreen mainScreen].bounds; ///calendarWeekScrollView.frame.size.width will be as same as screen width
    int width = rect.size.width;
    int columnHeight = COLUMN_HEIGHT*2;
    int borderLineHeight = 6;
    NSDate *crtDate = [NSDate date];
    NSUInteger flags;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (osVersion >= 8.0f)  {
        flags = NSCalendarUnitHour | NSCalendarUnitMinute;
    } else {
        flags = NSHourCalendarUnit | NSMinuteCalendarUnit;
    }
#else
    flags = NSHourCalendarUnit | NSMinuteCalendarUnit;
#endif
    NSDateComponents *crtComponents = [[NSCalendar currentCalendar] components:flags fromDate:crtDate];
    CGFloat height = columnHeight*(crtComponents.hour + (float)crtComponents.minute/60) + (float)columnHeight/2 -SCROLL_VIEW_OFFSET - (float)borderLineHeight/2;
    
    if(border != nil) {
        [border removeFromSuperview];
    }
    border = [[CCCalendarTimeViewBorder alloc] initWithFrame:CGRectMake(0,height ,width, borderLineHeight)];
    [self addSubview:border];
    ///Scroll to current time
    CGRect frame = self.frame;
    float offsetY;
    float contentSizeHeight = self.contentSize.height;
    float frameSizeHeight = (float)frame.size.height;
    if(height < (contentSizeHeight-frameSizeHeight/2)){
        offsetY = height - frameSizeHeight/2 + SCROLL_VIEW_OFFSET;
    }else{
        offsetY = frame.origin.y + contentSizeHeight;
    }
    
    //-------------------------
    // 
    //-------------------------
    if(offsetY<0){
        offsetY = 0;
    }else if(contentSizeHeight - frameSizeHeight < offsetY){
        offsetY = contentSizeHeight - frameSizeHeight + SCROLL_VIEW_OFFSET;
    }
    
    [self setContentOffset:CGPointMake(0, offsetY) animated:NO];
}

- (void)updateSelections:(NSMutableArray *)selectedHourTimes{
    self.selectedHourTimes = selectedHourTimes;

    CGRect rect = [UIScreen mainScreen].bounds; ///calendarWeekScrollView.frame.size.width will be as same as screen width
    int width = rect.size.width - LEFT_OFFSET;
    
    for (CCCalendarTimeSlotView *calendarTimeSlotView in addedSlotViews) {
        [calendarTimeSlotView removeFromSuperview];
    }
    addedSlotViews = [NSMutableArray array];
    
    for (CCHourTime *hourTime in self.selectedHourTimes) {
        int num = [hourTime.startHour intValue]*2 + 1;
        int columnNum = ([hourTime.endHour intValue] - [hourTime.startHour intValue])*2 + ([hourTime.endTime intValue] - [hourTime.startTime intValue])/30;
        CGRect frame = CGRectMake(LEFT_OFFSET,COLUMN_HEIGHT*num-SCROLL_VIEW_OFFSET,width,COLUMN_HEIGHT*columnNum);
        CCCalendarTimeSlotView *calendarTimeSlotView = [[CCCalendarTimeSlotView alloc] initWithFrameAndLabels:frame
                                                                                                     hourTime:hourTime
                                                                                                        is24h:is24h
                                                                                                     delegate:self];
        [self addSubview:calendarTimeSlotView];
        [self bringSubviewToFront:calendarTimeSlotView];
        [addedSlotViews addObject:calendarTimeSlotView];
    }
    [self resetProperties];
}

#pragma mark - Drag events

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSLog(@"scrollViewWillBeginDragging");
    
    //--------------------------------------------------------------------
    //
    // Judge the drag is expanding/shrinking slot or not
    //
    //--------------------------------------------------------------------
    isScrollViewDragging = YES;
    CGPoint tapPoint = [scrollView.panGestureRecognizer locationInView:scrollView];
    scrollStartPoint = tapPoint;
    for (CCCalendarTimeSlotView *calendarTimeSlotView in addedSlotViews) {
        CGPoint topButtonLeftUp = CGPointMake(calendarTimeSlotView.frame.origin.x + calendarTimeSlotView.topButton.frame.origin.x,
                                              calendarTimeSlotView.frame.origin.y + calendarTimeSlotView.topButton.frame.origin.y);
        CGPoint topButtonRightDown = CGPointMake(topButtonLeftUp.x + calendarTimeSlotView.topButton.frame.size.width,
                                                 topButtonLeftUp.y + calendarTimeSlotView.topButton.frame.size.height);
        if (topButtonLeftUp.x < tapPoint.x
            && tapPoint.x < topButtonRightDown.x
            && topButtonLeftUp.y < tapPoint.y
            && tapPoint.y < topButtonRightDown.y){
            ///Tapped in topBotton
            NSLog(@"Tapped in topBotton");
            isScrollViewDragging = NO;
            self.scrollEnabled = false;
            isTopDragging = YES;
            isBottomDragging = NO;
            slotDraggingStartPoint = tapPoint;
            draggedSlotView = calendarTimeSlotView;
        }
        
        CGPoint bottomButtonLeftUp = CGPointMake(calendarTimeSlotView.frame.origin.x + calendarTimeSlotView.bottomButton.frame.origin.x,
                                                 calendarTimeSlotView.frame.origin.y + calendarTimeSlotView.bottomButton.frame.origin.y);
        CGPoint bottomButtonRightDown = CGPointMake(bottomButtonLeftUp.x + calendarTimeSlotView.bottomButton.frame.size.width,
                                                    bottomButtonLeftUp.y + calendarTimeSlotView.bottomButton.frame.size.height);
        
        if (bottomButtonLeftUp.x < tapPoint.x && tapPoint.x < bottomButtonRightDown.x
            && bottomButtonLeftUp.y < tapPoint.y && tapPoint.y < bottomButtonRightDown.y) {
            ///Tapped in bottomBotton
            NSLog(@"Tapped in bottomBotton");
            isScrollViewDragging = NO;
            self.scrollEnabled = false;
            isTopDragging = NO;
            isBottomDragging = YES;
            slotDraggingStartPoint = tapPoint;
            draggedSlotView = calendarTimeSlotView;
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0){
    NSLog(@"CCCalendarTimeScrollView.m scrollViewWillEndDragging");
    
    //--------------------------------------------------------------------
    //
    // Judge the drag is swipe date or not
    //
    //--------------------------------------------------------------------
    CGPoint tapPoint = [scrollView.panGestureRecognizer locationInView:scrollView];
    if((tapPoint.x - scrollStartPoint.x) < -SWIPE_MOVEMENT){
        NSLog(@"swipe left");
        [self swipeLeft];
    }else if(SWIPE_MOVEMENT < (tapPoint.x - scrollStartPoint.x)){
        NSLog(@"swipe right");
        [self swipeRight];
    }
    isScrollViewDragging = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    NSLog(@"CCCalendarTimeScrollView.m scrollViewDidEndDragging");
    isScrollViewDragging = NO;
}

#pragma mark - Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    touchStart = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesMoved");
    if (isTopDragging == NO && isBottomDragging == NO) {
        return;
    }
    
    //--------------------------------------------------------------------
    //
    // For dragging check the range is in the vaild area/overlapping
    //
    //--------------------------------------------------------------------
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    int movementY = touchPoint.y - slotDraggingStartPoint.y;
    NSLog(@"movementY %d", movementY);
    ///Check overlapping
    if (isTopDragging == YES) {
        ///Check out of range
        if (draggedSlotView.frame.origin.y+movementY < 0) {
            return;
        }
        for (CCCalendarTimeSlotView *addedSlotView in addedSlotViews) {
            if(addedSlotView.frame.origin.y < draggedSlotView.frame.origin.y
               && draggedSlotView.frame.origin.y+movementY < addedSlotView.frame.origin.y + addedSlotView.frame.size.height ){
                return;
            }
            if (draggedSlotView.frame.size.height-movementY < COLUMN_HEIGHT) {
                return;
            }
        }
        draggedSlotView.frame = CGRectMake(draggedSlotView.frame.origin.x, draggedSlotView.frame.origin.y+movementY, draggedSlotView.frame.size.width, draggedSlotView.frame.size.height-movementY);
    }else if (isBottomDragging == YES) {
        ///Check out of range
        if (COLUMN_HEIGHT*48 < draggedSlotView.frame.origin.y + draggedSlotView.frame.size.height+movementY) {
            return;
        }
        for (CCCalendarTimeSlotView *addedSlotView in addedSlotViews) {
            if(draggedSlotView.frame.origin.y < addedSlotView.frame.origin.y
               && addedSlotView.frame.origin.y < draggedSlotView.frame.origin.y + draggedSlotView.frame.size.height + movementY){
                return;
            }
            if (draggedSlotView.frame.size.height+movementY < COLUMN_HEIGHT) {
                return;
            }
        }
        draggedSlotView.frame = CGRectMake(draggedSlotView.frame.origin.x, draggedSlotView.frame.origin.y, draggedSlotView.frame.size.width, draggedSlotView.frame.size.height+movementY);
    }
    
    slotDraggingStartPoint = touchPoint;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"CCCalendarTimeScrollView.m touchesEnded");
    
    if (isScrollViewDragging){
        [self resetProperties];
        return;
    }
    
    if(isTopDragging || isBottomDragging) {
        [self dragEnded];
    }else{
        UITouch *touch = [touches anyObject];
        CGPoint pos = [touch locationInView:self];
        
        //--------------------------------------------------------------------
        //
        // Judge the drag is swipe date or not
        //
        //--------------------------------------------------------------------
        if((pos.x - touchStart.x) < -SWIPE_MOVEMENT){
            NSLog(@"swipe left");
            [self swipeLeft];
            return;
        }else if(SWIPE_MOVEMENT < (pos.x - touchStart.x)){
            NSLog(@"swipe right");
            [self swipeRight];
            return;
        }
        
        //--------------------------------------------------------------------
        //
        // For Creating new, check the range is in the vaild area/overlapping
        //
        //--------------------------------------------------------------------
        ///Check out of range or not
        if (pos.x < LEFT_OFFSET || pos.y < 0 || COLUMN_HEIGHT*48 < pos.y) {
            return;
        }
        
        ///Check exist or not
        for (CCCalendarTimeSlotView *addedSlotView in addedSlotViews) {
            CGPoint leftUp = CGPointMake(addedSlotView.frame.origin.x,addedSlotView.frame.origin.y);
            CGPoint rightDown = CGPointMake(leftUp.x + addedSlotView.frame.size.width,leftUp.y + addedSlotView.frame.size.height);
            if (leftUp.x < pos.x && pos.x < rightDown.x && leftUp.y < pos.y && pos.y < rightDown.y){
                return;
            }
        }
        
        ///Add new selected time
        CGRect rect = [UIScreen mainScreen].bounds; ///calendarWeekScrollView.frame.size.width will be as same as screen width
        int width = rect.size.width - LEFT_OFFSET;
        int num = pos.y/COLUMN_HEIGHT + 1;
        CGRect frame = CGRectMake(LEFT_OFFSET,COLUMN_HEIGHT*num-SCROLL_VIEW_OFFSET,width,COLUMN_HEIGHT);
        int startHour = (num-1)/2;
        int startTime = ((num-1)%2)*30;
        int endHour, endTime;
        if (startTime == 30) {
            endHour = startHour + 1;
            endTime = 0;
        }else{
            endHour = startHour;
            endTime = 30;
        }
        
        ///Check exist or not again for white circle
        for (CCCalendarTimeSlotView *addedSlotView in addedSlotViews) {
            if ([addedSlotView.hourTime.startHour isEqualToString:[NSMutableString stringWithFormat:@"%d",startHour]]
                && [addedSlotView.hourTime.startTime isEqualToString:[NSMutableString stringWithFormat:@"%02d",startTime]])
            {
                return;
            }
        }
        
        CCHourTime *hourTime = [[CCHourTime alloc] initWithHourTime:[NSMutableString stringWithFormat:@"%d",startHour]
                                                          startTime:[NSMutableString stringWithFormat:@"%02d",startTime]
                                                            endHour:[NSMutableString stringWithFormat:@"%d",endHour]
                                                            endTime:[NSMutableString stringWithFormat:@"%02d",endTime]];
        [self addNewTimeSlot:frame hourTime:hourTime];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    NSLog(@"CCCalendarTimeScrollView.m touchesCancelled");
    [self resetProperties];
}

#pragma mark - Actions

- (void)addNewTimeSlot:(CGRect)frame hourTime:(CCHourTime *)hourTime{
    [self selectedHourTime:hourTime];
    CCCalendarTimeSlotView *calendarTimeSlotView = [[CCCalendarTimeSlotView alloc] initWithFrameAndLabels:frame
                                                                                                 hourTime:hourTime
                                                                                                    is24h:is24h
                                                                                                 delegate:self];
    [self addSubview:calendarTimeSlotView];
    [self bringSubviewToFront:calendarTimeSlotView];
    [addedSlotViews addObject:calendarTimeSlotView];
}

- (void)dragEnded{
    int startNum, endNum;
    float modifiedY;
    
    ///Adjusting time(by 30 min.)
    startNum = ceil((float)(draggedSlotView.frame.origin.y - SCROLL_VIEW_OFFSET)/COLUMN_HEIGHT) + 1;
    endNum = ceil((float)(draggedSlotView.frame.origin.y + draggedSlotView.frame.size.height - SCROLL_VIEW_OFFSET)/COLUMN_HEIGHT) + 1;
    if (isTopDragging) {
        modifiedY = COLUMN_HEIGHT*startNum-SCROLL_VIEW_OFFSET;
        float changedValue = draggedSlotView.frame.origin.y - modifiedY;
        draggedSlotView.frame = CGRectMake(draggedSlotView.frame.origin.x, modifiedY, draggedSlotView.frame.size.width, draggedSlotView.frame.size.height + changedValue);
    }else if(isBottomDragging){
        modifiedY = COLUMN_HEIGHT*endNum-SCROLL_VIEW_OFFSET;
        float modifiedHeight = modifiedY - draggedSlotView.frame.origin.y;
        draggedSlotView.frame = CGRectMake(draggedSlotView.frame.origin.x, draggedSlotView.frame.origin.y, draggedSlotView.frame.size.width, modifiedHeight);
    }
    
    ///Update stored time
    int startHour = (startNum-1)/2;
    int startTime = ((startNum-1)%2)*30;
    int endHour = (endNum-1)/2;
    int endTime = ((endNum-1)%2)*30;
    CCHourTime *draggedHourTime = draggedSlotView.hourTime;
    [self removedHourTime:draggedHourTime];
    CCHourTime *hourTime = [[CCHourTime alloc] initWithHourTime:[NSMutableString stringWithFormat:@"%d",startHour]
                                                      startTime:[NSMutableString stringWithFormat:@"%02d",startTime]
                                                        endHour:[NSMutableString stringWithFormat:@"%d",endHour]
                                                        endTime:[NSMutableString stringWithFormat:@"%02d",endTime]];
    [self selectedHourTime:hourTime];
    draggedSlotView.hourTime = hourTime;
    
    ///Reset properties
    [self resetProperties];
}

- (void)resetProperties{
    self.scrollEnabled = true;
    draggedSlotView = nil;
    isBottomDragging = NO;
    isTopDragging = NO;
}

- (void)selectedHourTime:(CCHourTime *)hourTime{
    [self.selectedHourTimes addObject:hourTime];
    NSLog(@"self.selectedHourTimes: %lu", (unsigned long)[self.selectedHourTimes count]);
}

- (void)removedHourTime:(CCHourTime *)hourTime{
    NSMutableArray *discards = [NSMutableArray array];
    for (CCHourTime *existHourTime in self.selectedHourTimes) {
        if([existHourTime.startHour isEqualToString:hourTime.startHour]
           && [existHourTime.startTime isEqualToString:hourTime.startTime]
           && [existHourTime.endHour isEqualToString:hourTime.endHour]
           && [existHourTime.endTime isEqualToString:hourTime.endTime]){
            [discards addObject:existHourTime];
        }
    }
    [self.selectedHourTimes removeObjectsInArray:discards];
    NSLog(@"self.selectedHourTimes: %lu", (unsigned long)[self.selectedHourTimes count]);
}

- (void)removedSlotView:(UIView *)slotView hourTime:(CCHourTime *)hourTime{
    [self removedHourTime:hourTime];
    
    NSMutableArray *discards = [NSMutableArray array];
    for (CCCalendarTimeSlotView *calendarTimeSlotView in addedSlotViews) {
        if([calendarTimeSlotView.hourTime.startHour isEqualToString:hourTime.startHour]
           && [calendarTimeSlotView.hourTime.startTime isEqualToString:hourTime.startTime]
           && [calendarTimeSlotView.hourTime.endHour isEqualToString:hourTime.endHour]
           && [calendarTimeSlotView.hourTime.endTime isEqualToString:hourTime.endTime]){
            [discards addObject:calendarTimeSlotView];
        }
    }
    [addedSlotViews removeObjectsInArray:discards];
    [slotView removeFromSuperview];
}

#pragma mark - Delegates

- (void)swipeLeft{
    if ([self.timeScrollViewDelegate respondsToSelector:@selector(moveForward)]) {
        [self.timeScrollViewDelegate moveForward];
    }
}

- (void)swipeRight{
    if ([self.timeScrollViewDelegate respondsToSelector:@selector(moveBack)]) {
        [self.timeScrollViewDelegate moveBack];
    }
}

@end
