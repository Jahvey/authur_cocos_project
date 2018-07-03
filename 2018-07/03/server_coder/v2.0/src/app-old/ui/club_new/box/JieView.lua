local JieView = class("JieView",PopboxBaseView)

function JieView:ctor(tid,setnum,fuc)
	self.fuc = fuc
	self.tid = tid
	self.setnum = setnum
	self:initView()
	self:initEvent()
	
end
function JieView:initView()
	local widget = cc.CSLoader:createNode("ui/club/smallbox/Jiesuanbox.csb")
	self:addChild(widget)
	self.widget = widget
	self.mainLayer = widget:getChildByName("main")

	self.closeBtn = self.mainLayer:getChildByName("closebtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		
		LaypopManger_instance:back()
	end)

	self.surebtn = self.mainLayer:getChildByName("createbtn")
	WidgetUtils.addClickEvent(self.surebtn, function( )
		self.fuc(tonumber(self.text:getString()))
		LaypopManger_instance:back()
	end)
	self.nowtext = self.mainLayer:getChildByName("local"):getChildByName("text")
	self.text = self.mainLayer:getChildByName("input"):getChildByName("text")
	self.text:setString(self.setnum)
	self.nowtext:setString(self.setnum)

	self.addbtn = self.mainLayer:getChildByName("input"):getChildByName("add")
	WidgetUtils.addClickEvent(self.addbtn, function( )
		self.text:setString(tonumber(self.text:getString())+1)
	end)

	self.jianbtn  =self.mainLayer:getChildByName("input"):getChildByName("jian")
	WidgetUtils.addClickEvent(self.jianbtn, function( )
		local num = tonumber(self.text:getString())-1
		if num < 0 then
			num =  0
		end
		self.text:setString(num)
	end)

	--Socketapi.requestmsgclube(self.tid)
end
function JieView:initEvent()
	--ComNoti_instance:addEventListener("cs_response_tea_bar_message",self,self.msgcallback)
	
end
return JieView