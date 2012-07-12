include $(CLEAR_VARS)
FFMPEG_TCDIR := $(realpath $(shell dirname $(TARGET_TOOLS_PREFIX)))
FFMPEG_TCPREFIX := $(shell basename $(TARGET_TOOLS_PREFIX))
# FIXME remove -fno-strict-aliasing once the aliasing violations are fixed
FFMPEG_COMPILER_FLAGS = $(subst -I ,-I../../,$(subst -include system/core/include/arch/linux-arm/AndroidConfig.h,,$(TARGET_GLOBAL_CFLAGS))) -fno-strict-aliasing -Wno-error=address -Wno-error=format-security
ifneq ($(strip $(SHOW_COMMANDS)),)
FF_VERBOSE="V=1"
endif

.PHONY: ffmpeg

droid: ffmpeg

systemtarball: ffmpeg

REALTOP=$(realpath $(TOP))

ffmpeg: x264 $(PRODUCT_OUT)/obj/STATIC_LIBRARIES/libvpx_intermediates/libvpx.a
	mkdir -p $(PRODUCT_OUT)/obj/ffmpeg
	cd $(PRODUCT_OUT)/obj/ffmpeg && \
	export PATH=$(FFMPEG_TCDIR):$(PATH) && \
	$(REALTOP)/external/ffmpeg/configure \
		--arch=arm \
		--target-os=linux \
		--prefix=/system \
		--bindir=/system/bin \
		--libdir=/system/lib \
		--enable-shared \
		--enable-gpl \
		--disable-avdevice \
		--enable-runtime-cpudetect \
		--enable-libvpx \
		--enable-libx264 \
		--enable-cross-compile \
		--cross-prefix=$(FFMPEG_TCPREFIX) \
		--extra-ldflags="-nostdlib -Wl,-dynamic-linker,/system/bin/linker,-z,muldefs$(shell if test $(PRODUCT_SDK_VERSION) -lt 16; then echo -n ',-T$(REALTOP)/$(BUILD_SYSTEM)/armelf.x'; fi),-z,nocopyreloc,--no-undefined -L$(REALTOP)/$(TARGET_OUT_STATIC_LIBRARIES) -L$(REALTOP)/$(PRODUCT_OUT)/system/lib -L$(REALTOP)/$(PRODUCT_OUT)/obj/STATIC_LIBRARIES/libvpx_intermediates -ldl -lc" \
		--extra-cflags="$(FFMPEG_COMPILER_FLAGS) -I$(REALTOP)/bionic/libc/include -I$(REALTOP)/bionic/libc/kernel/common -I$(REALTOP)/bionic/libc/kernel/arch-arm -I$(REALTOP)/bionic/libc/arch-arm/include -I$(REALTOP)/bionic/libm/include -I$(REALTOP)/external/libvpx -I$(REALTOP)/external/x264" \
		--extra-libs="-lgcc" && \
	$(MAKE) TARGET_CRTBEGIN_DYNAMIC_O=$(REALTOP)/$(TARGET_CRTBEGIN_DYNAMIC_O) TARGET_CRTEND_O=$(REALTOP)/$(TARGET_CRTEND_O) $(FF_VERBOSE) && \
	$(MAKE) install DESTDIR=$(REALTOP)/$(PRODUCT_OUT)
