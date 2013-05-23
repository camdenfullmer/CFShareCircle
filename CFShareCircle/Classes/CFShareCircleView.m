//
//  CFShareCircleView.m
//  CFShareCircle
//
//  Created by Camden on 12/18/12.
//  Copyright (c) 2012 Camden. All rights reserved.
//

#import "CFShareCircleView.h"
#import "CFSharer.h"

@interface CFShareCircleView()
- (void)setUpLayers; /* Build all the layers to be displayed onto the view of the share circle. */
- (void)updateLayers; /* Updates all the layers based on the new current position of the touch input. */
- (void)animateImagesIn; /* Animation used when the view is first presented to the user. */
- (void)animateImagesOut; /* Animation used to reset the images so the animation in works correctly. */
- (int)indexHoveringOver; /* Return the index that the user is hovering over at this exact moment in time. */
- (CGPoint)touchLocationAtPoint:(CGPoint)point; /* Determines where the touch images is going to be placed inside of the view. */
- (CGPoint)pointAtIndex:(int)index; /* Get the point at the specified index. */
- (BOOL)circleEnclosesPoint:(CGPoint)point; /* Returns if the point is inside the cirlce. */
@end

@implementation CFShareCircleView{
    CGPoint _currentPosition, _origin;
    BOOL _dragging, _readyForUser;
    CALayer *_closeButtonLayer, *_overlayLayer;
    CAShapeLayer *_backgroundLayer, *_touchLayer;
    CATextLayer *_introTextLayer, *_shareTitleLayer;
    NSMutableArray *_imageLayers, *_sharers;
}

#define BACKGROUND_SIZE 275
#define PATH_SIZE 200
#define IMAGE_SIZE 45
#define TOUCH_SIZE 70

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _sharers = [[NSMutableArray alloc] initWithObjects: [[CFSharer alloc] initWithType:CFSharerTypePinterest], [[CFSharer alloc] initWithType:CFSharerTypeGoogleDrive], [[CFSharer alloc] initWithType:CFSharerTypeTwitter ], [[CFSharer alloc] initWithType:CFSharerTypeFacebook], [[CFSharer alloc] initWithType:CFSharerTypeEvernote], [[CFSharer alloc] initWithType:CFSharerTypeDropbox], nil];
        [self setUpLayers];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame sharers:(NSArray *)sharers {
    self = [super initWithFrame:frame];
    if (self) {
        _sharers = [[NSMutableArray alloc] initWithArray:sharers];
        [self setUpLayers];
    }
    return self;
}

- (void)layoutSubviews {
    // Adjust geometry when updating the subviews.
    _overlayLayer.frame = self.bounds;
    _origin = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _currentPosition = _origin;
    if(_readyForUser) {
        _backgroundLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    } else {
        _backgroundLayer.position = CGPointMake(self.bounds.size.width + BACKGROUND_SIZE/2.0, CGRectGetMidY(self.bounds));
    }
    [self updateLayers];
}

#pragma mark - Private methods

