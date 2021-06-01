TARGET := iphone:clang:13.3.1

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = headphonifyPreferences

headphonifyPreferences_FILES = HPBRootListController.m
headphonifyPreferences_FRAMEWORKS = UIKit BluetoothManager
headphonifyPreferences_PRIVATE_FRAMEWORKS = Preferences
headphonifyPreferences_INSTALL_PATH = /Library/PreferenceBundles
headphonifyPreferences_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
