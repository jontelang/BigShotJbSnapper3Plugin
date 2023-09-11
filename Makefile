# SIMJECT or DEVICE (default)
TWEAK_ENVIRONMENT=DEVICE

DEBUG=1
BETA=0

ifeq ($(TWEAK_ENVIRONMENT), SIMJECT)
	ARCHS = arm64
	TARGET = simulator:clang::12.0
else
	THEOS_PACKAGE_SCHEME=rootless
	THEOS_DEVICE_USER=mobile
	THEOS=/Users/jontelang/theos
	THEOS_DEVICE_IP=192.168.1.33
	THEOS_DEVICE_PORT=22
	FINALPACKAGE=0
	MESSAGES=0
	ARCHS = arm64 arm64e
	TARGET = iphone:clang:15.0:15.0 # platform:compiler:sdk_version:deployment_version
endif

$(info Building [Tweak])
$(info TWEAK_ENVIRONMENT:    "$(TWEAK_ENVIRONMENT)")
$(info THEOS_PACKAGE_SCHEME: "$(THEOS_PACKAGE_SCHEME)")
$(info THEOS_DEVICE_USER:    "$(THEOS_DEVICE_USER)")
$(info THEOS:                "$(THEOS)")
$(info THEOS_DEVICE_IP:      "$(THEOS_DEVICE_IP)")
$(info FINALPACKAGE:         "$(FINALPACKAGE)")
$(info BETA:                 "$(BETA)")
$(info DEBUG:                "$(DEBUG)")
$(info MESSAGES:             "$(MESSAGES)")
$(info ARCHS:                "$(ARCHS)")
$(info TARGET:               "$(TARGET)")

ifeq ($(TWEAK_ENVIRONMENT), DEVICE)
	SDKVERSION = 13.7
	SYSROOT = $(THEOS)/sdks/iPhoneOS13.7.sdk
endif

GO_EASY_ON_ME = 1
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BigShotSnapper3Plugin

BigShotSnapper3Plugin_FILES = Tweak.x $(wildcard *.m)
BigShotSnapper3Plugin_FRAMEWORKS = UIKit CoreGraphics MobileCoreServices
BigShotSnapper3Plugin_CFLAGS = -fobjc-arc

ifeq ($(BETA), 1)
  BigShotSnapper3Plugin_CFLAGS += -DBETA -O1
  VERSION.EXTRAVERSION = ~beta
endif

include $(THEOS_MAKE_PATH)/tweak.mk

ifeq ($(TWEAK_ENVIRONMENT), DEVICE)
SUBPROJECTS += bigshotjbsnapper3plugin
include $(THEOS_MAKE_PATH)/aggregate.mk
endif

# This is for simject (instead of doing make package install do:
# make setup; /Users/jontelang/Desktop/simject/bin/resim;
setup:: clean all
	@sudo rm -f /opt/simject/$(TWEAK_NAME).dylib
	@sudo cp -v $(THEOS_OBJ_DIR)/$(TWEAK_NAME).dylib /opt/simject/$(TWEAK_NAME).dylib
	@sudo codesign -f -s - /opt/simject/$(TWEAK_NAME).dylib
	@sudo cp -v $(PWD)/$(TWEAK_NAME).plist /opt/simject
