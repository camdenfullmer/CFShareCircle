#CFShareCircle

CFShareCircle is a better way for app developers to let users share the content to many different services. It is a simple UIView that adds drag and share capabilities to a developers application. View was only tested on iOS 6.0, but should be 5.1+ capable. It now includes an additional menu when you have more than 6 different services to share to for your users!

![Demo Image 1](http://i.imgur.com/XGPKMGil.png?1).![Demo Image 2](http://i.imgur.com/UAC2nRSl.png)

![Demo Image 3](http://i.imgur.com/cIVjQ4Ol.png).![Demo Image 4](http://i.imgur.com/3GCJGdHl.png)

##How To Use

Follow the instructions to add CFShareCircle to your project.

###Basic Setup

1. Add the following frameworks to your project under "Link Binary With Libraries" in "Build Phases".

        - UIKit
        - QuartzCore
        - Foundation
        - CoreGraphics

2. Under the "CFShareCircle" directory copy the "Images" directory under "Resources" to your project. Then also copy over the CFShareCirleView and CFSharer files located under "Classes". Make sure that the CFShareCircle.m, CFShareCircle.h, CHSharer.m, and CFSharer.h are listed under "Copy Bundle Resources" under "Build Phases".

3. Edit your view controller header file to import the CFShareCircle header file, add the delegate, and create an object.

    ```
    #import "CFShareCircleView.h"
    
    @interface ViewController : UIViewController <CFShareCircleViewDelegate> {    
        CFShareCircleView *shareCircleView;        
    }
      ```
      
4. In your viewDidLoad method instantiate the CFShareCircle, set up the delegate, and add it to your navigation controller.
```
- (void)viewDidLoad {
        // Do any additional setup after loading the view, typically from a nib.
        shareCircleView = [[CFShareCircleView alloc] initWithFrame:self.view.frame];
        shareCircleView.delegate = self;
        [self.navigationController.view addSubview:shareCircleView];
        [super viewDidLoad];
}
```

5. Implement the delegate method for the view.
``` 
    - (void)shareCircleView:(CFShareCircleView *)aShareCircleView didSelectSharer:(CFSharer *)sharer {
        NSLog(@"Selected sharer: %@", sharer.name);
    }
```

6. Finally just animate in the view whenever you want it pop up for the user.
```
    [shareCircleView animateIn];
```

###Customize CFShareCirlce

If you would like to determine what the CFShareCircle view shows, all you have to do is intialize your own array of sharers.

```
shareCircleView = [[CFShareCircleView alloc] initWithFrame:self.view.frame sharers:[[NSMutableArray alloc] initWithObjects: [[CFSharer alloc] initWithType:CFSharerTypeTwitter ], [[CFSharer alloc] initWithType:CFSharerTypeFacebook], nil]];
```

Then to extend this you can create your own CFSharer objects, just provide your own name for the sharer and image. Note that icons should be 100px by 100px for @2x and 50px by 50px for standard.

```
CFSharer *newSharer = [[CFSharer alloc] initWithName:@"Facebook" imageName:@"facebook.png"];
```

Types of CFSharers included:

    - Evernote
    - Twitter
    - Google Drive
    - Facebook
    - Pinterest
    - Dropbox
    - Photos
    - Mail
    
##Requirments

    - ARC
    - iOS 5.1+
    
##Contact
[Twitter](https://twitter.com/camdenfullmer)

[Website](https://camdenfullmer.com)
    
##License
The MIT License (MIT)
Copyright (c) 2013 Camden Fullmer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
