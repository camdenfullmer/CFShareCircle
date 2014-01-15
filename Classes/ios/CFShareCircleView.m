//
//  CFShareCircleView.m
//  CFShareCircle
//
//  Created by Camden on 12/18/12.
//  Copyright (c) 2012 Camden. All rights reserved.
//

#import "CFShareCircleView.h"

#define IS_OS_7_OR_LATER (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)

#define CIRCLE_SIZE 275
#define PATH_SIZE 200
#define IMAGE_SIZE 45
#define TOUCH_SIZE 70
#define MAX_VISIBLE_SHARERS 6

static const UIWindowLevel UIWindowLevelCFShareCircle = 1999.0;  // Don't overlap system's alert.

@interface CFShareCircleView()

- (void)setupShareCircleContainerView;
- (void)setupSharers;
- (CALayer *)touchedSharerLayer;
- (CGPoint)touchLocationAtPoint:(CGPoint)point;
- (BOOL)circleEnclosesPoint:(CGPoint)point;
- (void)setup;
- (void)invalidateLayout;
- (void)validateLayout;
- (int)numberOfVisibleSharers;

@property CGPoint currentPosition;
@property (nonatomic, assign, getter = isDragging) BOOL dragging;
@property (nonatomic, assign, getter = isLayoutDirty) BOOL layoutDirty;
@property (nonatomic, strong) CALayer *closeButtonLayer;
@property (nonatomic, strong) CAShapeLayer *touchLayer;
@property (nonatomic, strong) CATextLayer *introTextLayer;
@property (nonatomic, strong) CATextLayer *shareTitleLayer;
@property (nonatomic, strong) NSArray *sharers;
@property (nonatomic, strong) NSMutableArray *sharerLayers;
@property (nonatomic, strong) UIView *shareCircleContainerView;
@property (nonatomic, strong) UIWindow *oldKeyWindow;
@property (nonatomic, strong) UIWindow *shareCircleWindow;
// Used so view is not animated out during the animation in.
@property (nonatomic) BOOL animating;

@end

#pragma mark - CFShareCircleViewController

@interface CFShareCircleViewController : UIViewController

@property (nonatomic, strong) CFShareCircleView *shareCircleView;

@end

@implementation CFShareCircleViewController

#pragma mark - View life cycle

- (void)loadView {
    self.view = self.shareCircleView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.shareCircleView setup];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.shareCircleView invalidateLayout];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

@end

#pragma mark - CFShareCircleBackgroundWindow

@interface CFShareCircleBackgroundWindow : UIWindow

@end

@interface CFShareCircleBackgroundWindow ()

@end

@implementation CFShareCircleBackgroundWindow

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = NO;
        self.windowLevel = UIWindowLevelCFShareCircle;
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.45];
    }
    return self;
}

@end

#pragma mark - CFShareCircleView

@implementation CFShareCircleView

