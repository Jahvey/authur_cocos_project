local UpdateNoticeBox = class("InfoBox",require "app.module.basemodule.BasePopBox")

function UpdateNoticeBox:onEnter()
	-- if self.needupdate then
	-- 	self:showSmallLoading()
	-- 	ComHttp.httpPOST(ComHttp.URL.WHEELGETCONF,{uid = LocalData_instance.uid},function(msg)
	-- 		printTable(msg)
	-- 		if not WidgetUtils:nodeIsExist(self) then
	-- 			return
	-- 		end

	-- 		self:hideSmallLoading()

	-- 		if msg.status ~= 1 then
	-- 			return
	-- 		end

	-- 		self.num = msg.redpacket or 0
	-- 		self:refreshView()
	-- 	end)
	-- end
end

function UpdateNoticeBox:onExit()

end

function UpdateNoticeBox:initView(data)
	self.widget = cc.CSLoader:createNode("ui/updatenotice/updateNoticeBox.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	-- self.closeBtn  = self.mainLayer:getChildByName("closeBtn")
	-- WidgetUtils.addClickEvent(self.closeBtn, function( )
	-- 	LaypopManger_instance:back()
	-- end)

	local surebtn = self.mainLayer:getChildByName("sureBtn")
	WidgetUtils.addClickEvent(surebtn, function( )
		LaypopManger_instance:back()
	end)
	
	local scrollview = self.mainLayer:getChildByName("scrollview")

	local viewsize = scrollview:getContentSize()

	local content = scrollview:getChildByName("content")

	content:ignoreContentAdaptWithSize(true)
	content:setTextAreaSize(cc.size(viewsize.width-10,0))
	content:setString(data.content or "")	
	content:ignoreContentAdaptWithSize(false)

	local height = content:getContentSize().height

	content:setPosition(cc.p(5,math.max(height+10,viewsize.height)-5))
	scrollview:setInnerContainerSize(cc.size(viewsize.width,math.max(height+10,viewsize.height)))
end


return UpdateNoticeBox