set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

find_program(CMAKE_C_COMPILER NAMES arm-none-eabi-gcc REQUIRED)
find_program(CMAKE_CXX_COMPILER NAMES arm-none-eabi-g++ REQUIRED)
find_program(CMAKE_ASM_COMPILER NAMES arm-none-eabi-as REQUIRED)
find_program(CMAKE_AR NAMES arm-none-eabi-ar REQUIRED)
find_program(CMAKE_RANLIB  NAMES arm-none-eabi-ranlib REQUIRED)
find_program(CMAKE_NM NAMES arm-none-eabi-nm REQUIRED)
find_program(CMAKE_LD_TOOL NAMES arm-none-eabi-ld REQUIRED)
find_program(CMAKE_APP_SIZE_TOOL NAMES arm-none-eabi-size REQUIRED)
find_program(CMAKE_OBJ_COPY_TOOL NAMES arm-none-eabi-objcopy REQUIRED)
find_program(CMAKE_OBJ_DUMP_TOOL NAMES arm-none-eabi-objdump REQUIRED)
find_program(CMAKE_DEBUG_TOOL NAMES gdb-multiarch REQUIRED)
