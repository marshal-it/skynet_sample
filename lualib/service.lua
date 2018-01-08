local skynet = require "skynet"
local log = require "log"

local service = {}

--初始化各种服务
--1.注册服务info
--2.注册服务的命令函数command
--3.启动服务
function service.init(mod)
	local funcs = mod.command --获取服务初始化时传入的command
	if mod.info then
		skynet.info_func(function() --不知道这里info_func是干了什么
			return mod.info
		end)
	end
	skynet.start(function()
		if mod.require then  --如果有请求启动服务的命令
			local s = mod.require
			for _, name in ipairs(s) do
				service[name] = skynet.uniqueservice(name)
			end
		end
		if mod.init then --如果有初始化的命令
			mod.init()
		end
		--skynet底层多播命令调用（skynet.call）
		skynet.dispatch("lua", function (_,_, cmd, ...)
			local f = funcs[cmd] --这里就会获取到之前其他服务command传入的函数接口
			if f then 
				skynet.ret(skynet.pack(f(...))) --回给消息调度中心异步去调用接口
			else
				log("Unknown command : [%s]", cmd)
				skynet.response()(false) --回给消息调度中心异步调用接口失败
			end
		end)
	end)
end

return service
