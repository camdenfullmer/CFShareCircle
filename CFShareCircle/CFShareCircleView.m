//
//  CFShareCircleView.m
//  CFShareCircle
//
//  Created by Camden on 12/18/12.
//  Copyright (c) 2012 Camden. All rights reserved.
//

#import "CFShareCircleView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CFShareCircleView

@synthesize delegate;
@synthesize images = _images;

-(id)init{
    self = [super init];
    if (self) {
        [self initialize];
        [self setImages:[[NSArray alloc] initWithObjects:@"evernote.png", @"facebook.png", @"googleplus.png", @"twitter.png", @"message.png", @"email.png", nil]];
        [self setUpLayers];
    }
    return self;
}

- (id)initWithCustomImages: (NSArray*)images{
    self = [super init];
    if (self) {
        [self initialize];
        [self setImages:images];
        [self setUpLayers];
    }
    return self;
}

/* Set all the default values for the share circle. */
- (void)initialize{
    self.hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    
    // Set up frame and positions.
    [self setFrame:CGRectMake(320, 0, 320, 480)];
    [self setBounds:CGRectMake(0, 0, 320, 480)];
    _origin = CGPointMake(160, 240);
    _currentPosition = _origin;
    visibile = NO;
    
    // Create shadow for UIView.
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.5;
    
    // Set up observer for orientation changes.    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
}

- (void)setUpLayers{
    // Create a larger circle layer for the background of the Share Circle.
    CAShapeLayer *backgroundLayer = [CAShapeLayer layer];
    backgroundLayer.bounds = self.bounds;
    backgroundLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    backgroundLayer.fillColor = [[UIColor whiteColor] CGColor];    
    CGMutablePathRef backgroundPath = CGPathCreateMutable();
    CGRect backgroundRect = CGRectMake(_origin.x - BACKGROUND_SIZE/2,_origin.y - BACKGROUND_SIZE/2,BACKGROUND_SIZE,BACKGROUND_SIZE);
    CGPathAddEllipseInRect(backgroundPath, nil, backgroundRect);
    backgroundLayer.path = backgroundPath;    
    [self.layer addSublayer:backgroundLayer];
    
    
    // Create the close button layer for the Share Circle.
    closeButtonLayer = [CAShapeLayer layer];
    closeButtonLayer.bounds = self.bounds;
    closeButtonLayer.contents = (id) [UIImage imageNamed:@"close_button.png"].CGImage;
    
    // Create the rect and the point to draw the image.
    // Calculate the x and y coordinate at pi/4.
    double x = _origin.x - CLOSE_BUTTON_SIZE/2.0 + cosf(M_PI/4)*BACKGROUND_SIZE/2.0;
    double y = _origin.y - CLOSE_BUTTON_SIZE/2.0 - sinf(M_PI/4)*BACKGROUND_SIZE/2.0;
    
    CGRect tempRect = CGRectMake(x,y,CLOSE_BUTTON_SIZE,CLOSE_BUTTON_SIZE);
    closeButtonLayer.frame = tempRect;
    
    // Create the overlay for the button
    CAShapeLayer *overlayLayer = [CAShapeLayer layer];
    overlayLayer.bounds = closeButtonLayer.frame;
    overlayLayer.frame = closeButtonLayer.frame;
    //overlayLayer.position = );
    overlayLayer.fillColor = [[UIColor whiteColor] CGColor];
    overlayLayer.opacity = 0.2;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, nil, CGRectMake(0, 0, 40, 40));
    overlayLayer.path = path;
    
    [self.layer addSublayer:closeButtonLayer];
    [closeButtonLayer addSublayer:overlayLayer];
    
    
    // Create the layers for all the sharing services.
    for(int i = 0; i < _images.count; i++) {
        UIImage *image = [UIImage imageNamed:[_images objectAtIndex:i]];
        CGPoint point = [self pointAtIndex:i];
        CGRect rect = CGRectMake(point.x,point.y, TEMP_SIZE,TEMP_SIZE);
        CAShapeLayer *tempLayer = [CAShapeLayer layer];
        tempLayer.bounds = self.bounds;
        tempLayer.contents = (id)image.CGImage;
        tempLayer.frame = rect;
        [self.layer addSublayer:tempLayer];
    }
    
    
    // Create the touch layer for the Share Circle.
    touchLayer = [CAShapeLayer layer];
    touchLayer.bounds = CGRectMake(_origin.x - TOUCH_SIZE/2.0, _origin.y - TOUCH_SIZE/2.0, TOUCH_SIZE, TOUCH_SIZE);
    touchLayer.contents = (id) [UIImage imageNamed:@"touch.png"].CGImage;
    touchLayer.position = [self touchLocationAtPoint:_currentPosition];
    [self.layer addSublayer:touchLayer];
}

/**
 TOUCH METHODS
 **/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
    _currentPosition = [touch locationInView:self];
    
    // Make sure the user starts with touch inside the circle.    
    if([self circleEnclosesPoint: _currentPosition] && ![self closeButtonEnclosesPoint:_currentPosition]){
        _dragging = YES;
        [self updateTouchPosition];
    } else if( [self closeButtonEnclosesPoint:_currentPosition]){
        // Hide overlay.
        CALayer *layer = [closeButtonLayer.sublayers objectAtIndex:0];
        layer.opacity = 0.0;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
    _currentPosition = [touch locationInView:self];
    
    if(_dragging)
        [self updateTouchPosition];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
    _currentPosition = [touch locationInView:self];
    
    // Show overlay.
    CALayer *layer = [closeButtonLayer.sublayers objectAtIndex:0];
    layer.opacity = 0.2;
    
    if([self closeButtonEnclosesPoint: _currentPosition] && !_dragging){
        [self.delegate shareCircleViewWasCanceled];
    }
    else if(_dragging){
        // Loop through all the rects to see if the user selected one.
        for(int i = 0; i < [_images count]; i++){
            CGPoint point = [self pointAtIndex:i];
            // Determine if point is inside rect.
            if(CGRectContainsPoint(CGRectMake(point.x, point.y, TEMP_SIZE, TEMP_SIZE), _currentPosition))
                [self.delegate shareCircleView:self didSelectIndex:i];
        }
    }
    
    _currentPosition = _origin;
    _dragging = NO;
    [self updateTouchPosition];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    // Reset location.
    _currentPosition = _origin;
    _dragging = NO;
}

