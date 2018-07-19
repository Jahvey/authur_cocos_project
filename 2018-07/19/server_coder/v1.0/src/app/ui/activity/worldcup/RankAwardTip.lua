local RankAwardTip = class("RankAwardTip",require "app.module.basemodule.BasePopBox")

local wechat = "jrhp007"
function RankAwardTip:initView(rank)
	self.widget = cc.CSLoader:createNode("ui/worldcup/box/rankAwardTip.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)

	self.btn = self.mainLayer:getChildByName("btn")
	WidgetUtils.addClickEvent(self.btn, function( )
		CommonUtils.copyTo(wechat)
		LaypopManger_instance:back()
	end)

	local tip = self.mainLayer:getChildByName("tip")
	tip:setString("   恭喜您在世界杯活动中排名第"..rank.."，您的奖励我们将会在活动结束后3日内发送至您背包，实物奖励还请联系客服"..wechat.."领取！")
end

function RankAwardTip:onEnter()
end

function RankAwardTip:onExit()
end

return RankAwardTip