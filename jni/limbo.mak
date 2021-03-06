# COMMON VARS
include $(LIMBO_JNI_ROOT)/android-config.mak

LIMBO_SRC_FILES = \
		  ./limbo/vm-executor-jni.c \
		  ./limbo/cpu-features.c

QEMU_NEED_CPU_DEF = \
        -DNEED_CPU_H

LOCAL_CFLAGS    :=

LOCAL_QEMU_CUSTOM_CFLAGS    := \
	-I$(LOCAL_PATH)/qemu/i386-softmmu \
	-I$(LOCAL_PATH)/qemu/slirp	-I$(LOCAL_PATH)	\
	-I$(LOCAL_PATH)/qemu	\
	-I$(LOCAL_PATH)/qemu/fpu	\
	-I$(LOCAL_PATH)/qemu/linux-headers	\
	-I$(LOCAL_PATH)/qemu/tcg	\
	-I$(LOCAL_PATH)/qemu/tcg/tci	\
	-I$(LOCAL_PATH)/qemu/tcg/i386 \
	 -D_FORTIFY_SOURCE=2	-D_GNU_SOURCE	\
	-D_FILE_OFFSET_BITS=64	-D_LARGEFILE_SOURCE	\
	-fno-strict-aliasing		-fstack-protector-all \
	-DHAS_AUDIO	\
	-DHAS_AUDIO_CHOICE \
	-I$(LOCAL_PATH)/qemu/linux-headers	\
	-I$(LOCAL_PATH)/..	-I$(LOCAL_PATH)/qemu/target-i386 \
	-DNEED_CPU_H	-pthread	-I$(LOCAL_PATH)/glib	\
	-I$(LOCAL_PATH)/glib/glib \
	-I$(NDK_ROOT)/sources/android/cpufeatures \
	-pthread	-I$(LOCAL_PATH)/glib	-I$(LOCAL_PATH)/glib/glib \
        -lm 


LOCAL_SRC_FILES :=
LOCAL_LDLIBS    :=   -lpthread -ldl -lutil \
	-lrt -pthread -pthread -lgthread-2.0 -lrt -lglib-2.0

EXTRA_LIBS := -luuid -ljpeg -lpng12

## OPTIONAL OPTIMIZATION FLAGS
OPTIM = \
-ffloat-store \
-ffast-math \
-fno-rounding-math \
-fno-signaling-nans \
-fcx-limited-range \
-fno-math-errno \
-funsafe-math-optimizations \
-fassociative-math \
-freciprocal-math \
-fassociative-math \
-freciprocal-math \
-ffinite-math-only \
-fno-signed-zeros \
-fno-trapping-math \
-frounding-math \
-fsingle-precision-constant \
-fcx-limited-range \
-fcx-fortran-rules


ANDROID_CFLAGS := $(ANDROID_CFLAGS) -I. -DANDROID

CUSTOM_ANDROID_CFLAGS = -Wa,--noexecstack \
	$(SYSTEM_INCLUDE)

CFILES:=

LIMBO_CFILES:= $(LIMBO_SRC_FILES)

OBJS=$(CFILES:%.c=%.o)

LIMBO_OBJS=$(LIMBO_CFILES:%.c=%.o)

LIBLIMBO = ../obj/local/$(APP_ABI)/liblimbo.so

all: $(OBJS) \
	$(LIMBO_OBJS) \
	liblimbo

# Target specific variable to use different flags
$(LIMBO_OBJS): EXTRA_FLAGS:= $(LOCAL_QEMU_CUSTOM_CFLAGS) $(LOCAL_LIMBO_CFLAGS)

limbo/cpu-features.o: $(NDK_ROOT)/sources/android/cpufeatures/cpu-features.c
	@echo "\n[Compiling] " $<
	$(CC) $(CFLAGS) $(EXTRA_DEFS) $(ARCH_CFLAGS) $(LOCAL_CFLAGS) $(EXTRA_FLAGS) \
	$(ANDROID_CFLAGS) $(CUSTOM_ANDROID_CFLAGS) -o $@ -c $(NDK_ROOT)/sources/android/cpufeatures/cpu-features.c 

%.o: %.c
	@echo "\n[Compiling] " $<
	$(CC) $(CFLAGS) $(EXTRA_DEFS) $(ARCH_CFLAGS) $(LOCAL_CFLAGS) $(EXTRA_FLAGS) \
	$(ANDROID_CFLAGS) $(CUSTOM_ANDROID_CFLAGS) -o $@ -c $<

clean:
	-rm $(LIBLIMBO)  \
	$(OBJS) \
	$(LIMBO_OBJS) 

veryclean:
	-find . -name *.o -exec rm -rf {} \;

liblimbo:
	$(LNK) -Wl,-soname,$(LIBLIMBO) \
	-shared $(SYS_ROOT) \
	$(LIMBO_OBJS) \
	$(GCC_STATIC) \
	-Wl,--no-undefined -Wl,-z,noexecstack  \
	$(USR_LIB) \
	-llog   \
    -ldl \
	-o $(LIBLIMBO)

### end of qemu