- (void)setUpLayers {
    // Set all the defaults for the circle.
    _imageLayers = [[NSMutableArray alloc] init];
    self.hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _readyForUser = NO;
    _origin = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _currentPosition = _origin;
    
    // Create the overlay layer for the entire screen.
    _overlayLayer = [CAShapeLayer layer];
    _overlayLayer.frame = self.bounds;
    _overlayLayer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8].CGColor;
    [self.layer addSublayer:_overlayLayer];
    
    // Create a larger circle layer for the background of the Share Circle.
    _backgroundLayer = [CAShapeLayer layer];
    _backgroundLayer.frame = CGRectMake(CGRectGetMidX(self.bounds) - BACKGROUND_SIZE/2.0, CGRectGetMidY(self.bounds) - BACKGROUND_SIZE/2.0, BACKGROUND_SIZE, BACKGROUND_SIZE);
    _backgroundLayer.position = CGPointMake(self.bounds.size.width + BACKGROUND_SIZE/2.0, CGRectGetMidY(self.bounds));
    _backgroundLayer.fillColor = [[UIColor whiteColor] CGColor];
    CGMutablePathRef backgroundPath = CGPathCreateMutable();
    CGRect backgroundRect = CGRectMake(0,0,BACKGROUND_SIZE,BACKGROUND_SIZE);
    CGPathAddEllipseInRect(backgroundPath, nil, backgroundRect);
    _backgroundLayer.path = backgroundPath;
    [self.layer addSublayer:_backgroundLayer];
    
    // Create the layers for all the sharing service images.
    for(int i = 0; i < _sharers.count; i++) {
        CFSharer *sharer = [_sharers objectAtIndex:i];
        UIImage *image = [sharer image];
        
        // Construct the base layer in which will be rotated around the origin of the circle.
        CAShapeLayer *baseLayer = [CAShapeLayer layer];
        baseLayer.frame = CGRectMake(0,0, BACKGROUND_SIZE,BACKGROUND_SIZE);
        baseLayer.position = CGPointMake(CGRectGetMidX(_backgroundLayer.bounds), CGRectGetMidY(_backgroundLayer.bounds));
        
        // Construct the image layer which will contain our image.
        CALayer *imageLayer = [CALayer layer];
        imageLayer.frame = CGRectMake(0, 0, IMAGE_SIZE, IMAGE_SIZE);
        imageLayer.position = CGPointMake(BACKGROUND_SIZE/2.0 + PATH_SIZE/2.0, BACKGROUND_SIZE/2.0);
        imageLayer.contents = (id)image.CGImage;
        imageLayer.shadowColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:213.0/255.0 alpha:1.0].CGColor;
        imageLayer.shadowOffset = CGSizeMake(1, 1);
        imageLayer.shadowRadius = 0;
        imageLayer.shadowOpacity = 1.0; 
        
        // Add all the layers
        [baseLayer addSublayer:imageLayer];
        [_imageLayers addObject:baseLayer];
        [_backgroundLayer addSublayer:[_imageLayers objectAtIndex:i]];
    }
    
    // Create the touch layer for the Share Circle.
    _touchLayer = [CAShapeLayer layer];
    _touchLayer.frame = CGRectMake(0, 0, TOUCH_SIZE, TOUCH_SIZE);
    CGMutablePathRef circularPath = CGPathCreateMutable();
    CGPathAddEllipseInRect(circularPath, NULL, CGRectMake(0, 0, TOUCH_SIZE, TOUCH_SIZE));
    _touchLayer.path = circularPath;
    _touchLayer.position = CGPointMake(CGRectGetMidX(_backgroundLayer.bounds), CGRectGetMidY(_backgroundLayer.bounds));
    _touchLayer.opacity = 0.0;
    _touchLayer.fillColor = [UIColor clearColor].CGColor;
    _touchLayer.strokeColor = [UIColor blackColor].CGColor;
    _touchLayer.lineWidth = 2.0f;
    [self.layer addSublayer:_touchLayer];
    
    // Create the intro text layer to help the user.
    _introTextLayer = [CATextLayer layer];
    _introTextLayer.string = @"Drag to\nShare";
    _introTextLayer.wrapped = YES;
    _introTextLayer.alignmentMode = kCAAlignmentCenter;
    _introTextLayer.fontSize = 14.0;
    _introTextLayer.font = CFBridgingRetain([UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f].fontName);
    _introTextLayer.foregroundColor = [UIColor blackColor].CGColor;
    _introTextLayer.frame = CGRectMake(0, 0, 60, 31);
    _introTextLayer.position = CGPointMake(CGRectGetMidX(_backgroundLayer.bounds), CGRectGetMidY(_backgroundLayer.bounds));
    _introTextLayer.contentsScale = [[UIScreen mainScreen] scale];
    _introTextLayer.opacity = 0.0;
    [_backgroundLayer addSublayer:_introTextLayer];
    
    // Create the share title text layer.
    _shareTitleLayer = [CATextLayer layer];
    _shareTitleLayer.string = @"";
    _shareTitleLayer.wrapped = YES;
    _shareTitleLayer.alignmentMode = kCAAlignmentCenter;
    _shareTitleLayer.fontSize = 20.0;
    _shareTitleLayer.font = CFBridgingRetain([UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f].fontName);
    _shareTitleLayer.foregroundColor = [UIColor blackColor].CGColor;
    _shareTitleLayer.frame = CGRectMake(0, 0, 120, 28);
    _shareTitleLayer.position = CGPointMake(CGRectGetMidX(_backgroundLayer.bounds), CGRectGetMidY(_backgroundLayer.bounds));
    _shareTitleLayer.contentsScale = [[UIScreen mainScreen] scale];
    _shareTitleLayer.opacity = 0.0;
    [_backgroundLayer addSublayer:_shareTitleLayer];
}

