//
//  ClockView.m
//

#import "ClockView.h"

@implementation ClockView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setUpClock];
    }
    
    return self;
}

- (void)setUpClock {
    CAShapeLayer *face = [CAShapeLayer layer];
    
    // face
    face.bounds = self.bounds;
    face.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    face.fillColor = [[UIColor grayColor] CGColor];
    face.strokeColor = [[UIColor blackColor] CGColor];
    face.lineWidth = 4.0;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, nil, self.bounds);
    face.path = path;
    
    [self.layer addSublayer:face];
    
    // numbers
    for (NSInteger i=1; i <= 12; ++i) {
        CATextLayer *number = [CATextLayer layer];
        number.string = [NSString stringWithFormat:@"%i", i];
        number.alignmentMode = @"center";
        number.fontSize = 18.0;
        number.foregroundColor = [[UIColor blackColor] CGColor];
        number.bounds = CGRectMake(0.0, 0.0, 25.0, self.bounds.size.height / 2.0 - 10.0);
        number.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        number.anchorPoint = CGPointMake(0.5, 1.0);
        number.transform = CATransform3DMakeRotation((M_PI * 2) / 12.0 * i, 0, 0, 1);
        
        [self.layer addSublayer:number];
    }
    
    // ticks
    for (NSInteger i=1; i <= 60; ++i) {
        CAShapeLayer *tick = [CAShapeLayer layer];
        
        path = CGPathCreateMutable();
        CGPathAddEllipseInRect(path, nil, CGRectMake(0.0, 0.0, 1.0, 5.0));
        
        tick.strokeColor = [[UIColor blackColor] CGColor];
        tick.bounds = CGRectMake(0.0, 0.0, 1.0, self.bounds.size.height / 2.0);
        tick.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        tick.anchorPoint = CGPointMake(0.5, 1.0);
        tick.transform = CATransform3DMakeRotation((M_PI * 2) / 60.0 * i, 0, 0, 1);
        tick.path = path;
        
        [self.layer addSublayer:tick];
    }
    
    // second hand
    secondHand_ = [CAShapeLayer layer];
    
    path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 1.0, 0.0);
    CGPathAddLineToPoint(path, nil, 1.0, self.bounds.size.height / 2.0 + 8.0);
    
    secondHand_.bounds = CGRectMake(0.0, 0.0, 3.0, self.bounds.size.height / 2.0 + 8.0);
    secondHand_.anchorPoint = CGPointMake(0.5, 0.8);
    secondHand_.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    secondHand_.lineWidth = 3.0;
    secondHand_.strokeColor = [[UIColor redColor] CGColor];
    secondHand_.path = path;
    secondHand_.shadowOffset = CGSizeMake(0.0, 3.0);
    secondHand_.shadowOpacity = 0.6;
    secondHand_.lineCap = kCALineCapRound;
    
    [self.layer addSublayer:secondHand_];
    
    // minute hand
    minuteHand_ = [CAShapeLayer layer];
    
    path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 2.0, 0.0);
    CGPathAddLineToPoint(path, nil, 2.0, self.bounds.size.height / 2.0);
    
    minuteHand_.bounds = CGRectMake(0.0, 0.0, 5.0, self.bounds.size.height / 2.0);
    minuteHand_.anchorPoint = CGPointMake(0.5, 0.8);
    minuteHand_.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    minuteHand_.lineWidth = 5.0;
    minuteHand_.strokeColor = [[UIColor blackColor] CGColor];
    minuteHand_.path = path;
    minuteHand_.shadowOffset = CGSizeMake(0.0, 3.0);
    minuteHand_.shadowOpacity = 0.3;
    minuteHand_.lineCap = kCALineCapRound;
    
    [self.layer addSublayer:minuteHand_];
    
    // hour hand
    hourHand_ = [CAShapeLayer layer];
    
    path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 3, 0);
    CGPathAddLineToPoint(path, nil, 3.0, self.bounds.size.height / 3.0);
    
    hourHand_.bounds = CGRectMake(0.0, 0.0, 7.0, self.bounds.size.height / 3.0);
    hourHand_.anchorPoint = CGPointMake(0.5, 0.8);
    hourHand_.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    hourHand_.lineWidth = 7.0;
    hourHand_.strokeColor = [[UIColor blackColor] CGColor];
    hourHand_.path = path;
    hourHand_.shadowOffset = CGSizeMake(0.0, 3.0);
    hourHand_.shadowOpacity = 0.3;
    hourHand_.lineCap = kCALineCapRound;
    
    [self.layer addSublayer:hourHand_];
    
    // midpoint
    CAShapeLayer *circle = [CAShapeLayer layer];
    
    path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, nil, CGRectMake(0.0, 0.0, 11.0, 11.0));
    
    circle.fillColor = [[UIColor yellowColor] CGColor];
    circle.bounds = CGRectMake(0.0, 0.0, 11.0, 11.0);
    circle.path = path;
    circle.shadowOpacity = 0.3;
    circle.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    circle.shadowOffset = CGSizeMake(0.0, 5.0);
    
    [self.layer addSublayer:circle];
    
    [self updateHands];
}

#pragma mark -

- (void)startUpdates {
    updateTimer_ = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateHands) userInfo:nil repeats:YES];
}

- (void)stopUpdates {
    [updateTimer_ invalidate];
    updateTimer_ = nil;
}

- (void)updateHands {
    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:now];
    
    NSInteger minutesIntoDay = [comps hour] * 60 + [comps minute];
    float percentageMinutesIntoDay = minutesIntoDay / (12.0 * 60.0);
    float percentageMinutesIntoHour = (float)[comps minute] / 60.0;
    float percentageSecondsIntoMinute = (float)[comps second] / 60.0;
    
    secondHand_.transform = CATransform3DMakeRotation((M_PI * 2) * percentageSecondsIntoMinute, 0, 0, 1);
    minuteHand_.transform = CATransform3DMakeRotation((M_PI * 2) * percentageMinutesIntoHour, 0, 0, 1);
    hourHand_.transform = CATransform3DMakeRotation((M_PI * 2) * percentageMinutesIntoDay, 0, 0, 1);
}

@end