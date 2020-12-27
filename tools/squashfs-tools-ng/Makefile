include $(TOPDIR)/rules.mk

PKG_NAME:=squashfs-tools-ng
PKG_VERSION:=1.0.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/AgentD/squashfs-tools-ng/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=7b1f198d6b1f49f253954e6108ab3e86a6a763b4dbf97758c31ff176bf694362

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/host-build.mk

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOST)/bin/
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/.libs/gensquashfs $(STAGING_DIR_HOST)/bin/gensquashfs
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/.libs/tar2sqfs $(STAGING_DIR_HOST)/bin/tar2sqfs
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/.libs/rdsquashfs $(STAGING_DIR_HOST)/bin/rdsquashfs
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/.libs/libsquashfs* $(STAGING_DIR_HOST)/lib/
endef

define Host/Clean
endef

$(eval $(call HostBuild))
