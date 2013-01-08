#CFShareCircle

CFShareCircle is a better way for app developers to let users share the content to many different services. It is a simple UIView that adds touch features.

![Demo Image](http://i.imgur.com/tTcAo.png)

##How To Use

Follow the instructions to add CFShareCircle to your project.

###Basic Setup

1. Add the following frameworks to your project under "Link Binary With Libraries"
    - UIKit
    - QuartzCore
    - Foundation
    - CoreGraphics
2. Add the images directory and CFShareCircle files to your project.
3. Edit your view controller to add the CFShareCircle Delegate and reference to the view.

    ```
    @interface ViewController : UIViewController <CFShareCircleViewDelegate>{    
        CFShareCircleView *shareCircleView;        
    }
      ```
4. In your viewDidLoad method instantiate the CFShareCircle, set up the delegate, and add it to your navigation controller.
```
- (void)viewDidLoad
{
        [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.
        shareCircleView = [[CFShareCircleView alloc] init];
        shareCircleView.delegate = self;
        [self.navigationController.view addSubview:shareCircleView];
}
```
5. Then set up the frame bounds for the view and implement the delegate method. Note that the index returned from the view is in order of the array (i.e. Starts from pi = 0 on the unit circle).
```
    - (void)viewWillAppear:(BOOL)animated{
        shareCircleView.frame = self.navigationController.view.frame;
    }
    
    - (void)shareCircleView:(CFShareCircleView *)shareCircleView didSelectIndex:(int)index{
        NSLog(@"Selected index: %d", index);
    }
```
6. Lastly, just show the view when you want it to appear.
```
    [shareCircleView setHidden:NO];
```

###Custom Sharing Images

To customize what sharing images you want to show all you have to do is intialize with your own array of images.

```
shareCircleView = [[CFShareCircleView alloc] initWithImageFileNames:[[NSArray alloc] initWithObjects: @"facebook.png", @"twitter.png", @"email.png", nil]];
```

List of sharing icons included with project.

    - Evernote (evernote.png)
    - Twitter (twitter.png)
    - Google+ (googleplus.png)
    - Facebook (facebook.png)
    - Email (email.png)
    - Message (message.png)
    
##License
The MIT License (MIT)
Copyright (c) 2013 Camden Fullmer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
