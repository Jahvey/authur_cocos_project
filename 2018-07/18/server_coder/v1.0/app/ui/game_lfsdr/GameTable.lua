local GameTable = class("GameTable", require("app.ui.game.GameTable"))
function GameTable:getHandCandsFen()
    -- 获取手牌的点数
    local fen_hand = 0

    print("--获取手牌的点数")
    if self.tableidx == self.gamescene:getMyIndex() or self.gamescene.name == "RecordScene"  then
        local list = ComHelpFuc.sortMyHandTile(clone(self.gamescene:getHandTileByIdx(self.tableidx)))
        -- printTable(list,"xp")

        for k,v in pairs(list) do
            local oldValue = 0
              for kk,vv in pairs(v.valueList) do
                if  oldValue ~= vv.real_value then
                	if self.gamescene:getIsJiangCard(vv.real_value) == false then --神牌不算分
	        			if vv.one_value < 4 then
	                        if vv.num == 3 then 
	                            fen_hand = fen_hand +  6   --绍3张6分
	                        elseif vv.num == 4 then
	                            fen_hand = fen_hand +  12   --绍4张12分
	                        else
	                            fen_hand = fen_hand +  vv.num  --其它数量，一个一分
	                        end
	                    else
	                        if vv.num == 3 then
	                           fen_hand = fen_hand +  4 --绍3张4分
	                        elseif vv.num == 4 then
	                           fen_hand = fen_hand +  8  --绍4张6分，
	                        end
	                    end
    				end
                end
                oldValue = vv.real_value
            end  
        end
    end
    return fen_hand
end
--wai  和 chi  都叫吃
-- 吃牌动画 从展示位到摆牌位
function GameTable:chiPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    
    self:showActionImg("action_chi")
    AudioUtils.playVoice("action_chi", self.gamescene:getSexByIndex(self:getTableIndex()))
    
    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"chiPaiAction")
end

-- 歪牌动画 从展示位到摆牌位
function GameTable:waiPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    self:showActionImg("action_chi")
    AudioUtils.playVoice("action_chi", self.gamescene:getSexByIndex(self:getTableIndex()))

    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"waiPaiAction")
end

--设置票 状态   -1 等待 1-5 飘 0不飘
function GameTable:setPiao(type)
    self.icon:getChildByName("ok"):setVisible(false)

    if self.icon:getChildByName("piaonode") == nil then
        local piaonode = cc.CSLoader:createNode("animation/piao/piao.csb")
        self.icon:addChild(piaonode)
        piaonode:setName("piaonode")
        piaonode:setVisible(false)
        piaonode:getChildByName("dingpiaozhong"):setVisible(false)
    end

    local piaonode = self.icon:getChildByName("piaonode"):setVisible(true)
    if type == -1 then
        piaonode:getChildByName("dingpiaozhong"):setVisible(true)
        piaonode:getChildByName("piao"):setVisible(false)
    elseif type >=1 and type <= 5 then
        piaonode:setPosition(cc.p(self.icon:getChildByName("piao"):getPosition()))
        piaonode:getChildByName("dingpiaozhong"):setVisible(false)
        piaonode:getChildByName("piao"):setVisible(true)
        AudioUtils.playVoice("action_piao",self.gamescene:getSexByIndex(self:getTableIndex()))
    else
        piaonode:setVisible(false)
        AudioUtils.playVoice("action_nopiao",self.gamescene:getSexByIndex(self:getTableIndex()))
    end

    self.icon:getChildByName("piaonode"):stopAllActions()
    if type ~= 0 then
        local action = cc.CSLoader:createTimeline("animation/piao/piao.csb")
        local function onFrameEvent(frame)
            if nil == frame then
                return
            end
            local str = frame:getEvent()
            if str == "end" then
                if type ~= -1 then
                    piaonode:removeFromParent()
                    local piao = self.icon:getChildByName("piao"):setVisible(true)
                    piao:setTexture("cocostudio/ui/game/icon_piao.png")
                    piao:getChildByName("piaoscore"):setVisible(true)
                    piao:getChildByName("redpoint"):setVisible(true)
                    self.icon:getChildByName("piao"):getChildByName("piaoscore"):setString(type)
                end
            end
        end
        action:setFrameEventCallFunc(onFrameEvent)
        self.icon:getChildByName("piaonode"):runAction(action)
        if type == -1 then
            action:gotoFrameAndPlay(0, true)
        else
            action:gotoFrameAndPlay(0, false)
        end
    end
end

