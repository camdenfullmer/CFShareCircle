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

-(id)init{
    self = [super init];
    if (self) {
        [self initialize];
        [self setImages:[[NSArray alloc] initWithObjects:@"evernote.png", @"facebook.png", @"twitter.png", @"message.png", @"email.png", nil]];
    }
    return self;
}

- (id)initWithImageFileNames: (NSArray*)imageFileNames{
    self = [super init];
    if (self) {
        [self initialize];
        [self setImages:imageFileNames];
    }
    return self;
}

/* Set all the default values for the share circle. */
- (void)initialize{
    // Initialization code
    _largeRectSize = 250;
    _smallRectSize = 50;
    _pathRectSize = 180;
    _tempRectSize = 50;
    
    self.hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    
    closeButtonImage = [UIImage imageNamed:@"close_button.png"];
    touchImage = [UIImage imageNamed:@"touch.png"];
    
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
    
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw the larger circle.
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGRect largeCircleRect = CGRectMake(_origin.x - _largeRectSize/2,_origin.y - _largeRectSize/2,_largeRectSize,_largeRectSize);
    CGContextAddEllipseInRect(context, largeCircleRect);
    CGContextFillPath(context);
    
    [self drawCloseButtonWithContext:context];
    [self drawImagesWithContext:context];
    [self drawTouchRegionWithContext:context];
}

/**
 TOUCH METHODS
 **/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
    _currentPosition = [touch locationInView:self];
    
    // Make sure the user starts with touch inside the circle.    
    if([self circleEnclosesPoint: _currentPosition] && ![self closeButtonEnclosesPoint:_currentPosition])
        _dragging = YES;
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
    _currentPosition = [touch locationInView:self];
    
    if(_dragging)
        [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
    _currentPosition = [touch locationInView:self];
    
    if([self closeButtonEnclosesPoint: _currentPosition]){
        [self.delegate shareCircleViewWasCanceled];
    }
    else if(_dragging){
        // Loop through all the rects to see if the user selected one.
        for(int i = 0; i < [images count]; i++){
            CGPoint point = [self pointAtIndex:i];
            // Determine if point is inside rect.
            if(CGRectContainsPoint(CGRectMake(point.x, point.y, _tempRectSize, _tempRectSize), _currentPosition))
                [self.delegate shareCircleView:self didSelectIndex:i];
        }
        
        _currentPosition = _origin;
        _dragging = NO;
    }
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    // Reset location.
    _currentPosition = _origin;
    _dragging = NO;
    [self setNeedsDisplay];
}

/**
 DRAWING METHODS
 **/

/* Draws all the images from the list. */
- (void) drawImagesWithContext:(CGContextRef) context{
    
    for (int i = 0; i < [images count]; i++) {
        UIImage *image = [images objectAtIndex:i];
        
        // Create the rect and the point to draw the image.
        CGPoint point = [self pointAtIndex:i];
        CGRect rect = CGRectMake(point.x,point.y, _tempRectSize,_tempRectSize);
        
        // Start image context.
        UIGraphicsBeginImageContext(image.size);
        UIGraphicsPushContext(context);
        
        // Draw the image.
        if(CGRectContainsPoint(CGRectMake(point.x, point.y, _tempRectSize, _tempRectSize), _currentPosition))
            [image drawInRect:rect];
        else
            [image drawInRect:rect blendMode:kCGBlendModeNormal alpha:0.8];
        
        // End image context.
        UIGraphicsPopContext();
        UIGraphicsEndImageContext();
    }
}

/* Draw the close button. */
- (void) drawCloseButtonWithContext:(CGContextRef) context{
    
    // Create the rect and the point to draw the image.
    // Calculate the x and y coordinate at pi/4.
    float x = _origin.x - closeButtonImage.size.width/2.0 + cosf(M_PI/4)*_largeRectSize/2.0;
    float y = _origin.y - closeButtonImage.size.height/2.0 - sinf(M_PI/4)*_largeRectSize/2.0;
    
    CGRect tempRect = CGRectMake(x,y,closeButtonImage.size.width,closeButtonImage.size.height);
    
    // Start image context.
    UIGraphicsBeginImageContext(closeButtonImage.size);
    UIGraphicsPushContext(context);
    
    // Draw the image.
    [closeButtonImage drawInRect:tempRect];
    
    // End image context.
    UIGraphicsPopContext();
    UIGraphicsEndImageContext();
    
    // Make the button a little lighter when not pushed.
    if(!CGRectContainsPoint(tempRect, _currentPosition)){
        CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1 alpha:0.2].CGColor);
        CGContextAddEllipseInRect(context, tempRect);
        CGContextFillPath(context);
    }
}

