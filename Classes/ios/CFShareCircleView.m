//
//  CFShareCircleView.m
//  CFShareCircle
//
//  Created by Camden on 12/18/12.
//  Copyright (c) 2012 Camden. All rights reserved.
//

#import "CFShareCircleView.h"

@interface CFShareCircleView()
- (void)setUpCircleLayers; /* Build all the layers to be displayed onto the view of the share circle. */
- (void)setUpSharingOptionsView; /* Build the view to show all the sharers when there is too many for the circle. */
- (void)updateLayers; /* Updates all the layers based on the new current position of the touch input. */
- (void)showMoreOptions; /* Animates the table view in to show all the sharer options. */
- (void)hideMoreOptions; /* Hides the table view with all the sharers. */
- (CALayer *)sharerLayerBeingTouched; /* Returns the sharer currently being touched. */
- (CGPoint)touchLocationAtPoint:(CGPoint)point; /* Determines where the touch images is going to be placed inside of the view. */
- (BOOL)circleEnclosesPoint:(CGPoint)point; /* Returns if the point is inside the cirlce. */
- (UIImage *)whiteOverlayedImage:(UIImage*)image;
- (NSUInteger)numberOfSharersInCircle; /* Determine the number of sharers in the circle. If it is more then the max then let's insert the more sharer into the array. */
@end

@implementation CFShareCircleView{
    CGPoint _currentPosition, _origin;
    BOOL _dragging, _circleIsVisible, _sharingOptionsIsVisible;
    CALayer *_closeButtonLayer, *_overlayLayer;
    CAShapeLayer *_backgroundLayer, *_touchLayer;
    CATextLayer *_introTextLayer, *_shareTitleLayer;
    NSMutableArray *_sharers, *_sharerLayers;
    UIView *_sharingOptionsView;
}

#define CIRCLE_SIZE 275
#define PATH_SIZE 200
#define IMAGE_SIZE 45
#define TOUCH_SIZE 70
#define MAX_VISIBLE_SHARERS 6

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _sharers = [[NSMutableArray alloc] initWithObjects: [CFSharer pinterest], [CFSharer dropbox], [CFSharer mail], [CFSharer cameraRoll], nil];
        [self setUpCircleLayers];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame sharers:(NSArray *)sharers {
    self = [super initWithFrame:frame];
    if (self) {
        _sharers = [[NSMutableArray alloc] initWithArray:sharers];
        [self setUpCircleLayers];
    }
    return self;
}

- (void)layoutSubviews {
    // Adjust geometry when updating the subviews.
    _overlayLayer.frame = self.bounds;
    _origin = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _currentPosition = _origin;
    if(_circleIsVisible) {
        _backgroundLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    } else {
        _backgroundLayer.position = CGPointMake(self.bounds.size.width + CIRCLE_SIZE/2.0, CGRectGetMidY(self.bounds));
    }
    if(_sharingOptionsIsVisible)
        _sharingOptionsView.frame = self.bounds;
    [self updateLayers];
}

#pragma mark -
#pragma mark - Private methods

- (NSUInteger)numberOfSharersInCircle {
    if(_sharers.count > MAX_VISIBLE_SHARERS) {
        return MAX_VISIBLE_SHARERS;
    } else {
        return _sharers.count;
    }
}

