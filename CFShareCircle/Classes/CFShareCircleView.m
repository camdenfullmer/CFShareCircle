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
- (void)setUpAllOptionsView; /* Build the view to show all the sharers when there is too many for the circle. */
- (void)updateLayers; /* Updates all the layers based on the new current position of the touch input. */
- (void)animateImagesIn; /* Animation used when the view is first presented to the user. */
- (void)animateImagesOut; /* Animation used to reset the images so the animation in works correctly. */
- (void)animateMoreOptionsIn; /* Animates the table view in to show all the sharer options. */
- (void)animateMoreOptionsOut; /* Hides the table view with all the sharers. */
- (NSString *)sharerNameHoveringOver; /* Return the name of the sharer that the user is hovering over at this exact moment in time. */
- (CGPoint)touchLocationAtPoint:(CGPoint)point; /* Determines where the touch images is going to be placed inside of the view. */
- (BOOL)circleEnclosesPoint:(CGPoint)point; /* Returns if the point is inside the cirlce. */
- (UIImage *)whiteOverlayedImage:(UIImage*)image;
@end

@implementation CFShareCircleView{
    CGPoint _currentPosition, _origin;
    BOOL _dragging, _circleIsVisible, _moreOptionsIsVisible;
    CALayer *_closeButtonLayer, *_overlayLayer;
    CAShapeLayer *_backgroundLayer, *_touchLayer;
    CATextLayer *_introTextLayer, *_shareTitleLayer;
    NSMutableArray *_imageLayers, *_sharers;
    NSUInteger _numberSharersInCircle;
    UIView *_moreOptionsView;
}

#define BACKGROUND_SIZE 275
#define PATH_SIZE 200
#define IMAGE_SIZE 45
#define TOUCH_SIZE 70
#define MAX_VISIBLE_SHARERS 6

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _sharers = [[NSMutableArray alloc] initWithObjects: [[CFSharer alloc] initWithType:CFSharerTypePinterest], [[CFSharer alloc] initWithType:CFSharerTypeGoogleDrive], [[CFSharer alloc] initWithType:CFSharerTypeTwitter ], [[CFSharer alloc] initWithType:CFSharerTypeFacebook], [[CFSharer alloc] initWithType:CFSharerTypeEvernote], [[CFSharer alloc] initWithType:CFSharerTypeDropbox], [[CFSharer alloc] initWithType:CFSharerTypeMail], [[CFSharer alloc] initWithType:CFSharerTypePhotoLibrary], nil];
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
        _backgroundLayer.position = CGPointMake(self.bounds.size.width + BACKGROUND_SIZE/2.0, CGRectGetMidY(self.bounds));
    }
    [self updateLayers];
}

#pragma mark -
#pragma mark - Private methods

