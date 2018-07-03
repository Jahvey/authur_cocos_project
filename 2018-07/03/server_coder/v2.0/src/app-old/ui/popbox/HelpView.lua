-------------------------------------------------
--   TODO   帮助UI
--   Create Date 2016.10.26
-------------------------------------------------
local HelpView = class("HelpView",PopboxBaseView)
function HelpView:ctor()
	self:initData()
	self:initView()
	self:initEvent()
end
function HelpView:initData()

end

function HelpView:initView()
	self.widget = cc.CSLoader:createNode("ui/createroom/helpView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("closeBtn"), function( )
		print("返回大厅")
		LaypopManger_instance:back()
	end)

	self.scrollView = WidgetUtils.getNodeByWay(self.mainLayer,{"contentnode","scrollView"})

	--右边横排
	self.checkboxes = {}
	for i=1,4 do
		table.insert(self.checkboxes,WidgetUtils.getNodeByWay(self.mainLayer,{"contentnode","CheckBox_"..i}))
	end

	for k,v in pairs(self.checkboxes) do
		WidgetUtils.addClickEvent(v, function(  )
			self:clickRightTap(k)
		end)
	end

	self.resoucre  = {}
	for k,v in pairs(HPGAMETYPE) do
		if GT_INSTANCE:getIsHelp(v) then
			table.insert(self.resoucre,v)
		end
	end

	table.sort(self.resoucre,function(_a,_b)
		return _a < _b
	end)

	self.listView = WidgetUtils.getNodeByWay(self.mainLayer,{"listView"})
	local itemmodel = self.listView:getChildByName("checkmodel")

	itemmodel:retain()
	self.listView:setItemModel(itemmodel)
	itemmodel:removeFromParent()
	itemmodel:release()

	self.listView:removeAllItems()
	ComHelpFuc.setScrollViewEvent(self.listView)
	self.listView:setScrollBarEnabled(false)
	
	self._gameTypeCheck = {}
	for i,v in ipairs(self.resoucre) do
		self.listView:pushBackDefaultItem()
		local item = self.listView:getItem(i-1)

		local img1 = item:getChildByName("image_1"):ignoreContentAdaptWithSize(true)
		local img2 = item:getChildByName("image_2"):ignoreContentAdaptWithSize(true)

		img1:loadTexture("ui/createroom/huapai_"..v.."_1.png")
		img2:loadTexture("ui/createroom/huapai_"..v.."_2.png")

		item.ttype = v
		table.insert(self._gameTypeCheck,item)
	end

	for k,v in pairs(self._gameTypeCheck) do
		WidgetUtils.addClickEvent(v, function(  )
			self:clickLeftGameTitle(k)
		end)
	end

	--中间类容
	self.row = 1
	self.column = 1
	local path = "helprule/rule_"..self.resoucre[self.row].."_"..self.column..".png"

	self.scrollView.imgcontent = ccui.ImageView:create(path)
		:addTo(self.scrollView)
		:setPosition(cc.p(self.scrollView:getContentSize().width/2.0,0))
		:setAnchorPoint(cc.p(0.5,0))

	self:refreshScrollView()


	self:runAction(cc.Sequence:create(cc.DelayTime:create(0),cc.CallFunc:create(function() 
		self:clickLeftGameTitle(1)
	end)))
end

function HelpView:changeContentImg()

	local path = "helprule/rule_"..self.resoucre[self.row].."_"..self.column..".png"
	self.scrollView.imgcontent:loadTexture(path)
	self:refreshScrollView()
	self.scrollView:jumpToTop()
end



function HelpView:clickRightTap(index)

	for k,v in pairs(self.checkboxes) do
		if  WidgetUtils:nodeIsExist(v) then
			if k == index  then
				self.column = k
				self:changeContentImg()
				v:getChildByName("text"):setColor(cc.c3b(0x66,0x1a,0x00))
				v:loadTexture("cocostudio/ui/createroom/tap_choose_on.png",ccui.TextureResType.localType)
			else
				v:getChildByName("text"):setColor(cc.c3b(0x7e,0x44,0x15))
				v:loadTexture("cocostudio/ui/createroom/tap_choose_off.png",ccui.TextureResType.localType)
			end
		else
		end

	end
end

function HelpView:clickLeftGameTitle(index)
	if  self.listView.isscrolling == true then
		return
	end
	for k,v in pairs(self._gameTypeCheck) do
		if  WidgetUtils:nodeIsExist(v) then
			if k == index  then
				self.row = k

				self.checkboxes[1]:getChildByName("text"):setString("游戏介绍")
				self.checkboxes[2]:getChildByName("text"):setString("基本规则")
				self.checkboxes[3]:getChildByName("text"):setString("基本操作")
				self.checkboxes[4]:getChildByName("text"):setString("胡牌条件")

				if self.resoucre[self.row] == HPGAMETYPE.YSGDDZ  or 
					self.resoucre[self.row] == HPGAMETYPE.ESDDZ then
					self.checkboxes[1]:getChildByName("text"):setString("基本规则")
					self.checkboxes[2]:getChildByName("text"):setString("基本牌型")
					self.checkboxes[3]:getChildByName("text"):setString("牌型大小")
					self.checkboxes[4]:getChildByName("text"):setString("特殊规则")
				elseif self.resoucre[self.row] == HPGAMETYPE.BDMJ  then
					self.checkboxes[3]:getChildByName("text"):setString("名词解释")
					self.checkboxes[4]:getChildByName("text"):setString("算分规则")
				end
				self:changeContentImg()
				v:getChildByName("image_1"):setVisible(true)
				v:getChildByName("image_2"):setVisible(false)
				v:loadTexture("cocostudio/ui/common/createroom_2.png",ccui.TextureResType.localType)
			else
				v:loadTexture("cocostudio/ui/common/createroom_3.png",ccui.TextureResType.localType)
				v:getChildByName("image_1"):setVisible(false)
				v:getChildByName("image_2"):setVisible(true)
			end
		else
			print(".............不存在！！！ k ＝ ",k)
		end

	end
end


function HelpView:refreshScrollView()
	local content = self.scrollView.imgcontent 
	local viewsize = self.scrollView:getContentSize()
	if content then
		local height = content:getContentSize().height
		if height > viewsize.height then
			self.scrollView:setInnerContainerSize(cc.size(viewsize.width,height))
			content:setPositionY(0)
		else
			self.scrollView:setInnerContainerSize(cc.size(viewsize.width,viewsize.height))
			content:setPositionY(viewsize.height - height)
		end
	end
end

function HelpView:initEvent()
	
end
return HelpView