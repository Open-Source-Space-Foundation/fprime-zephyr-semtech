# fprime-zephyr-semtech

F Prime + Zephyr support for Semtech radios through Semtech's Unified Software Platform (USP / LoRa Basics Modem RAL+RAC).

| Path | Contents |
|---|---|
| `lib/usp_zephyr` | Zephyr integration of USP (Zephyr module `usp_zephyr`): SX126x/LR11xx drivers, DT bindings, HAL |
| `lib/usp` | USP core library (Zephyr module `usp`): RAL/RALF, radio planner, RAC |
| `fprime-zephyr-semtech/Drv/UspRadio` | `Zephyr.UspRadio` F Prime component (`Svc.Com` radio driver) |

This library depends on [fprime-zephyr](https://github.com/fprime-community/fprime-zephyr).

## Setup

1. Add this repository as a submodule, e.g. `lib/fprime-zephyr-semtech`, and initialize it recursively:

   ```bash
   git submodule add <url> lib/fprime-zephyr-semtech
   git submodule update --init --recursive
   ```

2. Add it to `library_locations` in `settings.ini` after `fprime-zephyr`:

   ```ini
   library_locations: ./lib/fprime-zephyr:./lib/fprime-zephyr-semtech
   ```

3. Register the Zephyr modules in the project's top-level `CMakeLists.txt` before `find_package(Zephyr)`:

   ```cmake
   include("${CMAKE_CURRENT_LIST_DIR}/lib/fprime-zephyr-semtech/cmake/fprime-zephyr-semtech-modules.cmake")
   find_package(Zephyr ...)
   ```

   Do not also list `usp` or `usp_zephyr` in the project's `west.yml`.

4. Enable USP in the board defconfig or `prj.conf`:

   ```
   CONFIG_LORA_BASICS_MODEM_DRIVERS=y
   CONFIG_LORA_BASICS_MODEM_DRIVERS_RAL_RALF=y
   CONFIG_LORA_BASICS_MODEM_DRIVERS_EVENT_TRIGGER_GLOBAL_THREAD=y
   CONFIG_USP=y
   CONFIG_USP_MAIN_THREAD=y
   ```

   `CONFIG_LORA` must stay off. The radio node uses a USP binding (e.g. `semtech,sx1262-new`) and is selected with
   `chosen { zephyr,lorawan-transceiver = &<node>; }`.

## Usage

```cpp
#include "fprime-zephyr-semtech/Drv/UspRadio/RalSessionImpl.hpp"
#include "fprime-zephyr-semtech/Drv/UspRadio/UspRadio.hpp"

static Zephyr::RalSessionImpl ralSession(437400000U, 10);  // carrier Hz, TX power dBm

uspRadio.configure(ralSession);
uspRadio.startRadio(Zephyr::UspTransmitState::DISABLED);
```

`RalSessionImpl.cpp` builds only when `CONFIG_LORA_BASICS_MODEM_DRIVERS` is set.

## Host unit tests

```bash
cmake -S test -B build/test
cmake --build build/test
ctest --test-dir build/test
```

## Semtech libraries

`lib/usp` and `lib/usp_zephyr` are submodules. Each library's source depends on how many lines of code
Open-Source-Space-Foundation (OSSF) adds on top of the Semtech (Lora-net) release:

- Fewer than 20 lines: the submodule points at the Lora-net repository at a release tag, and the changes are kept in
  `patches/<library>/`.
- 20 to 50 lines: decided case by case.
- More than 50 lines: the submodule points at the OSSF fork, on a branch rebased onto the Lora-net release.

Both libraries are currently above 50 lines. Each uses its OSSF fork's `v1.2.1-ossf` branch, which is Lora-net v1.2.1
plus the following changes:

| Library | Change | Code lines |
|---|---|---|
| usp_zephyr | SX126x external RF-switch GPIOs (`tx-enable-gpios` / `rx-enable-gpios`) | 95 |
| usp_zephyr | Zephyr 4.3+: drop `select ZEPHYR_LORA_BASICS_MODEM_MODULE` | 1 |
| usp_zephyr | SX126x wake-up BUSY-poll settle delay | 1 |
| usp_zephyr | RAC API mutex in `protect_api_call` / `unprotect_api_call` | 5 |
| usp | Radio planner: exempt `UNLOCK_RADIO_ACCESS` from the failsafe panic | 1 |
| usp | Radio planner: lazy-sleep hysteresis via `STDBY_XOSC` fallback (`RP_LAZY_SLEEP_DELAY_MS`) | 64 |

v1.2.1 makes the SX126x `tx-power-cfg` devicetree property mandatory. Every `semtech,sx126x-new` node must now supply a
PA table. See `boards/shields/semtech_sx126xmbxxxs/semtech_sx1262_pa_cfg.dtsi` in `usp_zephyr` for the format.

## License

`fprime-zephyr-semtech/` is Apache-2.0 (see `LICENSE`). `lib/usp` and `lib/usp_zephyr` are Semtech code under their
own licenses (Clear BSD; see each `LICENSE.txt` / `LICENSES.txt`).
