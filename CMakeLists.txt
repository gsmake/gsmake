cmake_minimum_required(VERSION 3.3)
project(gsmake)

set(GSMAKE_VERSION "3.0.*")

# open user folders
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

if(MSVC)
    foreach(flag_var CMAKE_C_FLAGS CMAKE_CXX_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_CXX_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE CMAKE_CXX_FLAGS_RELEASE CMAKE_C_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO CMAKE_CXX_FLAGS_RELWITHDEBINFO)
        string(REGEX REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}")
        string(REGEX REPLACE "/MDd" "/MTd" ${flag_var} "${${flag_var}}")
        string(REGEX REPLACE "/W3" "/W4" ${flag_var} "${${flag_var}}")
    endforeach(flag_var)

    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4")
endif()

if(WIN32)
    add_definitions(/W4 /D_SCL_SECURE_NO_WARNINGS /D_CRT_SECURE_NO_WARNINGS /wd4267 /wd4127 /wd4100 /wd4701 /wd4602 /wd4431 /wd4193 /wd4161 /wd4244 /wd4702 /wd4324 /wd4055 /wd4054 /wd4018 /wd4310)
else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")
endif()

include_directories(${CMAKE_SOURCE_DIR}/lemon/src/main/cpp)

add_subdirectory(lemon)
add_subdirectory(gsmake)
