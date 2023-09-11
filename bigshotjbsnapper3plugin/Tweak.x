// from theos rootless.h
#ifdef THEOS_PACKAGE_INSTALL_PREFIX
#define ROOT_PATH(cPath) THEOS_PACKAGE_INSTALL_PREFIX cPath
#define ROOT_PATH_NS(path) @THEOS_PACKAGE_INSTALL_PREFIX path
#define ROOT_PATH_NS_VAR(path) [@THEOS_PACKAGE_INSTALL_PREFIX stringByAppendingPathComponent:path]
#define ROOT_PATH_VAR(cPath) ROOT_PATH_NS_VAR(@cPath).fileSystemRepresentation
#else
#define ROOT_PATH(cPath) cPath
#define ROOT_PATH_NS(path) path
#define ROOT_PATH_NS_VAR(path) path
#define ROOT_PATH_VAR(cPath) cPath
#endif

#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBAlertItemsController.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>

//
// internal stuff
//
@protocol SnapperMessagingDelegate <NSObject>
-(void)displayMessage:(NSString*)text;
@end
@interface SnapperCropOverlayViewController : UIViewController
@property (weak) id<SnapperMessagingDelegate> messagingDelegate;
@end

/// So we can display end message too
static id<SnapperMessagingDelegate> messagingDelegate;

extern CFNotificationCenterRef CFNotificationCenterGetDistributedCenter();

#include <dlfcn.h>
#import <objc/runtime.h>

//
// Build an object conforming to this protocol
//

@protocol Snapper3Plugin <NSObject>
@required
-(BOOL)removeSnapAfterProcessing;
-(UIImage*)image;
-(UIImage*)imageForMenuAndSettings; // And SETTINGS
-(NSString*)pluginIdentifier;
-(BOOL)shouldRegister;
-(BOOL)showInSettings;
-(BOOL)disabledInitially;
-(NSString*)name;
-(NSString*)info;
-(NSString*)tweakIdentifier;
-(NSString*)email;
-(NSString*)twitter;
-(NSString*)website; /// Keep https://
@optional
-(void)processImage:(UIImage*)image;
-(BOOL)isBottomPlugin; // 1.2
-(void)bottomPluginActionTapped; // 1.2
@end

//
// Register your object through this object
// 

@interface Snapper3PluginManager: NSObject
+(Snapper3PluginManager*)sharedInstance;
-(void)registerPlugin:(id<Snapper3Plugin>)plugin;
@end

@interface BigShotJBSnapper3Plugin: NSObject <Snapper3Plugin> @end
@implementation BigShotJBSnapper3Plugin
-(BOOL)removeSnapAfterProcessing { return YES; }

-(void)internal_doActionBarAction:(SnapperCropOverlayViewController*)controller {
    NSLog(@"[Snapper3] [IL2] [bigshot] internal_doActionBarAction");
    [controller.messagingDelegate displayMessage:@"Taking BigShot, please wait"];
    messagingDelegate = controller.messagingDelegate;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SpringBoard* sb = (SpringBoard*)[UIApplication sharedApplication];
        NSLog(@"[bigshot] sb: %@", sb);
        if ([sb respondsToSelector:@selector(_accessibilityFrontMostApplication)]) {
         SBApplication *front = (SBApplication*)[sb _accessibilityFrontMostApplication];
         if(front) {
             NSLog(@"[bigshot] front: %@", front);
            NSDictionary *original = @{ @"bundle" : front.bundleIdentifier };
            CFDictionaryRef dict = (__bridge CFDictionaryRef)original;
            CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("com.jontelang.snapper3.pluginto"), NULL, dict, YES);
        }
        }
    });
    CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("com.jontelang.snapper3.closecrop"), NULL, NULL, YES);
}
-(UIImage*)image { return [[UIImage alloc] initWithContentsOfFile:ROOT_PATH_NS_VAR(@"/Library/Snapper3BigShotPlugin/action_screenshot_bigshot.png")]; }
-(UIImage*)imageForMenuAndSettings { return [self image]; }
-(NSString*)name { return @"name"; }
-(NSString*)info { return @"info"; }
-(NSString*)pluginIdentifier { return @"com.jontelang.snapper3.bigshotjb.plugin"; }
-(NSString*)tweakIdentifier { return @"tweakIdentifier"; }
-(NSString*)email { return @"email"; }
-(NSString*)twitter { return @"twitter"; }
-(NSString*)website { return @"website"; }
-(BOOL)shouldRegister { return YES; }
-(BOOL)showInSettings { return NO; }
-(BOOL)disabledInitially { return NO; }
-(BOOL)isBottomPlugin { return YES; }; // 1.2
@end

static inline void listenForSaveImage(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSLog(@"[bigshot] got bac, image");
    NSDictionary *dict = (__bridge NSDictionary*)userInfo;
    NSLog(@"[bigshot] dict: %@", dict);
    UIImage *i = [UIImage imageWithData:[dict objectForKey:@"image"]];
    UIImageWriteToSavedPhotosAlbum(i, nil, nil, nil);
    [messagingDelegate displayMessage:@"Saved BigShot to Photos app"];
    messagingDelegate = nil;
}


static inline void initializeTweak(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"[Snapper3][IL2] wanna register it ");
        Snapper3PluginManager *s3pm = [objc_getClass("Snapper3PluginManager") sharedInstance];
        NSLog(@"[Snapper3][IL2] instance: %@", s3pm);
        [s3pm registerPlugin:[[BigShotJBSnapper3Plugin alloc] init]];
    });
}



%ctor {
    NSLog(@"[instalauncher2] ctor");
    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(), 
        NULL, 
        &initializeTweak, 
        CFSTR("SBSpringBoardDidLaunchNotification"), 
        NULL, 
        CFNotificationSuspensionBehaviorDeliverImmediately);

    CFNotificationCenterAddObserver(
                            CFNotificationCenterGetDistributedCenter(), 
                            NULL, 
                            (CFNotificationCallback)listenForSaveImage, 
                            CFSTR("com.jontelang.snapper3.listenforsavableimage"), 
                            NULL, 
                            CFNotificationSuspensionBehaviorCoalesce);
}
