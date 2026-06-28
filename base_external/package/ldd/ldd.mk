
##############################################################
#
# LDD
#
##############################################################

LDD_VERSION = 8ce3d151b3f69de0cb585b9d295905b135d438a0
LDD_SITE = git@github.com:cu-ecen-aeld/assignment-7-PrayagKakoty.git
LDD_SITE_METHOD = git
LDD_GIT_SUBMODULES = YES

LDD_DEPENDENCIES = linux

define LDD_BUILD_CMDS
	@echo "=== DEBUG: Checking where Buildroot extracted files are ==="
	ls -ls $(@D)
	@echo "==========================================================="
	@echo "=== Patching outdated kernel API (no_llseek -> noop_llseek) ==="
	find $(@D)/scull $(@D)/misc-modules -type f -name "*.c" -exec sed -i 's/\bno_llseek\b/noop_llseek/g' {} +

	@echo "=== Building Modules ==="

	$(MAKE) -C $(LINUX_DIR) $(LINUX_MAKE_FLAGS) \
		M=$(@D)/misc-modules \
		EXTRA_CFLAGS="-I$(@D)/include"\
		modules
	$(MAKE) -C $(LINUX_DIR) $(LINUX_MAKE_FLAGS) \
		M=$(@D)/scull \
		EXTRA_CFLAGS="-I$(@D)/include"\
		modules
endef

define LDD_INSTALL_TARGET_CMDS
	$(eval ACTUAL_LINUX_VERSION = $(shell $(MAKE) -C $(LINUX_DIR) --no-print-directory kernelrelease))
	$(INSTALL) -d $(TARGET_DIR)/lib/modules/$(ACTUAL_LINUX_VERSION)/extra
	
	if [ -f $(@D)/misc-modules/hello.ko ]; then \
		$(INSTALL) -m 0644 $(@D)/misc-modules/*.ko $(TARGET_DIR)/lib/modules/$(ACTUAL_LINUX_VERSION)/extra/; \
	fi

	if [ -f $(@D)/scull/scull.ko ]; then \
		$(INSTALL) -m 0644 $(@D)/scull/*.ko $(TARGET_DIR)/lib/modules/$(ACTUAL_LINUX_VERSION)/extra/; \
	fi
endef

define LDD_REBUILD_DEPMOD
	$(eval ACTUAL_LINUX_VERSION = $(shell $(MAKE) -C $(LINUX_DIR) --no-print-directory kernelrelease))
	$(HOST_DIR)/sbin/depmod -b $(TARGET_DIR) $(LINUX_VERSION)
endef

LDD_ROOTFS_PRE_CMD_HOOKS += LDD_REBUILD_DEPMOD


$(eval $(generic-package))
