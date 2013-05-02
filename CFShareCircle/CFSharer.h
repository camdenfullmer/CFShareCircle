//
//  Sharer.h
//  CFShareCircle
//
//  Created by Camden on 1/15/13.
//  Copyright (c) 2013 Camden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class CFSharer;

@interface CFSharer : NSObject

@property NSString* name;

/**
 Intializes a sharer object with the string.
 @param NSString
 */
- (id)initWithName:(NSString*)aName;

/**
 Returns a UIImage that is used to display the sharing service in the circle.
 @return UIImage
 */
- (UIImage *)mainImage;

/**
 Returns a UIImage that is displayed when the user hovers over the main image.
 @return UIImage
 */
- (UIImage *)titleImage;

@end
