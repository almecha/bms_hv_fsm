##########################################################################################################################
# File automatically-generated by STM32forVSCode
##########################################################################################################################

# ------------------------------------------------
# Generic Makefile (based on gcc)
#
# ChangeLog :
#   2024-04-27 - Added env file inclusion. 
#                Added way to overide: build directory, target name and optimisation.
#                Added GCC_PATH by env file to not make the makefile machine dependent.
#                Currently folder structure in build directory is preserved
#                Switching of debug/release build output folder now happens based on debug flag
#   2017-02-10 - Several enhancements + project update mode
#   2015-07-22 - first version
# ------------------------------------------------

######################################
# Environment Variables
######################################
# Imports the environment file in which the compiler and other tooling is set
# for the build machine.
# This can also be used to overwrite some makefile variables
file_exists = $(or $(and $(wildcard $(1)),1),0)
ifeq ($(call file_exists,.stm32env),1)
  include .stm32env
endif

######################################
# Target
######################################
# This is the name of the embedded target which will be build
# The final file name will also have debug or release appended to it.
TARGET ?= bms_hv_fsm

#######################################
# Build directories
#######################################
# Build path can be overwritten when calling make or setting the environment variable
# in .stm32env

BUILD_DIRECTORY ?= build


######################################
# Optimization
######################################
# Optimization is switched based upon the DEBUG variable. If set to 1
# it will be build in debug mode with the Og optimization flag (optimized for debugging).
# If set to 0 (false) then by default the variable is used in the configuration yaml
# This can also be overwritten using the environment variable or by overwriting it
# by calling make with the OPTIMIZATION variable e.g.:
# make -f STM32Make.make -j 16  OPTIMIZATION=Os

# variable which determines if it is a debug build
DEBUG ?= 1

# debug flags when debug is defined
OPTIMIZATION ?= -Og

RELEASE_DIRECTORY = $(BUILD_DIRECTORY)/debug
ifeq ($(DEBUG),1)
  # Sets debugging optimization -Og and the debug information output
  OPTIMIZATION_FLAGS += -Og -g -gdwarf -ggdb
  $(TARGET) := $(TARGET)-debug
  RELEASE_DIRECTORY := $(BUILD_DIRECTORY)/debug
else
  OPTIMIZATION_FLAGS += $(OPTIMIZATION)
  $(TARGET) := $(TARGET)-release
  RELEASE_DIRECTORY := $(BUILD_DIRECTORY)/release
endif

######################################
# source
######################################
# C sources
C_SOURCES =  \
Core/Src/L9963_utils.c \
Core/Src/adc.c \
Core/Src/bms_hv_fsm.c \
Core/Src/bms_hv_fsm_weak.c \
Core/Src/can.c \
Core/Src/gpio.c \
Core/Src/main.c \
Core/Src/ntc.c \
Core/Src/spi.c \
Core/Src/stm32_if.c \
Core/Src/stm32f4xx_hal_msp.c \
Core/Src/stm32f4xx_it.c \
Core/Src/syscalls.c \
Core/Src/sysmem.c \
Core/Src/system_stm32f4xx.c \
Core/Src/usart.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_adc.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_adc_ex.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_can.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_cortex.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma_ex.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_exti.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash_ex.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash_ramfunc.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_gpio.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr_ex.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc_ex.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_spi.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_tim.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_tim_ex.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_uart.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_ll_adc.c \
Lib/stmlibs/fsm/fsm.c


CXX_SOURCES = \


# ASM sources
ASM_SOURCES =  \
startup_stm32f446xx.s


#######################################
# Tools
#######################################
ARM_PREFIX = arm-none-eabi-
POSTFIX = "
PREFIX = "
# The gcc compiler bin path can be defined in the make command via ARM_GCC_PATH variable (e.g.: make ARM_GCC_PATH=xxx)
# or it can be added to the PATH environment variable.
# By default the variable be used from the environment file: .stm32env.
# if it is not defined

ifdef ARM_GCC_PATH
    CC = $(PREFIX)$(ARM_GCC_PATH)/$(ARM_PREFIX)gcc$(POSTFIX)
    CXX = $(PREFIX)$(ARM_GCC_PATH)/$(ARM_PREFIX)g++$(POSTFIX)
    AS = $(PREFIX)$(ARM_GCC_PATH)/$(ARM_PREFIX)gcc$(POSTFIX) -x assembler-with-cpp
    CP = $(PREFIX)$(ARM_GCC_PATH)/$(ARM_PREFIX)objcopy$(POSTFIX)
    SZ = $(PREFIX)$(ARM_GCC_PATH)/$(ARM_PREFIX)size$(POSTFIX)
    DP = $(PREFIX)$(ARM_GCC_PATH)/$(ARM_PREFIX)objdump$(POSTFIX)
