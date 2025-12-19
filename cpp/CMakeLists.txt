cmake_minimum_required(VERSION 3.10)
project(WindowsVolumeController)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find required Windows libraries
find_library(OLE32_LIBRARY ole32)
find_library(OLEAUT32_LIBRARY oleaut32)

# Source files
set(SOURCES
    VolumeController.cpp
)

# Create executable
add_executable(VolumeController ${SOURCES})

# Link libraries
target_link_libraries(VolumeController 
    ${OLE32_LIBRARY}
    ${OLEAUT32_LIBRARY}
)

# Set compiler-specific options
if(MSVC)
    target_compile_options(VolumeController PRIVATE /W4)
    target_compile_definitions(VolumeController PRIVATE _CRT_SECURE_NO_WARNINGS)
endif()

# Set output directory
set_target_properties(VolumeController PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Copy to a more convenient location
add_custom_command(TARGET VolumeController POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    $<TARGET_FILE:VolumeController>
    ${CMAKE_SOURCE_DIR}/VolumeController.exe
)