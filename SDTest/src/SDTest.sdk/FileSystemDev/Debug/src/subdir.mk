################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
LD_SRCS += \
../src/lscript.ld 

C_SRCS += \
../src/fat_filesystem.c \
../src/main.c \
../src/platform.c \
../src/sd_filesystem.c \
../src/sgf_writer.c 

OBJS += \
./src/fat_filesystem.o \
./src/main.o \
./src/platform.o \
./src/sd_filesystem.o \
./src/sgf_writer.o 

C_DEPS += \
./src/fat_filesystem.d \
./src/main.d \
./src/platform.d \
./src/sd_filesystem.d \
./src/sgf_writer.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MicroBlaze gcc compiler'
	mb-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" -I../../FileSystemDev_bsp/microblaze_0/include -mlittle-endian -mxl-barrel-shift -mno-xl-soft-div -mcpu=v9.5 -mno-xl-soft-mul -mhard-float -Wl,--no-relax -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


