local skynet = require "skynet"
local sprotoparser = require "sprotoparser"
local sprotoloader = require "sprotoloader"
local service = require "service"
local log = require "log"

local loader = {}
local data = {}

local function load(name)
	local filename = string.format("proto/%s.sproto", name)
	local f = assert(io.open(filename), "Can't open " .. name)
	local t = f:read "a"
	f:close()
	return sprotoparser.parse(t)
end

--加载sproto相关协议表，由main.lua通过skynet.call调用过来的接口
function loader.load(list)
	for i, name in ipairs(list) do
		local p = load(name)
		log("load proto [%s] in slot %d", name, i)
		data[name] = i
		sprotoloader.save(p, i)
	end
end
--获得sproto协议在skynet sprotoloader里序号
function loader.index(name)
	return data[name]
end

function loader.test(name)
	print("loader test")
end

--服务初始化，并且传入相关命令和数据到skynet底层进行注册
service.init {
	command = loader,
	info = data
}

--调用顺序
--1.server.init在启动服务器时默认调用
--2.loader.load全局函数由skynet.call调用
--3.load局部函数由自身脚本调用