/* Draw touch region. */
- (void) drawTouchRegionWithContext: (CGContextRef) context{
    
    // Create the rect and the point to draw the image.
    CGRect smallCircleRect = [self touchRectLocationAtPoint:_currentPosition];
    
    // Start image context.
    UIGraphicsBeginImageContext(touchImage.size);
    UIGraphicsPushContext(context);
    
    // Determine alpha based on if the user is dragging.
    float alpha;
    if(_dragging)
        alpha = 1.0;
    else
        alpha = 0.3;
    
    // Draw the image.
    [touchImage drawInRect:smallCircleRect blendMode:kCGBlendModeNormal alpha:alpha];
    
    // End image context.
    UIGraphicsPopContext();
    UIGraphicsEndImageContext();
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
                         _dragging = NO;
                     }];
}

/**
 HELPER METHODS
 **/

/* Determines where the touch images is going to be placed inside of the view. */
- (CGRect) touchRectLocationAtPoint:(CGPoint)point{
    
    // If not dragging make sure we redraw the touch image at the origin.
    if(!_dragging)
        point = _origin;
    
    float touchImageSize = touchImage.size.height;   
    
    // See if the new point is outside of the circle's radius.
    if(pow(_largeRectSize/2.0 - touchImageSize/2.0,2) < (pow(point.x - _origin.x,2) + pow(point.y - _origin.y,2))){
        
        // Determine x and y from the center of the circle.
        point.x = _origin.x - point.x;
        point.y -= _origin.y;
        
        // Calculate the angle on the around the circle.
        double angle = atan2(point.y, point.x);
        
        // Get the new x and y from the point on the edge of the circle subtracting the size of the touch image.
        point.x = _origin.x - (_largeRectSize/2.0 - touchImageSize/2.0) * cos(angle);
        point.y = _origin.y + (_largeRectSize/2.0 - touchImageSize/2.0) * sin(angle);
    }
    
    return CGRectMake(point.x - touchImage.size.width/2.0,point.y - touchImage.size.height/2.0,touchImage.size.width,touchImage.size.height);
}

/* Get the point at the specified index. */
- (CGPoint) pointAtIndex:(int) index{
    // Number for trig.
    float trig = index/([images count]/2.0)*M_PI;
    
    // Calculate the x and y coordinate.
    // Points go around the unit circle starting at pi = 0.
    float x = _origin.x - _tempRectSize/2.0 + cosf(trig)*_pathRectSize/2.0;
    float y = _origin.y - _tempRectSize/2.0 - sinf(trig)*_pathRectSize/2.0;
    
    return CGPointMake(x, y);
}

/* Helper method to determine if a specified point is inside the circle. */
- (BOOL) circleEnclosesPoint: (CGPoint) point{
    if(pow(_largeRectSize/2.0,2) < (pow(point.x - _origin.x,2) + pow(point.y - _origin.y,2)))
        return NO;
    else
        return YES;
}

/* Helper method to determine if a specified point is inside the close button. */
- (BOOL) closeButtonEnclosesPoint: (CGPoint) point{
    float x = _origin.x - closeButtonImage.size.width/2.0 + cosf(M_PI/4)*_largeRectSize/2.0;
    float y = _origin.y - closeButtonImage.size.height/2.0 - sinf(M_PI/4)*_largeRectSize/2.0;
    
    CGRect tempRect = CGRectMake(x,y,closeButtonImage.size.width,closeButtonImage.size.height);
    
    if(CGRectContainsPoint(tempRect, point))
        return YES;
    else
        return NO;
}

/* Override setter method for imageFileNames so that when they are set the images can be preloaded.
 * This is important so that the images aren't loaded everytime drawRect is called.
 */
- (void) setImages:(NSArray *)imageFileNames{
    images = [[NSMutableArray alloc] init];
    // Preload all the images.
    for (int i = 0; i < [imageFileNames count]; i++) {
        [images addObject:[UIImage imageNamed:[imageFileNames objectAtIndex:i]]];
    }
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
