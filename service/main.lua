local skynet = require "skynet"

skynet.start(function()
	skynet.error("Server start")
	if not skynet.getenv "daemon" then
		local console = skynet.newservice("console")
	end
	 --创建一个debug_console服务
	skynet.newservice("debug_console",8000)

	--启动一个protoloader服务用于加载数据协议
	local proto = skynet.uniqueservice "protoloader" 
	skynet.call(proto, "lua", "load", { --调用protoloader服务lua类型消息的分发函数load
		"proto.c2s",
		"proto.s2c",
	})

	--启动一个hub服务
	local hub = skynet.uniqueservice "hub"
	skynet.call(hub, "lua", "open", "0.0.0.0", 5678) --调用hub服务lua类型消息的分发函数open，并且传入IP和端口

	--skynet服务退出
	skynet.exit()
end)
