####
# fprime-zephyr-semtech library manifest.
#
# Zephyr modules (lib/usp, lib/usp_zephyr) must be registered before find_package(Zephyr);
# see cmake/fprime-zephyr-semtech-modules.cmake.
####
add_fprime_subdirectory("${CMAKE_CURRENT_LIST_DIR}/fprime-zephyr-semtech/Drv")