/**
 ANIMATION METHODS
 **/
- (void) animateIn{
    self.hidden = NO;
    visibile = YES;
    // Reset the view.
    [self setNeedsDisplay];
    
    [UIView animateWithDuration: 0.2
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self setViewFrame];
                     }
                     completion:^(BOOL finished){}];
}

- (void) animateOut{
    visibile = NO;
    [UIView animateWithDuration: 0.2
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self setViewFrame];
                     }
                     completion:^(BOOL finished){
                         self.hidden = YES;
                     }];
}

- (void) updateTouchPosition{
    [CATransaction begin];
    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    touchLayer.position = [self touchLocationAtPoint:_currentPosition];
    [CATransaction commit];
}

/**
 HELPER METHODS
 **/

/* Determines where the touch images is going to be placed inside of the view. */
- (CGPoint) touchLocationAtPoint:(CGPoint)point{
    
    // If not dragging make sure we redraw the touch image at the origin.
    if(!_dragging)
        point = _origin;
        
    // See if the new point is outside of the circle's radius.
    if(pow(BACKGROUND_SIZE/2.0 - TOUCH_SIZE/2.0,2) < (pow(point.x - _origin.x,2) + pow(point.y - _origin.y,2))){
        
        // Determine x and y from the center of the circle.
        point.x = _origin.x - point.x;
        point.y -= _origin.y;
        
        // Calculate the angle on the around the circle.
        double angle = atan2(point.y, point.x);
        
        // Get the new x and y from the point on the edge of the circle subtracting the size of the touch image.
        point.x = _origin.x - (BACKGROUND_SIZE/2.0 - TOUCH_SIZE/2.0) * cos(angle);
        point.y = _origin.y + (BACKGROUND_SIZE/2.0 - TOUCH_SIZE/2.0) * sin(angle);
    }
    
    return point;
}

/* Get the point at the specified index. */
- (CGPoint) pointAtIndex:(int) index{
    // Number for trig.
    float trig = index/([_images count]/2.0)*M_PI;
    
    // Calculate the x and y coordinate.
    // Points go around the unit circle starting at pi = 0.
    float x = _origin.x - TEMP_SIZE/2.0 + cosf(trig)*PATH_SIZE/2.0;
    float y = _origin.y - TEMP_SIZE/2.0 - sinf(trig)*PATH_SIZE/2.0;
    
    return CGPointMake(x, y);
}

/* Helper method to determine if a specified point is inside the circle. */
- (BOOL) circleEnclosesPoint: (CGPoint) point{
    if(pow(BACKGROUND_SIZE/2.0,2) < (pow(point.x - _origin.x,2) + pow(point.y - _origin.y,2)))
        return NO;
    else
        return YES;
}

/* Helper method to determine if a specified point is inside the close button. */
- (BOOL) closeButtonEnclosesPoint: (CGPoint) point{
    float x = _origin.x - CLOSE_BUTTON_SIZE/2.0 + cosf(M_PI/4)*BACKGROUND_SIZE/2.0;
    float y = _origin.y - CLOSE_BUTTON_SIZE/2.0 - sinf(M_PI/4)*BACKGROUND_SIZE/2.0;
    
    CGRect tempRect = CGRectMake(x,y,CLOSE_BUTTON_SIZE,CLOSE_BUTTON_SIZE);
    
    if(CGRectContainsPoint(tempRect, point))
        return YES;
    else
        return NO;
}

/* Determine the frame that the view is to use based on orientation. */

- (void) setViewFrame{
    if(UIDeviceOrientationIsPortrait(currentOrientation)){
        [self setFrame:CGRectMake(320*!visibile, 0, 320, 480)];
        [self setBounds:CGRectMake(0, 0, 320, 480)];
        _origin = CGPointMake(160, 240);
        _currentPosition = _origin;
    }else if(UIDeviceOrientationIsLandscape(currentOrientation)){
        [self setFrame:CGRectMake(480*!visibile, 0, 480, 320)];
        [self setBounds:CGRectMake(0, 0, 480, 320)];
        _origin = CGPointMake(240, 160);
        _currentPosition = _origin;
    }
    [self setNeedsDisplay];
}

/**
 ORIENTATION CHANGE
 **/

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    //Obtaining the current device orientation
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    //Ignoring specific orientations
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown || currentOrientation == orientation) {
        return;
    }
    
    if ((UIDeviceOrientationIsPortrait(currentOrientation) && UIDeviceOrientationIsPortrait(orientation)) ||
        (UIDeviceOrientationIsLandscape(currentOrientation) && UIDeviceOrientationIsLandscape(orientation))) {
        //still saving the current orientation
        currentOrientation = orientation;
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(relayoutLayers) object:nil];
    //Responding only to changes in landscape or portrait
    currentOrientation = orientation;
    //
    [self performSelector:@selector(setViewFrame) withObject:nil afterDelay:0];
}

@end
