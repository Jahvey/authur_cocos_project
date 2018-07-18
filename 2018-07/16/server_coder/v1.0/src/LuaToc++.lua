
if device.platform == "ios" or device.platform == "android" then

	if Downtool == nil then
		Downtool = DownManger
		Downtool.sharedDowntool = DownManger.getInstance
		Downtool.downLoad = DownManger.downLoad
		Downtool.UncompressPackage = function(  )
			return DownManger:getInstance():Uncompresszip()
		end
		Downtool.getProssgress = function( ... )
			 return DownManger:getInstance():getdownProssgress()
		end
	end

	if IMDispatchMsgNode == nil then
		IMDispatchMsgNode = IMskdNode
	end
end