-- 刷新座位信息
function GameTable:refreshSeat(info, isStart)

    if not info then
        info = self.gamescene:getSeatInfoByIdx(self:getTableIndex())
    end

    self.icon:setVisible(true)


    local headbg = self.icon:getChildByName("headbg")
    if info.state == poker_common_pb.EN_SEAT_STATE_NO_PLAYER or info.user == nil or info.user == { } then
        for i, v in ipairs(self.icon:getChildren()) do
            v:setVisible(false)
        end
        headbg:setVisible(true)
        local bg_type = cc.UserDefault:getInstance():getIntegerForKey("bg_type", 3)
        headbg:loadTexture("game/bg_headbg_" .. bg_type .. ".png", ccui.TextureResType.localType)
        self.icon:getChildByName("head_icon"):setVisible(true)

    else
        for i, v in ipairs(self.icon:getChildren()) do
            if self.addfaceeffectnode ~= v then
                v:setVisible(false)
            end
        end
        headbg:setVisible(true)

        local bg_type = cc.UserDefault:getInstance():getIntegerForKey("bg_type", 3)
        headbg:loadTexture("game/bg_headbg_" .. bg_type .. ".png", ccui.TextureResType.localType)

        local head = self.icon:getChildByName("headicon")

        local name = self.icon:getChildByName("name"):setVisible(false)
        local ready = self.icon:getChildByName("ok"):setVisible(false)
        local zhuang = self.icon:getChildByName("zhuang"):setVisible(false)
        zhuang:setColor(cc.c3b(255, 255, 255))
        local lixiantip = self.icon:getChildByName("lixian"):setVisible(false)
        local fangzhutip = self.icon:getChildByName("fangzhu"):setVisible(false)

        local huxitext = self.icon:getChildByName("huxitext"):setVisible(false)
        local fentext = self.icon:getChildByName("fentext"):setVisible(false)
        local xiazhuatext = self.icon:getChildByName("xiazhuatext"):setVisible(false)
        local piao = self.icon:getChildByName("piao"):setVisible(false)
        piao:getChildByName("piaoscore"):setVisible(false)
        piao:getChildByName("redpoint"):setVisible(false)
        local piaopos = cc.p(piao:getPositionX(),piao:getPositionY())
        local bao = self.icon:getChildByName("bao")
        self.icon:getChildByName("huazhuang"):setVisible(false)
        
        head:setVisible(true)
        name:setString(info.user.nick)

        -- local size = headbg:getContentSize()
        local headicon = require("app.ui.common.HeadIcon").new(head, info.user.role_picture_url,66).headicon
        head.headicon = headicon
        head:setPosition(cc.p(0, 2))

        if info.state == poker_common_pb.EN_SEAT_STATE_WAIT_FOR_NEXT_ONE_GAME then
            name:setVisible(true)

        elseif info.state == poker_common_pb.EN_SEAT_STATE_READY_FOR_NEXT_ONE_GAME then
            ready:setVisible(true)
            name:setVisible(true)
        elseif info.state == poker_common_pb.EN_SEAT_STATE_PLAYING then
            if self.gamescene:getDealerIndex() == self:getTableIndex() then
                if isStart then
                    self:showZhuangAction()
                else
                    zhuang:setVisible(true)
                end
            end

            if self.gamescene:getOldDealerIndex() == self:getTableIndex() then
                zhuang:setVisible(true)
                zhuang:setColor(cc.c3b(0x99, 0x96, 0x96))
            end

            fentext:setVisible(true)
            huxitext:setVisible(true)
            if info.total_score == nil then
                info.total_score = 0
            end
            fentext:setString("分数: " .. info.total_score)
            self:updataHuXiText()

            if self.gamescene:getTableConf().ttype == HPGAMETYPE.HFBH then
                xiazhuatext:setVisible(true)
                xiazhuatext:setString(string.format("下抓:%d", info.disable_4_times))
            end

        elseif info.state == poker_common_pb.EN_SEAT_STATE_WIN then
            fentext:setVisible(true)
            huxitext:setVisible(true)
            if info.total_score == nil then
                info.total_score = 0
            end
            fentext:setString("分数: " .. info.total_score)
            self:updataHuXiText()

            if self.gamescene:getTableConf().ttype == HPGAMETYPE.HFBH then
                xiazhuatext:setVisible(true)
                xiazhuatext:setString(string.format("下抓:%d", info.disable_4_times))
            end

        elseif info.state == 99 then
            if self.gamescene:getDealerIndex() == self:getTableIndex() then
                if isStart then
                    self:showZhuangAction()
                else
                    zhuang:setVisible(true)
                end
            end
            if self.gamescene:getOldDealerIndex() == self:getTableIndex() then
                zhuang:setVisible(true)
                zhuang:setColor(cc.c3b(0x99, 0x96, 0x96))
            end
            name:setVisible(true)
            huxitext:setVisible(true)
        else
            print("不存在的玩家状态")
        end

        if info.user.is_offline then
            lixiantip:setVisible(true)
        end

        if self.gamescene:getTableCreaterID() == info.user.uid then
            fangzhutip:setVisible(true)
        end

        if self.gamescene:getSeatInfoByIdx(self.tableidx).state ~= 99 then
            WidgetUtils.addClickEvent(headicon, function()
                self:clickHeadIcon(info.user)
            end )
        end
        if info.index == self.gamescene:getMyIndex() then
            self.gamescene.UILayer:refreshReadyCancel(info)
        end

        if info.piao_score and info.piao_score > 0 then
            piao:setVisible(true)
            if info.piao_score and info.piao_score > 0 then
                piao:getChildByName("piaoscore"):setVisible(true)
                piao:getChildByName("redpoint"):setVisible(true)
                piao:getChildByName("piaoscore"):setString(info.piao_score)
            end
        end
    end
end

function GameTable:playPaiVoice(pai)
    local _str = (math.floor(pai / 16))..(pai % 16)
    if pai == 0x43 or pai == 0x73 then
        AudioUtils.playVoice("pai_bd_".._str, self.gamescene:getSexByIndex(self:getTableIndex()))
        return
    end
    AudioUtils.playVoice("pai_".._str, self.gamescene:getSexByIndex(self:getTableIndex()))
end

return GameTable