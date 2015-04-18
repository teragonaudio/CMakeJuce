CMakeJuce
=========

This project contains a single CMake file which can be included by
[Juce][juce] projects in order to build them with the project files generated
by Introjucer. Similar projects, like [cmake-juce][cmake-juce] attempt to
solve this problem by recreating the build targets like Juce does. This
project provides CMake with a way to build via the generated project files by
Introjucer.

The raison d'être of this project is the ability to use alternative IDEs such
as [CLion][clion] or [NetBeans][netbeans] with Juce projects. Since Introjucer
does not support CMake as a build target type, this file can allow one to
utilize Introjucer without being forced to a particular IDE.


Project setup
-------------

First, generate a new Juce project with Introjucer. Then add this project's
repository to your Juce project as a submodule under the `Builds` folder. So
an example project structure might look something like this:

    /path/to/YourProjectName
    ├── Builds
    │   ├── CMakeJuce <-- This repo
    │   ├── Linux
    │   ├── MacOSX
    │   └── VisualStudio2013
    ├── CMakeLists.txt
    ├── YourProjectName.jucer
    ├── JuceLibraryCode
    │   ├── AppConfig.h
    │   ├── JuceHeader.h
    │   ├── ReadMe.txt
    │   └── modules
    ├── LICENSE
    ├── README.md
    ├── Source
    │   ├── PluginEditor.cpp
    │   ├── PluginEditor.h
    │   ├── PluginProcessor.cpp
    │   └── PluginProcessor.h


Create the following `CMakeLists.txt` file in your project's top-level
directory:

```cmake
    cmake_minimum_required(VERSION 2.8)
    project(YourProjectName)

    if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
      add_subdirectory(Builds/MacOSX)
    elseif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
      add_subdirectory(Builds/Linux)
    endif()
```

`YourProjectName` should match the project name which you made in Introjucer.
For each platform that you want to build, create a `CMakeLists.txt` file in
that subdirectory (for instance, under `Builds/Linux` or `Builds/MacOSX`). It
should contain the following:

```cmake
cmake_minimum_required(VERSION 2.8)
include(../CMakeJuce/juce.cmake)
```

The reason that this is required is that we want the `include` to come from
the same directory as the Introjucer-generated build file. That way, compiler
errors will have correct relative paths and be rendered as links in IDEs that
support this.


Usage
-----

Once you have the initial project set up, point your CMake-supported IDE to
the top-level `CMakeLists.txt` file and everything should work out! This
project will generate for you two targets, `build_YourProjectName` and
`virtual_YourProjectName`. Set `build_YourProjectName` as the compiler target
as the `virtual_YourProjectName` is only used to give a target to the IDE for
correct indexing of the project's source code.


[juce]: http://www.juce.com
[cmake-juce]: https://github.com/nclack/cmake-juce
[clion]: https://www.jetbrains.com/clion/
[netbeans]: https://netbeans.org/features/cpp/
