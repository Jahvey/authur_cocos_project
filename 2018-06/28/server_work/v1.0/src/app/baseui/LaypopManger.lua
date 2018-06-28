
-------------------------------------------------
--   TODO   弹出框管理类
--   @author sjp
--   Create Date 2016.10.24
-------------------------------------------------

local LaypopManger = class("LaypopManger")
--所有弹出框必须填入下面table中
POPBOX = {
	-- 进入房间
	JoinRoomView = {class = require "app.ui.popbox.JoinRoomView"},
	-- 玩家详情
	PlayerInfoView = {class = require "app.ui.popbox.PlayInfoView"},
	-- 创建房间
	CreateRoomView = {class = require "app.ui.createroom.CreateRoomViewNew"},
	-- 帮助
	HelpView = {class = require "app.ui.popbox.HelpView"},
	-- 消息
	MessageView = {class = require "app.ui.popbox.MessageView"},
	-- 设置
	SetView = {class = require "app.ui.popbox.SetView"},
	-- 通用弹框
	PromptBoxView = {class = require "app.ui.popbox.PromptBoxView"}, 
	-- -- 牌局结束
	-- AllResultView = {class = require "app.ui.result.AllResultView"},
	-- 单局结算
	SingleResultView = {class = require "app.ui.result.SingleResultView",opacity = 95,color = cc.c3b(0x47,0x3f,0x3b)},
	DDZSingleResultView = {class =require "app.ui.result.DDZSingleResultView"},

	-- 解散牌局
	DissolveView = {class = require "app.ui.popbox.DissolveView",notadd = true},
	-- 用户协议
	UserAgreementView = {class = require "app.ui.popbox.UserAgreementView"},
	-- 聊天
	ChatView = {class = require "app.ui.common.ChatView"},
	-- 战绩
	HistoryRecordView = {class = require "app.ui.historyrecord.HistoryRecordView"},
	-- 距离弹框
	DistanceView = {class = require "app.ui.popbox.DistanceView"},
	-- 邀请弹框
	InviteCodeView = {class = require "app.ui.popbox.InviteCodeView"},
	-- 新版商城
	ShopView = {class = require "app.ui.popbox.ShopView"},
	-- 活动公告
	NoticeActView = {class = require "app.ui.popbox.NoticeActView"},
	
	

	-- 排行榜弹框
	RankListView = {class = require "app.ui.popbox.RankListView"},
	
	-- 玩家详情
	PlayInfoViewforgame = {class = require "app.ui.popbox.PlayInfoViewforgame"},

	----------活动
	--实名认证
	Setrealname = {class = require "app.ui.popbox.Setrealname"},

	--分享活动
	ShareActivity = {class = require "app.ui.activity.ShareActivity"},

	-- 邀请活动
	InviteActivityView = {class = require "app.ui.activity.InviteActivityView"},

	--分享弹框
	SharePromptBoxView = {class = require "app.ui.popbox.SharePromptBoxView"},

	--定时玩牌
  	MeiriActivity = {class = require "app.ui.activity.MeiriActivity"},
 	MeiriActivityjilv = {class = require "app.ui.activity.MeiriActivityjilv"},
  	MeiriActivitybox = {class = require "app.ui.activity.MeiriActivitybox"},

	-----club
	OpenView =  {class = require "app.ui.club.OpenView"},
	JoinclubView = {class = require "app.ui.club.JoinView"},
	CreateclubView =  {class = require "app.ui.club.CreateView"},
	MainViewclub = {class = require "app.ui.club.MainView"},
	MsgViewclub = {class = require "app.ui.club.MsgView"},
	InfoViewclue ={class = require "app.ui.club.InfoView"},
	OtherInfoViewclue = {class = require "app.ui.club.OtherInfoView"},
	AddfangclueView ={class = require "app.ui.club.box.AddfangView"},
	JieclueView ={class = require "app.ui.club.box.JieView"},
	TableinfoclueView ={class = require "app.ui.club.box.TableinfoView"},
	RetinfoView = {class = require "app.ui.club.box.RetinfoView"},
	JieshaoclueView = {class = require "app.ui.club.box.JieshaoView"},
	TablejiesuanInfo = {class = require "app.ui.club.box.TablejiesuanInfo"},

	RecordCodeView = {class = require "app.ui.historyrecord.RecordCode"},

	GuideView = {class = require "app.ui.popbox.GuideView"},

	----club

	IFRPView = {class = require "app.ui.activity.inviteforredpacke.MainView"},

	NewCommerAct = {class = require "app.ui.activity.newcommer.NewCommerBox"},

	InviteCodeActBox = {class = require "app.ui.activity.invitecode.InviteCodeActBox"},

	MainViewclub = {class = require "app.ui.club_new.MainView"},
	OpenView =  {class = require "app.ui.club_new.OpenView"},
	JoinclubView = {class = require "app.ui.club_new.JoinView"},

	NewyearaddView = {class = require "app.ui.newyear.AddView"},
	PrizeListView1 = {class = require "app.ui.newyear.PrizeListView1"},
	PrizeListView2 = {class = require "app.ui.newyear.PrizeListView2"},

	RecallActivity = {class = require "app.ui.activity.RecallActivity"},

}
local CSB_LIST = {
	--已改界面
	"ui/joinRoom/joinRoomView.csb",
	"ui/createroom/helpView.csb",
	"ui/popbox/loadingView.csb",
	"ui/result/allResultView.csb",
	"ui/singleResult/singleResultView.csb",
	"ui/createroom/createRoomViewNew.csb",
	"ui/rankList/RankListView.csb",
	"ui/popbox/messageView.csb",
	"ui/popbox/promptBoxView.csb",
	"ui/popbox/userAgreementView.csb",
	"ui/popbox/sharePromptBoxView.csb",
	"ui/chat/chatView.csb",
	"ui/dissolveroom/dissolveView.csb",
	"ui/historyrecord/historyRecordView.csb",
	"ui/inviteAct/inviteActView.csb",
	"ui/shop/shopView.csb",
	"ui/shop/shopView2.csb",
	"ui/playerinfo/playInfoView.csb",
	"ui/playerinfo/playInfoViewforgame.csb",
	"ui/setView/setView.csb",
	"ui/setView/setViewForGame.csb",
	"ui/setrealname/setrealname.csb",
	--未改界面
	"ui/distance/distanceView.csb",
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
	-- self:removeUnusedNode()
	--local scene = glApp.curscene
	local scene = cc.Director:getInstance():getRunningScene()
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
	scene:addChild(node)
	return node
end

function LaypopManger:back()
	-- self:removeUnusedNode()
	if #self.pophistroy == 0 then
		print("no  popbox")
		return 
	end

	if  WidgetUtils:nodeIsExist(self.pophistroy[#self.pophistroy].node) then
		if self.pophistroy[#self.pophistroy].node:getParent() then
			self.pophistroy[#self.pophistroy].node:removeFromParent()
		end
		self.pophistroy[#self.pophistroy] = nil	
	end

end

function LaypopManger:backByName( _name )

	if #self.pophistroy == 0 then
		print("no  popbox")
		return 
	end

	for k,v in pairs(self.pophistroy) do
		if v.name == _name then
			if  WidgetUtils:nodeIsExist(v.node) then
				if v.node:getParent() then
					v.node:removeFromParent()
					table.remove(self.pophistroy,k)
					return
				end
			end
		end
	end
end

function LaypopManger:removeUnusedNode()
	for i=#self.pophistroy,1,-1 do
		if self.pophistroy[i].node and not tolua.cast(self.pophistroy[i].node,"cc.Node") then
			table.remove(self.pophistroy,i)
		end
	end
end

function LaypopManger:replaceScene()
	print("===========replaceScene")
	printTable(self.pophistroy,"sjp3")
	self.pophistroy = {}
end
LaypopManger.getInstance()