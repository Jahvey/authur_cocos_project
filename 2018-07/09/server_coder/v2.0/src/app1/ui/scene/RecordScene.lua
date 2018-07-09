
require "app.help.ComNoti"
require "app.help.WidgetUtils"
Cards = require "app.ui.game.Card"


local confdata = {
}
local RecordScene = class("RecordScene",function()
    return cc.Scene:create()
end)

local testtime1 = 0
local testime2 = 0
function RecordScene:ctor(jsonlist,step)
	self.jsonlist = jsonlist
	self.localplayindex = 1
	self.step = step
	local data = nil
	self.actiondata = {}
	self.resultdata = nil
	for i,v in ipairs(jsonlist) do
		local jsondata = cjson.decode(v)
		release_print(jsondata.keytype)
		if jsondata then
			if jsondata.keytype == "3;4;1" then
				data = jsondata
			elseif jsondata.keytype == "3;4;6" then
				self.resultdata = jsondata
			else
				if jsondata.keytype == "3;4;4" or jsondata.keytype == "3;4;5" then
					table.insert(self.actiondata,jsondata)
				end
			end
		end
	end
	self.ismyturn = false
	AudioUtils.playMusic("bgm2")
	self.confstr ="打"..data.totalGameNums.."告"
	--printTable(data,"sjp")
	self.gameplaybird = data.gameplaybird
	self.gamestatus = data.status
	self.gameplayernums =  data.gameplayernums
	self.data = data
	self.tableid = data.roomnum
	for i,v in ipairs(data.roomPlayerItemJsons) do
		if v.userid == LocalData_instance:getUid() then
			self.myindex = v.index
		end
	end
	self:initview()


	self.gameplayernums = data.gameplayernums
	self.gameshowcardtype = data.gameshowcardtype
	self.gamefirstplaytype = data.gamefirstplaytype
	self.gamemustplaytype = data.gamemustplaytype
	self.ismyturn = false
	AudioUtils.playMusic("bgm2")
	self.confstr =""
	if data.gameplaytype == 1 then
		self.confstr = self.confstr.."经典玩法 "
	elseif data.gameplaytype == 2 then
		self.confstr = self.confstr.."15张玩法 "
	elseif data.gameplaytype == 3 then
		self.confstr = self.confstr.."懒子玩法 "
	end
	self.confstr = self.confstr..data.totalGameNums.."局 "
	self.confstr = self.confstr..data.gameplayernums.."人玩 "
	if data.gamefirstplaytype == 1 then
		self.confstr = self.confstr.."不显示牌 "
	else
		self.confstr = self.confstr.."显示牌 "
	end
	if data.gamefirstplaytype == 1 then
		self.confstr = self.confstr.."首局必出黑桃3 "
	end

	if data.gamemustplaytype == 1 then
		self.confstr = self.confstr.."必须管 "
	else
		self.confstr = self.confstr.."可不要 "
	end
	if data.gameplaybirdtype == 1 then
		self.confstr = self.confstr.."红桃10扎鸟 "
	end
	WidgetUtils.getNodeByWay(self.mainlayer,{"tableinfo"}):setString(self.confstr)
	WidgetUtils.getNodeByWay(self.mainlayer,{"ju"}):setString("局："..data.curGameNums.."/"..data.totalGameNums)
	--printTable(data)
	self:updatainfo(data)
	
end
function RecordScene:onExit()

