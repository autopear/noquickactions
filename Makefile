export ARCHS = arm64 armv7s armv7
export TARGET = iphone:9.0:9.0

include theos/makefiles/common.mk

TWEAK_NAME = NoQuickActions
NoQuickActions_FILES = Tweak.xm
NoQuickActions_FRAMEWORKS = UIKit

VERSION.INC_BUILD_NUMBER = 1

include $(THEOS_MAKE_PATH)/tweak.mk

before-package::
	find _ -name "*.plist" -exec plutil -convert binary1 {} \;
	find _ -name "*.strings" -exec chmod 0644 {} \;
	find _ -name "*.plist" -exec chmod 0644 {} \;
	find _ -exec touch -r _/Library/MobileSubstrate/DynamicLibraries/NoQuickActions.dylib {} \;

after-package::
	rm -fr .theos/packages/*
