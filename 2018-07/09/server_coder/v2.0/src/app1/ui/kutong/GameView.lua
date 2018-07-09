
local Card = require "app.ui.kutong.Card"
local Gameview = class("Gameview",function()
    return cc.Node:create()
end)

function Gameview:ctor(scene,data,isre)
	self.data = data
	self.scene = scene
	self:initView(isre)
end
function Gameview:initView(isre)
	self.tableviews = {}
	local Basetable = require "app.ui.kutong.Basetable"
	for i,v in ipairs(self.data.roomPlayerItemJsons) do
		local localpos = self.scene:getLocalindex(v.index)
		self.tableviews[localpos] = Basetable.new(localpos,self.scene,v)
		if localpos == 1 then
			if isre then
				self.tableviews[localpos]:createcards()
			else
				self.tableviews[localpos]:createcards(true)
			end
			self.tableviews[localpos]:initHandCard()
			if isre then
				self:showAction(v)
			else
				self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function( ... )
					self:showAction(v)
				end)))
			end
		end
		self:addChild(self.tableviews[localpos])
	end
	if isre then
		print("重连")
		if self.data.roundlist then
			for i,v in ipairs(self.data.roundlist) do
				if v.carddatas == nil  then
					v.carddatas = v.curCards
				end
				if v.actiontype == 2 then
					self:chupai(v,false)
				elseif v.actiontype == 3 then
					self:guo(v)
				end
			end
		end 
	end
end
function Gameview:showAction( data )
	if data.playTypes[1] == 1 then
		self:runAction(cc.CallFunc:create(function( ... )
			if self.data.gameplaytype == 2 then
				self.scene.liangbtn:setVisible(true)
			else
				LaypopManger_instance:PopBox("LiangView",self.scene)
			end
		end))
		
	elseif data.playTypes[1] == 2 then
		self.scene.actionnode:setVisible(true)
		self.scene:setclock(self.scene.actionnode:getChildByName("clock"))
		local chubtn = self.scene.actionnode:getChildByName("chubtn")
		WidgetUtils.addClickEvent(chubtn, function( )
			self.tableviews[1]:actionchu(data.preAction)
		end)

		local guobtn = self.scene.actionnode:getChildByName("bubtn")
		WidgetUtils.addClickEvent(guobtn, function( )
			Socketapi.doactionforkutong(3)
			self.scene.actionnode:setVisible(false)
			self.scene.actionnode:getChildByName("clock"):stopAllActions()
			self.tableviews[1]:actionclean()
		end)
		self.tableviews[1].tipnum = 1
		self.tableviews[1].tiptab = nil
		local tipbtn = self.scene.actionnode:getChildByName("tipbtn")
		WidgetUtils.addClickEvent(tipbtn, function( )
			self.tableviews[1]:tips(data.preAction)
			self.tableviews[1].tipnum = self.tableviews[1].tipnum + 1
		end)
		if data.preAction then
			tipbtn:setVisible(true)
			guobtn:setVisible(true)
			chubtn:setPositionX(219)
		else
			tipbtn:setVisible(false)
			guobtn:setVisible(false)
			chubtn:setPositionX(12)
		end


		self.scene.painode:getChildByName("buchu"..1):setVisible(false)
		self.tableviews[1].putnode:removeAllChildren()
	end
end
function Gameview:chupai(data,isdele)
	local localpos = self.scene:getLocalindex(data.index)
	self.tableviews[localpos]:chupai(data,true)
end
function Gameview:guo(data)
	local localpos = self.scene:getLocalindex(data.index)
	self.scene.painode:getChildByName("buchu"..localpos):setVisible(true)
	self.tableviews[localpos].putnode:removeAllChildren()
end

function Gameview:cleanputout(  )
	for k,v in pairs(self.tableviews) do
		local localpos = self.scene:getLocalindex(tonumber(k))
		self.scene.painode:getChildByName("buchu"..localpos):setVisible(false)
		self.tableviews[localpos].putnode:removeAllChildren()
	end
end

return Gameview