cmake_minimum_required(VERSION 2.8)

# TODO: Document and split off to submodule

# Set the output destination
set(plugin_BUILDS_DIR ${PROJECT_SOURCE_DIR}/Builds)

# TODO: Add support for Windows
if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  set(plugin_BUILD_DIR ${plugin_BUILDS_DIR}/MacOSX)
  set(plugin_OUTPUT ${plugin_BUILDS_DIR}/build/${CMAKE_PROJECT_NAME}.vst)
  set(plugin_BUILDER "xcodebuild")
  set(CMAKE_SKIP_BUILD_RPATH TRUE)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  set(plugin_BUILD_DIR ${plugin_BUILDS_DIR}/Linux)
  set(plugin_OUTPUT ${plugin_BUILDS_DIR}/build/${CMAKE_PROJECT_NAME}.so)
  set(plugin_BUILDER "make -j8")
endif()

# Create a custom target that will build the generated project from Introjucer
set(main_TARGET build_${CMAKE_PROJECT_NAME})
add_custom_target(${main_TARGET} ALL
                  COMMAND ${plugin_BUILDER}
                  WORKING_DIRECTORY
                  ${plugin_BUILD_DIR}
                  COMMENT "Running external builder")

# Paths to plugin source & Juce sources
set(plugin_SOURCE_DIR ${PROJECT_SOURCE_DIR}/Source)
set(juce_SOURCE_DIR ${PROJECT_SOURCE_DIR}/JuceLibraryCode)

# TODO: How to add additional sources here?
set(plugin_SOURCES
    ${plugin_SOURCE_DIR}/PluginEditor.cpp
    ${plugin_SOURCE_DIR}/PluginProcessor.cpp
)

# TODO: How to add additional sources here?
set(plugin_HEADERS
    ${plugin_SOURCE_DIR}/PluginEditor.h
    ${plugin_SOURCE_DIR}/PluginProcessor.h
    ${juce_SOURCE_DIR}/AppConfig.h
    ${juce_SOURCE_DIR}/JuceHeader.h
)

# Glob all Juce sources so they are visible in the IDE
file(GLOB_RECURSE juce_SOURCES
     RELATIVE
     ${CMAKE_CURRENT_SOURCE_DIR}
     "${juce_SOURCE_DIR}/*.cpp"
     "${juce_SOURCE_DIR}/*.h"
     "${juce_SOURCE_DIR}/*.mm"
)

# Help some IDEs with #include completion
include_directories(${juce_SOURCE_DIR})

# Create a fake shared library so that the IDE project will associate the
# project sources with a target. This target will usually not compile since
# Introducer is doing some special things in the generated project, like
# setting compiler flags or not building certain files on a given platform.
#
# Rather than attempt to copy all of those things to these target, you should
# just use the build_PROJECT target in your IDE instead of virtual_TARGET.
set(virtual_TARGET virtual_${CMAKE_PROJECT_NAME})

add_library(virtual_TARGET SHARED
            ${plugin_SOURCES}
            ${plugin_HEADERS}
            ${juce_SOURCES}
)

set_target_properties(virtual_TARGET PROPERTIES PREFIX "")

set_property(TARGET virtual_TARGET
             APPEND
             PROPERTY
             IMPORTED_CONFIGURATIONS
             NOCONFIG)

set_target_properties(virtual_TARGET
                      PROPERTIES
                      IMPORTED_LOCATION_NOCONFIG
                      "${plugin_OUTPUT}")

# Allow the main target to build with the external build target
add_dependencies(virtual_TARGET ${main_TARGET})