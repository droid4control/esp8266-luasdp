local tmr = tmr
local require = require
local tostring = tostring
local string = string
local print = print
local crypto = crypto
local node = node
local led = led

local M = {}

setfenv(1, M)

local _id = nil
local _secretkey = nil
local _comm = nil
local _nonce = ""

local _in = nil
local _noack = 0

local _sleeptime = nil
local _rcvcb = nil

local function get_signature(data)
	if _nonce == "" then
		print "ERROR: nonce is not known yet"
	end
	return crypto.toBase64(crypto.hmac('sha256', _nonce .. data, _secretkey))
end

function _sdpreceiver(s, datagram)
	tmr.stop(3)	-- cancel RX timeout
	led("RX", true)
	print ("-- RX ----------\n" .. datagram .. "----------------\n")
	local signature = nil
	local nonce = nil
	local ack = false
	led("RX", false)
	local function ParseSDPLine(line)
		key, val = string.match(line, "(.*):(.*)")
		if not key or not val then return end
		if key == "in" then
			if tostring(_in) == val then
				ack = true
			else
				print "RCV wrong ACK"
			end
		elseif key == "sha256" then
			signature = val
		elseif key == "nonce" then
			nonce = val
		end
	end
	local function SDPCheckSignature (data, nonce, signature)
		local _packet = nil
		data:gsub("(.*)sha256:", function (x) _packet = x end)
		if not _packet then
			return false
		end
		local hmac = crypto.toBase64(crypto.hmac('sha256', nonce .. _packet, _secretkey))
		return hmac == signature
	end

	datagram:gsub("[^\r\n]+", ParseSDPLine)
	if not signature then
		print "ERROR: response is not signed"
		return
	end
	if nonce then
		if SDPCheckSignature(datagram, nonce, signature) then
			print("New nonce ACCEPTED")
			_nonce = nonce
			if _rcvcb then
				local cb = _rcvcb
				_rcvcb = nil
				return cb()
			else
				return
			end
		end
	end
	if _nonce == "" then
		print "ERROR: nonce is not known"
		return
	end
	if not SDPCheckSignature(datagram, _nonce, signature) then
		print "ERROR: datagram signature INVALID"
		return
	end
	if ack then
		_noack = _noack - 1
		if _sleeptime then
			print ("Going to sleep for " .. (_sleeptime / 1000000) .. " sec")
			led("RX", false)
			led("TX", false)
--			tmr.alarm(1, 100, 0, function () node.dsleep(_sleeptime) end)
			return node.dsleep(_sleeptime)
		else
			if _rcvcb then
				local cb = _rcvcb
				_rcvcb = nil
				return cb()
			else
				return
			end
		end
	end
end

function init (id, secretkey, comm)
	_id = id
	_secretkey = secretkey
	_comm = comm
	_comm.set_sdpreceiver(_sdpreceiver)
end

function send (packet, rcvcb)
	_rcvcb = rcvcb
	if _noack > 5 then
		print "ERROR: more than 5 packets without ACK, rebooting"
		node.restart()
		return
	end
	print ("sdp.send NOACK=" .. _noack)
	if _in then
		_in = _in + 1
		packet.insert_val("in", _in)
		_noack = _noack + 1
	else
		_in = 0
	end
	packet.insert_val("id", _id)
	packet.add_val("sha256", get_signature(packet.get()))
	_comm.send(packet.get())
	if _rcvcb then
		-- RX timeout
		tmr.alarm(3, 3000, 0,
			function()
				print("RX timeout..")
				local cb = _rcvcb
				_rcvcb = nil
				return cb()
			end)
	end
end

function sleep_after_ack (sleeptime)
	_sleeptime = sleeptime
end

return M
