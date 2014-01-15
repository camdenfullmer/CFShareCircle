#CFShareCircle

CFShareCircle is a better way for app developers to let users share the content to many different services. It is a simple UIView that adds drag and share capabilities to a developers application.

###YouTube Video
<a href="http://www.youtube.com/watch?feature=player_embedded&v=-yz1qjddIbs" target="_blank"><img src="http://img.youtube.com/vi/-yz1qjddIbs/0.jpg" alt="CFShareCircle Demo" width="480" height="360"/></a>

##How To Use

Follow the instructions to add CFShareCircle to your project.

###Installation

1. CFShareCircle can be installed via [Cocoapods](http://cocoapods.org/). Simply add `pod 'CFShareCircle'` to your Podfile. If you don't use Cocoapods you're welcome to use git submodules, or simply [download](https://github.com/camdenfullmer/CFShareCircle/archive/master.zip) the files manually. If you go with the manual route just include the files located in Classes and Resources to your project.

2. Edit your view controller header file to import the CFShareCircle header file and declare the delegation protocol.

    ```
    #import "CFShareCircleView.h"
    
    @interface ViewController : UIViewController <CFShareCircleViewDelegate>
    
    @end
    ```
    
3. Declare a property for the CFShareCircle.

    ```
    @interface ViewController ()

    @property (nonatomic, strong) CFShareCircleView *shareCircleView;

    @end
    ```

4. In your viewDidLoad method instantiate the CFShareCircle and set your view controller as the delegate.

    ```
    - (void)viewDidLoad {
        [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.
        shareCircleView = [[CFShareCircleView alloc] init];
        shareCircleView.delegate = self;
    }
    ```

5. Implement the delegate method for the view.

    ``` 
    - (void)shareCircleView:(CFShareCircleView *)shareCircleView didSelectSharer:(CFSharer *)sharer {
        NSLog(@"Selected sharer: %@", sharer.name);
    }
    
    - (void)shareCircleCanceled:(NSNotification *)notification{ 
        NSLog(@"Share circle view was canceled.");
    }
    ```

6. Finally, just show the view whenever you want it to pop up for the user.

    ```
    [shareCircleView showAnimated:YES];
    ```

###Customize CFShareCirlce

If you would like to determine what the CFShareCircle view shows, all you have to do is intialize your own array of sharers.

```
shareCircleView = [[CFShareCircleView alloc] initWithSharers:@[[CFSharer twitter], [CFSharer facebook], [CFSharer dropbox]]];
```

Then to extend this you can create your own CFSharer objects, just provide your own name for the sharer and image. Note that icons should be 100px by 100px for retina and 50px by 50px for standard.

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
    - Camera Roll
    - Mail
    - AirPrint
    
##Requirments

    - ARC
    - iOS 5.0+
    - Following Frameworks: UIKit, CoreGraphics and QuartzCore.
    
##Contact

[Twitter](https://twitter.com/camdenfullmer)

[Website](https://camdenfullmer.com)
    
##License
The MIT License (MIT)
Copyright (c) 2013 Camden Fullmer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
