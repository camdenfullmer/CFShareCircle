//
//  CFShareCircleView.m
//  CFShareCircle
//
//  Created by Camden on 12/18/12.
//  Copyright (c) 2012 Camden. All rights reserved.
//

#import "CFShareCircleView.h"
#import "CFSharer.h"

@implementation CFShareCircleView{
    CGPoint _currentPosition, _origin;
    BOOL _dragging, _visible;
    UIDeviceOrientation _currentOrientation;
    CALayer *_closeButtonLayer;
    CAShapeLayer *_backgroundLayer, *_touchLayer;
    CATextLayer *_introTextLayer, *_shareTitleLayer;
    NSMutableArray *_imageLayers, *_imageColors, *_sharers;
}

@synthesize delegate = _delegate;

- (id)init {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 480)];
    if (self) {
        [self initialize:[[NSArray alloc] initWithObjects: @"Evernote", @"Facebook", @"Google+", @"Twitter", @"Flickr", @"Mail", @"Message", @"Photo Album", nil]];
        [self setUpLayers];
        [self setViewFrame];
    }
    return self;
}

- (id)initWithSharers:(NSArray *)someSharers {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 480)];
    if (self) {
        [self initialize:someSharers];
        [self setUpLayers];
        [self setViewFrame];
    }
    return self;
}

/* Set all the default values for the share circle. */
- (void)initialize:(NSArray *)someSharers {
    
    // Setup all the sharer objects.
    _sharers = [[NSMutableArray alloc] init];
    for(int i = 0; i<[someSharers count]; i++)
        [_sharers addObject:[[CFSharer alloc] initWithName:[someSharers objectAtIndex:i]]];
    
    _imageLayers = [[NSMutableArray alloc] init];
    _imageColors = [[NSMutableArray alloc] init];
    
    self.hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    self.bounds = CGRectMake(0, 0, 320,480);
    _origin = CGPointMake(160, 240);
    _currentPosition = _origin;
    _visible = NO;
    _currentOrientation = [[UIDevice currentDevice] orientation];
    
    // Set up observer for orientation changes.
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
}

/**
 Build all the layers to be displayed onto the view of the share circle.
 */
