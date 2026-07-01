add_executable(test-gcc-arm-none-eabi EXCLUDE_FROM_ALL main.cpp)

target_link_options(test-gcc-arm-none-eabi PRIVATE
    -specs=nano.specs
    -specs=nosys.specs
)
