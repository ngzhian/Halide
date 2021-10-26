
function(add_wasm_library TARGET)
    set(options)
    set(oneValueArgs)
    set(multiValueArgs SRCS DEPS INCLUDES ENABLE_IF)
    cmake_parse_arguments(args "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (args_ENABLE_IF AND NOT (${args_ENABLE_IF}))
        return()
    endif ()

    # Conceptually, we want something like this:
    # add_executable(${TARGET} ${args_SRCS})
    # if (args_INCLUDES)
    #     target_include_directories("${TARGET}" PRIVATE ${args_INCLUDES})
    # endif()
    # if (args_DEPS)
    #     target_link_libraries(${TARGET} PRIVATE ${args_DEPS})
    # endif ()

    find_program(EMCC emcc HINTS "$ENV{EMSDK}/upstream/emscripten")

    if (NOT EMCC)
        message(FATAL_ERROR "Building tests or apps for WASM requires that EMSDK point to a valid Emscripten install.")
    endif ()

    set(EMCC_FLAGS
        -O3
        -g
        -std=c++17
        -Wall
        -Wcast-qual
        -Werror
        -Wignored-qualifiers
        -Wno-comment
        -Wno-psabi
        -Wno-unknown-warning-option
        -Wno-unused-function
        -Wno-unused-private-field
        -Wsign-compare
        -Wsuggest-override
        -s ASSERTIONS=1
        -s ALLOW_MEMORY_GROWTH=1
        -s WASM_BIGINT=1
        -s STANDALONE_WASM=1
        -s RELOCATABLE=1
        -s ENVIRONMENT=shell
        -s ERROR_ON_UNDEFINED_SYMBOLS=0
        -s LLD_REPORT_UNDEFINED
        --no-entry)

    set(SRCS)
    foreach (S IN LISTS args_SRCS)
        list(APPEND SRCS "${CMAKE_CURRENT_SOURCE_DIR}/${S}")
    endforeach ()

    set(INCLUDES)
    foreach (I IN LISTS args_INCLUDES)
        list(APPEND INCLUDES "-I${I}")
    endforeach ()

    set(DEPS)
    foreach (D IN LISTS args_DEPS)
        # list(APPEND DEPS $<TARGET_FILE:${D}>)
        if (${D} MATCHES ".a$")
          list(APPEND DEPS ${D})
        else ()
          list(APPEND DEPS ${D}.wasm)
        endif ()
    endforeach ()

    add_custom_command(OUTPUT "${TARGET}.wasm"
                       COMMAND ${EMCC} ${EMCC_FLAGS} ${INCLUDES} ${SRCS} ${DEPS} -o "${TARGET}.wasm"
                       DEPENDS ${SRCS} ${DEPS}
                       VERBATIM)

    add_custom_target("${TARGET}" ALL
                      DEPENDS "${TARGET}.wasm")

endfunction()

function(add_wasm_executable TARGET)
    set(options)
    set(oneValueArgs)
    set(multiValueArgs SRCS DEPS INCLUDES ENABLE_IF)
    cmake_parse_arguments(args "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (args_ENABLE_IF AND NOT (${args_ENABLE_IF}))
        return()
    endif ()

    # Conceptually, we want something like this:
    # add_executable(${TARGET} ${args_SRCS})
    # if (args_INCLUDES)
    #     target_include_directories("${TARGET}" PRIVATE ${args_INCLUDES})
    # endif()
    # if (args_DEPS)
    #     target_link_libraries(${TARGET} PRIVATE ${args_DEPS})
    # endif ()

    find_program(EMCC emcc HINTS "$ENV{EMSDK}/upstream/emscripten")

    if (NOT EMCC)
        message(FATAL_ERROR "Building tests or apps for WASM requires that EMSDK point to a valid Emscripten install.")
    endif ()

    set(EMCC_FLAGS
        -O3
        -g
        -std=c++17
        -Wall
        -Wcast-qual
        -Werror
        -Wignored-qualifiers
        -Wno-comment
        -Wno-psabi
        -Wno-unknown-warning-option
        -Wno-unused-function
        -Wno-unused-private-field
        -Wsign-compare
        -Wsuggest-override
        -s ASSERTIONS=1
        -s ALLOW_MEMORY_GROWTH=1
        -s WASM_BIGINT=1
        -s STANDALONE_WASM=1
        -s RELOCATABLE=1
        -s ERROR_ON_UNDEFINED_SYMBOLS=0
        -s LLD_REPORT_UNDEFINED
        -s ENVIRONMENT=shell)

    set(SRCS)
    foreach (S IN LISTS args_SRCS)
        list(APPEND SRCS "${CMAKE_CURRENT_SOURCE_DIR}/${S}")
    endforeach ()

    set(INCLUDES)
    foreach (I IN LISTS args_INCLUDES)
        list(APPEND INCLUDES "-I${I}")
    endforeach ()

    set(DEPS)
    set(LIBS) # like DEPS but with .wasm suffix.
    foreach (D IN LISTS args_DEPS)
        # list(APPEND DEPS $<TARGET_FILE:${D}>)
        list(APPEND DEPS ${D})
        list(APPEND LIBS ${D}.wasm)
    endforeach ()

    add_custom_command(OUTPUT "${TARGET}.wasm" "${TARGET}.js"
                       COMMAND ${EMCC} ${EMCC_FLAGS} ${INCLUDES} ${SRCS} ${LIBS} -o "${TARGET}.js"
                       DEPENDS ${SRCS} ${DEPS}
                       VERBATIM)

    add_custom_target("${TARGET}" ALL
                      DEPENDS "${TARGET}.wasm" "${TARGET}.js")

endfunction()