- (id)init {
    self = [super init];
    if(self) {
        _sharers = @[[CFSharer dropbox], [CFSharer mail], [CFSharer cameraRoll], [CFSharer twitter], [CFSharer evernote], [CFSharer airPrint]];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (id)initWithSharers:(NSArray *)sharers {
    self = [super init];
    if (self) {
        _sharers = [[NSArray alloc] initWithArray:sharers];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (int)numberOfVisibleSharers {
    if(self.sharers.count > MAX_VISIBLE_SHARERS) {
        return MAX_VISIBLE_SHARERS;
    }
    else {
        return self.sharers.count;
    }
}

#pragma mark - Public methods

- (void)showAnimated:(BOOL)animated {
    self.oldKeyWindow = [[UIApplication sharedApplication] keyWindow];
    
    CFShareCircleViewController *viewController = [[CFShareCircleViewController alloc] initWithNibName:nil bundle:nil];
    viewController.shareCircleView = self;
    
    // Set up new window to be presented over the application window.
    if (!self.shareCircleWindow) {
        CFShareCircleBackgroundWindow *window = [[CFShareCircleBackgroundWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.rootViewController = viewController;
        self.shareCircleWindow = window;
    }
    [self.shareCircleWindow makeKeyAndVisible];
    
    // Ensure layout is correct before presenting to user.
    [self validateLayout];
    
    // Create the starting point.
    self.shareCircleContainerView.center = CGPointMake(CGRectGetMidX(self.bounds), 0 - CIRCLE_SIZE/2.0f);
    
    // Create the block for the animation.
    void(^animationBlock)(void) = ^{
        CGPoint center = self.shareCircleContainerView.center;
        center.y = CGRectGetMidY(self.bounds);
        self.shareCircleContainerView.center = center;
    };
    
    // Create the completion block for the animaiton.
    void(^completionBlock)(BOOL) = ^(BOOL finished){
        self.animating = NO;
    };
    
    if(animated) {
        self.animating = YES;
        if(IS_OS_7_OR_LATER) {
            [UIView animateWithDuration:1.0f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:0.5f options:UIViewAnimationCurveLinear animations:animationBlock completion:completionBlock];
        }
        else {
            [UIView animateWithDuration:0.4f animations:animationBlock completion:completionBlock];
        }
    }
    else {
        animationBlock();
    }
}

- (void)dismissAnimated:(BOOL)animated {
    if(self.animating) {
        return;
    }
    
    // Create the block for the animation.
    void(^animationBlock)(void) = ^{
        CGPoint center = self.shareCircleContainerView.center;
        center.y = CGRectGetMaxY(self.bounds) + CIRCLE_SIZE/2.0f;
        self.shareCircleContainerView.center = center;
    };
    
    // Create the completion block for the animaiton.
    void(^completionBlock)(BOOL) = ^(BOOL finished){
        [self teardown];
    };
    
    if(animated) {
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:animationBlock completion:completionBlock];
    }
    else {
        animationBlock();
        completionBlock(YES);
    }
        
    // Replace the original application window.
    [self.oldKeyWindow makeKeyWindow];
    self.oldKeyWindow.hidden = NO;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    [self validateLayout];
}

- (void)invalidateLayout {
    self.layoutDirty = YES;
    [self setNeedsLayout];
}

- (void)validateLayout {
    if (!self.isLayoutDirty) {
        return;
    }
    self.layoutDirty = NO;
    
    self.shareCircleContainerView.frame = CGRectMake(CGRectGetMidX(self.bounds) - CIRCLE_SIZE/2.0, CGRectGetMidY(self.bounds) - CIRCLE_SIZE/2.0, CIRCLE_SIZE, CIRCLE_SIZE);
    self.shareCircleContainerView.layer.cornerRadius = CGRectGetWidth(self.shareCircleContainerView.frame) / 2.0;
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.shareCircleContainerView.bounds), CGRectGetMidY(self.shareCircleContainerView.bounds));
    self.introTextLayer.position = center;
    self.shareTitleLayer.position = center;
    
    if(self.isDragging) {
        // Removes animation on small change and adds it back in on a substantial change.
        CGPoint newTouchLocation = [self touchLocationAtPoint:self.currentPosition];
        if(MAX(ABS(newTouchLocation.x - self.touchLayer.position.x),ABS(newTouchLocation.y - self.touchLayer.position.y)) > 20.0f) {
            self.touchLayer.position = newTouchLocation;
        }
        else {
            [CATransaction begin];
            [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
            self.touchLayer.position = newTouchLocation;
            [CATransaction commit];
        }
        
        self.introTextLayer.opacity = 0.0;
        self.touchLayer.opacity = 1.0;
        
        // Check to see if a sharer layer is selected.
        CALayer *selectedSharerLayer = nil;
        for(CALayer *layer in self.sharerLayers) {
            if(CGRectContainsPoint(layer.frame, newTouchLocation)) {
                selectedSharerLayer = layer;
                break;
            }
        }
        
        // Update sharer layers.
        for(int i = 0; i < [self numberOfVisibleSharers]; i++) {
            CALayer *layer = [self.sharerLayers objectAtIndex:i];
            if([layer isEqual:selectedSharerLayer]) {
                layer.opacity = 1.0;
                self.shareTitleLayer.string = selectedSharerLayer.name;
            }
            else {
                layer.opacity = 0.6f;
            }
        }
        
        if(!selectedSharerLayer) {
            self.shareTitleLayer.string = @"";
        }
    } else {
        self.touchLayer.position = center;
        self.introTextLayer.opacity = 1.0;
        self.touchLayer.opacity = 0.2;
        self.shareTitleLayer.string = @"";
        
        for(int i = 0; i < [self numberOfVisibleSharers]; i++) {
            CALayer *layer = [self.sharerLayers objectAtIndex:i];
            layer.opacity = 1.0;
        }
    }
}

#pragma mark - Setup

- (void)setup {
    [self setupShareCircleContainerView];
    [self setupSharers];
    [self invalidateLayout];
}

- (void)teardown {
    [self.shareCircleContainerView removeFromSuperview];
    self.shareCircleContainerView = nil;
    [self.shareCircleWindow removeFromSuperview];
    self.shareCircleWindow = nil;
    self.layoutDirty = NO;
    [self.sharerLayers removeAllObjects];
    self.dragging = NO;
}

- (void)setupShareCircleContainerView {
    self.shareCircleContainerView = [[UIView alloc] initWithFrame:self.bounds];
    self.shareCircleContainerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.shareCircleContainerView];
}

#define NESTY 18.0f

- (void)setupSharers {
    // Set all the defaults for the share circle.
    self.sharerLayers = [[NSMutableArray alloc] init];
    
    // Create the CGFont that is to be used on the layers.
    NSString *fontName = @"HelveticaNeue-Light";
    CFStringRef cfFontName = (CFStringRef)CFBridgingRetain(fontName);
    CGFontRef font = CGFontCreateWithFontName(cfFontName);
    CFRelease(cfFontName);
    
    // Create the layers for all the sharing service images.
    for(int i = 0; i < self.sharers.count; i++) {
        CFSharer *sharer = [self.sharers objectAtIndex:i];
        UIImage *image = sharer.image;
        
        // Construct the image layer which will contain the sharer image.
        CALayer *sharerLayer = [CALayer layer];
        sharerLayer.frame = CGRectMake(0, 0, IMAGE_SIZE, IMAGE_SIZE);
        
        // Calculate the x and y coordinate. Points go around the unit circle starting at pi = 0.
        int section = i > 5 ? 5 : i; // If more than 6 sharers, keep the rest in the last position.
        float trig = section/([self numberOfVisibleSharers]/2.0)*M_PI;
        float x = CIRCLE_SIZE/2.0 + cosf(trig)*PATH_SIZE/2.0;
        float y = CIRCLE_SIZE/2.0 - sinf(trig)*PATH_SIZE/2.0;
        sharerLayer.position = CGPointMake(x, y);
        sharerLayer.contents = (id)image.CGImage;
        sharerLayer.name = sharer.name;
        
        if(i > 5) {
            sharerLayer.opacity = 0.0f;
        }
        
        [self.sharerLayers addObject:sharerLayer];
        [self.shareCircleContainerView.layer addSublayer:[self.sharerLayers objectAtIndex:i]];
    }
    
    // Create the touch layer for the Share Circle.
    self.touchLayer = [CAShapeLayer layer];
    self.touchLayer.frame = CGRectMake(0, 0, TOUCH_SIZE, TOUCH_SIZE);
    CGMutablePathRef circularPath = CGPathCreateMutable();
    CGPathAddEllipseInRect(circularPath, NULL, CGRectMake(0, 0, TOUCH_SIZE, TOUCH_SIZE));
    self.touchLayer.path = circularPath;
    CGPathRelease(circularPath);
    
    self.touchLayer.fillColor = [UIColor clearColor].CGColor;
    self.touchLayer.strokeColor = [UIColor blackColor].CGColor;
    self.touchLayer.lineWidth = 2.0f;
    [self.shareCircleContainerView.layer addSublayer:self.touchLayer];
    
    // Create the intro text layer to help the user.
    self.introTextLayer = [CATextLayer layer];
    self.introTextLayer.string = @"Drag to\nShare";
    self.introTextLayer.opacity = 1.0;
    self.introTextLayer.wrapped = YES;
    self.introTextLayer.alignmentMode = kCAAlignmentCenter;
    self.introTextLayer.fontSize = 14.0;
    self.introTextLayer.font = font;
    self.introTextLayer.foregroundColor = [UIColor blackColor].CGColor;
    self.introTextLayer.frame = CGRectMake(0, 0, 60, 31);
    self.introTextLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.shareCircleContainerView.layer addSublayer:self.introTextLayer];
    
    // Create the share title text layer.
    self.shareTitleLayer = [CATextLayer layer];
    self.shareTitleLayer.string = @"";
    self.shareTitleLayer.wrapped = YES;
    self.shareTitleLayer.alignmentMode = kCAAlignmentCenter;
    self.shareTitleLayer.fontSize = 20.0;
    self.shareTitleLayer.font = font;
    self.shareTitleLayer.foregroundColor = [[UIColor blackColor] CGColor];
    self.shareTitleLayer.frame = CGRectMake(0, 0, 120, 28);
    self.shareTitleLayer.contentsScale = [[UIScreen mainScreen] scale];
    [self.shareCircleContainerView.layer addSublayer:self.shareTitleLayer];
    
    CGFontRelease(font);
}

#pragma mark - Touch methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
    self.currentPosition = [touch locationInView:self.shareCircleContainerView];
    
    if([self circleEnclosesPoint:self.currentPosition]) {
        self.dragging = YES;
        [self invalidateLayout];
    }
    else {
        [self dismissAnimated:YES];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
    self.currentPosition = [touch locationInView:touch.view];
    
    if(self.isDragging) {
        [self invalidateLayout];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
    self.currentPosition = [touch locationInView:touch.view];
    CALayer *sharerLayer = [self touchedSharerLayer];
    
    if(self.isDragging) {
        if(sharerLayer) {
            [_delegate shareCircleView:self didSelectSharer:[self.sharers objectAtIndex:[self.sharerLayers indexOfObject:sharerLayer]]];
            self.currentPosition = CGPointMake(CGRectGetMidX(self.shareCircleContainerView.bounds), CGRectGetMidY(self.shareCircleContainerView.bounds));
            [self dismissAnimated:YES];
        }
        else {
            self.currentPosition = CGPointMake(CGRectGetMidX(self.shareCircleContainerView.bounds), CGRectGetMidY(self.shareCircleContainerView.bounds));
            self.dragging = NO;
            [self invalidateLayout];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // Reset location.
    self.currentPosition = CGPointMake(CGRectGetMidX(self.shareCircleContainerView.bounds), CGRectGetMidY(self.shareCircleContainerView.bounds));
    self.dragging = NO;
}

- (CALayer *)touchedSharerLayer {
    for(CALayer *layer in self.sharerLayers) {
        if(CGRectContainsPoint(layer.frame, self.touchLayer.position)) {
            return layer;
        }
    }
    return nil;
}

- (BOOL)circleEnclosesPoint:(CGPoint)point {
    if(pow(CIRCLE_SIZE/2.0,2) < (pow(point.x - CGRectGetMidX(self.shareCircleContainerView.bounds),2) + pow(point.y - CGRectGetMidY(self.shareCircleContainerView.bounds),2))) {
        return NO;
    }
    else {
        return YES;
    }
}

#define GRAVITATIONAL_PULL 30.0

- (CGPoint)touchLocationAtPoint:(CGPoint)point {
    // If not dragging make sure we redraw the touch image at the origin.
    if(!self.isDragging) {
        point = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
    // See if the new point is outside of the circle's radius.
    else if(pow(CIRCLE_SIZE/2.0 - TOUCH_SIZE/2.0,2) < (pow(point.x - CGRectGetMidX(self.shareCircleContainerView.bounds),2) + pow(point.y - CGRectGetMidY(self.shareCircleContainerView.bounds),2))) {
        // Determine x and y from the center of the circle.
        point.x = CGRectGetMidX(self.shareCircleContainerView.bounds) - point.x;
        point.y -= CGRectGetMidY(self.shareCircleContainerView.bounds);
        
        // Calculate the angle on the around the circle.
        double angle = atan2(point.y, point.x);
        
        // Get the new x and y from the point on the edge of the circle subtracting the size of the touch image.
        point.x = CGRectGetMidX(self.shareCircleContainerView.bounds) - (CIRCLE_SIZE/2.0 - TOUCH_SIZE/2.0) * cos(angle);
        point.y = CGRectGetMidY(self.shareCircleContainerView.bounds) + (CIRCLE_SIZE/2.0 - TOUCH_SIZE/2.0) * sin(angle);
    }
    
    // Put the point in terms of the background layers position.
    point.x -= CGRectGetMinX(self.shareCircleContainerView.bounds);
    point.y -= CGRectGetMinY(self.shareCircleContainerView.bounds);
    
    // Add the gravitation physics effect.
    for(CALayer *layer in self.sharerLayers) {
        CGPoint sharerLocation = layer.position;
        
        if(MAX(ABS(sharerLocation.x - point.x),ABS(sharerLocation.y - point.y)) < GRAVITATIONAL_PULL) {
            point = sharerLocation;
            break;
        }
    }
    return point;
}

@end