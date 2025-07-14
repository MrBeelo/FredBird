#--SETTINGS--

#Some options: native, windows, macos, linux-gnu
PLATFORM ?= native

#Some options: native, x86_64, i386, aarm64
ARCH ?= native

#Run the project immediately after export?
RUN = true

#A search prefix is needed for the compiler to find all libraries for linux and macos. You can get away with using /usr if
#you're compiling on the same OS, otherwise you should provide a Linux/MacOS SDK and enter the usr folder from there.
SEARCH_PREFIX ?= your-sdk/usr

#LINUX ONLY: GlibC version to use. You should probably keep this at 2.41 unless it doesn't work.
LINUX_GLIBC_VERSION ?= 2.41 

#MACOS ONLY: The path for the mac sdk.
MAC_SDK_PATH ?= mac-sdk

#--SCRIPT--

FLAGS := 

ifeq ($(RUN), true)
	FLAGS += run
endif

ifeq ($(PLATFORM), linux-gnu)
	FLAGS += -Dtarget=$(ARCH)-$(PLATFORM).$(LINUX_GLIBC_VERSION) --search-prefix $(SEARCH_PREFIX) -p zig-out/$(PLATFORM)
else ifeq ($(PLATFORM), macos)
	FLAGS += -Dtarget=$(ARCH)-$(PLATFORM) -Dmacos-sdk-path=$(MAC_SDK_PATH) --search-prefix $(SEARCH_PREFIX) -p zig-out/$(PLATFORM)
else
	FLAGS += -Dtarget=$(ARCH)-$(PLATFORM) -p zig-out/$(PLATFORM)
endif

build:
	zig build $(FLAGS)
	
clean:
	rm -rf zig-out
	
clean-this:
	rm -rf zig-out/$(PLATFORM)

.PHONY:
