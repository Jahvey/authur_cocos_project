-- 长牌场景
local GameScene = class("GameScene", require "app.ui.game.GameScene")


--漂相关
function GameScene:SelectPiao(data)

	self.UILayer:gameStartAciton()
     if not self:getSeatInfoByIdx(self:getMyIndex()).is_piao then
        if not data then
            local piao_score = self:getSeatInfoByIdx(self:getMyIndex()).piao_score
            if not piao_score then
                piao_score = 0
            end
            data = {can_pass = (piao_score == 0),
                    min_score = piao_score, }
        end
        local selectnode = cc.Node:create()
        selectnode:setPosition(display.cx,display.cy)
        local btn1 = ccui.Button:create("game/btn_piao.png", "game/btn_piao.png", "game/btn_piao.png", ccui.TextureResType.localType)
        
        selectnode:addChild(btn1)
        self:addChild(selectnode)
        btn1:setPositionX(0)
        WidgetUtils.addClickEvent(btn1,function ()
            self:clickPiaoBtn(selectnode,btn1,data.min_score)
        end)

        if data.can_pass then
            local btn2 = ccui.Button:create("game/btn_guo.png", "game/btn_guo.png", "game/btn_guo.png", ccui.TextureResType.localType)
            selectnode:addChild(btn2)
            btn1:setPositionX(-100)
            btn2:setPositionX(100)
            
            WidgetUtils.addClickEvent(btn2,function ()
                self:requestPiao(0)
                selectnode:removeFromParent()
            end)
        end
    end

    for i,v in ipairs(self:getSeatsInfo()) do
        if not v.is_piao then
            self.tablelist[v.index+1]:setPiao(-1)
        else
            self.tablelist[v.index+1]:setPiao(v.piao_score)
        end
    end
end

function GameScene:notifyPiao( data )

    print("GameScene:notifyPiao( data )")
    printTable(data,"xpp")

    local _score = data.piao_score or 0
    if _score > 0 then
        self:getSeatInfoByIdx(data.seat_index).is_piao = true
    else
        self:getSeatInfoByIdx(data.seat_index).is_piao = false
        _score = 0
    end
    self:getSeatInfoByIdx(data.seat_index).piao_score = _score
    self.tablelist[data.seat_index+1]:setPiao(_score)
end

-- 生成飘的2级页面
function GameScene:clickPiaoBtn(selectnode,btn,min_score)
	
	if btn.layer and tolua.cast(btn.layer,"cc.Node") then
		btn.layer:removeFromParent()
		btn.layer = nil
		return
	end

	btn.layer = cc.Node:create()
		:addTo(selectnode)

	local bg = ccui.ImageView:create("game/action_bg.png")
        :setScale9Enabled(true)
        :setCapInsets(cc.rect(30, 30, 44, 44))
        :setAnchorPoint(cc.p(0.5, 0))
        bg:setLocalZOrder(-1)
        bg:setContentSize(cc.size(56 + 44 + 92 *(5 - 1), 76 + 76))
        btn.layer:addChild(bg)

    local jiantou = ccui.ImageView:create("game/action_arrow.png")
        jiantou:setAnchorPoint(cc.p(0.5, 1))
        jiantou:setPositionX(bg:getContentSize().width / 2.0)
        bg:addChild(jiantou)

   	-- 生成选择项
    for i=1,5 do
        -- local node = self:createSelectNode(v)
        local node = cc.Node:create()

        local btn = ccui.Button:create("game/piaobtn/piao_yellow_"..i..".png", "game/piaobtn/piao_yellow_"..i..".png", "game/piaobtn/piao_gray_"..i..".png", ccui.TextureResType.localType)
	    btn:setAnchorPoint(cc.p(0.5, 0.5))
	    btn:setScale9Enabled(true)
	    -- btn:setContentSize(cc.size(50, 76 +(5 - 1) * 32))
	    btn:setPositionX(0)
	    btn:setPositionY(0)

        if min_score > i then
            btn:setBright(false)
            btn:setTouchEnabled(false)
        end

	    WidgetUtils.addClickEvent(btn, function()
	        -- self:sendAction(_tab)
            self:requestPiao(i)
	        if tolua.cast(selectnode,"cc.Node") then
	        	selectnode:removeFromParent()
	        end
	    end )
	    node:addChild(btn)

        node:setPositionX(28 + 22 +(i - 1) * 92)
        node:setPositionY(bg:getContentSize().height / 2.0)
        bg:addChild(node)
    end

    local _x, _y = btn:getPosition()
    btn.layer:setPosition(cc.p(_x, _y + 80))
end

function GameScene:requestPiao(piao_score)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_select_piao
    request.is_piao = true
    request.piao_score = piao_score
    SocketConnect_instance:send("cs_request_select_piao", msg)
end


return GameScene