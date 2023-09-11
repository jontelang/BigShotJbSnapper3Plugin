TARGET = iphone:clang:15.0:15.0 # platform:compiler:sdk_version:deployment_version
INSTALL_TARGET_PROCESSES = SpringBoard
SDKVERSION = 13.7
SYSROOT = $(THEOS)/sdks/iPhoneOS13.7.sdk

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BigShotJbSnapper3Plugin

BigShotJbSnapper3Plugin_FILES = Tweak.x
BigShotJbSnapper3Plugin_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
