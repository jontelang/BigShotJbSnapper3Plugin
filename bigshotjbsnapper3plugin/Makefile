TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BigShotJbSnapper3Plugin

BigShotJbSnapper3Plugin_FILES = Tweak.x
BigShotJbSnapper3Plugin_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
