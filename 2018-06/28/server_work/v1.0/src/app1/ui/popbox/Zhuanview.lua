-------------------------------------------------
--   TODO   帮助UI
--   @author yc
--   Create Date 2016.10.26
-------------------------------------------------
local Zhuanview = class("Zhuanview",PopboxBaseView)
function Zhuanview:ctor()
	self:initView()
	self:initEvent()
end
-- function Zhuanview:initData()
-- 	Socketapi.zhuamsg()
-- end

function Zhuanview:initView()
	self.widget = cc.CSLoader:createNode("ui/zhuanpan/zhuanpan.csb")
	self:addChild(self.widget)
	self.mainLayer = self.widget:getChildByName("main")
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("closeBtn"), function( )
		print("返回大厅")
		LaypopManger_instance:back()
	end)
	self.text = self.mainLayer:getChildByName("text")
	self.text:setString("")
	self.btn = self.mainLayer:getChildByName("btn")
	self.btn:setEnabled(false)
	self.btntext = self.mainLayer:getChildByName("btn"):getChildByName("num")
	self.btntext:setVisible(false)
	self.iszhuan = false
	WidgetUtils.addClickEvent(self.btn, function( )
		print("返回大厅")
		if self.iszhuan then
			return
		end
		self.btn:setEnabled(false)
		self.iszhuan = true
		Socketapi.choumsg()
	end)
	for i=1,6 do
		 self.mainLayer:getChildByName("node"..i):setVisible(false)
	end

	self.zhuantip = self.btn
	Socketapi.zhuamsg()

	-- for i,v in ipairs(self.data.rewardInfos) do
	-- 	if v.
	-- end
end
function Zhuanview:zhancall( data )

	if data.result and data.result ~= 1 then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = data.info})
		return
	end
	self.text:setString("每满20局可以抽奖一次，当前可用抽次数("..data.currewardnums..")")
	self.data = data
	self.btn:setEnabled(true)
	-- self.btntext:setVisible(true)
	-- self.btntext:setString(data.usecoins.."房卡")
	for i,v in ipairs(data.rewardInfos) do
		local node = self.mainLayer:getChildByName("node"..i)
		node:setVisible(true)
		if v.gamecoins == 0 then
			node:getChildByName("icon"):setVisible(false)
			node:getChildByName("text"):setVisible(false)
			node:getChildByName("textxiexie"):setVisible(true)
			node:getChildByName("textxiexie"):setString(v.rewardname)
		else
			node:getChildByName("icon"):setVisible(true)
			node:getChildByName("text"):setVisible(true)
			node:getChildByName("textxiexie"):setVisible(false)
			node:getChildByName("text"):setString(v.rewardname)
			node:getChildByName("icon"):setTexture("cocostudio/ui/zhuanpan/jiang"..v.imgid..".png")
		end
	end
end
function Zhuanview:getpic( value )
end

function Zhuanview:jieguo( data )
	if data.result and data.result == 0 then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = data.info})
		return
	end
	self.text:setString("抽奖次数:"..data.currewardnums)
	local index = 0
	for i,v in ipairs(self.data.rewardInfos) do
		if v.rewardid == data.rewardid then
			index = i
		end
	end
	if index == 0 then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "系统错误请关闭大转盘重试"})
		return
	end
	local needrotain = (index-1)*60
	local rotion = self.zhuantip:getRotation()
	rotion = rotion 
	rotion = needrotain -rotion%360 +10*360
	local action = cc.EaseSineOut:create(cc.RotateBy:create(3,rotion))
	self.zhuantip:runAction(cc.Sequence:create(action,cc.CallFunc:create(function( ... )
		if  data.gamecoins > 0 then
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "恭喜您获得了"..data.rewardname})
		else
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "再接再厉"})
		end
		self.iszhuan = false
		self.btn:setEnabled(true)
	end)))
end
function Zhuanview:initEvent()
	ComNoti_instance:addEventListener("3;1;11;1",self,self.zhancall)
	ComNoti_instance:addEventListener("3;1;11;2",self,self.jieguo)
end
return Zhuanview