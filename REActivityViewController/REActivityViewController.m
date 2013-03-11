//
// REActivityViewController.m
// REActivityViewController
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "REActivityViewController.h"
#import "REActivityView.h"

@implementation REActivityViewController

static CGFloat landscapeHeightOffset = 0;
static CGFloat portraitHeightOffset = 70;

- (id)initWithViewController:(UIViewController *)viewController activities:(NSArray *)activities
{
    self = [super init];
    if (self) {
        CGRect frame = [UIScreen mainScreen].bounds;
        
        self.view.frame = frame;
        self.presentingController = viewController;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            _backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
            _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _backgroundView.backgroundColor = [UIColor blackColor];
            _backgroundView.alpha = 0;
            [self.view addSubview:_backgroundView];
        }
        
        _activities = activities;
        _activityView = [[REActivityView alloc] initWithFrame:CGRectMake(0,
                                                                         UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ?
                                                                         self.view.frame.size.height : 0,
                                                                         frame.size.width, [self  _calculateViewHeight])
                                                   activities:activities];
        _activityView.containerName = NSStringFromClass([viewController class]);
        _activityView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        
        _activityView.activityViewController = self;
        [self.view addSubview:_activityView];
    }
    
    return self;
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self willAnimateRotationToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation] duration:0];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [UIView animateWithDuration:0.4 animations:^{
            _backgroundView.alpha = 0;
            CGRect frame = _activityView.frame;
            frame.origin.y = [UIScreen mainScreen].bounds.size.height;
            _activityView.frame = frame;
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            if (completion)
                completion();
        }];
    } else {
        [self.presentingPopoverController dismissPopoverAnimated:YES];
        [self performBlock:^{
            if (completion)
                completion();
        } afterDelay:0.4];
    }
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    CGRect frame = _activityView.frame;
    frame.origin.y = [self _calculateHightOffset];
    frame.size.height = [self _calculateViewHeight];
    _activityView.frame = frame;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [UIView animateWithDuration:0.4 animations:^{
            _backgroundView.alpha = 0.4;
            
            CGRect frame = _activityView.frame;
            frame.origin.y = [self _calculateHightOffset];
            _activityView.frame = frame;
        }];
    }
    
     [super viewWillAppear:animated];
}


- (NSInteger) _calculateViewHeight
{
    //CGRect screen = [UIScreen mainScreen].bounds;
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        return self.view.bounds.size.height - [self _calculateHightOffset];
    }
    return self.view.bounds.size.height - [self _calculateHightOffset];
}


- (NSInteger) _calculateHightOffset
{
    NSInteger offset = 0;
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        offset = landscapeHeightOffset;
        if ([_activityView.activities count] <= (int)_activityView.numberOfIconsInLine)  offset += 60;
    }
    else {
        offset =  portraitHeightOffset;
        if ([_activityView.activities count] <= 2*(int)_activityView.numberOfIconsInLine)  offset += 60;
    }
    
    
    return offset;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - 
#pragma mark Helpers

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
    block = [block copy];
    [self performSelector:@selector(runBlockAfterDelay:) withObject:block afterDelay:delay];
}

- (void)runBlockAfterDelay:(void (^)(void))block
{
	if (block != nil)
		block();
}

#pragma mark -
#pragma mark Orientation

- (NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationMaskAll;
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    return (orientation == UIInterfaceOrientationPortrait);
}

@end
