TARGET := iphone:clang:latest:13.3.1
INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64 arm64e

# INSTALL_TARGET_PROCESSES = Preferences

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Sonitus

$(TWEAK_NAME)_FILES = Tweak.xm SessionController.mm Sony.mm Bose.mm Soundcore.mm Sennheiser.mm Jabra.mm $(wildcard Actions/*.xm)
SUBPROJECTS += Preferences

$(TWEAK_NAME)_CFLAGS = -fobjc-arc -std=c++17

$(TWEAK_NAME)_FRAMEWORKS = Foundation ExternalAccessory CoreBluetooth UIKit
$(TWEAK_NAME)_EXTRA_FRAMEWORKS = Cephei
$(TWEAK_NAME)_LIBRARIES = powercuts

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

#after-install:: install.exec "killall -9 backboardd"