- (void)setUpCircleLayers {
    // Set all the defaults for the share circle.
    _sharerLayers = [[NSMutableArray alloc] init];
    self.hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _circleIsVisible = NO;
    _sharingOptionsIsVisible = NO;
    _origin = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _currentPosition = _origin;
    
    // Create the CGFont that is to be used on the layers.
    NSString *fontName = @"HelveticaNeue-Light";
    CFStringRef cfFontName = (CFStringRef)CFBridgingRetain(fontName);
    CGFontRef font = CGFontCreateWithFontName(cfFontName);
    CFRelease(cfFontName);
    
    // Create the overlay layer for the entire screen.
    _overlayLayer = [CAShapeLayer layer];
    _overlayLayer.frame = self.bounds;
    _overlayLayer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8].CGColor;
    [self.layer addSublayer:_overlayLayer];
    
    // Create a larger circle layer for the background of the Share Circle.
    _backgroundLayer = [CAShapeLayer layer];
    _backgroundLayer.frame = CGRectMake(CGRectGetMidX(self.bounds) - CIRCLE_SIZE/2.0, CGRectGetMidY(self.bounds) - CIRCLE_SIZE/2.0, CIRCLE_SIZE, CIRCLE_SIZE);
    _backgroundLayer.position = CGPointMake(self.bounds.size.width + CIRCLE_SIZE/2.0, CGRectGetMidY(self.bounds));
    _backgroundLayer.fillColor = [[UIColor whiteColor] CGColor];
    CGMutablePathRef backgroundPath = CGPathCreateMutable();
    CGRect backgroundRect = CGRectMake(0,0,CIRCLE_SIZE,CIRCLE_SIZE);
    CGPathAddEllipseInRect(backgroundPath, nil, backgroundRect);
    _backgroundLayer.path = backgroundPath;
    CGPathRelease(backgroundPath);
    [self.layer addSublayer:_backgroundLayer];
    
    // Create the layers for all the sharing service images.
    for(int i = 0; i < [self numberOfSharersInCircle]; i++) {
        CFSharer *sharer;
        if(i == 5 && _sharers.count > 6)
            sharer = [[CFSharer alloc] initWithName:@"More" imageName:@"more.png"];
        else
            sharer = [_sharers objectAtIndex:i];
        UIImage *image = sharer.image;
        
        // Construct the image layer which will contain our image.
        CALayer *imageLayer = [CALayer layer];
        imageLayer.bounds = CGRectMake(0, 0, IMAGE_SIZE+30, IMAGE_SIZE+30);
        imageLayer.frame = CGRectMake(0, 0, IMAGE_SIZE, IMAGE_SIZE);

        // Calculate the x and y coordinate. Points go around the unit circle starting at pi = 0.
        float trig = i/([self numberOfSharersInCircle]/2.0)*M_PI;
        float x = CIRCLE_SIZE/2.0 + cosf(trig)*PATH_SIZE/2.0;
        float y = CIRCLE_SIZE/2.0 - sinf(trig)*PATH_SIZE/2.0;
        imageLayer.position = CGPointMake(x, y);
        imageLayer.contents = (id)image.CGImage;
        imageLayer.shadowColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:213.0/255.0 alpha:1.0].CGColor;
        imageLayer.shadowOffset = CGSizeMake(1, 1);
        imageLayer.shadowRadius = 0;
        imageLayer.shadowOpacity = 1.0;
        imageLayer.name = sharer.name;        
        [_sharerLayers addObject:imageLayer];
        [_backgroundLayer addSublayer:[_sharerLayers objectAtIndex:i]];
    }
    
    // Create the touch layer for the Share Circle.
    _touchLayer = [CAShapeLayer layer];
    _touchLayer.frame = CGRectMake(0, 0, TOUCH_SIZE, TOUCH_SIZE);
    CGMutablePathRef circularPath = CGPathCreateMutable();
    CGPathAddEllipseInRect(circularPath, NULL, CGRectMake(0, 0, TOUCH_SIZE, TOUCH_SIZE));
    _touchLayer.path = circularPath;
    CGPathRelease(circularPath);
    _touchLayer.position = CGPointMake(CGRectGetMidX(_backgroundLayer.bounds), CGRectGetMidY(_backgroundLayer.bounds));
    _touchLayer.opacity = 0.0;
    _touchLayer.fillColor = [UIColor clearColor].CGColor;
    _touchLayer.strokeColor = [UIColor blackColor].CGColor;
    _touchLayer.lineWidth = 2.0f;
    [_backgroundLayer addSublayer:_touchLayer];
    
    // Create the intro text layer to help the user.
    _introTextLayer = [CATextLayer layer];
    _introTextLayer.string = @"Drag to\nShare";
    _introTextLayer.wrapped = YES;
    _introTextLayer.alignmentMode = kCAAlignmentCenter;
    _introTextLayer.fontSize = 14.0;
    _introTextLayer.font = font;
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
    _shareTitleLayer.font = font;
    _shareTitleLayer.foregroundColor = [[UIColor blackColor] CGColor];
    _shareTitleLayer.frame = CGRectMake(0, 0, 120, 28);
    _shareTitleLayer.position = CGPointMake(CGRectGetMidX(_backgroundLayer.bounds), CGRectGetMidY(_backgroundLayer.bounds));
    _shareTitleLayer.contentsScale = [[UIScreen mainScreen] scale];
    _shareTitleLayer.opacity = 0.0;
    [_backgroundLayer addSublayer:_shareTitleLayer];
    
    // Create the sharing options view if we need it.
    if(_sharers.count > MAX_VISIBLE_SHARERS)
        [self setUpSharingOptionsView];
    
    // Release the font.
    CGFontRelease(font);
}

