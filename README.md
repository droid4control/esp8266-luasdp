# **SDP implementation in ESP8266 using lua** #

## Requirements:

- NodeMCU: [nodemcu-firmware](https://github.com/nodemcu/nodemcu-firmware)

## NodeMCU configuration

These lines should be enabled in [app/include/user_modules.h](https://github.com/nodemcu/nodemcu-firmware/blob/master/app/include/user_modules.h)
```c
  #define LUA_USE_MODULES_NODE
  #define LUA_USE_MODULES_FILE
  #define LUA_USE_MODULES_GPIO
  #define LUA_USE_MODULES_WIFI
  #define LUA_USE_MODULES_NET
  #define LUA_USE_MODULES_TMR
  #define LUA_USE_MODULES_ADC
  #define LUA_USE_MODULES_UART
  #define LUA_USE_MODULES_CRYPTO
```

You can use [NodeMCU custom build server](http://frightanic.com/nodemcu-custom-build/) to build your firmware without installing all necessary tools.

## Configuration

Wifi configuration is in [wifisetup.lua](https://github.com/droid4control/esp8266-luasdp/blob/master/wifisetup.lua)
```lua
wifi.setmode(wifi.STATION)
wifi.sta.config("your-ssid", "your-wifi-key")
```

UniSCADA configuration is in the beginning of [droidcontroller.lua](https://github.com/droid4control/esp8266-luasdp/blob/master/droidcontroller.lua)
```lua
local secretkey = "sha25-secret-key"
local unscadahost = "api.uniscada.eu"
local uniscadaport = 44444
```

## Install

- Copy all *.lua files to ESP8266 (use [nodemcu-uploader.py](https://github.com/kmpm/nodemcu-uploader), [luatool](https://github.com/4refr0nt/luatool) or any other upload tool)
- configure WiFi running [wifisetup.lua](https://github.com/droid4control/esp8266-luasdp/blob/master/wifisetup.lua)

```lua
> dofile "wifisetup.lua"
```

## Run

First restart compiles *.lua files, removes original source files from ESP8266 and restarts controller to start with maximum free heap.

Second restart waits IP address from WiFi using [waitip.lua](https://github.com/droid4control/esp8266-luasdp/blob/master/waitip.lua) and then starts start_controller() and SendSDP() loop in [droidcontroller.lua](https://github.com/droid4control/esp8266-luasdp/blob/master/droidcontroller.lua).

## Notes

Some settings/constant you might want to change
- Initial start timeout (1 sec) in [init.lua](https://github.com/droid4control/esp8266-luasdp/blob/master/init.lua)
- TX/RX LED pins (GPOI4, GPIO14) in [init.lua](https://github.com/droid4control/esp8266-luasdp/blob/master/init.lua)
- deep sleep time (none) or SDP sending interval (1 sec) in [droidcontroller.lua](https://github.com/droid4control/esp8266-luasdp/blob/master/droidcontroller.lua)
- SDP data fields (ADC value, temperature value from TC1047 via ADC in degrees an 1/10th degrees of Celsius, heap) in [droidcontroller.lua](https://github.com/droid4control/esp8266-luasdp/blob/master/droidcontroller.lua)
- Maximum IP wait time (20 × 1 sec) in [droidcontroller.lua](https://github.com/droid4control/esp8266-luasdp/blob/master/droidcontroller.lua) and [waitip.lua](https://github.com/droid4control/esp8266-luasdp/blob/master/waitip.lua)
- Maximum SDP ACK wait time (3 sec) in [sdp.lua](https://github.com/droid4control/esp8266-luasdp/blob/master/sdp.lua)
- Maximum number missing ACKs before controller reset (5) in [sdp.lua](https://github.com/droid4control/esp8266-luasdp/blob/master/sdp.lua)
