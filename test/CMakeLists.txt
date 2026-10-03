####
# Host-side unit tests for Drv/UspRadio.
#
# These sources have no F Prime, Zephyr, or USP dependencies. LINK_PROFILES_USE_HOST_TYPES makes the headers use
# <cstdint> types instead of F Prime types. test_LinkProfiles.cpp defines it itself.
#
#   cmake -S test -B build/test && cmake --build build/test && ctest --test-dir build/test
####
cmake_minimum_required(VERSION 3.16)
project(fprime-zephyr-semtech-host-tests CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(GTest QUIET)
if (NOT GTest_FOUND)
    include(FetchContent)
    FetchContent_Declare(googletest
        URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.tar.gz
        URL_HASH SHA256=8ad598c73ad796e0d8280b082cebd82a630d73e73cd3c70057938a6501bba5d7
    )
    FetchContent_MakeAvailable(googletest)
endif()

enable_testing()

set(LIBRARY_ROOT "${CMAKE_CURRENT_LIST_DIR}/..")
set(USP_RADIO_DIR "${LIBRARY_ROOT}/fprime-zephyr-semtech/Drv/UspRadio")

function(add_usp_radio_test NAME)
    cmake_parse_arguments(TEST "HOST_TYPES" "" "SOURCES" ${ARGN})
    add_executable(${NAME} ${TEST_SOURCES})
    target_include_directories(${NAME} PRIVATE "${LIBRARY_ROOT}")
    if (TEST_HOST_TYPES)
        target_compile_definitions(${NAME} PRIVATE LINK_PROFILES_USE_HOST_TYPES)
    endif()
    target_link_libraries(${NAME} PRIVATE GTest::gtest_main)
    add_test(NAME ${NAME} COMMAND ${NAME})
endfunction()

add_usp_radio_test(test_LinkProfiles SOURCES "${USP_RADIO_DIR}/test/ut/test_LinkProfiles.cpp")
add_usp_radio_test(test_ProfilePolicy HOST_TYPES SOURCES
    "${USP_RADIO_DIR}/test/ut/test_ProfilePolicy.cpp"
    "${USP_RADIO_DIR}/ProfilePolicy.cpp"
)
add_usp_radio_test(test_RadioHeadShim HOST_TYPES SOURCES "${USP_RADIO_DIR}/test/ut/test_RadioHeadShim.cpp")
add_usp_radio_test(test_TxOutcomePolicy SOURCES "${USP_RADIO_DIR}/test/ut/test_TxOutcomePolicy.cpp")
