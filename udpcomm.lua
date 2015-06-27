local print = print
local net = net
local led = led

local M = {}

setfenv(1, M)

local unscadahost = nil
local uniscadaport

local sk

function init (host, port)
	sk = net.createConnection(net.UDP, 0)
	sk:connect(port, host)
end

function set_sdpreceiver (cb)
	sk:on("receive", cb)
end

function send (datagram)
	led("TX", true)
	print ("-- TX ----------\n" .. datagram .. "----------------\n")
	sk:send(datagram)
	led("TX", false)
end

return M
