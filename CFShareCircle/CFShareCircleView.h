//
//  CFShareCircleView.h
//  CFShareCircle
//
//  Created by Camden on 12/18/12.
//  Copyright (c) 2012 Camden. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CFShareCircleView;

@protocol CFShareCircleViewDelegate
- (void)shareCircleView:(CFShareCircleView *)aShareCircleView didSelectIndex:(int)index;
- (void)shareCircleViewWasCanceled;
@end

@interface CFShareCircleView : UIView{
    CGPoint _currentPosition;
    CGPoint _origin;
    int _largeRectSize;
    int _smallRectSize;
    int _pathRectSize;
    int _tempRectSize;
    BOOL _dragging;
    NSMutableArray *images;
    UIImage *touchImage;
    UIImage *closeButtonImage;
}

@property (assign) id <CFShareCircleViewDelegate> delegate;
- (id)initWithImageFileNames: (NSArray*)imageFileNames;

@end
