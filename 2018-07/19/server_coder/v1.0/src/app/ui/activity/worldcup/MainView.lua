local MainView = class("MainView",require "app.module.basemodule.BasePopBox")

local MODULE_PATH = "app.ui.activity.worldcup."
local RESOURCE_PATH = "ui/worldcup/"
local PAGE_NAME = {
	[1] = "GuessingPage",
	[2] = "TaskPage",
	[3] = "RankPage",
	[4] = "SignPage",
	[5] = "ShopPage",
}

local COUNTRY_MAP = {
	[1] = "阿根廷",
	[2] = "埃及",
	[3] = "澳大利亚",
	[4] = "巴拿马",
	[5] = "巴西",
	[6] = "比利时",
	[7] = "冰岛",
	[8] = "波兰",
	[9] = "丹麦",
	[10] = "德国",
	[11] = "俄罗斯",
	[12] = "法国",
	[13] = "哥伦比亚",
	[14] = "哥斯达黎加",
	[15] = "韩国",
	[16] = "克罗地亚",
	[17] = "秘鲁",
	[18] = "摩洛哥",
	[19] = "墨西哥",
	[20] = "尼日利亚",
	[21] = "葡萄牙",
	[22] = "日本",
	[23] = "瑞典",
	[24] = "瑞士",
	[25] = "塞尔维亚",
	[26] = "塞内加尔",
	[27] = "沙特阿拉伯",
	[28] = "突尼斯",
	[29] = "乌拉圭",
	[30] = "西班牙",
	[31] = "伊朗",
	[32] = "英格兰",
}

function MainView:initData()
	self.page = {}
	self.data = nil
end

function MainView:initView()
	self.widget = cc.CSLoader:createNode(self:getResourcePath().."mainView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")

	WidgetUtils.setScalepos(self.mainLayer)
	local bg = self.mainLayer:getChildByName("bg")
	bg:setScale9Enabled(true)
	bg:setCapInsets(cc.rect(0,0,1280,720))
	bg:setContentSize(cc.size(display.width,display.height))
	
	self.contentNode = self.mainLayer:getChildByName("contentnode")

	self:initTopNode()
	self:initListView()
end

function MainView:initTopNode()
	self.topNode = self.mainLayer:getChildByName("topnode")
	WidgetUtils.setScalepos(self.topNode)

	self.numLabel = self.topNode:getChildByName("num")
	self.countLabel = self.topNode:getChildByName("countbg"):getChildByName("count")
	self.animaNode = self.topNode:getChildByName("icon"):getChildByName("node")

	local backbtn = self.topNode:getChildByName("backbtn")
	WidgetUtils.addClickEvent(backbtn, function( )
		LaypopManger_instance:back()
	end)
end

function MainView:initListView()
	self.listNode = self.mainLayer:getChildByName("listnode")
	self.listView = self.listNode:getChildByName("listview"):setScrollBarEnabled(false)

	local itemmodel = self.listView:getChildByName("item")
	itemmodel:retain()
	self.listView:setItemModel(itemmodel)
	self.listView:removeAllItems()
	itemmodel:release()
end

function MainView:refreshView(data)
	self:refreshListView(data)
	self:refreshTopNode(data)
end

function MainView:refreshListView(data)
	self.listView:removeAllItems()

	self.listView.itemList = {}

	for i,v in ipairs(data.list or {}) do
		self.listView:pushBackDefaultItem()

		local item = self.listView:getItem(i-1)
		item.index = v.id

		local text_u = item:getChildByName("text_u"):ignoreContentAdaptWithSize(true)
		local text_s = item:getChildByName("text_s"):ignoreContentAdaptWithSize(true)
		local redpoint = item:getChildByName("redpoint")

		text_u:loadTexture(self:getResourcePath().."text_"..item.index.."_u.png")
		text_s:loadTexture(self:getResourcePath().."text_"..item.index.."_s.png")

		item.setRedVisible = function (bool)
			redpoint:setVisible(bool)
		end
		item.setRedVisible(v.red == 1)

		WidgetUtils.addClickEvent(item, function()
			self:clickListItem(item)
		end)

		table.insert(self.listView.itemList, item)
	end

	if self.listView.itemList[1] then
		self:clickListItem(self.listView.itemList[1])
	end
end

function MainView:refreshTopNode(data)
	self.numLabel:setString(data.point or 0)

	self.countLabel:stopAllActions()
	self.countLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function ()
		if os.time() >= data.endtime then
			self.countLabel:setString("活动已结束！")
		else
			self.countLabel:setString("倒计时:"..self:formatTime(data.endtime-os.time()))
		end
	end),cc.DelayTime:create(1))))
