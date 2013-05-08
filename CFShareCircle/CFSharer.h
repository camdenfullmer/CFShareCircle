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

typedef enum {
    CFSharerTypeFacebook,
    CFSharerTypeTwitter,
    CFSharerTypeDropbox,
    CFSharerTypeGoogleDrive,
    CFSharerTypePinterest,
    CFSharerTypeEvernote
} CFSharerType;

@interface CFSharer : NSObject

@property NSString *name;
@property UIImage *image;

/**
 Initialize a custom sharer with the name that will be presented when hovering over and the name of the image.
 */
- (id)initWithName:(NSString *)name imageName:(NSString *)imageName;

/**
 Initialize a sharer with a predefined type.
 */
- (id)initWithType:(NSInteger)type;

@end
