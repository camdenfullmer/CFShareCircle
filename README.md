#CFShareCircle

CFShareCircle is a better way for app developers to let users share the content to many different services. It is a simple UIView that adds touch features.

![Demo Image](http://s8.postimage.org/qwvio8syt/demo.png)

##How To Use

1. Add the images directory and CFShareCircle files to your project.
2. Edit your view controller to add the CFShareCircle Delegate and reference to the view.

    ```
    @interface ViewController : UIViewController <CFShareCircleViewDelegate>{    
        CFShareCircleView *shareCircleView;        
    }
      ```
3. In your viewDidLoad method instantiate the CFShareCircle, set up the delegate, and add it to your navigation controller.
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
4. Then set up the frame bounds for the view and implement the delegate method.
```
    - (void)viewWillAppear:(BOOL)animated{
        shareCircleView.frame = self.navigationController.view.frame;
    }
    
    - (void)shareCircleView:(CFShareCircleView *)shareCircleView didSelectIndex:(int)index{
        NSLog(@"Selected index: %d", index);
    }
```
5. Lastly, just show the view when you want it to appear.
```
    [shareCircleView setHidden:NO];
```