else
  CC ?= $(ARM_PREFIX)gcc
  CXX ?= $(ARM_PREFIX)g++$
  AS ?= $(ARM_PREFIX)gcc -x assembler-with-cpp
  CP ?= $(ARM_PREFIX)objcopy
  SZ ?= $(ARM_PREFIX)size
  DP ?= $(ARM_PREFIX)objdump
endif

HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S
LSS = $(DP) -h -S


REMOVE_DIRECTORY_COMMAND = rm -fR
mkdir_function = mkdir -p $(1)
ifeq ($(OS),Windows_NT)
  convert_to_windows_path = $(strip $(subst /,\,$(patsubst %/,%,$(1))))
  REMOVE_DIRECTORY_COMMAND = cmd /c rd /s /q
  mkdir_function = cmd /e:on /c if not exist $(call convert_to_windows_path,$(1)) md $(call convert_to_windows_path,$(1))
endif


# Flash and debug tools
# Default is openocd however will be gotten from the env file when existing
OPENOCD ?= openocd


#######################################
# CFLAGS
#######################################
# cpu
CPU = -mcpu=cortex-m4

# fpu
FPU = -mfpu=fpv4-sp-d16

# float-abi
FLOAT-ABI = -mfloat-abi=hard

# mcu
MCU = $(CPU) -mthumb $(FPU) $(FLOAT-ABI)

# macros for gcc
# AS defines
AS_DEFS = 

# C defines
C_DEFS =  \
-DSTM32F446xx \
-DUSE_HAL_DRIVER


# CXX defines
CXX_DEFS =  \
-DSTM32F446xx \
-DUSE_HAL_DRIVER


# AS includes
AS_INCLUDES = \

# C includes
C_INCLUDES =  \
-ICore/Inc \
-IDrivers/CMSIS/Device/ST/STM32F4xx/Include \
-IDrivers/CMSIS/Include \
-IDrivers/STM32F4xx_HAL_Driver/Inc \
-IDrivers/STM32F4xx_HAL_Driver/Inc/Legacy \
-ILib/L9963E/inc \
-ILib/stmlibs \
-ILib/stmlibs/fsm



# compile gcc flags
ASFLAGS = $(MCU) $(AS_DEFS) $(AS_INCLUDES) $(C_INCLUDES) $(C_DEFS) $(OPTIMIZATION_FLAGS) 

CFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPTIMIZATION_FLAGS)

CXXFLAGS = $(MCU) $(CXX_DEFS) $(C_INCLUDES) $(OPTIMIZATION_FLAGS)

# Add additional flags
CFLAGS += -Wall -fdata-sections -ffunction-sections 
ASFLAGS += -Wall -fdata-sections -ffunction-sections 
CXXFLAGS += -fno-exceptions -fno-rtti 

# Generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"
CXXFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"

# Output a list file for the compiled source file.
# This is a representative of the source code in assembly
ASSEMBLER_LIST_OUTPUT_FLAG = -Wa,-a,-ad,-alms=$(call add_release_directory,$<,lst)
CFLAGS += $(ASSEMBLER_LIST_OUTPUT_FLAG)
CXXFLAGS += $(ASSEMBLER_LIST_OUTPUT_FLAG)

#######################################
# LDFLAGS
#######################################
# link script
LDSCRIPT = STM32F446VETx_FLASH.ld

# libraries
LIBS = -lc -lm -lnosys 
LIBDIR = \


# Additional LD Flags from config file
ADDITIONALLDFLAGS = -Wl,--print-memory-usage -specs=nano.specs 

LDFLAGS = $(MCU) $(ADDITIONALLDFLAGS) -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIRECTORY)/$(TARGET).map,--cref -Wl,--gc-sections

#######################################
# build the application
#######################################
add_release_directory = $(sort $(addprefix $(RELEASE_DIRECTORY)/,$(addsuffix .$(2),$(basename $(notdir $(1))))))



