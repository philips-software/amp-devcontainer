# This toolchain file enables cross-compilation from non-Windows hosts to Windows hosts using the
# GNU-style clang driver. It assumes the Windows SDK and CRT are installed at a path specified by
# WINDOWS_SDK_ROOT.
#
# The recommended way of installing the SDK and CRT is by using xwin (https://github.com/Jake-Shadle/xwin):
# $ xwin --accept-license splat --preserve-ms-arch-notation
#
# Unlike clang-cl, the GNU-style driver has no /winsdkdir and /vctoolsdir options, so the include and
# library directories of the SDK and CRT are passed explicitly.

set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(CMAKE_TRY_COMPILE_CONFIGURATION Release)

set(WINDOWS_SDK_ROOT "/winsdk" CACHE PATH "Path to a Windows SDK and CRT installation")
set(CMAKE_RC_STANDARD_INCLUDE_DIRECTORIES ${WINDOWS_SDK_ROOT}/sdk/include/um ${WINDOWS_SDK_ROOT}/sdk/include/ucrt ${WINDOWS_SDK_ROOT}/sdk/include/shared)

find_program(CMAKE_C_COMPILER NAMES clang REQUIRED)
find_program(CMAKE_CXX_COMPILER NAMES clang++ REQUIRED)
find_program(CMAKE_AR NAMES llvm-ar REQUIRED)
find_program(CMAKE_RANLIB NAMES llvm-ranlib REQUIRED)

# The target has to be known during compiler identification, otherwise CMake detects a
# MinGW environment and generates GNU-style link commands that lld-link does not accept.
foreach(LANGUAGE IN ITEMS ASM C CXX)
    set(CMAKE_${LANGUAGE}_COMPILER_TARGET x86_64-pc-windows-msvc)
endforeach()

# Repeated options are de-duplicated, so use the joined form of -isystem.
add_compile_options(
    -isystem${WINDOWS_SDK_ROOT}/crt/include
    -isystem${WINDOWS_SDK_ROOT}/sdk/include/ucrt
    -isystem${WINDOWS_SDK_ROOT}/sdk/include/um
    -isystem${WINDOWS_SDK_ROOT}/sdk/include/shared)
add_link_options(
    -L${WINDOWS_SDK_ROOT}/crt/lib/x64
    -L${WINDOWS_SDK_ROOT}/sdk/lib/ucrt/x64
    -L${WINDOWS_SDK_ROOT}/sdk/lib/um/x64)
