# CMake links MSVC-like compilers with the linker directly. That bypasses the compiler
# driver, so driver options like -fsanitize=... never contribute their runtime libraries
# and library search paths to the link. These rules link through clang-cl instead.
#
# CMAKE_<LANG>_LINK_MODE stays LINKER, so pass linker options as -Xlinker instead of LINKER:.

if(PROJECT_MAKE_RULES_OVERRIDE)
    include(${PROJECT_MAKE_RULES_OVERRIDE})
endif()

foreach(LANGUAGE IN ITEMS C CXX)
    set(CMAKE_${LANGUAGE}_CREATE_CONSOLE_EXE "-Xlinker /subsystem:console")
    set(CMAKE_${LANGUAGE}_CREATE_WIN32_EXE "-Xlinker /subsystem:windows")
    set(CMAKE_${LANGUAGE}_LINK_EXECUTABLE
        "<CMAKE_${LANGUAGE}_COMPILER> <FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> -Xlinker /implib:<TARGET_IMPLIB> -Xlinker /pdb:<TARGET_PDB> <LINK_LIBRARIES>")
    set(CMAKE_${LANGUAGE}_CREATE_SHARED_LIBRARY
        "<CMAKE_${LANGUAGE}_COMPILER> <FLAGS> <LINK_FLAGS> -Xlinker /dll <OBJECTS> -o <TARGET> -Xlinker /implib:<TARGET_IMPLIB> -Xlinker /pdb:<TARGET_PDB> <LINK_LIBRARIES>")
    set(CMAKE_${LANGUAGE}_CREATE_SHARED_MODULE "${CMAKE_${LANGUAGE}_CREATE_SHARED_LIBRARY}")
endforeach()

# The linker flags that CMake initializes for MSVC now have to pass through the driver.
foreach(TARGET_TYPE IN ITEMS EXE SHARED MODULE)
    set(CMAKE_${TARGET_TYPE}_LINKER_FLAGS_INIT "")
    set(CMAKE_${TARGET_TYPE}_LINKER_FLAGS_DEBUG_INIT "-Xlinker /debug -Xlinker /INCREMENTAL")
    set(CMAKE_${TARGET_TYPE}_LINKER_FLAGS_RELWITHDEBINFO_INIT "-Xlinker /debug -Xlinker /INCREMENTAL")
    set(CMAKE_${TARGET_TYPE}_LINKER_FLAGS_RELEASE_INIT "-Xlinker /INCREMENTAL:NO")
    set(CMAKE_${TARGET_TYPE}_LINKER_FLAGS_MINSIZEREL_INIT "-Xlinker /INCREMENTAL:NO")
endforeach()
