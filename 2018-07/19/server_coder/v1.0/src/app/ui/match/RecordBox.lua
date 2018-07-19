local RecordBox = class("RecordBox",require "app.module.basemodule.BasePopBox")

function RecordBox:initView()
	self.widget = cc.CSLoader:createNode("ui/match/record/recordbox.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)

	self:initListView()
end

function RecordBox:initListView()
	self.listView = self.mainLayer:getChildByName("listview")

	local itemmodel = self.listView:getChildByName("item")
	itemmodel:retain()
	self.listView:setItemModel(itemmodel)
	self.listView:removeAllItems()
	itemmodel:release()
end

function RecordBox:refreshView(data)
	for i,v in ipairs(data.list or {}) do
		self.listView:pushBackDefaultItem()

		local item = self.listView:getItem(i-1)

		self:setItem(item,v)
	end
end

function RecordBox:setItem(item,data)
	item.data = data

	local name = item:getChildByName("name")
	local tip = item:getChildByName("tip")
	local time = item:getChildByName("time")
	local btn = item:getChildByName("btn")
	local getbtn = item:getChildByName("getbtn")

	name:setString(data.name)
	time:setString(os.date("%Y-%m-%d %H:%M",tonumber(data.time)))
	if data.status == 2 then
		tip:setString("您在"..data.name.."中获得第"..data.ord.."名，离胜利只有一步之遥了，加油！")
		getbtn:setVisible(false)
		btn:setVisible(true)
	else
		local awradstr = ""
		for _,award in ipairs(data.list or {}) do
			if #awradstr > 0 then
				awradstr = awradstr..","
			end
			awradstr = awradstr..award.name.."x"..award.num
		end
		tip:setString("您在"..data.name.."荣获"..data.ord.."名，奖励"..awradstr.."，请及时领取您的奖励！")

		if data.status == 1 then
			getbtn:setVisible(false)
			btn:setVisible(true)
		else
			getbtn:setVisible(true)
			btn:setVisible(false)
		end
	end
	
	WidgetUtils.addClickEvent(btn,function ()
		local scenePackageName = "app.ui.scene.MatchResultScene"
	    local sceneClass = require(scenePackageName)
	    local scene = sceneClass.new(data)
	    cc.Director:getInstance():pushScene(scene)
	end)

	WidgetUtils.addClickEvent(getbtn,function ()
		self:getAward(item)
	end)
end

function RecordBox:getRecord()
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.MATCHGETRECORD,{uid = LocalData_instance.uid},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self:hideSmallLoading()

		if msg.status ~= 1 then
			return
		end

		self.data = msg.list
		self:refreshView(msg)
	end)
end

function RecordBox:getAward(item)
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.MATCHGETAWARD,{uid = LocalData_instance.uid,id = item.data.id, key = item.data.key},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self:hideSmallLoading()

		if msg.status ~= 1 then
			return
		end

		if msg.list[1] then
			self:showreward(msg.list[1])
		end

		item.data.status = 1
		self:setItem(item,item.data)

	end)
end

function RecordBox:showreward(data)

	local widget = cc.CSLoader:createNode("cocostudio/ui/match/gongxihuode/gongxihuode.csb")
	widget:setPosition(cc.p((display.cx-640)/2,0))
	self:addChild(widget,2)
	local btn = widget:getChildByName("final"):getChildByName("btn"):getChildByName("btn")

	if data.item_type == 1 then
		local num = widget:getChildByName("final"):getChildByName("num")
		local icon = widget:getChildByName("final"):getChildByName("baoxiang")
		num:setString(data.name.."x"..data.num)
		icon:loadTexture("cocostudio/ui/match/gongxihuode/icon_fangka.png", ccui.TextureResType.localType)
		icon:ignoreContentAdaptWithSize(true)
	elseif data.item_type == 2 then
		local num = widget:getChildByName("final"):getChildByName("num")
		local icon = widget:getChildByName("final"):getChildByName("baoxiang")
		num:setString(data.name)
		icon:loadTexture("cocostudio/ui/match/gongxihuode/icon_hongbao.png", ccui.TextureResType.localType)
		-- icon:setScale(0.7)
		icon:ignoreContentAdaptWithSize(true)
		-- if data.tipstr then
		-- 	widget:getChildByName("final"):getChildByName("info"):setString(data.tipstr)
		-- end
	end

	WidgetUtils.addClickEvent(btn, function( )
		widget:removeFromParent()
	end)

	local action = cc.CSLoader:createTimeline("cocostudio/ui/match/gongxihuode/gongxihuode.csb")

    widget:runAction(action)
    action:gotoFrameAndPlay(0,false)

    local action = cc.CSLoader:createTimeline("cocostudio/ui/match/gongxihuode/xuanzhuanguang.csd.csb")

    widget:getChildByName("FileNode_1"):runAction(action)
    action:gotoFrameAndPlay(0,true)
end


function RecordBox:onEnter()
	self:getRecord()
end

function RecordBox:onExit()
end

return RecordBox