end
function RecordScene:initview()
	self.layout = cc.CSLoader:createNode("ui/game/gamelayer.csb")
	self:addChild(self.layout)

	WidgetUtils.setBgScale(WidgetUtils.getNodeByWay(self.layout,{"bg"}))
	self.mainlayer = WidgetUtils.getNodeByWay(self.layout,{"main"})
	WidgetUtils.setScalepos(self.mainlayer)
	self.talklayer = WidgetUtils.getNodeByWay(self.mainlayer,{"talklayer"})
	self.tableidlable = WidgetUtils.getNodeByWay(self.mainlayer,{"top","tableid"})
	self.talklayer:setLocalZOrder(100)
	WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode"}):setVisible(false)
	self.painode = WidgetUtils.getNodeByWay(self.mainlayer,{"painode"})
	WidgetUtils.getNodeByWay(self.mainlayer,{"top","setbtn"}):setVisible(false)
	WidgetUtils.getNodeByWay(self.mainlayer,{"top","exitbtn"}):setVisible(false)
	WidgetUtils.getNodeByWay(self.mainlayer,{"top","dian"}):setVisible(false)
	WidgetUtils.getNodeByWay(self.mainlayer,{"top","wifi"}):setVisible(false)
	WidgetUtils.getNodeByWay(self.mainlayer,{"time"}):setVisible(false)
	WidgetUtils.getNodeByWay(self.mainlayer,{"voicebtn"}):setVisible(false)
	WidgetUtils.getNodeByWay(self.mainlayer,{"talkbtn"}):setVisible(false)
	WidgetUtils.getNodeByWay(self.mainlayer,{"doaction"}):setVisible(false)


	self.icon = {}
	for i=1,3 do
		self.icon[i] = WidgetUtils.getNodeByWay(self.mainlayer,{"iconbg"..(i)})
		self.icon[i]:setVisible(false)
		WidgetUtils.getNodeByWay(self.icon[i],{"clock"}):setVisible(false)
		self.icon[i]:setLocalZOrder(1)
	end
	
	WidgetUtils.getNodeByWay(self.mainlayer,{"recordbg"}):setVisible(true)
	WidgetUtils.getNodeByWay(self.mainlayer,{"recordbg"}):setLocalZOrder(10)
	self.playbtn  = WidgetUtils.getNodeByWay(self.mainlayer,{"recordbg","playbtn"})
	self.leftbtn  = WidgetUtils.getNodeByWay(self.mainlayer,{"recordbg","leftbtn"})
	self.rightbtn  = WidgetUtils.getNodeByWay(self.mainlayer,{"recordbg","rightbtn"})
	self.exitbtn  = WidgetUtils.getNodeByWay(self.mainlayer,{"recordbg","exitbtn"})
	self.stopbtn  = WidgetUtils.getNodeByWay(self.mainlayer,{"recordbg","stopbtn"})

	WidgetUtils.addClickEvent(self.exitbtn, function( )
		
		 cc.Director:getInstance():popScene()
	end)


	WidgetUtils.addClickEvent(self.leftbtn, function( )
		self.stopbtn:setVisible(false)
		self.playbtn:setVisible(true)
		self:stopAllActions()
		if self.localplayindex > 2 then
			local  scene = require "app.ui.scene.RecordScene".new(self.jsonlist,(self.localplayindex - 2))
	        display.runScene(scene)
	    end
	end)

	WidgetUtils.addClickEvent(self.rightbtn, function( )
		self.stopbtn:setVisible(false)
		self.playbtn:setVisible(true)
		self:stopAllActions()
		self:nextstep(1)
	end)

	WidgetUtils.addClickEvent(self.playbtn, function( )
		self:play()
	end)

	WidgetUtils.addClickEvent(self.stopbtn, function( )
		self.stopbtn:setVisible(false)
		self.playbtn:setVisible(true)
		self:stopAllActions()
	end)

	self:setregamestart(self.data)

	if self.step  == nil then
		self:play()
	else
		self.stopbtn:setVisible(false)
		self.playbtn:setVisible(true)
		self:stopAllActions()
		self:nextstep(self.step)
	end
end

function RecordScene:nextstep(num)
	local isnotan = nil 
	if num > 1 then
		isnotan = true
	end
	for i=1,num do
		if self.actiondata[self.localplayindex] ~= nil then
			if self.actiondata[self.localplayindex].keytype == "3;4;4" then
				self:moAction(self.actiondata[self.localplayindex],isnotan)
			else
				self:doAction(self.actiondata[self.localplayindex],isnotan)
			end
			self.localplayindex = self.localplayindex + 1
		else
			self:stopAllActions()
			self:setTip()
			if self.resultdata then
				self:gameover(self.resultdata)
			end
		end
	end
end

function RecordScene:play()

	self.stopbtn:setVisible(true)
	self.playbtn:setVisible(false)
	self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function( ... )
		if self.actiondata[self.localplayindex] ~= nil then
			if self.actiondata[self.localplayindex].keytype == "3;4;4" then
				self:moAction(self.actiondata[self.localplayindex])
			else
				self:doAction(self.actiondata[self.localplayindex])
			end
			self.localplayindex = self.localplayindex + 1
		else
			self:stopAllActions()
			self:setTip()
			if self.resultdata then
				self:gameover(self.resultdata)
			end
		end
	end))))
end

function RecordScene:getSex(index)
	for i,v in ipairs(self.data.roomPlayerItemJsons) do
		if v.index == index then
			print("find")
			return v.sex
		end
	end
	return 1
