####
# fprime-zephyr-semtech-modules.cmake:
#
# Registers the Semtech USP core library (lib/usp) and its Zephyr integration (lib/usp_zephyr) as Zephyr modules.
# Include this file from the project's top-level CMakeLists.txt before `find_package(Zephyr)`.
#
# Projects that already supply usp/usp_zephyr through west.yml must not include this file; Zephyr rejects duplicate
# module names.
####
set(FPRIME_ZEPHYR_SEMTECH_DIR "${CMAKE_CURRENT_LIST_DIR}/..")
cmake_path(NORMAL_PATH FPRIME_ZEPHYR_SEMTECH_DIR)
foreach(_module IN ITEMS usp usp_zephyr)
    set(_module_dir "${FPRIME_ZEPHYR_SEMTECH_DIR}lib/${_module}")
    if (NOT EXISTS "${_module_dir}/zephyr/module.yml")
        message(FATAL_ERROR "${_module_dir} is not initialized. Run `git submodule update --init --recursive`.")
    endif()
    list(APPEND ZEPHYR_EXTRA_MODULES "${_module_dir}")
endforeach()