- (void)setUpCircleLayers {
    // Set all the defaults for the share circle.
    _imageLayers = [[NSMutableArray alloc] init];
    self.hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _circleIsVisible = NO;
    _moreOptionsIsVisible = NO;
    _origin = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _currentPosition = _origin;
    
    // Determine the number of sharers in the circle. If it is more then the max then let's insert the more sharer into the array.
    // Also construct the all options view if the max has been exceeded.
    if(_sharers.count > MAX_VISIBLE_SHARERS) {
        _numberSharersInCircle = MAX_VISIBLE_SHARERS;
        [self setUpAllOptionsView];
    } else {
        _numberSharersInCircle = _sharers.count;
    }
    
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
    for(int i = 0; i < _numberSharersInCircle; i++) {
        CFSharer *sharer;
        if(i == 5 && _sharers.count > 6)
            sharer = [[CFSharer alloc] initWithType:CFSharerTypeMore];
        else
            sharer = [_sharers objectAtIndex:i];
        UIImage *image = sharer.image;
        
        // Construct the image layer which will contain our image.
        CALayer *imageLayer = [CALayer layer];
        imageLayer.frame = CGRectMake(0, 0, IMAGE_SIZE, IMAGE_SIZE);
        imageLayer.position = CGPointMake(BACKGROUND_SIZE/2.0, BACKGROUND_SIZE/2.0);
        imageLayer.contents = (id)image.CGImage;
        imageLayer.shadowColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:213.0/255.0 alpha:1.0].CGColor;
        imageLayer.shadowOffset = CGSizeMake(1, 1);
        imageLayer.shadowRadius = 0;
        imageLayer.shadowOpacity = 1.0;
        imageLayer.name = sharer.name;
        
        [_imageLayers addObject:imageLayer];
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

- (void)setUpAllOptionsView {
    CGRect frame = self.bounds;
    frame.origin.y += frame.size.height;
    _moreOptionsView = [[UIView alloc] initWithFrame:frame];
    _moreOptionsView.backgroundColor = [UIColor whiteColor];
    
    // Add the label.
    UILabel *sharingOptionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _moreOptionsView.frame.size.width, 45.0f)];
    sharingOptionsLabel.text = @"Sharing Options";
    sharingOptionsLabel.textAlignment = NSTextAlignmentCenter;
    sharingOptionsLabel.textColor = [UIColor whiteColor];
    sharingOptionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:15.0f];
    sharingOptionsLabel.backgroundColor = [UIColor colorWithRed:47.0/255.0 green:47.0/255.0 blue:47.0/255.0 alpha:1.0];
    [_moreOptionsView addSubview:sharingOptionsLabel];
    
    // Add table view.
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 45.0f, _moreOptionsView.frame.size.width, _moreOptionsView.frame.size.height)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.rowHeight = 60.0f;
    [_moreOptionsView addSubview:tableView];
    
    // Add the close button.
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(_moreOptionsView.frame.size.width - 45.f,0.0f,45.0f,45.0f);
    // Create an image for the button when highlighted.
    CGRect rect = CGRectMake(0.0f, 0.0f, 45.0f, 45.0f);
    UIImage *closeButtonImage = [UIImage imageNamed:@"close.png"];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();    
    CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:35.0/255.0 green:35.0/255.0 blue:35.0/255.0 alpha:1.0] CGColor]);
    CGContextFillRect(context, rect);
    [closeButtonImage drawInRect:CGRectMake(15.0f,15.0f,closeButtonImage.size.width,closeButtonImage.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    UIImage *highlightedButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [closeButton setBackgroundImage:highlightedButtonImage forState:UIControlStateHighlighted];
    // Create the normal image for the button.
    UIGraphicsBeginImageContext(rect.size);
    context = UIGraphicsGetCurrentContext();
    [closeButtonImage drawInRect:CGRectMake(15.0f,15.0f,closeButtonImage.size.width,closeButtonImage.size.height) blendMode:kCGBlendModeNormal alpha:0.5];
    UIImage *normalButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [closeButton setBackgroundImage:normalButtonImage forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(animateMoreOptionsOut) forControlEvents:UIControlEventTouchUpInside];
    [_moreOptionsView addSubview:closeButton];
}

- (void)updateLayers {
    // Only update if the circle is presented to the user.
    if(_circleIsVisible) {
        // Update the touch layer without waiting for an animation.
        [CATransaction begin];
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
        _touchLayer.position = [self touchLocationAtPoint:_currentPosition];
        [CATransaction commit];
        
        NSString *sharerName = [self sharerNameHoveringOver];
        // Update the images.
        for(int i = 0; i < [_imageLayers count]; i++) {
            CALayer *layer = [_imageLayers objectAtIndex:i];
            if(!_dragging || [sharerName isEqualToString:layer.name])
                layer.opacity = 1.0;
            else
                layer.opacity = 0.6;
        }
        
        // Update the touch layer.
        if(sharerName)
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
        if(sharerName) {
            _shareTitleLayer.string = sharerName;
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
        _introTextLayer.opacity = 0.0;
        _shareTitleLayer.opacity = 0.0;
        [CATransaction commit];
    }
}

- (void)animateImagesIn {
    for(int i = 0; i < _numberSharersInCircle; i++) {
        // Animate the base layer for the main rotation.
        CALayer* layer = [_imageLayers objectAtIndex:i];
        
        // Calculate the x and y coordinate. Points go around the unit circle starting at pi = 0.
        float trig = i/(_numberSharersInCircle/2.0)*M_PI;
        float x = layer.position.x + cosf(trig)*PATH_SIZE/2.0;
        float y = layer.position.y - sinf(trig)*PATH_SIZE/2.0;
        layer.position = CGPointMake(x, y);
    }
}

- (void)animateImagesOut {
    for(int i = 0; i < _numberSharersInCircle; i++) {
        // Animate the base layer for the main rotation.
        CALayer* layer = [_imageLayers objectAtIndex:i];
        layer.position = CGPointMake(BACKGROUND_SIZE/2.0, BACKGROUND_SIZE/2.0);
    }
}

- (NSString*)sharerNameHoveringOver {
    NSString *name = nil;
    CALayer *hitLayer = [_backgroundLayer hitTest:_currentPosition];
    if(_dragging && hitLayer.name) {
        return hitLayer.name;
    }
    return name;
}

- (CGPoint)touchLocationAtPoint:(CGPoint)point {
    
    // If not dragging make sure we redraw the touch image at the origin.
    if(!_dragging)
        point = _origin;
    
    // See if the new point is outside of the circle's radius.
    else if(pow(BACKGROUND_SIZE/2.0 - TOUCH_SIZE/2.0,2) < (pow(point.x - _origin.x,2) + pow(point.y - _origin.y,2))) {
        
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

- (BOOL)circleEnclosesPoint:(CGPoint)point {
    if(pow(BACKGROUND_SIZE/2.0,2) < (pow(point.x - _origin.x,2) + pow(point.y - _origin.y,2)))
        return NO;
    else
        return YES;
}

- (void)animateMoreOptionsIn {
    _moreOptionsIsVisible = YES;
    [self addSubview:_moreOptionsView];
    [UIView animateWithDuration:0.5
                     animations:^{
                         _moreOptionsView.frame = self.bounds;
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)animateMoreOptionsOut {
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect frame = _moreOptionsView.frame;
                         frame.origin.y += self.bounds.size.height;
                         _moreOptionsView.frame = frame;
                     }
                     completion:^(BOOL finished){
                         _moreOptionsIsVisible = NO;
                         self.hidden = YES;
                         [_moreOptionsView removeFromSuperview];
                     }];
}

-  (UIImage *)whiteOverlayedImage:(UIImage *)image {
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContext(rect.size);
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

#pragma mark -
#pragma mark - Animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if([[anim valueForKey:@"id"] isEqual:@"animateOut"]) {
        _backgroundLayer.position = CGPointMake(self.bounds.size.width + BACKGROUND_SIZE/2.0, CGRectGetMidY(self.bounds)); // Needed for Core Animation fix??
        if(!_circleIsVisible && !_moreOptionsIsVisible) self.hidden = YES;
    } else if([[anim valueForKey:@"id"] isEqual:@"animateIn"]) {
        _backgroundLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)); // Needed for Core Animation fix??
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
    CALayer *hitLayer = [_backgroundLayer hitTest:_currentPosition];
    
    if(_dragging && hitLayer.name) {
        // Return the sharer that was selected and then animate out.
        if([hitLayer.name isEqualToString:@"All options"]) {
            [self animateMoreOptionsIn];
        } else {
            for(CFSharer *sharer in _sharers) {
                if([sharer.name isEqualToString:hitLayer.name]) {
                    [_delegate shareCircleView:self didSelectSharer:sharer];
                    break;
                }
            }
        }
        [self animateOut];
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

#pragma mark -
#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self animateMoreOptionsOut];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_delegate shareCircleView:self didSelectSharer:[_sharers objectAtIndex:indexPath.row]];
}

#pragma mark -
#pragma mark - Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SharerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SharerCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    CFSharer *sharer = [_sharers objectAtIndex:indexPath.row];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0, 10.0, 150.0, 40.0)];
    nameLabel.text = sharer.name;
    nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f];
    nameLabel.highlightedTextColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30.0, 15.0, 30.0, 30.0)];
    imageView.image = sharer.image;
    imageView.highlightedImage = [self whiteOverlayedImage:sharer.image];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:47.0/255.0 green:47.0/255.0 blue:47.0/255.0 alpha:1.0];
    [cell.contentView addSubview:nameLabel];
    [cell.contentView addSubview:imageView];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sharers.count;
}

#pragma mark -
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
    _circleIsVisible = NO;
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