OBJECTS = $(call add_release_directory,$(C_SOURCES),o)
OBJECTS += $(call add_release_directory,$(CXX_SOURCES),o)
OBJECTS += $(call add_release_directory,$(ASM_SOURCES),o)
vpath %.c $(sort $(dir $(C_SOURCES)))
vpath %.cc $(sort $(dir $(CXX_SOURCES)))
vpath %.cp $(sort $(dir $(CXX_SOURCES)))
vpath %.cxx $(sort $(dir $(CXX_SOURCES)))
vpath %.cpp $(sort $(dir $(CXX_SOURCES)))
vpath %.c++ $(sort $(dir $(CXX_SOURCES)))
vpath %.C $(sort $(dir $(CXX_SOURCES)))
vpath %.CPP $(sort $(dir $(CXX_SOURCES)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))
vpath %.S $(sort $(dir $(ASM_SOURCES)))

#######################################
# all
#######################################
# note needs to be located as the first rule to be the default build rule
# default action: build all
all: $(RELEASE_DIRECTORY)/$(TARGET).elf $(RELEASE_DIRECTORY)/$(TARGET).hex $(RELEASE_DIRECTORY)/$(TARGET).bin $(RELEASE_DIRECTORY)/$(TARGET).lss 


# C build
$(RELEASE_DIRECTORY)/%.o: %.c STM32Make.make | $(RELEASE_DIRECTORY)
	$(CC) -c $(CFLAGS) $< -o $@

# C++ build 
$(RELEASE_DIRECTORY)/%.o: %.cc STM32Make.make | $(RELEASE_DIRECTORY)
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(RELEASE_DIRECTORY)/%.o: %.cp STM32Make.make | $(RELEASE_DIRECTORY)
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(RELEASE_DIRECTORY)/%.o: %.cxx STM32Make.make | $(RELEASE_DIRECTORY)
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(RELEASE_DIRECTORY)/%.o: %.cpp STM32Make.make | $(RELEASE_DIRECTORY)
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(RELEASE_DIRECTORY)/%.o: %.c++ STM32Make.make | $(RELEASE_DIRECTORY)
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(RELEASE_DIRECTORY)/%.o: %.C STM32Make.make | $(RELEASE_DIRECTORY)
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(RELEASE_DIRECTORY)/%.o: %.CPP STM32Make.make | $(RELEASE_DIRECTORY)
	$(CXX) -c $(CXXFLAGS) $< -o $@

#Assembly build
$(RELEASE_DIRECTORY)/%.o: %.s STM32Make.make | $(RELEASE_DIRECTORY)
	$(AS) -c $(ASFLAGS) $< -o $@

$(RELEASE_DIRECTORY)/%.o: %.S STM32Make.make | $(RELEASE_DIRECTORY)
	$(AS) -c $(ASFLAGS) $< -o $@

$(RELEASE_DIRECTORY)/%.o: %.sx STM32Make.make | $(RELEASE_DIRECTORY)
	$(AS) -c $(ASFLAGS) $< -o $@

$(RELEASE_DIRECTORY)/$(TARGET).elf: $(OBJECTS) STM32Make.make | $(RELEASE_DIRECTORY)
	@echo $(OBJECTS) > $@.in
	$(CC) @$@.in $(LDFLAGS) -o $@
	$(SZ) $@

$(RELEASE_DIRECTORY)/%.hex: $(RELEASE_DIRECTORY)/%.elf | $(RELEASE_DIRECTORY)
	$(HEX) $< $@

$(RELEASE_DIRECTORY)/%.bin: $(RELEASE_DIRECTORY)/%.elf | $(RELEASE_DIRECTORY)
	$(BIN) $< $@

$(RELEASE_DIRECTORY)/%.lss: $(RELEASE_DIRECTORY)/%.elf | $(RELEASE_DIRECTORY)
	$(LSS) $< > $@

$(RELEASE_DIRECTORY):
	$(call mkdir_function, $@)

$(BUILD_DIRECTORY): | $(RELEASE_DIRECTORY)
	$(call mkdir_function, $@)


#######################################
# flash
#######################################
flash: all
	"$(OPENOCD)" -f ./openocd.cfg -c "program $(RELEASE_DIRECTORY)/$(TARGET).elf verify reset exit"

#######################################
# erase
#######################################
erase: all
	"$(OPENOCD)" -f ./openocd.cfg -c "init; reset halt; stm32f4x mass_erase 0; exit"

#######################################
# clean up
#######################################
clean:
	$(REMOVE_DIRECTORY_COMMAND) $(BUILD_DIRECTORY)

#######################################
# custom makefile rules
#######################################

	
#######################################
# dependencies
#######################################
-include $(wildcard $(RELEASE_DIRECTORY)/*.d)

# *** EOF ***