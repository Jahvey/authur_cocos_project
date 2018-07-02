local IdView = class("IdView",PopboxBaseView)

function IdView:ctor(data,scene,ipcommon)
	self.scene = scene
	self.data = data
	self.ipcommon = ipcommon
	self:initView()
	
end


function IdView:initView()

	self.widget = cc.CSLoader:createNode("ui/popbox/idview.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")

	local namestr = ""
	for i,v in ipairs(self.data.roomPlayerItemJsons) do
		if v.playerid ~= LocalData_instance.playerid then
			if v.ip == self.ipcommon then
				namestr = namestr.."  "..v.nickname
			end
		end
	end

	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("closeBtn"), function( )
		print("继续游戏")
		LaypopManger_instance:back()
		--glApp:enterSceneByName("MainScene")
	end)

	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("surebtn"), function( )
		print("继续游戏")
		LaypopManger_instance:back()
		--glApp:enterSceneByName("MainScene")
	end)
	local canlebtn1 = self.mainLayer:getChildByName("canlebtn")
	WidgetUtils.addClickEvent(canlebtn1, function( )
		print("解散房间")
		self.scene:exitbtncall()
	end)
	local text = self.mainLayer:getChildByName("1")
	text:setString("检测到玩家"..namestr.."  为同一IP,\n是否继续游戏?")
end
return IdView