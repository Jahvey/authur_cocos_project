-------------------------------------------------
--   TODO   单局结算UI
--   @author yc
--   Create Date 2016.10.27
-------------------------------------------------
local Card = require "app.ui.game.Card"

local SingleResultView = class("SingleResultView",PopboxBaseView)
local curdata  ={
       ["hand_cards"] = {
        0,
        0,
        0,
        0,
        0,
        0,
        0,
      },
       ["out_col"] = {
         {
               ["dest_card"] = 81,
               ["col_type"] = 5,
               ["cards"] =    {
                81,
              },
               ["score"] = 0,
          },
         {
               ["an_num"] = 0,
               ["col_type"] = 4,
               ["dest_card"] = 19,
               ["cards"] =    {
                19,
                43,
              },
               ["score"] = 4,
          },
      },
       ["user"] = {
           ["acc_type"] = 0,
           ["role_picture_url"] = "",
           ["chip"] = 100,
           ["channel"] = 0,
           ["uid"] = 49026,
           ["nick"] = "Guest49026",
           ["is_offline"] = true,
           ["gender"] = 0,
           ["last_login_ip"] = "::ffff:218.88.30.78",
           ["connect_id"] = 101,
      },
       ["action_token"] = 0,
       ["hu_xi"] = 0,
       ["out_cards"] = {
        59,
        28,
        44,
      },
       ["an_2_col_on_hand"] = {
         {
               ["dest_card"] = 20,
               ["col_type"] = 11,
               ["cards"] =    {
                20,
                52,
                68,
              },
               ["an_num"] = 0,
          },
      },
       ["index"] = 1,
       ["state"] = 3,
       ["total_score"] = 0,
       ["multiple"] = 0,
       ["final_score"] = 0,
  }

function SingleResultView:ctor(data,scene,ishuifang)
	self.scene = scene
  self.ishuifang = ishuifang
  self.data = data or curdata
  --printTable(data,"sjp")
	self:initView()