- (void)setUpSharingOptionsView {
    CGRect frame = self.bounds;
    frame.origin.y += frame.size.height;
    _sharingOptionsView = [[UIView alloc] initWithFrame:frame];
    _sharingOptionsView.backgroundColor = [UIColor whiteColor];
    _sharingOptionsView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    // Add the label.
    UILabel *sharingOptionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _sharingOptionsView.frame.size.width, 45.0f)];
    sharingOptionsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    sharingOptionsLabel.text = @"Sharing Options";
    sharingOptionsLabel.textAlignment = NSTextAlignmentCenter;
    sharingOptionsLabel.textColor = [UIColor whiteColor];
    sharingOptionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:15.0f];
    sharingOptionsLabel.backgroundColor = [UIColor colorWithRed:47.0/255.0 green:47.0/255.0 blue:47.0/255.0 alpha:1.0];
    [_sharingOptionsView addSubview:sharingOptionsLabel];
    
    // Add table view.
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 45.0f, _sharingOptionsView.frame.size.width, _sharingOptionsView.frame.size.height - 45.0f)];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.rowHeight = 60.0f;
    [_sharingOptionsView addSubview:tableView];
    
    // Add the close button.
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(_sharingOptionsView.frame.size.width - 45.f,0.0f,45.0f,45.0f);
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    // Create an image for the button when highlighted.
    CGRect rect = CGRectMake(0.0f, 0.0f, 45.0f, 45.0f);
    UIImage *closeButtonImage = [UIImage imageNamed:@"close.png"];
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:35.0/255.0 green:35.0/255.0 blue:35.0/255.0 alpha:1.0] CGColor]);
    CGContextFillRect(context, rect);
    [closeButtonImage drawInRect:CGRectMake(15.0f,15.0f,closeButtonImage.size.width,closeButtonImage.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    UIImage *highlightedButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [closeButton setBackgroundImage:highlightedButtonImage forState:UIControlStateHighlighted];
    // Create the normal image for the button.
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    UIGraphicsGetCurrentContext();
    [closeButtonImage drawInRect:CGRectMake(15.0f,15.0f,closeButtonImage.size.width,closeButtonImage.size.height) blendMode:kCGBlendModeNormal alpha:0.5];
    UIImage *normalButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [closeButton setBackgroundImage:normalButtonImage forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(hideMoreOptions) forControlEvents:UIControlEventTouchUpInside];
    [_sharingOptionsView addSubview:closeButton];
    
    // Add the view.
    [self addSubview:_sharingOptionsView];
}

#define SUBSTANTIAL_MARGIN 20.0

- (void)updateLayers {
    // Only update if the circle is presented to the user.
    if(_circleIsVisible) {
        // Update the touch layer without waiting for an animation if the difference is not substantial.
        CGPoint newTouchLocation = [self touchLocationAtPoint:_currentPosition];
        if(MAX(ABS(newTouchLocation.x - _touchLayer.position.x),ABS(newTouchLocation.y - _touchLayer.position.y)) > SUBSTANTIAL_MARGIN) {
            _touchLayer.position = newTouchLocation;
        } else {
            [CATransaction begin];
            [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
            _touchLayer.position = newTouchLocation;
            [CATransaction commit];
        }
        
        CALayer *selectedSharerLayer = nil;
        for(CALayer *layer in _sharerLayers) {
            if(CGRectContainsPoint(layer.frame, _touchLayer.position)) {
                selectedSharerLayer = layer;
                break;
            }
        }
        
        // Update the images.
        for(int i = 0; i < [_sharerLayers count]; i++) {
            CALayer *layer = [_sharerLayers objectAtIndex:i];
            if(!_dragging || [selectedSharerLayer.name isEqualToString:layer.name])
                layer.opacity = 1.0;
            else
                layer.opacity = 0.6;
        }
        
        // Update the touch layer.
        if(selectedSharerLayer)
            _touchLayer.opacity = 1.0;
        else if(_dragging)
            _touchLayer.opacity = 0.5;
        else
            _touchLayer.opacity = 0.1;
        
        // Update the intro text layer.
        if(_dragging)
            _introTextLayer.opacity = 0.0;
        else
            _introTextLayer.opacity = 0.6;
        
        // Update the share title text layer
        if(selectedSharerLayer) {
            _shareTitleLayer.string = selectedSharerLayer.name;
            _shareTitleLayer.opacity = 0.6;
        } else {
            _shareTitleLayer.opacity = 0.0;
            _shareTitleLayer.string = @"";
        }
    }
    
    // Hide all the layers if the they are not presented to the user.
    else {
        [CATransaction begin];
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
        _touchLayer.opacity = 0.0;
        _touchLayer.position = CGPointMake(CGRectGetMidX(_backgroundLayer.bounds), CGRectGetMidY(_backgroundLayer.bounds));
        _introTextLayer.opacity = 0.0;
        _shareTitleLayer.opacity = 0.0;
        _currentPosition = _origin;
        _dragging = NO;
        // Update the images.
        for(int i = 0; i < [_sharerLayers count]; i++) {
            CALayer *layer = [_sharerLayers objectAtIndex:i];
            layer.opacity = 0.6;
        }
        [CATransaction commit];
    }
}

#define GRAVITATIONAL_PULL 30.0

- (CGPoint)touchLocationAtPoint:(CGPoint)point {
    
    // If not dragging make sure we redraw the touch image at the origin.
    if(!_dragging)
        point = _origin;
    
    // See if the new point is outside of the circle's radius.
    else if(pow(CIRCLE_SIZE/2.0 - TOUCH_SIZE/2.0,2) < (pow(point.x - _origin.x,2) + pow(point.y - _origin.y,2))) {
        
        // Determine x and y from the center of the circle.
        point.x = _origin.x - point.x;
        point.y -= _origin.y;
        
        // Calculate the angle on the around the circle.
        double angle = atan2(point.y, point.x);
        
        // Get the new x and y from the point on the edge of the circle subtracting the size of the touch image.
        point.x = _origin.x - (CIRCLE_SIZE/2.0 - TOUCH_SIZE/2.0) * cos(angle);
        point.y = _origin.y + (CIRCLE_SIZE/2.0 - TOUCH_SIZE/2.0) * sin(angle);
    }
    
    // Put the point in terms of the background layers position.
    point.x -= _backgroundLayer.frame.origin.x;
    point.y -= _backgroundLayer.frame.origin.y;
    
    // Add the gravitation physics effect.
    for(CALayer *layer in _sharerLayers) {
        CGPoint sharerLocation = layer.position;
               
        if(MAX(ABS(sharerLocation.x - point.x),ABS(sharerLocation.y - point.y)) < GRAVITATIONAL_PULL)
            point = sharerLocation;
    }    
    
    return point;
}

- (BOOL)circleEnclosesPoint:(CGPoint)point {
    if(pow(CIRCLE_SIZE/2.0,2) < (pow(point.x - _origin.x,2) + pow(point.y - _origin.y,2)))
        return NO;
    else
        return YES;
}

- (void)showMoreOptions {
    _sharingOptionsIsVisible = YES;
    [UIView animateWithDuration:0.5
                     animations:^{
                         _sharingOptionsView.frame = self.bounds;
                     }
                     completion:nil];
}

- (void)hideMoreOptions {
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect frame = _sharingOptionsView.frame;
                         frame.origin.y += self.bounds.size.height;
                         _sharingOptionsView.frame = frame;
                     }
                     completion:^(BOOL finished){
                         _sharingOptionsIsVisible = NO;
                         self.hidden = YES;
                     }];
}

