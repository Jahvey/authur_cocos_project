-------------------------------------------------
--   TODO   帮助UI
--   @author yc
--   Create Date 2016.10.26
-------------------------------------------------
local HelpView = class("HelpView",PopboxBaseView)
function HelpView:ctor(data)
	self:initData()
	self:initView(data)
	self:initEvent()
end
function HelpView:initData()

end

function HelpView:initView(data)
	self.widget = cc.CSLoader:createNode("ui/popbox/GuiView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("closeBtn"), function( )
		print("返回大厅")
		LaypopManger_instance:back()
	end)
	local wanfa = {"明牌抢庄","通比牛牛","自由抢庄","固定庄家","牛牛上庄","明牌抢庄牛几几倍","下注抢庄牛几几倍","自由抢庄牛几几倍","赖子玩法牛几几倍"}
	self.mainLayer:getChildByName("text1"):setString("玩法说明: "..wanfa[data.gamebankertype])
	if data.gametimestype == 1 then
		if data.gamebankertype < 5 then
			self.mainLayer:getChildByName("text2"):setString("翻倍规则: ".."牛牛4倍 牛九3倍 牛八2倍 牛七2倍")
		else
			self.mainLayer:getChildByName("text2"):setString("翻倍规则: ".."牛几几倍")
		end
	end
	local text9 = "特殊牌型:"
	if data.gamebankertype < 5 then
		if data.gameshunniutype == 1 then
			text9 = text9.."".."顺子牛(5倍)"
		end
		if data.gamehuaniutype== 1 then
			text9 = text9.."".."五花牛(5倍)"
		end
		if data.gamesamehuaniutype == 1 then
			text9 = text9.."".."同花牛(6倍)"
		end
		if data.gamehuluniutype == 1 then
			text9 = text9.."".."葫芦牛(7倍)"
		end
		if data.gameboomniutype== 1 then
			text9 = text9.."".."炸弹牛(6倍)"
		end
		if data.gamewuxiaoniutype== 1 then
			text9 = text9.."".."五小牛(8倍)"
		end
	else
		text9 = text9.."五炸牛40倍 同花顺25倍 四炸20倍 五花牛19倍 五小牛18倍 葫芦17倍 同花16倍 顺子15倍 牛牛10倍"
	end

	self.mainLayer:getChildByName("text9"):setString(text9)
	self.mainLayer:getChildByName("text3"):setString("局     数: "..data.totalGameNums)
	if  self.gamebankertype ~=2 then
		if data.gamediscoretype == 1 then
			self.mainLayer:getChildByName("text4"):setString("底     分: 1-2")
		elseif data.gamediscoretype == 2 then
			self.mainLayer:getChildByName("text4"):setString("底     分: 2-4")
		elseif data.gamediscoretype == 4 then
			self.mainLayer:getChildByName("text4"):setString("底     分: 4-8")
		elseif data.gamediscoretype == 5 then
			self.mainLayer:getChildByName("text4"):setString("底     分: 5-10")
		elseif data.gamediscoretype == 10 then
			self.mainLayer:getChildByName("text4"):setString("底     分: 10-20")
		end
	else
		self.mainLayer:getChildByName("text4"):setString("底     分: 1"..data.gamediscoretype)
	end
	if data.gamebankertype == 2 then
		self.mainLayer:getChildByName("text4"):setString("底     分: "..data.gamediscoretype)
	end
	if data.gamebankertype == 4 then
		if data.gamemusthit == 1 then
			self.mainLayer:getChildByName("text4"):setString("必打选项: 首局必打")
		elseif data.gamemusthit == 2 then
			self.mainLayer:getChildByName("text4"):setString("必打选项: 二局必打")
		elseif data.gamemusthit == 3 then
			self.mainLayer:getChildByName("text4"):setString("必打选项: 三局必打")
		end
	end

	if data.gameusecoinstype == 1 then
		self.mainLayer:getChildByName("text5"):setString("房     费: ".."房主支付")
	elseif data.gameusecoinstype == 2 then
		self.mainLayer:getChildByName("text5"):setString("房     费: ".."AA支付")
	elseif data.gameusecoinstype == 3 then
		self.mainLayer:getChildByName("text5"):setString("房     费: ".."大赢家支付")
	elseif data.gameusecoinstype == 4 then
		self.mainLayer:getChildByName("text5"):setString("房     费: ".."代开房")
	end
	self.mainLayer:getChildByName("text6"):setString("推     注: "..data.gamepushtimes.."倍")
	local str5 = ""
	if data.gamejointype == 1 then
		str5 = "特     殊: ".."游戏开始后禁止加入"
	else
		str5 = "特     殊: ".."游戏开始后可以加入"
	end
	if data.gamecuocardtype == 1 then
		str5 = str5.." ".."禁止搓牌"
	end
	if data.gamebankertype == 1 or data.gamebankertype == 3 then
		if data.gamebetlimit == 1 then
			str5 = str5.." ".."下注限制"
		end
	end

	self.mainLayer:getChildByName("text7"):setString(str5)
	self.mainLayer:getChildByName("text8"):setVisible(false)
	-- if data.gamebankerscore then
	-- 	self.mainLayer:getChildByName("text8"):setVisible(true)
	-- 	self.mainLayer:getChildByName("text8"):setString("上庄分数: "..data.gamebankerscore)
	-- end
	if data.gamebankertype == 1 then
		if data.gameqiangbankertimes then
			self.mainLayer:getChildByName("text8"):setVisible(true)
			self.mainLayer:getChildByName("text8"):setString("抢庄倍数: "..data.gameqiangbankertimes.."倍")
		end
	end
end

function HelpView:initEvent()
end
return HelpView