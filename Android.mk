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

ffmpeg: x264 $(PRODUCT_OUT)/obj/STATIC_LIBRARIES/libvpx_intermediates/libvpx.a
	cd $(TOP)/external/ffmpeg && \
	export PATH=$(FFMPEG_TCDIR):$(PATH) && \
	./configure \
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
		--extra-ldflags="-nostdlib -Wl,-dynamic-linker,/system/bin/linker,-z,muldefs,-T../../$(BUILD_SYSTEM)/armelf.x,-z,nocopyreloc,--no-undefined -L../../$(TARGET_OUT_STATIC_LIBRARIES) -L../../$(PRODUCT_OUT)/system/lib -L../../$(PRODUCT_OUT)/obj/STATIC_LIBRARIES/libvpx_intermediates -ldl -lc" \
		--extra-cflags="$(FFMPEG_COMPILER_FLAGS) -I../../bionic/libc/include -I../../bionic/libc/kernel/common -I../../bionic/libc/kernel/arch-arm -I../../bionic/libc/arch-arm/include -I../../bionic/libm/include -I../libvpx -I../x264" \
		--extra-libs="-lgcc" && \
	$(MAKE) TARGET_CRTBEGIN_DYNAMIC_O=../../$(TARGET_CRTBEGIN_DYNAMIC_O) TARGET_CRTEND_O=../../$(TARGET_CRTEND_O) $(FF_VERBOSE) && \
	$(MAKE) install DESTDIR=$(realpath $(TOP)/$(PRODUCT_OUT)/)