end

function MainView:clickListItem(item)
	for _,v in ipairs(self.listView.itemList) do
		v:getChildByName("text_u"):setVisible(true)
		v:getChildByName("text_s"):setVisible(false)
		v:getChildByName("bg_u"):setVisible(true)
		v:getChildByName("bg_s"):setVisible(false)
	end

	item:getChildByName("text_s"):setVisible(true)
	item:getChildByName("text_u"):setVisible(false)
	item:getChildByName("bg_s"):setVisible(true)
	item:getChildByName("bg_u"):setVisible(false)

	if not self.page[item.index] then
		self.page[item.index] = require (MODULE_PATH..PAGE_NAME[item.index]).new(self,item)
			:addTo(self.contentNode)
	end

	for _,v in pairs(self.page) do
		v:setVisible(false)
	end
	self.page[item.index]:setVisible(true)
end

function MainView:getPoint()
	return self.data and self.data.point or 0
end

function MainView:setPoint(num)
	if not self.data then
		return
	end
	self.data.point = num
	self:refreshPoint()
end

function MainView:setPointNum(num)
	if not self.data then
		return
	end
	self.data.point = num
end

function MainView:refreshPoint()
	self.numLabel:setString(self:getPoint())
end

function MainView:formatTime(sec)
	local formatstr = ""
	local day = math.floor(sec / (24*60*60))
	if day > 0 then
		formatstr = formatstr..day.."天"
	end

	sec = sec % (24*60*60)
	local hour = math.floor(sec / (60*60))
	if hour > 0 then
		formatstr = formatstr..hour.."时"
	end

	sec = sec % (60*60)
	local min = math.floor(sec / (60))
	if min > 0 then
		formatstr = formatstr..min.."分"
	end

	return formatstr
end

function MainView:getCountryName(id)
	return COUNTRY_MAP[id] or ""
end

function MainView:getCountryFlag(id)
	return RESOURCE_PATH.."flag/"..id..".png"
end

function MainView:getResourcePath()
	return RESOURCE_PATH
end

function MainView:gainPoint(num,startpos)
	local nownum = self:getPoint()
	self:setPointNum(self:getPoint()+(num or 0))
	self:flyBallAnimation(nownum,num,startpos)
end

function MainView:flyBallAnimation(nownum,gainnum,startpos)
	-- startpos = cc.p(0,0)
	local balllist = {}
	for i=1,math.random(4,5) do
		local ball = ccui.ImageView:create(self:getResourcePath().."task/zuqiu.png")
			:addTo(self)
			:setPosition(cc.p(startpos.x+math.random(-10,10),startpos.y+math.random(-10,10)))
			:setVisible(false)

		table.insert(balllist,ball)
	end

	local time = 0.8

	balllist[1]:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function ()
			self:gainPointAnimation(nownum,gainnum)
		end)))
	local count = 1

	local function getAction(count,ball)
		local endpos = self:convertToNodeSpace(self.animaNode:getParent():convertToWorldSpace(cc.p(self.animaNode:getPositionX()+math.random(-10,10),self.animaNode:getPositionY()+math.random(-10,10))))
		local moveaction = cc.MoveTo:create(time,endpos)
		local action = cc.Sequence:create(cc.DelayTime:create(0.1*(count-1)),cc.CallFunc:create(function ()
			ball:setVisible(true)
		end),moveaction,cc.CallFunc:create(function ()
			ball:removeFromParent()
		end))

		return action
	end
	
	for i,v in ipairs(balllist) do
		v:runAction(getAction(i,v))
	end
end

function MainView:gainPointAnimation(num,gainnum)
	local delay = math.max(1/gainnum,0.04)

	local nownum = num
	local target = self:getPoint()

	local floorstep = math.floor(gainnum*delay)
	local ceilstep = math.ceil(gainnum*delay)
	local pro = gainnum*delay - ceilstep


	local function getAction()
		local ran = math.random(1,100)
		if ran > pro*100 then
			nownum = nownum + ceilstep
		else
			nownum = nownum + floorstep
		end
		
		if target - nownum < ceilstep then
			self.numLabel:setString(target)
		else
			self.numLabel:runAction(cc.Sequence:create(
				cc.CallFunc:create(function ()
					self.numLabel:setString(nownum)
				end),
				cc.DelayTime:create(delay),
				cc.CallFunc:create(function ()
					getAction()
				end)))
		end
	end

	getAction()

	-- self.numLabel:runAction()

	local node =  cc.CSLoader:createNode(self:getResourcePath().."anima/zuqiu/zuqiu.csb")
	local action = cc.CSLoader:createTimeline(self:getResourcePath().."anima/zuqiu/zuqiu.csb")
	local function onFrameEvent(frame)
		if nil == frame then
			return
		end
		local str = frame:getEvent()
		if str == "end" then
			node:removeFromParent()
		end
	end
	action:setFrameEventCallFunc(onFrameEvent)

	node:runAction(action)
	action:gotoFrameAndPlay(0,false)
	node:addTo(self.animaNode)
	-- return node 
