TARGET := iphone:clang:14.5

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = sonitusPreferences

THEOS_PACKAGE_SCHEME=rootless

ARCHS = arm64e
$(BUNDLE_NAME)_FILES = SPBRootListController.m SPBSonyListController.m PackageNameHeaderCell.m
$(BUNDLE_NAME)_FRAMEWORKS = UIKit BluetoothManager
$(BUNDLE_NAME)_EXTRA_FRAMEWORKS = Cephei CepheiPrefs
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