- (void)updateLayers {
    // Only update if the circle is presented to the user.
    if(_readyForUser) {
        
        int hoveringIndex = [self indexHoveringOver];
        
        // Update the touch layer without waiting for an animation.
        [CATransaction begin];
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
        _touchLayer.position = [self touchLocationAtPoint:_currentPosition];
        [CATransaction commit];
        
        // Update the images.
        for(int i = 0; i < [_imageLayers count]; i++) {
            CALayer *layer = [_imageLayers objectAtIndex:i];
            if(i == hoveringIndex || !_dragging) {
                layer.opacity = 1.0;
            } else {
                layer.opacity = 0.6;
            }
        }
        
        // Update the touch layer.
        if(hoveringIndex != -1) {
            _touchLayer.opacity = 1.0;
        } else if(_dragging) {
            _touchLayer.opacity = 0.5;
        } else {
            _touchLayer.opacity = 0.1;
        }
        _touchLayer.strokeColor = [UIColor blackColor].CGColor;
        
        // Update the intro text layer.
        if(_dragging) {
            _introTextLayer.opacity = 0.0;
        } else {
            _introTextLayer.opacity = 0.6;
        }
            
        // Update the share title text layer
        if(hoveringIndex != -1) {
            CFSharer *sharer = [_sharers objectAtIndex:hoveringIndex];
            _shareTitleLayer.string = [sharer name];
            _shareTitleLayer.opacity = 0.6;
        } else {
            _shareTitleLayer.opacity = 0.0;
            _shareTitleLayer.string = @"";
        }
    } else {
        // Hide all the layers if the they are not presented to the user.
        [CATransaction begin];
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
        _touchLayer.opacity = 0.0;
        _introTextLayer.opacity = 0.0;
        _shareTitleLayer.opacity = 0.0;
        [CATransaction commit];
    }
}

- (void)animateImagesIn {
    for(int i = 0; i < _sharers.count; i++) {
        // Animate the base layer for the main rotation.
        CALayer* layer = [_imageLayers objectAtIndex:i];
        layer.transform = CATransform3DMakeRotation(-i/([_sharers count]/2.0)*M_PI, 0, 0, 1);
        layer.opacity = 1.0;
        
        // Animate the image layer to get the correct orientation.
        CALayer* sub = [layer.sublayers objectAtIndex:0];
        sub.transform = CATransform3DMakeRotation(i/([_sharers count]/2.0)*M_PI, 0, 0, 1);
    }
}

- (void)animateImagesOut {
    for(int i = 0; i < _sharers.count; i++) {
        // Animate the base layer for the main rotation.
        CALayer* layer = [_imageLayers objectAtIndex:i];
        layer.transform = CATransform3DMakeRotation(0, 0, 0, 1);
        
        // Animate the iamge layer to get the correct orientation.
        CALayer* sub = [layer.sublayers objectAtIndex:0];
        sub.transform = CATransform3DMakeRotation(0, 0, 0, 1);
    }
}

