local AddfangView = class("AddfangView",PopboxBaseView)

function AddfangView:ctor(tid,chips)
	self.tid = tid
	self.chips = chips
	self:initView()
	self:initEvent()
	
end
function AddfangView:initView()
	local widget = cc.CSLoader:createNode("ui/club/smallbox/Addfangbox.csb")
	self:addChild(widget)
	self.widget = widget
	self.mainLayer = widget:getChildByName("main")

	self.closeBtn = self.mainLayer:getChildByName("closebtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		
		LaypopManger_instance:back()
	end)
	self.text = self.mainLayer:getChildByName("input"):getChildByName("text")
	self.text:setString(cc.UserDefault:getInstance():getIntegerForKey("clueaddfang",0))
	self.surebtn = self.mainLayer:getChildByName("createbtn")
	self.mainLayer:getChildByName("local"):getChildByName("text"):setString(self.chips)
	WidgetUtils.addClickEvent(self.surebtn, function( )
		local num = tonumber(self.text:getString())
		if num and num > 0 then 
			cc.UserDefault:getInstance():setIntegerForKey("clueaddfang",num)
		end
		Socketapi.requestaddfangclue(self.tid,num)
		--LaypopManger_instance:back()
	end)

	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("input"):getChildByName("jian"), function( )
		print("123")
		self.text:setString(tonumber(self.text:getString())-100)
	end)

	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("input"):getChildByName("add"), function( )
		print("123")
		self.text:setString(tonumber(self.text:getString())+100)
	end)
	--Socketapi.requestmsgclube(self.tid)
end

function AddfangView:msgcallback(data)
	if data.result == 0 then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "操作房卡成功"})
		self.text:setString("0")
	else
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end
function AddfangView:initEvent()
	ComNoti_instance:addEventListener("cs_response_put_chips_to_tea_bar",self,self.msgcallback)
	
end
return AddfangView