//
//  CFShareCircleView.h
//  CFShareCircle
//
//  Created by Camden on 12/18/12.
//  Copyright (c) 2012 Camden. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BACKGROUND_SIZE 250
#define PATH_SIZE 180
#define TEMP_SIZE 50
#define CLOSE_BUTTON_SIZE 40
#define TOUCH_SIZE 64

@class CFShareCircleView;

@protocol CFShareCircleViewDelegate
- (void)shareCircleView:(CFShareCircleView *)aShareCircleView didSelectIndex:(int)index;
- (void)shareCircleViewWasCanceled;
@end

@interface CFShareCircleView : UIView{
    CGPoint _currentPosition;
    CGPoint _origin;
    BOOL _dragging;
    UIDeviceOrientation currentOrientation;
    BOOL visibile;
}

@property (assign) id <CFShareCircleViewDelegate> delegate;
@property (strong) NSArray *images;
- (id)initWithImageFileNames: (NSArray*)images;
- (void)animateIn;
- (void)animateOut;

@end
