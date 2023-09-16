#import "ControlCenterUIKit/CCUIToggleModule.h"

@interface BigShotCCSupport : CCUIToggleModule
{
  BOOL _selected;
}
@end

@interface SBControlCenterController
  +(id)sharedInstance;
  -(void)dismissAnimated:(BOOL)arg1 completion:(id)arg2;
@end

@interface UIApplication (SNPCC)
  +(id)sharedApplication;
  -(void)lockButtonDown:(id)arg1;
@end

@interface SpringBoard
  -(id)_accessibilityFrontMostApplication;
  -(void)_simulateLockButtonPress;
  -(void)_simulateHomeButtonPress;
  -(void)_returnToHomescreenWithCompletion:(id)arg1;
@end