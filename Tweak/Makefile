ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Axon
$(TWEAK_NAME)_FILES = Tweak.xm $(wildcard AXN*.m)
$(TWEAK_NAME)_FRAMEWORKS += QuartzCore WebKit MediaPlayer
ADDITIONAL_OBJCFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk