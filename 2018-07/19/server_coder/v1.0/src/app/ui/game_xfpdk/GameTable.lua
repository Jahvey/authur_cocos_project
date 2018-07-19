local GameTable = class("GameTable", require("app.ui.game_base_cdd.GameTable"))

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
         
        self.icon:getChildByName("iconbg"):setVisible(true)
        self.icon:getChildByName("head_icon"):setVisible(true)
        
    else
          
        for i, v in ipairs(self.icon:getChildren()) do
            if self.addfaceeffectnode ~= v then
                v:setVisible(false)
            end
        end
       
        self.icon:getChildByName("iconbg"):setVisible(true)
        local head = self.icon:getChildByName("headicon")

        local ready = self.icon:getChildByName("ok"):setVisible(false)
        local zhuang = self.icon:getChildByName("zhuang"):setVisible(false):ignoreContentAdaptWithSize(true):loadTexture("gameddz/play_zhuang2.png")
        local lixiantip = self.icon:getChildByName("lixian"):setVisible(false)
        local fangzhutip = self.icon:getChildByName("fangzhu"):setVisible(false)
        local name = self.icon:getChildByName("name"):setVisible(true)
        local score = self.icon:getChildByName("score"):setVisible(true)
        head:setVisible(true)
        name:setString(ComHelpFuc.getCharacterCountInUTF8String(info.user.nick,9)) 
        
        score:setString("分数: " .. info.total_score)
        local headicon = require("app.ui.common.HeadIcon_Club").new(head, info.user.role_picture_url,66).headicon
        head.headicon = headicon

       if info.state == poker_common_pb.EN_SEAT_STATE_READY_FOR_NEXT_ONE_GAME then
            ready:setVisible(true)            

        elseif info.state == poker_common_pb.EN_SEAT_STATE_PLAYING then
            if self.gamescene:getDealerIndex() == self:getTableIndex() then
                zhuang:setVisible(true)
                if info.is_baozi_zhuang then
                   self:showBaoZiDIZhu(false) 
                end
            end

            -- printTable(info)
            if info.hand_cards then
                if self.node:getChildByName("card") then
                    self.node:getChildByName("card"):setVisible(true)
                    self.node:getChildByName("card"):getChildByName("num"):setString(#info.hand_cards)
                end
            else
               if self.node:getChildByName("card") then
                    self.node:getChildByName("card"):setVisible(false)
               end
            end
            --info.bao_type = 2
            if info.bao_type and info.bao_type > 0 then
                self:showbaojing(info.bao_type,false)
            end

            self:shuangDoubletip(false)

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
            headicon:setTouchEnabled(true)
            WidgetUtils.addClickEvent(headicon, function()
                print("-----1111")
                self:clickHeadIcon(info.user)
            end )
        end
        if info.index == self.gamescene:getMyIndex() then
            self.gamescene.UILayer:refreshReadyCancel(info)
        end
    end
end

return GameTable