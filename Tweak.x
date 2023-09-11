#import <libactivator/libactivator.h>
#import <rocketbootstrap/rocketbootstrap.h>

#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBAlertItemsController.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>

#import <AppSupport/CPDistributedMessagingCenter.h>

#import <dlfcn.h>
#import <objc/runtime.h>

// #define NSLog(...)

@interface UIWindow (BigShot)

-(UIImage*)takeFullScreenShot;

@end


@implementation UIWindow (BigShot)

UIScrollView* getVerticalScrollView(UIView *aView);
UIWebView* getWebView(UIView *aView);

-(UIImage*)takeFullScreenShot{
    CGRect bounds = self.bounds;
    CGPoint previousContentOffset = CGPointZero;
    UIScrollView *scrollView = getVerticalScrollView(self);
    UIWebView *webView = getWebView(self);

    CGFloat calculatedHeight = 0;
    if (webView != nil) {
        CGFloat exceptWebViewHeight = bounds.size.height - webView.frame.size.height;
        CGFloat webViewContentHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.height"] floatValue];
        calculatedHeight = webViewContentHeight + exceptWebViewHeight;
        previousContentOffset = webView.scrollView.contentOffset;
    } else if (scrollView != nil) {
        CGFloat exceptScollViewHeight = bounds.size.height - scrollView.bounds.size.height;
        calculatedHeight = scrollView.contentSize.height + exceptScollViewHeight;
        previousContentOffset = scrollView.contentOffset;
    }

    if (calculatedHeight > 10000) {
        calculatedHeight = 10000;
    }

    if (calculatedHeight > self.bounds.size.height) {
        self.bounds = CGRectMake(0, 0, self.bounds.size.width, calculatedHeight);
    }

    NSLog(@"[bigshot] calculatedHeight: %f", calculatedHeight);
    NSLog(@"[bigshot] self.bounds.size.height: %f", self.bounds.size.height);
    NSLog(@"[bigshot] bounds.size.height: %f", bounds.size.height);

    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque,0.0);
    [[UIApplication sharedApplication].keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.bounds = bounds;
    scrollView.contentOffset = previousContentOffset;

    return image;
}

UIScrollView* getVerticalScrollView(UIView *aView) {

    if (isVerticalScrollingView(aView)) {
        return  (UIScrollView*)aView;
    }

    for (UIView *view in aView.subviews) {
        UIScrollView *scrollView =  getVerticalScrollView(view);
        if (isVerticalScrollingView(scrollView)) {
            return scrollView;
        }
    }

    return nil;
}

BOOL isVerticalScrollingView(UIView *view) {
    if (view != nil && [view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView*)view;
        if (scrollView.contentSize.height > scrollView.bounds.size.height) {
            return YES;
        }
    }
    return NO;
}

UIWebView* getWebView(UIView *aView) {

    if ([aView isKindOfClass:[UIWebView class]]) {
        return  (UIWebView*)aView;
    }

    for (UIView *view in aView.subviews) {
        UIWebView *webView = getWebView(view);
        if (webView !=nil) {
            return webView;
        }
    }

    return nil;
}

@end

extern CFNotificationCenterRef CFNotificationCenterGetDistributedCenter();

@implementation UIApplication (BigShot)
-(void)captureScreenShot
{
	NSLog(@"[bigshot] captureScreenShot called !!!");
	UIImage *image = [self.keyWindow takeFullScreenShot];
    NSDictionary *original = @{
        @"image" : UIImagePNGRepresentation(image),
    };
	NSLog(@"[bigshot] captureScreenShot image got, sending push with dict: %@", original);
    CFDictionaryRef dict = (__bridge CFDictionaryRef)original;
    CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(),
                                         CFSTR("com.jontelang.snapper3.listenforsavableimage"),
                                         NULL,
                                         dict,
                                         YES);
}
@end

static inline void initializeTweak3(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSDictionary *dict = (__bridge NSDictionary*)userInfo;
	NSString *ocrResult = [dict objectForKey:@"bundle"];
	NSLog(@"[bigshot] message '%@' received in '%@'", ocrResult, [[NSBundle mainBundle] bundleIdentifier]);
	if ([ocrResult isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
		NSLog(@"[bigshot] match");
		dispatch_async(dispatch_get_main_queue(), ^{
			NSLog(@"[bigshot] take screenshot");
			[[UIApplication sharedApplication] captureScreenShot];
		});
	} 
}



%ctor
{
	NSLog(@"[bigshot] ctor 2");
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		NSLog(@"[bigshot] UIApplicationDidBecomeActiveNotification");
	}];

	NSLog(@"[bigshot] register NSNotification");
        CFNotificationCenterAddObserver(
                            CFNotificationCenterGetDistributedCenter(), 
                            NULL, 
                            (CFNotificationCallback)initializeTweak3, 
                            CFSTR("com.jontelang.snapper3.pluginto"), 
                            NULL, 
                            CFNotificationSuspensionBehaviorCoalesce);
}



















