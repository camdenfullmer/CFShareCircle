//
//  Sharer.m
//  CFShareCircle
//
//  Created by Camden on 1/15/13.
//  Copyright (c) 2013 Camden. All rights reserved.
//

#import "CFSharer.h"

@implementation CFSharer

@synthesize name = _name;
@synthesize image = _image;

- (id)initWithName:(NSString *)name imageName:(NSString *)imageName {
    self = [super init];
    if (self) {
        _name = name;
        _image = [UIImage imageNamed:imageName];
    }
    return self;    
}

- (id)initWithType:(NSInteger)type {
    self = [super init];
    if (self) {
        switch(type) {
            case CFSharerTypeDropbox:
                _name = @"Dropbox";
                _image = [UIImage imageNamed:@"dropbox.png"];
                break;
            case CFSharerTypeEvernote:
                _name = @"Evernote";
                _image = [UIImage imageNamed:@"evernote.png"];
                break;
            case CFSharerTypeFacebook:
                _name = @"Facebook";
                _image = [UIImage imageNamed:@"facebook.png"];
                break;
            case CFSharerTypeGoogleDrive:
                _name = @"Google Drive";
                _image = [UIImage imageNamed:@"google_drive.png"];
                break;
            case CFSharerTypePinterest:
                _name = @"Pinterest";
                _image = [UIImage imageNamed:@"pinterest.png"];
                break;
            case CFSharerTypeTwitter:
                _name = @"Twitter";
                _image = [UIImage imageNamed:@"twitter.png"];
                break;
            default:
                _name = @"";
                _image = nil;
        }
    }
    return self;
}

@end
