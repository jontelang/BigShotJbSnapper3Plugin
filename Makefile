DEBUG=0
THEOS_PACKAGE_SCHEME=rootless
THEOS_DEVICE_USER=mobile
THEOS=/Users/jontelang/theos
THEOS_DEVICE_IP=192.168.1.33
THEOS_DEVICE_PORT=22
FINALPACKAGE=1
MESSAGES=0
ARCHS = arm64 arm64e
TARGET = iphone:clang:15.0:15.0 # platform:compiler:sdk_version:deployment_version

$(info Building [Tweak])
$(info THEOS_PACKAGE_SCHEME: "$(THEOS_PACKAGE_SCHEME)")
$(info THEOS_DEVICE_USER:    "$(THEOS_DEVICE_USER)")
$(info THEOS:                "$(THEOS)")
$(info THEOS_DEVICE_IP:      "$(THEOS_DEVICE_IP)")
$(info FINALPACKAGE:         "$(FINALPACKAGE)")
$(info DEBUG:                "$(DEBUG)")
$(info MESSAGES:             "$(MESSAGES)")
$(info ARCHS:                "$(ARCHS)")
$(info TARGET:               "$(TARGET)")

SDKVERSION = 13.7
SYSROOT = $(THEOS)/sdks/iPhoneOS13.7.sdk

GO_EASY_ON_ME = 1
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BigShotSnapper3Plugin

BigShotSnapper3Plugin_FILES = Tweak.x $(wildcard *.m)
BigShotSnapper3Plugin_FRAMEWORKS = UIKit CoreGraphics MobileCoreServices
BigShotSnapper3Plugin_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += bigshotjbsnapper3plugin
include $(THEOS_MAKE_PATH)/aggregate.mk