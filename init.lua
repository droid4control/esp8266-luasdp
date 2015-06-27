local function start(nextfile)
	-- This code is based on https://github.com/marcoskirsch/nodemcu-httpserver

	local compileAndRemoveIfNeeded = function(f)
		if file.open(f) then
			file.close()
			print('Compiling:', f)
			node.compile(f)
			file.remove(f)
			print('Compiled:', f)
			collectgarbage()
			return 1
		end
		return 0
	end

	local serverFiles = { 'droidcontroller.lua', 'sdp.lua', 'sdppacket.lua', 'udpcomm.lua', 'waitip.lua' }
	local compiledfiles = 0
	for i, f in ipairs(serverFiles) do
		compiledfiles = compiledfiles + compileAndRemoveIfNeeded(f)
	end

	if (compiledfiles > 0) then
		print("Cleanup reboot after compiled ", compiledfiles, " files")
		return node.restart()
	end

	-- end of nodemcu-httpserver code

	return dofile(nextfile)
end

local pin_sdp_tx = 2
local pin_sdp_rx = 5

gpio.mode(pin_sdp_rx, gpio.OUTPUT)
gpio.mode(pin_sdp_tx, gpio.OUTPUT)
gpio.write(pin_sdp_rx, gpio.HIGH)
gpio.write(pin_sdp_tx, gpio.LOW)

led = function (name, status)
	local pin = nil
	if name == "RX" then pin = pin_sdp_rx end
	if name == "TX" then pin = pin_sdp_tx end
	if not pin then return end
	if status then
		gpio.write(pin, gpio.HIGH)
	else
		gpio.write(pin, gpio.LOW)
	end
end

tmr.alarm(0, 1000, 0, function() return start("droidcontroller.lc") end)