end
function SingleResultView:initView()
	self.widget = cc.CSLoader:createNode("ui/result/singleResultView.csb")
	self:addChild(self.widget)
  self.cell = self.widget:getChildByName("cell")
  self.cell:setVisible(false)

	self.mainLayer = self.widget:getChildByName("main")
	

  WidgetUtils.addClickEvent(self.mainLayer:getChildByName("againbtn"), function( )
    print("继续游戏")
        self.scene.SingleResultView = nil 
      if self.data.gameAllEndRespJson then
         LaypopManger_instance:PopBox("AllResultView",self.data.gameAllEndRespJson)
      else
          LaypopManger_instance:back()
         Socketapi.readyaction()
         
      end
  end)


  WidgetUtils.addClickEvent(self.mainLayer:getChildByName("sharebtn"), function( )
    print("分享")
    CommonUtils.shareScreen()
  end)
  for i=1,4 do
    self.mainLayer:getChildByName("iconbg"..i):setVisible(false)
  end
  local win =  self.mainLayer:getChildByName("success")
  win:setVisible(false)
  local fail =  self.mainLayer:getChildByName("failed")
   fail:setVisible(false)
  local zero =  self.mainLayer:getChildByName("zero")
   zero:setVisible(false)
  for i,v in ipairs(self.data.gameendinfolist) do
      local iconnode =   self.mainLayer:getChildByName("iconbg"..i)
      iconnode:setVisible(true)
      iconnode:getChildByName("zha"):setString(v.nickname)
      -- if v.index == self.data.curBanker then
      --   iconnode:getChildByName("zhuang"):setVisible(true)
      -- else
      --   iconnode:getChildByName("zhuang"):setVisible(false)
      -- end
      require("app.ui.common.HeadIcon").new( iconnode:getChildByName("icon"),v.headimgurl)
      iconnode:getChildByName("icon"):setLocalZOrder(-1)

      if v.playerid == LocalData_instance.playerid then
        if v.onescore > 0 then
           win:setVisible(true)
           AudioUtils.playEffect("yingle",false)
        elseif v.onescore == 0 then
           zero:setVisible(true)
        else
          AudioUtils.playEffect("shule2",false)
           fail:setVisible(true)
        end
      end
      local score = iconnode:getChildByName("score")
      if v.onescore >= 0 then
        score:setString("+"..v.onescore)
        score:setColor(cc.c3b(0, 255, 0))
      else
        score:setString(v.onescore)
        score:setColor(cc.c3b(255, 0, 0))
      end
      local node1 = iconnode:getChildByName("node1")
      local node2 = iconnode:getChildByName("node2")
      local node3 = iconnode:getChildByName("node3")
      if  v.curPutCardsItems[1].cardtype > 10 then
          self:createcard( node1,v.curPutCardsItems[1].curCards )
          local nodecopy = self.cell:clone()
          nodecopy:setVisible(true)
          nodecopy:getChildByName("image"):loadTexture("game/action/action"..v.curPutCardsItems[1].cardtype..".png", ccui.TextureResType.localType)
          node1:addChild(nodecopy)
          nodecopy:setPositionY(-120)
           nodecopy:setPositionX(0)
          local text =  nodecopy:getChildByName("text")
          if v.curPutCardsItems[1].score >= 0 then
            text:setColor(cc.c3b(0, 255, 0))
            text:setString("+"..v.curPutCardsItems[1].score)
          else
            text:setColor(cc.c3b(255, 0, 0))
            text:setString(v.curPutCardsItems[1].score)
          end
      else
         self:createcard( node1,v.curPutCardsItems[1].curCards )
            local nodecopy = self.cell:clone()
             nodecopy:setVisible(true)
            nodecopy:getChildByName("image"):loadTexture("game/action/action"..v.curPutCardsItems[1].cardtype..".png", ccui.TextureResType.localType)
            node1:addChild(nodecopy)
            nodecopy:setPositionY(-120)
            nodecopy:setPositionX(0)
            local text =  nodecopy:getChildByName("text")
            if v.curPutCardsItems[1].score >= 0 then
              text:setColor(cc.c3b(0, 255, 0))
              text:setString("+"..v.curPutCardsItems[1].score)
            else
              text:setColor(cc.c3b(255, 0, 0))
              text:setString(v.curPutCardsItems[1].score)
            end

          self:createcard( node2,v.curPutCardsItems[2].curCards )
             local nodecopy = self.cell:clone()
              nodecopy:setVisible(true)
              nodecopy:getChildByName("image"):loadTexture("game/action/action"..v.curPutCardsItems[2].cardtype..".png", ccui.TextureResType.localType)
              node2:addChild(nodecopy)
              nodecopy:setPositionY(-120)
               nodecopy:setPositionX(0)
              local text =  nodecopy:getChildByName("text")
              if v.curPutCardsItems[2].score >= 0 then
                text:setColor(cc.c3b(0, 255, 0))
                text:setString("+"..v.curPutCardsItems[2].score)
              else
                text:setColor(cc.c3b(255, 0, 0))
                text:setString(v.curPutCardsItems[2].score)
              end
          self:createcard( node3,v.curPutCardsItems[3].curCards )

            local nodecopy = self.cell:clone()
             nodecopy:setVisible(true)
          nodecopy:getChildByName("image"):loadTexture("game/action/action"..v.curPutCardsItems[3].cardtype..".png", ccui.TextureResType.localType)
          node3:addChild(nodecopy)
          nodecopy:setPositionY(-120)
           nodecopy:setPositionX(0)
          local text =  nodecopy:getChildByName("text")
          if v.curPutCardsItems[3].score >= 0 then
            text:setColor(cc.c3b(0, 255, 0))
            text:setString("+"..v.curPutCardsItems[3].score)
          else
            text:setColor(cc.c3b(255, 0, 0))
            text:setString(v.curPutCardsItems[3].score)
          end
      end
  end
  
end


function SingleResultView:createcard( node,cards )
  node:setScale(0.5)
    for i,v in ipairs(cards) do
      local card = Card.new(v)
      
      card:setCardAnchorPoint(cc.p(0,0.5))

      card:setPositionX((i - 1)*70)
      node:addChild(card)
    end
end

return SingleResultView