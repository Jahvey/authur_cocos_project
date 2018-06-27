
-------------------------------------------------
--   TODO   弹出框管理类
--   @author sjp
--   Create Date 2016.10.24
-------------------------------------------------

local LaypopManger = class("LaypopManger")
--所有弹出框必须填入下面table中
local POPBOX = {
	-- 进入房间
	JoinRoomView = {class = require "app.ui.popbox.JoinRoomView"},
	-- 玩家详情
	PlayerInfoView = {class = require "app.ui.popbox.PlayInfoView"},
	PlayerInfoViewforgame = {class = require "app.ui.popbox.PlayInfoViewforgame"},
	-- 购卡提示
	CardPromptBoxView = {class = require "app.ui.popbox.CardPromptBoxView"},
	-- 创建房间
	CreateRoomView = {class = require "app.ui.createroom.CreateRoomView"},
	CreateRoomView1 =  {class = require "app.ui.createroom.CreateRoomView1"},
	-- 帮助
	HelpView = {class = require "app.ui.popbox.HelpView"},
	-- 消息
	MessageView = {class = require "app.ui.popbox.MessageView"},
	-- 设置
	SetView = {class = require "app.ui.popbox.SetView"},
	-- 通用弹框
	PromptBoxView = {class = require "app.ui.popbox.PromptBoxView"}, 
	AllResultViewforkutong = {class = require "app.ui.result.AllResultViewforkutong"},
	-- 牌局结束
	AllResultView = {class = require "app.ui.result.AllResultView"},
	-- 单局结算
	SingleResultView = {class = require "app.ui.result.SingleResultView"},
	-- 解散牌局
	DissolveView = {class = require "app.ui.popbox.DissolveView"},
	-- 用于协议
	UserAgreementView = {class = require "app.ui.popbox.UserAgreementView"},
	-- 战绩
	HistoryRecordView = {class = require "app.ui.historyrecord.HistoryRecordView"},
	-- 战绩
	HistoryRecordView1 = {class = require "app.ui.historyrecord.HistoryRecordView1"},
	HistoryRecordViewforkutong =  {class = require "app.ui.historyrecord.HistoryRecordViewforkutong"},
	-- 距离弹框
	DistanceView = {class = require "app.ui.popbox.DistanceView"},
	-- 邀请弹框
	InviteCodeView = {class = require "app.ui.popbox.InviteCodeView"},
	--商店
	ShopView = {class = require "app.ui.popbox.ShopView"},
	Guiview=  {class = require "app.ui.popbox.Guiview"},

	idview = {class = require "app.ui.result.IdView"},
	ShareView = {class = require "app.ui.popbox.ShareView"},
	CodeView = {class = require "app.ui.popbox.CodeView"},
	Zhuanview = {class = require "app.ui.popbox.Zhuanview"},
	DaikaifangHelpView = {class = require "app.ui.popbox.DaikaifangHelpView"},
	Renwu = {class = require "app.ui.popbox.RenwuView"},
	NoticeActView = {class = require "app.ui.popbox.NoticeActView"},
	sunView = {class = require "app.ui.popbox.sunView"},
	LiangView = {class = require "app.ui.kutong.LiangView"},
}
local CSB_LIST = {
	"ui/popbox/cardPromptBoxView.csb",
	"ui/popbox/jiesanbox.csb",
	"ui/popbox/loadingView.csb",
	"ui/popbox/playInfoView.csb",
	"ui/popbox/promptBoxView.csb",
	"ui/popbox/setView.csb",
	"ui/popbox/userAgreementView.csb",
	"ui/popbox/helpView.csb",
	"ui/popbox/messageView.csb",
	"ui/createroom/createRoomView.csb",
	"ui/historyrecord/historyRecordView.csb",
	"ui/shop/shopView.csb",
}
-- csb
function LaypopManger:loadCSB()
	local handler = nil
	local count = 1
	local function beginhandle()
		-- print("====0===")
        if CSB_LIST[count] then
        	local node = cc.CSLoader:createNode(CSB_LIST[count])
        	-- print("====================0=",count)
        	if node then
        		-- print("====================1=",count)
        		count = count + 1
        	end
        else
        	if handler then
        		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(handler)
        		handler = nil
        	end		
        end
    end
	handler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(beginhandle,0.00001,false)    
end
function LaypopManger:ctor( ) 
	self.pophistroy = {}
	self:init()
end

function LaypopManger.getInstance()
    if not LaypopManger_instance then
	    LaypopManger_instance = LaypopManger.new()
	end
	return LaypopManger_instance
end

function LaypopManger:init( )
	self:loadCSB()
end

function LaypopManger:PopBox(name,...)
	local scene = glApp.curscene

	local elementName = POPBOX[name or '']
	if not elementName then
		print("error popbox  not have  "..name)
		return
	end
	local NODECLASS = elementName.class 
	if not NODECLASS then
		print("error popbox  not have  class "..name)
		return
	end
	local node = NODECLASS.new(...)
	node:setLocalZOrder(1)
	if node.initview then
		node:initview()
	end	
	table.insert(self.pophistroy,{name = name,node = node})
	cc.Director:getInstance():getRunningScene():addChild(node)
	return node
end


function LaypopManger:PopBoxexe(name,...)
	local scene = glApp.curscene

	local elementName = POPBOX[name or '']
	if not elementName then
		print("error popbox  not have  "..name)
		return
	end
	local NODECLASS = elementName.class 
	if not NODECLASS then
		print("error popbox  not have  class "..name)
		return
	end
	local node = NODECLASS.new(...)
	node:setLocalZOrder(1)
	if node.initview then
		node:initview()
	end	
	cc.Director:getInstance():getRunningScene():addChild(node)
	return node
end

function LaypopManger:back()
	if #self.pophistroy == 0 then
		print("no  popbox")
		return 
	end
	if self.pophistroy[#self.pophistroy] and tolua.cast(self.pophistroy[#self.pophistroy].node,"cc.Node") then
		self.pophistroy[#self.pophistroy].node:removeFromParent()
		self.pophistroy[#self.pophistroy] = nil
	end	
end

function LaypopManger:replaceScene()
	self.popBoxHistory = {}
end
LaypopManger.getInstance()