-  (UIImage *)whiteOverlayedImage:(UIImage *)image {
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *tempImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tempImage;
}

- (CALayer *)sharerLayerBeingTouched {
    for(CALayer *layer in _sharerLayers) {
        if(CGRectContainsPoint(layer.frame, _touchLayer.position)) {
            return layer;
        }
    }
    return nil;
}

- (void)hideCircle {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    // Set delegate and key/value to know when animation ends.
    animation.delegate = self;
    [animation setValue:@"animateOut" forKey:@"id"];
    
    // Construct the animation.
    animation.fromValue = [_backgroundLayer valueForKey:@"position"];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.bounds.size.width + CIRCLE_SIZE/2.0, CGRectGetMidY(self.bounds))];
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    // Intiate the animation.
    _backgroundLayer.position = CGPointMake(self.bounds.size.width + CIRCLE_SIZE/2.0, CGRectGetMidY(self.bounds));
    [_backgroundLayer addAnimation:animation forKey:@"position"];
}

#pragma mark -
#pragma mark - Animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if([[anim valueForKey:@"id"] isEqual:@"animateOut"]) {
        _circleIsVisible = NO;
        if(!_circleIsVisible && !_sharingOptionsIsVisible) self.hidden = YES;
        [self updateLayers];
    } else if([[anim valueForKey:@"id"] isEqual:@"animateIn"]) {
        _circleIsVisible = YES;
        [self updateLayers];
    }
}

