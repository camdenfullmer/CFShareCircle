//
//  CFShareCircleView.h
//  CFShareCircle
//
//  Created by Camden on 12/18/12.
//  Copyright (c) 2012 Camden. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LARGE_CIRCLE_SIZE 250
#define PATH_SIZE 180
#define TEMP_SIZE 50

@class CFShareCircleView;

@protocol CFShareCircleViewDelegate
- (void)shareCircleView:(CFShareCircleView *)aShareCircleView didSelectIndex:(int)index;
- (void)shareCircleViewWasCanceled;
@end

@interface CFShareCircleView : UIView{
    CGPoint _currentPosition;
    CGPoint _origin;
    BOOL _dragging;
    NSMutableArray *images;
    UIImage *touchImage;
    UIImage *closeButtonImage;
    UIDeviceOrientation currentOrientation;
    BOOL visibile;
}

@property (assign) id <CFShareCircleViewDelegate> delegate;
- (id)initWithImageFileNames: (NSArray*)imageFileNames;
- (void)animateIn;
- (void)animateOut;

@end
