// #include <UIKit/UIKit.h>
// #import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <objc/runtime.h>
// #import <CoreFoundation/CoreFoundation.h>
// #import <CoreFoundation/CFNotificationCenter.h>
#import "SnapperCC.h"

extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter();

@interface UIImage ()
+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
@end

@implementation BigShotCCSupport
- (UIImage *)iconGlyph {
	return [UIImage imageNamed:@"icon" inBundle:[NSBundle bundleForClass:[self class]]];
}

- (UIColor *)selectedColor {
	return nil;// not much point having this as it can confuse people
}

- (BOOL)isSelected {
	return _selected;
}

- (void)setSelected:(BOOL)selected {
	_selected = selected;
	[super refreshState];
	SBControlCenterController *instance=[objc_getClass("SBControlCenterController") sharedInstance];
	[instance dismissAnimated:YES completion:nil];

	_selected = NO;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("com.jontelang.bigshot.go"), NULL, NULL, YES);
	});
}

@end