end

function MainView:showReward(data)
	local widget = cc.CSLoader:createNode(self:getResourcePath().."anima/gongxihuode/gongxihuode.csb")
	widget:setPosition(cc.p((display.cx-640)/2,0))
	self:addChild(widget,2)
	local btn = widget:getChildByName("final"):getChildByName("btn"):getChildByName("btn")

	if data.item_type == 1 then
		local num = widget:getChildByName("final"):getChildByName("num")
		local icon = widget:getChildByName("final"):getChildByName("baoxiang")
		num:setString(data.name)
		icon:loadTexture(self:getResourcePath().."anima/gongxihuode/icon_fangka.png", ccui.TextureResType.localType)
		icon:ignoreContentAdaptWithSize(true)
	elseif data.item_type == 2 then
		local num = widget:getChildByName("final"):getChildByName("num")
		local icon = widget:getChildByName("final"):getChildByName("baoxiang")
		num:setString(data.name)
		icon:loadTexture(self:getResourcePath().."anima/gongxihuode/icon_hongbao.png", ccui.TextureResType.localType)
		icon:ignoreContentAdaptWithSize(true)
	end

	WidgetUtils.addClickEvent(btn, function( )
		widget:removeFromParent()
	end)

	local action = cc.CSLoader:createTimeline(self:getResourcePath().."anima/gongxihuode/gongxihuode.csb")

	widget:runAction(action)
	action:gotoFrameAndPlay(0,false)

	local action = cc.CSLoader:createTimeline(self:getResourcePath().."anima/gongxihuode/xuanzhuanguang.csd.csb")

	widget:getChildByName("FileNode_1"):runAction(action)
	action:gotoFrameAndPlay(0,true)
end

function MainView:getConf()
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.WCGETCONF,{uid = LocalData_instance.uid},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self:hideSmallLoading()

		if msg.status ~= 1 then
			return
		end

		self.data = msg
		self:refreshView(msg)
	end)
end

function MainView:onEnter()
	self:getConf()
end

function MainView:sharePic()
	local default = {}
	local maxnum = 9
	for i=1,maxnum do
		table.insert(default,i)
	end
	local save = cc.UserDefault:getInstance():getStringForKey("WCSHARETABLE",cjson.encode(default))

	local tab = cjson.decode(save)

	if #tab <= 0 or #tab > maxnum then
		tab = default
	end

	local idx = math.random(1,#tab)

	local picpath = "cocostudio/"..self:getResourcePath().."share_"..tab[idx]..".jpg"

	table.remove(tab,idx)

	cc.UserDefault:getInstance():setStringForKey("WCSHARETABLE",cjson.encode(tab))

	local iconPath = self:movePictocache(picpath)

	print(iconPath)
	if device.platform == "android" then
		luaj = require("cocos.cocos2d.luaj")
		local function logincallback(code)
			print("====分享成功")
		end
		local className = NOWANDROIDPATH
		local methodName = "sharepic"
		local args  =  {iconPath,1}
		local sig = "(Ljava/lang/String;I)V"
		luaj.callStaticMethod(className, methodName, args, sig)
	elseif device.platform == "ios" then
		luaoc.callStaticMethod("RootViewController","weixinsharepic",{flag = 1,path = iconPath})
	end
end


function MainView:movePictocache(pathpic)
	local iconPath = cc.FileUtils:getInstance():fullPathForFilename(pathpic)
	if string.find(iconPath, cc.FileUtils:getInstance():getWritablePath()) then
	else
		local image = cc.Image:new()
		image:initWithImageFile(iconPath)
		local picsavepath = cc.FileUtils:getInstance():getWritablePath().."appdata/res/"..pathpic
		local ts = string.reverse(picsavepath)
		local pos = string.find(ts,"/")
		pos = string.len(ts) - pos
		local directorypath = string.sub(picsavepath,1,pos)
		print(directorypath)
		if cc.FileUtils:getInstance():isDirectoryExist(directorypath) then
		else
			cc.FileUtils:getInstance():createDirectory(directorypath)
		end
		if image:saveToFile(picsavepath, true) then
			print("end yes")
			iconPath = picsavepath
		else
			print("end no")

		end
	end
	return iconPath
end

return MainView