- (int)indexHoveringOver {
    if(_dragging){
        for(int i = 0; i < [_sharers count]; i++){
            CGPoint point = [self pointAtIndex:i];
            // Determine if point is inside rect or adjust for the user overshooting sharing service.
            if(CGRectContainsPoint(CGRectMake(point.x, point.y, IMAGE_SIZE, IMAGE_SIZE), _currentPosition) || CGRectContainsPoint(CGRectMake(point.x, point.y, IMAGE_SIZE, IMAGE_SIZE), [self touchLocationAtPoint:_currentPosition]))
                return i;
        }
    }
    return -1;
}

- (CGPoint)touchLocationAtPoint:(CGPoint)point {
    
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

- (CGPoint)pointAtIndex:(int)index {
    // Calculate the x and y coordinate.
    // Points go around the unit circle starting at pi = 0.
    float trig = index/([_sharers count]/2.0)*M_PI;
    float x = _origin.x + cosf(trig)*PATH_SIZE/2.0;
    float y = _origin.y - sinf(trig)*PATH_SIZE/2.0;
    
    // Subtract half width and height of image size.
    x -= IMAGE_SIZE/2.0;
    y -= IMAGE_SIZE/2.0;
    
    return CGPointMake(x, y);
}

- (BOOL)circleEnclosesPoint:(CGPoint)point {
    if(pow(BACKGROUND_SIZE/2.0,2) < (pow(point.x - _origin.x,2) + pow(point.y - _origin.y,2)))
        return NO;
    else
        return YES;
}

#pragma mark - Animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if([[anim valueForKey:@"id"] isEqual:@"animateOut"]) {
        _backgroundLayer.position = CGPointMake(self.bounds.size.width + BACKGROUND_SIZE/2.0, CGRectGetMidY(self.bounds)); // Needed for Core Animation fix??
        self.hidden = YES;
    } else if([[anim valueForKey:@"id"] isEqual:@"animateIn"]) {
        _backgroundLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)); // Needed for Core Animation fix??
        _readyForUser = YES;
        [self updateLayers];
    }
}

#pragma mark - Touch delegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
    _currentPosition = [touch locationInView:self];
    
    // Make sure the user starts with touch inside the circle.
    if([self circleEnclosesPoint: _currentPosition]) {
        _dragging = YES;
        [self updateLayers];
    } else {
        [self animateOut];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
    _currentPosition = [touch locationInView:self];
    
    if(_dragging) [self updateLayers];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
    _currentPosition = [touch locationInView:self];
    
    if(_dragging){
        // Loop through all the rects to see if the user selected one.
        for(int i = 0; i < [_sharers count]; i++){
            CGPoint point = [self pointAtIndex:i];
            // Determine if point is inside rect or also account for overshooting circle so just swiping works.
            if(CGRectContainsPoint(CGRectMake(point.x, point.y, IMAGE_SIZE, IMAGE_SIZE), _currentPosition) || CGRectContainsPoint(CGRectMake(point.x, point.y, IMAGE_SIZE, IMAGE_SIZE), [self touchLocationAtPoint:_currentPosition])){
                [_delegate shareCircleView:self didSelectIndex:i];
                [self animateOut];
            }
        }
    }
    
    _currentPosition = _origin;
    _dragging = NO;
    [self updateLayers];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // Reset location.
    _currentPosition = _origin;
    _dragging = NO;
}

#pragma mark - Public methods

- (void)animateIn {
    self.hidden = NO;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setValue:@"animateIn" forKey:@"id"];
    animation.fromValue = [NSValue valueWithCGPoint:_backgroundLayer.position];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];
    animation.duration = 0.3;
    animation.delegate = self;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [_backgroundLayer addAnimation:animation forKey:@"position"];    
    [self animateImagesIn];
}

- (void)animateOut {
    _readyForUser = NO;
    [self updateLayers];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setValue:@"animateOut" forKey:@"id"];
    animation.fromValue = [NSValue valueWithCGPoint:_backgroundLayer.position];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.bounds.size.width + BACKGROUND_SIZE/2.0, CGRectGetMidY(self.bounds))];
    animation.duration = 0.3;
    animation.delegate = self;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [_backgroundLayer addAnimation:animation forKey:@"position"];    
    [self animateImagesOut];
}

@end