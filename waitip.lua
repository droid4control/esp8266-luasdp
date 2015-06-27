-- from http://www.esp8266.com/viewtopic.php?f=18&t=628

return function (ip_try_max, ip_ok_callback)
	local l_ip_try = 0
	local l_ip_try_max = ip_try_max
	local l_ip_ok_callback = ip_ok_callback

	local waitip = function ()
		l_ip_try = l_ip_try + 1
		uart.write(0, ".")
		local wifi_ip = wifi.sta.getip()
		if wifi_ip then
			tmr.stop(0)
			waitip = nil
			print(" Got IP " .. wifi_ip .. "\n")
			return l_ip_ok_callback()
		elseif l_ip_try < l_ip_try_max then
			l_ip_try = l_ip_try + 1
			return
		else
			tmr.stop(0)
			print(" Connection timed out, restarting..")
			return node.restart()
		end
		return
	end
	uart.write(0, "Waiting for WiFi ")
	return tmr.alarm(0, 1000, 1, waitip)
end
