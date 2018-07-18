local ActionView = class("ActionView", require "app.ui.game_base_cdd.ActionView")

function ActionView:showAction(choices)

    print(".....ActionView:showAction")
    printTable(choices,"xp66")


    if self.gamescene:getDealerIndex() == self.gamescene:getMyIndex() then
        self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_JIA_BEI].img = "gameddz/btn_huiti.png"
    else
        self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_JIA_BEI].img = "gameddz/btn_tijiao.png"
    end
    
    self.btnNode:removeAllChildren()
    self.tipstable = nil
    local choices = clone(choices)

    local btnlist = {}
    local ischupai = false
    for i,v in ipairs(choices) do
        print(v.act_type)

        local actCof = self.ACTIONCONF[v.act_type]
        local btn
        if actCof.type == 0 then
            btn = ccui.Button:create(actCof.img)
        else
            btn = ccui.Button:create(self.btnbg[actCof.type])
            local spr = cc.Sprite:create(actCof.img)
            local size = btn:getContentSize()
            spr:setPosition(cc.p(size.width/2,size.height/2))
            btn:addChild(spr)
        end
        btn.data = v
        btn.sort = actCof.sort
        table.insert(btnlist,btn)

        if v.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI then
            ischupai = true
        end
    end
    --提示
    if ischupai then
        local lastaction = nil 
        if self.gamescene.table_info.sdr_total_action_flows and #self.gamescene.table_info.sdr_total_action_flows > 0 then
            local totall = #self.gamescene.table_info.sdr_total_action_flows
            for i,v in ipairs(self.gamescene.table_info.sdr_total_action_flows) do
                local action = self.gamescene.table_info.sdr_total_action_flows[totall-i+1].action
                if action.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI then
                    lastaction = action
                    break
                end
            end
        end
        if lastaction ~= nil then

            --计算出 提示的数据
            -- printTable(lastaction,"xp66")
            lastaction.type = lastaction.cardtype
            if self.tipstable == nil then
                self.tipstable = self.gamescene.Suanfuc:gettips(self.gamescene:getHandTileByIdx(self.gamescene:getMyIndex()),lastaction)
                -- print(".........获得提示！")
            end
            if #self.tipstable == 0 then
                --最后一张牌，要不起，就直接过
                if #self.gamescene:getHandTileByIdx(self.gamescene:getMyIndex()) == 1 then
                    local pass_data = nil
                    for i,v in ipairs(btnlist) do
                        if  v.data.act_type == poker_common_pb.EN_SDR_ACTION_PASS then
                            pass_data = v.data
                            break
                        end 
                    end
                    if pass_data ~= nil then
                         print("最后一张牌，要不起，就直接过")
                        Socketapi.request_do_actionforddz(pass_data.seat_index, pass_data.act_type,pass_data.action_token)
                        self:setVisible(false)
                        self.gamescene.mytable:setIsMyTurn(false)
                    end
                    return
                end
                -- for i,v in ipairs(btnlist) do
                --     if v.data.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI then
                --         table.remove(btnlist,i)
                --         break
                --     end
                -- end
                -- self.gamescene.mytable:showCannotPut()
            else
                --最后一张牌，要得起，就直接出
                if #self.gamescene:getHandTileByIdx(self.gamescene:getMyIndex()) == 1 then
                    print("最后一张牌，要得起，就直接出")
                    self.gamescene.mytable._pokers[1]:setSelected(true)
                    self.gamescene.mytable:tryChupai(self,choices[1])
                    return
                end

                local btn = ccui.Button:create(self.btnbg[1])
                local spr = cc.Sprite:create(self.ACTIONCONF[1000].img)
                local size = btn:getContentSize()
                spr:setPosition(cc.p(size.width/2,size.height/2))
                btn:addChild(spr)
                btn.data = {act_type = 1000}
                btn.lastaction = lastaction
                btn.sort = self.ACTIONCONF[1000].sort
                table.insert(btnlist,btn)

                self.tipnum = 1

                
            end
            
        else
            --最后一张牌，最后一手！，就直接出
            if #self.gamescene:getHandTileByIdx(self.gamescene:getMyIndex()) == 1 then
                print("最后一张牌，最后一手！，就直接出！！！")
                printTable(choices)
                self.gamescene.mytable._pokers[1]:setSelected(true)
                self.gamescene.mytable:tryChupai(self,choices[1])
                return
            end
        end
    end
    table.sort(btnlist,function(a,b)
        return a.sort > b.sort
    end)

    local totall = #btnlist
    for i,v in ipairs(btnlist) do
        v:setPositionX((i-(totall + 1) / 2)*200)
        self.btnNode:addChild(v)
        if v.data.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI then
            self.gamescene.mytable:setIsMyTurn(true)
        end

        WidgetUtils.addClickEvent(v, function()
           if v.data.act_type == poker_common_pb.EN_DSS_ACTION_CHUPAI then
                self.gamescene.mytable:tryChupai(self,v.data)
            elseif v.data.act_type == 1000 then
              --   v.lastaction.type =v.lastaction.cardtype
              --   if self.tipstable == nil then
              --       self.tipstable = self.gamescene.Suanfuc:gettips(self.gamescene:getHandTileByIdx(self.gamescene:getMyIndex()),v.lastaction)
                    -- printTable(self.tipstable,"sjp10")
              --   end
                if #self.tipstable > 0 then
                    if self.tipstable[self.tipnum] == nil then
                        self.tipnum = 1
                    end
                    -- print("....提示 ")
                    -- printTable(self.tipstable[self.tipnum],"xp69")

                    self.gamescene.mytable:showTip(self.tipstable[self.tipnum].values)
                    self.tipnum = self.tipnum + 1

           


                end
            else
                print("......其它操作 data.act_type ＝ ",v.data.act_type)

                Socketapi.request_do_actionforddz(v.data.seat_index, v.data.act_type,v.data.action_token)
                self:setVisible(false)
                self.gamescene.mytable:setIsMyTurn(false)
            end
        end )
    end
    self:setVisible(true)
end

return ActionView