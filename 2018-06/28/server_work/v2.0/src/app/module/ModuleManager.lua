ModuleManager = class("ModuleManager")

function ModuleManager.getHallView()
	return 	cc.Director:getInstance():getRunningScene().HallView
end

local enterHallEvent = {}

function ModuleManager.addEnterHallEvent(fuc)
	table.insert(enterHallEvent,fuc)
end

function ModuleManager.getEnterHallEvent()
	return enterHallEvent
end

function loadModule(src)
	require(src..".init")()
end

HttpManager.regiterHttpUrl("CHECKREALNAME","Activity1/checkrealname")
loadModule("app.ui.activity.wheelsurf")
loadModule("app.ui.activity.rechargeact")
loadModule("app.ui.popbox.updatenotice")
loadModule("app.ui.game_base_cdd.test")
loadModule("app.ui.game.test")