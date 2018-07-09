require "app.baseui.PopboxBaseView"
require("app.module.HttpManager")
require("app.net.ComHttp")

local fangkaNodeView= class("fangkaNodeView",PopboxBaseView)

HttpManager.regiterHttpUrl("WHEELEXCHANGE","/Activity3/turntable_exchange")
HttpManager.regiterHttpUrl("WHEELCONFIG","/Activity3/turntable_config")


function fangkaNodeView:ctor(opentype,param)
	
	
	self.num=param or {}
	self:initView()
	--self:initEvent()
end
-- function fangkaNodeView:initData(opentype,param)
-- 	if not opentype then
-- 		opentype=1
-- 	end

-- 	self.opentype=opentype
-- 	self.param=param or {}

-- end


--在弹出的窗口中的layer层中，将layer层的交互性 的选项勾选上，防止下层的触摸响应事件穿透到上层的layer中
--调用的时候必须要用self.别名的方式来调用相应的组件，原因不明
--不能写成initview，会跟父类的方法名字重名，而导致重载
function fangkaNodeView:initView()
	self.widget = cc.CSLoader:createNode("myui/raward/fangka.csb")


	self.mainLayer = self.widget:getChildByName("main")
    self.btn_exit = self.mainLayer:getChildByName("Button_Exit")
    WidgetUtils.addClickEvent(self.btn_exit, function()
         print("设置 fangka关闭按钮")

        LaypopManger_instance:back()

    end)

	self:refreshView()
	self:addChild(self.widget)


end

function fangkaNodeView:refreshView()
	local numlabel = self.mainLayer:getChildByName("num_result")

	numlabel:setString(self.num.numpackets.."元")

	local btn1 = self.mainLayer:getChildByName("Button_withdraw")

	local btn2 = self.mainLayer:getChildByName("Button_ExchangeCard")

	WidgetUtils.addClickEvent(btn1,function ()
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "你提现的请求已提交，请联系客服xxx007领取。"})
	end)
	
	WidgetUtils.addClickEvent(btn2,function ()
		LaypopManger_instance:PopBox("PromptBoxView",2,{tipstr = "你是否兑换10张房卡？",sureCallFunc = function()
			self:exchangeCard()
		end,cancelCallFunc = function()
		end})
	end)
end

function fangkaNodeView:exchangeCard()
	self:showSmallLoading()
	--print("uid:="..LocalData_instance.uid)
	ComHttp.httpPOST(ComHttp.URL.WHEELEXCHANGE,{uid = LocalData_instance.uid},function(msg)
		printTable(msg,"sjp3")
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self:hideSmallLoading()

		if msg.status ~= 1 then
			return
		end

		self.num = msg.redpacket
		self:refreshView()

		
	end)
end

return fangkaNodeView