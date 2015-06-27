local print = print

local M = {}

setfenv(1, M)

local _id = nil
local _secretkey = nil
local _comm = nil
local _nonce = nil

local _packet = ""

function init (id)
	_packet = ""
end

function add_val (key, val)
	_packet = _packet .. key .. ":" .. val .. "\n"
end

function insert_val (key, val)
	_packet = key .. ":" .. val .. "\n" .. _packet
end

function set (data)
	_packet = data
end

function get ()
	return _packet
end

return M