- (void)setUpLayers {
    
    // Create a larger circle layer for the background of the Share Circle.
    _backgroundLayer = [CAShapeLayer layer];
    _backgroundLayer.bounds = self.bounds;
    _backgroundLayer.masksToBounds = NO;
    _backgroundLayer.shadowRadius = 10;
    _backgroundLayer.shadowOpacity = 0.5;
    _backgroundLayer.shadowOffset = CGSizeMake(0,0);
    _backgroundLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _backgroundLayer.fillColor = [[UIColor whiteColor] CGColor];
    CGMutablePathRef backgroundPath = CGPathCreateMutable();
    CGRect backgroundRect = CGRectMake(_origin.x - BACKGROUND_SIZE/2,_origin.y - BACKGROUND_SIZE/2,BACKGROUND_SIZE,BACKGROUND_SIZE);
    CGPathAddEllipseInRect(backgroundPath, nil, backgroundRect);
    _backgroundLayer.path = backgroundPath;
    [self.layer addSublayer:_backgroundLayer];
    
    // Create the layers for all the sharing service images.
    for(int i = 0; i < _sharers.count; i++) {
        CFSharer *sharer = [_sharers objectAtIndex:i];
        
        UIImage *image = [sharer mainImage];
        
        //Add major color to the array to display later.
        [_imageColors addObject:[self colorAtPoint:CGPointMake(3, 25) inImage:image]];
        // Construct the base layer in which will be rotated around the origin of the circle.
        CAShapeLayer *baseLayer = [CAShapeLayer layer];
        baseLayer.bounds = CGRectMake(0,0, BACKGROUND_SIZE,BACKGROUND_SIZE);
        baseLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        // Construct the image layer which will contain our image.
        CALayer *imageLayer = [CALayer layer];
        imageLayer.bounds = CGRectMake(0, 0, TEMP_SIZE, TEMP_SIZE);
        imageLayer.position = CGPointMake(BACKGROUND_SIZE/2.0 + PATH_SIZE/2.0, BACKGROUND_SIZE/2.0);
        imageLayer.contents = (id)image.CGImage;
        // Add all the layers
        [baseLayer addSublayer:imageLayer];
        [_imageLayers addObject:baseLayer];
        [self.layer addSublayer:[_imageLayers objectAtIndex:i]];
    }
    
    // Create the touch layer for the Share Circle.
    _touchLayer = [CAShapeLayer layer];
    _touchLayer.bounds = self.bounds;
    _touchLayer.frame = CGRectMake(0, 0, TOUCH_SIZE, TOUCH_SIZE);
    CGMutablePathRef circularPath = CGPathCreateMutable();
    CGPathAddEllipseInRect(circularPath, NULL, CGRectMake(0, 0, TOUCH_SIZE, TOUCH_SIZE));
    _touchLayer.path = circularPath;
    _touchLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _touchLayer.opacity = 0.1;
    _touchLayer.fillColor = [UIColor clearColor].CGColor;
    _touchLayer.strokeColor = [UIColor blackColor].CGColor;
    _touchLayer.lineWidth = 3;
    [self.layer addSublayer:_touchLayer];
    
    // Create the intro text layer to help the user.
    _introTextLayer = [CATextLayer layer];
    _introTextLayer.string = @"Drag and Share";
    _introTextLayer.wrapped = YES;
    _introTextLayer.alignmentMode = kCAAlignmentCenter;
    _introTextLayer.fontSize = 13.0;
    _introTextLayer.bounds = self.bounds;
    _introTextLayer.foregroundColor = [UIColor blackColor].CGColor;
    _introTextLayer.frame = CGRectMake(0, 0, 60, 29);
    _introTextLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _introTextLayer.contentsScale = [[UIScreen mainScreen] scale];
    _introTextLayer.opacity = 0.5;
    [self.layer addSublayer:_introTextLayer];
    
    // Create the share title text layer.
    _shareTitleLayer = [CATextLayer layer];
    _shareTitleLayer.string = @"";
    _shareTitleLayer.wrapped = YES;
    _shareTitleLayer.alignmentMode = kCAAlignmentCenter;
    _shareTitleLayer.fontSize = 20.0;
    _shareTitleLayer.bounds = self.bounds;
    _shareTitleLayer.foregroundColor = [UIColor blackColor].CGColor;
    _shareTitleLayer.frame = CGRectMake(0, 0, 120, 28);
    _shareTitleLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _shareTitleLayer.contentsScale = [[UIScreen mainScreen] scale];
    _shareTitleLayer.opacity = 0.0;
    [self.layer addSublayer:_shareTitleLayer];
    
    // BLURRING IMAGE SAMPLE CODE
    /*CIImage *inputImage = [[CIImage alloc] initWithImage:[UIImage imageNamed:@"evernote.png"]];
    
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setDefaults];
    [blurFilter setValue: inputImage forKey: @"inputImage"];
    [blurFilter setValue: [NSNumber numberWithFloat:10.0f]
                  forKey:@"inputRadius"];
    
    
    CIImage *outputImage = [blurFilter valueForKey: @"outputImage"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    backgroundLayer.contents = (id)[UIImage imageWithCGImage:[context createCGImage:outputImage fromRect:outputImage.extent]].CGImage;*/
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
    _currentPosition = [touch locationInView:self];
    
    // Make sure the user starts with touch inside the circle and not in the close button.
    if([self circleEnclosesPoint: _currentPosition]){
        _dragging = YES;
        [self updateLayers];
    } else{
        [self animateOut];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
    _currentPosition = [touch locationInView:self];
    
    if(_dragging){
        [self updateLayers];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
    _currentPosition = [touch locationInView:self];
    
    if(_dragging){
        // Loop through all the rects to see if the user selected one.
        for(int i = 0; i < [_sharers count]; i++){
            CGPoint point = [self pointAtIndex:i];
            // Determine if point is inside rect or also account for overshooting circle so just swiping works.
            if(CGRectContainsPoint(CGRectMake(point.x, point.y, TEMP_SIZE, TEMP_SIZE), _currentPosition) || CGRectContainsPoint(CGRectMake(point.x, point.y, TEMP_SIZE, TEMP_SIZE), [self touchLocationAtPoint:_currentPosition])){
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

- (void)animateIn {
    _visible = YES;
    self.hidden = NO;
    _introTextLayer.opacity = 0.5;
    
    [UIView animateWithDuration: 0.2
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self setViewFrame];
                     }
                     completion:^(BOOL finished){
                         [self animateImagesIn];
                     }];
}

- (void)animateOut {
    _visible = NO;
    [self animateImagesOut];
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

/**
 Updates all the layers based on the new current position of the touch input.
 */
- (void)updateLayers {
    // Update the touch layer.
    [CATransaction begin];
    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    // Update the position of the touch layer.
    _touchLayer.position = [self touchLocationAtPoint:_currentPosition];
    [CATransaction commit];
    
    int hoveringIndex = [self indexHoveringOver];
    
    // Update the images.
    for(int i = 0; i < [_imageLayers count]; i++){
        CALayer *layer = [_imageLayers objectAtIndex:i];
        if(i == hoveringIndex || !_dragging)
            layer.opacity = 1.0;
        else
            layer.opacity = 0.6;
    }
    
    // Update the touch layer.
    if(hoveringIndex != -1){
        // Update color of touch layer.
        UIColor *newColor = (UIColor *)[_imageColors objectAtIndex:hoveringIndex];
        _touchLayer.strokeColor = newColor.CGColor;
        _touchLayer.opacity = 1.0;
    } else if(_dragging){
        _touchLayer.strokeColor = [UIColor blackColor].CGColor;
        _touchLayer.opacity = 0.5;
    } else {
        _touchLayer.opacity = 0.1;
        _touchLayer.strokeColor = [UIColor blackColor].CGColor;
    }
    
    // Update the intro text layer.
    if(_dragging)
        _introTextLayer.opacity = 0.0;
    else
        _introTextLayer.opacity = 0.6;
    
    // Update the share title text layer
    int index = [self indexHoveringOver];
    if(index != -1){
        CFSharer *sharer = [_sharers objectAtIndex:index];
        if([sharer titleImage]){
            _shareTitleLayer.contents = (id)[sharer titleImage].CGImage;
            _shareTitleLayer.opacity = 1.0;
        }else{
            _shareTitleLayer.string = [sharer name];
            _shareTitleLayer.opacity = 0.6;
        }
    }else{
        _shareTitleLayer.opacity = 0.0;
        _shareTitleLayer.string = @"";
    }
}

/* Animation used when the view is first presented to the user. */
- (void)animateImagesIn {
    for(int i = 0; i < _sharers.count; i++) {
        // Animate the base layer for the main rotation.
        CALayer* layer = [_imageLayers objectAtIndex:i];
        layer.transform = CATransform3DMakeRotation(-i/([_sharers count]/2.0)*M_PI, 0, 0, 1);
        layer.opacity = 1.0;
        
        // Animate the iamge layer to get the correct orientation.
        CALayer* sub = [layer.sublayers objectAtIndex:0];
        sub.transform = CATransform3DMakeRotation(i/([_sharers count]/2.0)*M_PI, 0, 0, 1);
    }
}

/* Animation used to reset the images so the animation in works correctly. */
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

/**
 Return the index that the user is hovering over at this exact moment in time.
 */
- (int)indexHoveringOver {
    if(_dragging){
        for(int i = 0; i < [_sharers count]; i++){
            CGPoint point = [self pointAtIndex:i];
            // Determine if point is inside rect or adjust for the user overshooting sharing service.
            if(CGRectContainsPoint(CGRectMake(point.x, point.y, TEMP_SIZE, TEMP_SIZE), _currentPosition) || CGRectContainsPoint(CGRectMake(point.x, point.y, TEMP_SIZE, TEMP_SIZE), [self touchLocationAtPoint:_currentPosition]))
                return i;
        }
    }
    return -1;
}

/* Determines where the touch images is going to be placed inside of the view. */
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

/* Get the point at the specified index. */
- (CGPoint)pointAtIndex:(int)index {
    // Number for trig.
    float trig = index/([_sharers count]/2.0)*M_PI;
    
    // Calculate the x and y coordinate.
    // Points go around the unit circle starting at pi = 0.
    float x = _origin.x + cosf(trig)*PATH_SIZE/2.0;
    float y = _origin.y - sinf(trig)*PATH_SIZE/2.0;
    
    // Subtract half width and height of image size.
    x -= TEMP_SIZE/2.0;
    y -= TEMP_SIZE/2.0;
    
    return CGPointMake(x, y);
}

/**
 Returns if the point is inside the cirlce.
 */
- (BOOL) circleEnclosesPoint: (CGPoint) point{
    if(pow(BACKGROUND_SIZE/2.0,2) < (pow(point.x - _origin.x,2) + pow(point.y - _origin.y,2)))
        return NO;
    else
        return YES;
}

/**
 Return the color at the specified point in an image.
 */
- (UIColor *)colorAtPoint:(CGPoint)point inImage:(UIImage *)image {
    CGImageRef cgImage = CGImageCreateWithImageInRect(image.CGImage,
                                                      CGRectMake(point.x * image.scale,
                                                                 point.y * image.scale,
                                                                 1.0f,
                                                                 1.0f));
    CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
    CFDataRef data = CGDataProviderCopyData(provider);
    CGImageRelease(cgImage);
    UInt8* buffer = (UInt8*)CFDataGetBytePtr(data);
    CGFloat red   = (float)buffer[0] / 255.0f;
    CGFloat green = (float)buffer[1] / 255.0f;
    CGFloat blue  = (float)buffer[2] / 255.0f;
    CGFloat alpha = (float)buffer[3] / 255.0f;
    CFRelease(data);
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/* Determine the frame that the view is to use based on orientation. */
- (void)setViewFrame{
    
    if(UIDeviceOrientationIsPortrait(_currentOrientation)){
        [self setFrame:CGRectMake(320*!_visible, 0, 320, 480)];
        [self setBounds:CGRectMake(0, 0, 320, 480)];
        _origin = CGPointMake(160, 240);
        _currentPosition = _origin;
    }else if(UIDeviceOrientationIsLandscape(_currentOrientation)){
        [self setFrame:CGRectMake(480*!_visible, 0, 480, 320)];
        [self setBounds:CGRectMake(0, 0, 480, 320)];
        _origin = CGPointMake(240, 160);
        _currentPosition = _origin;
    }
    
    // Update all the layers positions.
    _backgroundLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _introTextLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _shareTitleLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self updateLayers];
    for(int i = 0; i < _sharers.count; i++) {
        CALayer* layer = [_imageLayers objectAtIndex:i];
        layer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    //Obtaining the current device orientation
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    //Ignoring specific orientations
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown || _currentOrientation == orientation) {
        return;
    }
    
    if ((UIDeviceOrientationIsPortrait(_currentOrientation) && UIDeviceOrientationIsPortrait(orientation)) ||
        (UIDeviceOrientationIsLandscape(_currentOrientation) && UIDeviceOrientationIsLandscape(orientation))) {
        //still saving the current orientation
        _currentOrientation = orientation;
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(relayoutLayers) object:nil];
    //Responding only to changes in landscape or portrait
    _currentOrientation = orientation;
    //
    [self performSelector:@selector(setViewFrame) withObject:nil afterDelay:0];
}

@end