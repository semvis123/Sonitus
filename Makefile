TARGET := iphone:clang:13.3.1
INSTALL_TARGET_PROCESSES = SpringBoard
# INSTALL_TARGET_PROCESSES = Preferences

THEOS_DEVICE_IP = 192.168.2.9
include $(THEOS)/makefiles/common.mk
ARCHS = arm64 arm64e
TWEAK_NAME = Headphonify
$(TWEAK_NAME)_FILES = Tweak.xm SessionController.mm Sony.mm Bose.mm Soundcore.mm
SUBPROJECTS += Preferences
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -std=c++17
$(TWEAK_NAME)_FRAMEWORKS = Foundation ExternalAccessory
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
