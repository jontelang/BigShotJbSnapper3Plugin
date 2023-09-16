ARCHS = arm64 arm64e
TARGET = iphone:clang:15.0:15.0
SDKVERSION = 13.7
SYSROOT = $(THEOS)/sdks/iPhoneOS13.7.sdk
THEOS=/Users/jontelang/theos

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = BigShotCCSupport
BigShotCCSupport_BUNDLE_EXTENSION = bundle
BigShotCCSupport_CFLAGS =  -fobjc-arc
BigShotCCSupport_PRIVATE_FRAMEWORKS = ControlCenterUIKit
BigShotCCSupport_FILES = BigShotCCSupport.xm
BigShotCCSupport_INSTALL_PATH = /Library/ControlCenter/Bundles/
BigShotCCSupport_FRAMEWORKS = UIKit

after-install::
	install.exec "killall -9 SpringBoard"

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
