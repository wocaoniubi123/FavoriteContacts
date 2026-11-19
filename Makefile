ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
    # rootless（Dopamine / palera1n 等）路径前缀是 /var/jb，最低 iOS 15
    TARGET := iphone:clang:latest:15.0
else
    TARGET := iphone:clang:latest:14.0
endif

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
FavoriteContacts_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat || true"