end
function RecordScene:setTip(index)
	print("")
	
	local nodelocal = {}
	for i=1,3 do
		nodelocal[i] = WidgetUtils.getNodeByWay(self.icon[i],{"clock"})
		nodelocal[i]:setVisible(false)
		nodelocal[i]:stopAllActions()
	end
	if index == nil or  index == 0 then
		return 
	end
	local localindex = self:getLocalindex(index)
	nodelocal[localindex]:setVisible(true)
	--nodelocal[localindex]:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.4),cc.FadeIn:create(0.4))))
	local time = WidgetUtils.getNodeByWay(self.icon[localindex],{"clock","text"})
	time:stopAllActions()
	local timedata = 10
	time:setString(timedata)
	nodelocal[localindex]:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function( ... )
		timedata = timedata -1
		-- if timedata == 3 then
		-- 	AudioUtils.playEffect("jinggao",false)
		-- end
		if timedata < 0 then
			timedata = 0
		end
		time:setString(timedata)
	end))))

end
function RecordScene:exitbtncall()
	if self.gamestatus == 0 then
		Socketapi.sendexit()
	else
		LaypopManger_instance:PopBox("PromptBoxView",2,{tipstr = "是否解散房间？",sureCallFunc = function()
			Socketapi.sendjiesan()
		end})
	end
end


function RecordScene:updatainfo(data)
	--WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode"}):setVisible(true)
	self:updataicon(data)
end
function RecordScene:updataicon(data,isgamestart)
	for i,v in ipairs(self.icon) do
		v:setVisible(false)
	end
	for i,v in ipairs(data.roomPlayerItemJsons) do
			print("icon:"..i)
			local localindex = self:getLocalindex(v.index)
			print(localindex)
			self.icon[localindex]:setVisible(true)
			self.icon[localindex].curdata = v
			self.icon[localindex]:getChildByName("name"):setString(ComHelpFuc.getStrWithLengthByJSP(v.nickname))
			self.icon[localindex]:getChildByName("fen"):setString(v.score)
			self.icon[localindex]:getChildByName("ready"):setVisible(false)
			self.icon[localindex]:getChildByName("fang"):setVisible(false)
			self.icon[localindex]:getChildByName("zhuang"):setVisible(false)
			local icon  = self.icon[localindex]:getChildByName("icon")
			require("app.ui.common.HeadIcon").new(icon,v.headimgurl)

	end
end
function RecordScene:setregamestart(data)
	self.lastaction = data.lastPlayerPlayRespJson
	self.lastoneaction = data.lastButOnePlayerPlayRespJson
	LAIZIVALUE = data.mouseCard
	if LAIZIVALUE == 0 then
		LAIZIVALUE = nil
	end
	if LAIZIVALUE then
		LAIZIVALUE = (LAIZIVALUE - 1)%13 + 1
	end
	self.gameview = require "app.ui.record.GameView".new(self,data)
	self.gameview:setPosition(cc.p(0,0))
	self.mainlayer:addChild(self.gameview)
	self:setTip(data.curPlayerIndex or data.curPlayerFlag)
end
--{"curQuan":0,"curBanker":1,"curGameNums":1,"index":1,"score":0,"curCards":[4,5,6,9,11,12,13,14,17,24,24,25,26,28],"curOutCards":[],"isPlayCard":1,"curDeskCardsItems":[],"playTypes":[7],"curPlayerIndex":1,"curPlayerFlag":1,"diCardCount":83,"keytype":"3;4;2"}


--可出牌类型：-1:无操作 1:暗杠2:明杠3:听牌4:碰5:弯杠6胡牌
--7:出牌8:过)





function RecordScene:getLocalindex(index)
	local localindex = 1
	if index - self.myindex >= 0 then
		localindex = index - self.myindex + 1
	else
		localindex = index - self.myindex + self.gameplayernums+1
	end
	return localindex
end

function RecordScene:getindexforlocal(localindex)
	local sun = self.myindex+localindex - 1
	if sun > 3 then
		return sun - 3
	else
		return sun
	end
end
--1:拢2:招3:报牌4:碰5:吃6:胡7:特殊天胡8:出牌9:过10:畏)
function RecordScene:doAction(data,isnotta)
	printTable(data,"sjp")
	self:setTip(data.curPlayerIndex or data.curPlayerFlag)

	-- for i,v in ipairs(self.outnowlayer) do
	-- 	v:removeAllChildren()
	-- end

	if data.actiontype == 1 then
		self.gameview:chupai(data,isnotta)
		self.lastaction = data
	elseif data.actiontype == 2 then
		self.gameview:guo(data,isnotta)
	end


end
function RecordScene:gameover(data)

	
	self:setTip()
	self.layout:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
		if self.SingleResultView == nil then
			self.SingleResultView = LaypopManger_instance:PopBoxexe("SingleResultView",data,self,true)
			
			if tolua.cast(self.gameview,"cc.Node") then
				self.gameview:removeFromParent()
			end
		end
	end)))
end


function RecordScene:exitgame(data)
	glApp:enterSceneByName("MainScene")
end


return RecordScene