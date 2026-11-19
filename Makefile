TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = WeChat

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FavoriteContacts

FavoriteContacts_FILES = Tweak.xm \
	ZDHHCommon.m \
	ZDHHFavoriteBar.m \
	ZDHHSettingsViewController.m \
	ZDHHMembersViewController.m

FavoriteContacts_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-function
FavoriteContacts_FRAMEWORKS = UIKit Foundation QuartzCore
FavoriteContacts_PRIVATE_FRAMEWORKS =
FavoriteContacts_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat || true"
