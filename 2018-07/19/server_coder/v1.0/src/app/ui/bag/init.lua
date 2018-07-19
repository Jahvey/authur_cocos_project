local function loadModule()
	require("app.ui.bag.ItemConf")

	HttpManager.regiterHttpUrl("BAGGETLIST","/Bag/getlist")
	HttpManager.regiterHttpUrl("BAGGETINFO","/Bag/getinfo")
	HttpManager.regiterHttpUrl("BAGUSEITEM","/Bag/useitem")
	HttpManager.regiterHttpUrl("BAGUNUSEITEM","/Bag/unuseitem")

	PopBoxManager.registerPopBox("BagView","app.ui.bag.BagView")
	PopBoxManager.registerPopBox("BagOpenBox","app.ui.bag.OpenView")
end

return loadModule