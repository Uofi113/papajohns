export ARCHS = armv7 armv7s
export TARGET = iphone:clang:latest:6.0

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = PapaJohns

PapaJohns_FILES = src/main.m \
                  src/AppDelegate.m \
                  src/PJNetworkManager.m \
                  src/PJMenuItem.m \
                  src/PJCartItem.m \
                  src/PJCartManager.m \
                  src/PJGlossButton.m \
                  src/PJMenuCell.m \
                  src/PJSberCell.m \
                  src/PJMenuViewController.m \
                  src/PJAuthViewController.m \
                  src/PJItemDetailViewController.m \
                  src/PJCartViewController.m

PapaJohns_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore
PapaJohns_CFLAGS     = -fobjc-arc
PapaJohns_INSTALL_PATH = /Applications

include $(THEOS_MAKE_PATH)/application.mk
