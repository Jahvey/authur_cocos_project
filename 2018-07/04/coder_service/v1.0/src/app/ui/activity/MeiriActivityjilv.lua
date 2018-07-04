local MeiriActivityjilv = class("MeiriActivityjilv",PopboxBaseView)
require "mime"
function MeiriActivityjilv:ctor()
	self:initView()

	self:showSmallLoading()
end

function MeiriActivityjilv:initView()
	self.widget = cc.CSLoader:createNode("ui/activity/meiri/JiluView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn  = self.mainLayer:getChildByName("closebtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
		
	end)

	self.listview = self.mainLayer:getChildByName("listview")
	self.cell1 = self.widget:getChildByName("cell1")
	self.cell1:setVisible(false)
	self.cell2 = self.widget:getChildByName("cell2")
	self.cell2:setVisible(false)


	local checks = {}
	checks[1] = self.mainLayer:getChildByName("check1")
	checks[1]:setTag(1)
	checks[1]:setTouchEnabled(false)
	checks[2] = self.mainLayer:getChildByName("check2")
	checks[2]:setTag(2)
	checks[2]:setTouchEnabled(false)
	local function selectedEvent1( sender, eventType )

        if eventType == ccui.CheckBoxEventType.selected then
        	for i,v in ipairs(checks) do
        		v:setSelected(false)
        		v:setTouchEnabled(true)
        		v:getChildByName("text1"):setVisible(false)
        		v:getChildByName("text2"):setVisible(true)
        	end
        	sender:setSelected(true)
        	sender:setTouchEnabled(false)
        	sender:getChildByName("text1"):setVisible(true)
        	sender:getChildByName("text2"):setVisible(false)
        	if sender:getTag() == 1 then
        		self.mainLayer:getChildByName("tip1"):setVisible(true)
        		self.mainLayer:getChildByName("tip2"):setVisible(false)
        	else
        		self.mainLayer:getChildByName("tip1"):setVisible(false)
        		self.mainLayer:getChildByName("tip2"):setVisible(true)
        	end
        	self:updateview( sender:getTag() )
        end
    end
    selectedEvent1( checks[1], ccui.CheckBoxEventType.selected )
    checks[1]:addEventListener(selectedEvent1)
    checks[2]:addEventListener(selectedEvent1)

    self.checks = checks

	
end
function MeiriActivityjilv:updateview( type )
	self.listview:removeAllItems()
	if type == 1 then
		self.listview:setItemModel(self.cell1)
	else
		self.listview:setItemModel(self.cell2)
	end
	if type == 1 then
		if self.listall == nil then
			return
		end
		for i,v in ipairs(self.listall) do
			self.listview:pushBackDefaultItem()
        	local item = self.listview:getItem(i-1)
        	item:setVisible(true)
        	local icon = item:getChildByName("icon")
        	icon:setScale(0.82)
        	require("app.ui.common.HeadIcon").new(icon,v.img)
        	local name = item:getChildByName("time")
        	local namestr = mime.unb64(v.name)
        	print(namestr)
        	item:getChildByName("info"):setString(v.prizecontent)
        	name:setString( ComHelpFuc.getStrWithLength(namestr))
		end
	else
		if self.listmy == nil then
			return
		end
		for i,v in ipairs(self.listmy) do
			self.listview:pushBackDefaultItem()
        	local item = self.listview:getItem(i-1)
        	item:setVisible(true)
        	local name = item:getChildByName("time")
        	name:setString(v.timestr)
        	item:getChildByName("info"):setString(v.prizecontent)
		end
	end

end
function MeiriActivityjilv:onEndAni()
	ComHttp.httpPOST(ComHttp.URL.DINGDIANWANPAILIST,{uid = LocalData_instance.uid},function(msg)
			if not WidgetUtils:nodeIsExist(self) then
				return
			end
			self.listmy = msg.my
			self.listall = msg.all
			self.checks[1]:setTouchEnabled(true)
			self.checks[2]:setTouchEnabled(true)
			self:hideSmallLoading()
			printTable(msg,"sjp3")
			self:updateview( 1 )
		end)
end


return MeiriActivityjilv