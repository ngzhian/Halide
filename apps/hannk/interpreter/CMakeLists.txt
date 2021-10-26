include("../../../cmake/Wasm.cmake")

if (Halide_TARGET MATCHES "wasm")
add_wasm_library(elementwise_program
  SRCS elementwise_program.cpp
  INCLUDES
    "$<BUILD_INTERFACE:${hannk_SOURCE_DIR}>"
    "${CMAKE_SOURCE_DIR}/../../src/runtime"
  )
add_wasm_library(interpreter_lower
  SRCS lower.cpp
  INCLUDES
    $<BUILD_INTERFACE:${hannk_SOURCE_DIR}>
    "${CMAKE_SOURCE_DIR}/../../src/runtime"
  )
add_wasm_library(interpreter
  SRCS
            allocation_planner.cpp
            interpreter.cpp
            interval.cpp
            model.cpp
            ops.cpp
            tensor.cpp
            transforms.cpp
  DEPS
  elementwise_program
  "${CMAKE_BINARY_DIR}/halide/add_uint8_uint8.a"
  "${CMAKE_BINARY_DIR}/halide/average_pool_uint8.a"
  "${CMAKE_BINARY_DIR}/halide/conv_u8_u8_u8.a"
  # op_impls
  interpreter_lower
  # elementwise_program here should be compiled to Wasm, but then hannk/halide requires elementwise_program compiled to host to run the generators, we might need to figure something out.
# elementwise_program op_impls interpreter_lower Halide::Runtime)
  INCLUDES
    $<BUILD_INTERFACE:${hannk_SOURCE_DIR}>
    "${CMAKE_SOURCE_DIR}/../../src/runtime"
    "${CMAKE_BINARY_DIR}"
  )
else ()
add_library(elementwise_program STATIC
            elementwise_program.cpp)
target_include_directories(elementwise_program PUBLIC $<BUILD_INTERFACE:${hannk_SOURCE_DIR}>)
target_link_libraries(elementwise_program PRIVATE Halide::Runtime)

add_library(interpreter_lower STATIC
            lower.cpp)
target_include_directories(interpreter_lower PUBLIC $<BUILD_INTERFACE:${hannk_SOURCE_DIR}>)
target_link_libraries(interpreter_lower PRIVATE Halide::Runtime)

add_library(interpreter STATIC
            allocation_planner.cpp
            interpreter.cpp
            interval.cpp
            model.cpp
            ops.cpp
            tensor.cpp
            transforms.cpp)
target_include_directories(interpreter PUBLIC $<BUILD_INTERFACE:${hannk_SOURCE_DIR}>)
target_link_libraries(interpreter PRIVATE elementwise_program op_impls interpreter_lower Halide::Runtime)

foreach (LIB IN ITEMS
            elementwise_program
            interpreter_lower
            interpreter)
    target_compile_options(${LIB}
                           PRIVATE
                           $<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-Woverloaded-virtual>
                           $<$<CXX_COMPILER_ID:GNU>:-Wsuggest-override>
                           $<$<CXX_COMPILER_ID:Clang,AppleClang>:-Winconsistent-missing-destructor-override>
                           $<$<CXX_COMPILER_ID:Clang,AppleClang>:-Winconsistent-missing-override>)
endforeach ()
endif ()
