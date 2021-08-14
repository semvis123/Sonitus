TARGET := iphone:clang:13.3.1
INSTALL_TARGET_PROCESSES = SpringBoard
# INSTALL_TARGET_PROCESSES = Preferences

THEOS_DEVICE_IP = 192.168.2.15
include $(THEOS)/makefiles/common.mk
ARCHS = arm64 arm64e
TWEAK_NAME = Sonitus
$(TWEAK_NAME)_FILES = Tweak.xm SessionController.mm Sony.mm Bose.mm Soundcore.mm Sennheiser.mm
SUBPROJECTS += Preferences
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -std=c++17
$(TWEAK_NAME)_FRAMEWORKS = Foundation ExternalAccessory CoreBluetooth
$(TWEAK_NAME)_EXTRA_FRAMEWORKS = Cephei
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
