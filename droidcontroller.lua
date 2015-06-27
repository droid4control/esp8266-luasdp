local secretkey = "sha25-secret-key"
local unscadahost = "api.uniscada.eu"
local uniscadaport = 44444

local sdpinterval = 5000	-- 5 sec
local sleeptime = 10000000	-- 10 sec

sleeptime = nil	-- test without sleep
sdpinterval = 1000	-- test with 1 sec sending interval

u = nil -- udpcomm
s = nil -- sdp
p = nil -- sdppacket

local function start_controller ()
	local function SendSDP()
		p.init()
		p.add_val("ADV", adc.read(0))
		p.add_val("TDV", adc.read(0)*100/1024-50)
		p.add_val("TMV", adc.read(0)*1000/1024-500)
		p.add_val("FMV", node.heap())
		s.send(p, function()
			print("Set timer for SendSDP in ", sdpinterval)
			tmr.alarm(1, sdpinterval, 0, SendSDP)
		end)
		return collectgarbage()
	end

	led("RX", false)
	print "start_controller"
	local id = string.gsub(wifi.sta.getmac(), "(:)", function(a) return "" end)

	collectgarbage()
	u = require "udpcomm"
	u.init(unscadahost, uniscadaport)

	s = require "sdp"
	s.init(id, secretkey, u)
	s.sleep_after_ack(sleeptime)

	p = require "sdppacket"

	-- send empty packet to get nonce
	p.init()
	s.send(p, SendSDP)
	collectgarbage()
end

local function bootsrtap ()
	led("RX", true)
	print "bootsrtap"
	return dofile('waitip.lc')(20, start_controller)
end

led("RX", false)
led("TX", false)
tmr.alarm(0, 1000, 0, bootsrtap)
