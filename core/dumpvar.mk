# ---------------------------------------------------------------
# the setpath shell function in envsetup.sh uses this to figure out
# what to add to the path given the config we have chosen.
ifeq ($(CALLED_FROM_SETUP),true)

ifneq ($(filter /%,$(HOST_OUT_EXECUTABLES)),)
ABP:=$(HOST_OUT_EXECUTABLES)
else
ABP:=$(PWD)/$(HOST_OUT_EXECUTABLES)
endif

ANDROID_BUILD_PATHS := $(ABP)
ANDROID_PREBUILTS := prebuilt/$(HOST_PREBUILT_TAG)
ANDROID_GCC_PREBUILTS := prebuilts/gcc/$(HOST_PREBUILT_TAG)

# The "dumpvar" stuff lets you say something like
#
#     CALLED_FROM_SETUP=true \
#       make -f config/envsetup.make dumpvar-TARGET_OUT
# or
#     CALLED_FROM_SETUP=true \
#       make -f config/envsetup.make dumpvar-abs-HOST_OUT_EXECUTABLES
#
# The plain (non-abs) version just dumps the value of the named variable.
# The "abs" version will treat the variable as a path, and dumps an
# absolute path to it.
#
dumpvar_goals := \
	$(strip $(patsubst dumpvar-%,%,$(filter dumpvar-%,$(MAKECMDGOALS))))
ifdef dumpvar_goals

  ifneq ($(words $(dumpvar_goals)),1)
    $(error Only one "dumpvar-" goal allowed. Saw "$(MAKECMDGOALS)")
  endif

  # If the goal is of the form "dumpvar-abs-VARNAME", then
  # treat VARNAME as a path and return the absolute path to it.
  absolute_dumpvar := $(strip $(filter abs-%,$(dumpvar_goals)))
  ifdef absolute_dumpvar
    dumpvar_goals := $(patsubst abs-%,%,$(dumpvar_goals))
    ifneq ($(filter /%,$($(dumpvar_goals))),)
      DUMPVAR_VALUE := $($(dumpvar_goals))
    else
      DUMPVAR_VALUE := $(PWD)/$($(dumpvar_goals))
    endif
    dumpvar_target := dumpvar-abs-$(dumpvar_goals)
  else
    DUMPVAR_VALUE := $($(dumpvar_goals))
    dumpvar_target := dumpvar-$(dumpvar_goals)
  endif

.PHONY: $(dumpvar_target)
$(dumpvar_target):
	@echo $(DUMPVAR_VALUE)

endif # dumpvar_goals

ifneq ($(dumpvar_goals),report_config)
PRINT_BUILD_CONFIG:=
endif

endif # CALLED_FROM_SETUP

-include $(TOPDIR)vendor/pac/tools/colors.mk

ifneq ($(PRINT_BUILD_CONFIG),)
HOST_OS_EXTRA:=$(shell python -c "import platform; print(platform.platform())")
$(info $(BLDMAG)$(LINE)$(RST))
$(info   PLATFORM_VERSION_CODENAME=$(BLDCYA)$(PLATFORM_VERSION_CODENAME)$(RST))
$(info   PLATFORM_VERSION=$(BLDCYA)$(PLATFORM_VERSION)$(RST))
$(info   PAC_VERSION=$(BLDCYA)$(PAC_BUILD_VERSION)$(RST))
$(info   TARGET_PRODUCT=$(BLDCYA)$(TARGET_PRODUCT)$(RST))
$(info   TARGET_BUILD_VARIANT=$(BLDCYA)$(TARGET_BUILD_VARIANT)$(RST))
$(info   TARGET_BUILD_TYPE=$(BLDCYA)$(TARGET_BUILD_TYPE)$(RST))
ifdef TARGET_BUILD_APPS
$(info   TARGET_BUILD_APPS=$(BLDCYA)$(TARGET_BUILD_APPS)$(RST))
endif
$(info   TARGET_ARCH=$(BLDCYA)$(TARGET_ARCH)$(RST))
$(info   TARGET_ARCH_VARIANT=$(BLDCYA)$(TARGET_ARCH_VARIANT)$(RST))
$(info   TARGET_CPU_VARIANT=$(BLDCYA)$(TARGET_CPU_VARIANT)$(RST))
ifdef TARGET_2ND_ARCH
$(info   TARGET_2ND_ARCH=$(BLDCYA)$(TARGET_2ND_ARCH)$(RST))
$(info   TARGET_2ND_ARCH_VARIANT=$(BLDCYA)$(TARGET_2ND_ARCH_VARIANT)$(RST))
$(info   TARGET_2ND_CPU_VARIANT=$(BLDCYA)$(TARGET_2ND_CPU_VARIANT)$(RST))
endif
$(info   HOST_ARCH=$(BLDCYA)$(HOST_ARCH)$(RST))
$(info   HOST_OS=$(BLDCYA)$(HOST_OS)$(RST))
$(info   HOST_OS_EXTRA=$(BLDCYA)$(HOST_OS_EXTRA)$(RST))
$(info   HOST_BUILD_TYPE=$(BLDCYA)$(HOST_BUILD_TYPE)$(RST))
$(info   BUILD_ID=$(BLDCYA)$(BUILD_ID)$(RST))
$(info   OUT_DIR=$(BLDCYA)$(OUT_DIR)$(RST))
ifeq ($(CYNGN_TARGET),true)
$(info   CYNGN_TARGET=$(BLDCYA)$(CYNGN_TARGET)$(RST))
$(info   CYNGN_FEATURES=$(BLDCYA)$(CYNGN_FEATURES)$(RST))
endif
$(info $(BLDMAG)$(LINE)$(RST))
endif