#pragma mark -
#pragma mark - Touch delegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
    _currentPosition = [touch locationInView:self];
    
    // Make sure the user starts with touch inside the circle.
    if([self circleEnclosesPoint: _currentPosition]) {
        _dragging = YES;
        [self updateLayers];
    } else {
        [self hideCircle];
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
    CALayer *sharerLayer = [self sharerLayerBeingTouched];
        
    if(_dragging && sharerLayer) {
        if([sharerLayer.name isEqualToString:@"More"]) {
            [self showMoreOptions];
        } else {
            [_delegate shareCircleView:self didSelectSharer:[_sharers objectAtIndex:[_sharerLayers indexOfObject:sharerLayer]]];
        }
        [self hideCircle];
    } else {
        // Reset values.
        _currentPosition = _origin;
        _dragging = NO;
        [self updateLayers];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // Reset location.
    _currentPosition = _origin;
    _dragging = NO;
}

#pragma mark -
#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self hideMoreOptions];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_delegate shareCircleView:self didSelectSharer:[_sharers objectAtIndex:indexPath.row]];
}

#pragma mark -
#pragma mark - Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#define LABEL_TAG 13
#define IMAGE_VIEW_TAG 14
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SharerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SharerCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:47.0/255.0 green:47.0/255.0 blue:47.0/255.0 alpha:1.0];
    
    CFSharer *sharer = [_sharers objectAtIndex:indexPath.row];
    // Determine if the label or imageview have already been created.
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:LABEL_TAG];;
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:IMAGE_VIEW_TAG];
    if(nameLabel == nil) {
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0, 10.0, 150.0, 40.0)];
        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f];
        nameLabel.highlightedTextColor = [UIColor whiteColor];
        nameLabel.tag = LABEL_TAG;
        [cell.contentView addSubview:nameLabel];
    }
    if(imageView == nil)  {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30.0, 15.0, 30.0, 30.0)];
        imageView.tag = IMAGE_VIEW_TAG;
        [cell.contentView addSubview:imageView];
    }
    
    // Set the label and image properties.
    nameLabel.text = sharer.name;
    imageView.image = sharer.image;
    imageView.highlightedImage = [self whiteOverlayedImage:sharer.image];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sharers.count;
}

#pragma mark -
#pragma mark - Public methods

- (void)show {
    self.hidden = NO;
        
    int keyframeCount = 60;
    CGFloat toValue = CGRectGetMidX(self.bounds);
    CGFloat fromValue = _backgroundLayer.position.x;
    
    // Calculate the values for the keyframe animation.
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:keyframeCount];
	for(size_t frame = 0; frame < keyframeCount; ++frame) {
        CGFloat value = EaseOutBack(frame, fromValue, toValue - fromValue, keyframeCount);
		[values addObject:[NSNumber numberWithFloat:(float)value]];
	}
	
    // Construct the animation.
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
	[animation setValues:values];
    animation.delegate = self;
    [animation setValue:@"animateIn" forKey:@"id"];
    animation.duration = 0.5;
    
    // Intiate the animation and ensure the layer stays there.
    _backgroundLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [_backgroundLayer addAnimation:animation forKey:@"position.x"];
}

- (void)hide {
    if(_circleIsVisible)
       [self hideCircle];
    else if(_sharingOptionsIsVisible)
        [self hideMoreOptions];
}

# pragma mark - 
# pragma mark - C Functions

/*
 
 Open source under the BSD License.
 
 Copyright © 2001 Robert Penner
 All rights reserved.
 
 // back easing out - moving towards target, overshooting it slightly, then reversing and coming back to target
 // t: current time, b: beginning value, c: change in value, d: duration, s: overshoot amount (optional)
 // t and d can be in frames or seconds/milliseconds
 // s controls the amount of overshoot: higher s means greater overshoot
 // s has a default value of 1.70158, which produces an overshoot of 10 percent
 // s==0 produces cubic easing with no overshoot
 
 Math.easeOutBack = function (t, b, c, d, s) {
 if (s == undefined) s = 1.70158;
 return c*((t=t/d-1)*t*((s+1)*t + s) + 1) + b;
 };
 
 */

#define OVERSHOOT 1.5

float EaseOutBack(float currentTime, float startValue, float changeValue, float duration) {
    return changeValue * ((currentTime = currentTime/duration-1)*currentTime*((OVERSHOOT+1)*currentTime + OVERSHOOT) + 1) + startValue;
}

@end