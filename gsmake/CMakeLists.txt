file(GLOB_RECURSE src_files *.c *.cpp *.cxx *.h *.hpp)

add_executable(gsmake ${src_files})

target_compile_features(gsmake PUBLIC cxx_strong_enums)

target_link_libraries(gsmake lemon)

add_dependencies(gsmake lemon)

set_target_properties(
        gsmake
        PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin/
        RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_SOURCE_DIR}/bin/
        RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_SOURCE_DIR}/bin/)

if(WIN32)

    set_target_properties(
            gsmake
            PROPERTIES
            LINK_FLAGS "/level='requireAdministrator'")

endif(WIN32)
