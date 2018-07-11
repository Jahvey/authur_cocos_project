require "app.help.WidgetUtils"
local LongCard = require "app.ui.game_base_cdd.base.LongCard"
local PICWIDTH = 200



local ActionView = class("ActionView", function()
    return cc.Node:create()
end )

function ActionView:ctor(gamescene)
    self.gamescene = gamescene

    self.ACTIONCONF = 
    {
        [poker_common_pb.EN_SDR_ACTION_BUY] = {type =0, sort = 10,img = "gameddz/btn_hongpai.png"}, -- 买牌
        [poker_common_pb.EN_SDR_ACTION_SELL] = {type =0,sort = 0,img = "gameddz/btn_heipai.png"}, --卖牌
        [poker_common_pb.EN_SDR_ACTION_JIA_BEI] = {type =0,sort = 10,img = "gameddz/btn_tijiao.png"}, --加倍
        [poker_common_pb.EN_SDR_ACTION_BU_JIA_BEI] = {type =0,sort = 0,img = "gameddz/btn_buti.png"}, --不加倍

        [poker_common_pb.EN_SDR_ACTION_CHUPAI] = {type =1,sort = 0,img = "gameddz/ddz_btn_text_chupai.png"},
        [poker_common_pb.EN_SDR_ACTION_PASS] = {type =2,sort = 12,img = "gameddz/ddz_btn_text_buchu.png"},

        [poker_common_pb.EN_SDR_ACTION_QIANG_DI_ZHU] = {type =1,sort = 10,img = "gameddz/ddz_btn_text_jiaodizhu.png"}, --叫地主
        [poker_common_pb.EN_SDR_ACTION_BU_QIANG] = {type =2,sort = 0,img = "gameddz/ddz_btn_text_bujiao.png"}, --不叫

        [poker_common_pb.EN_SDR_ACTION_QIANG_MIAN_ZHAN] = {type =2,sort = 10,img = "gameddz/ddz_btn_text_touxiang.png"},
        [poker_common_pb.EN_SDR_ACTION_FAN_DI_PAI] = {type =1,sort = 0,img = "gameddz/ddz_btn_text_fanpai.png"},

        [poker_common_pb.EN_SDR_ACTION_MING_PAI] = {type =1,sort = 10,img = "gameddz/btn_mingpai.png"}, -- 明牌
        [poker_common_pb.EN_SDR_ACTION_BU_MING] = {type =2,sort = 0,img = "gameddz/btn_bumingpai.png"}, -- 不明牌

        [poker_common_pb.EN_SDR_ACTION_JIAO_DI_ZHU] = {type =1,sort = 10,img = "gameddz/ddz_btn_text_jiaodizhu.png"}, --叫地主
        [poker_common_pb.EN_SDR_ACTION_BU_JIAO] = {type =2,sort = 0,img = "gameddz/ddz_btn_text_bujiao.png"}, --不叫

        [1000] = {type =1,sort = 11,img = "gameddz/ddz_btn_text_tishi.png"},
    }

    self.huazhuangsrc = "game/btn_guo.png"

    self.btnNode = cc.Node:create()
    self:addChild(self.btnNode)
    self:setVisible(false)
    self.btnNode:setPositionY(-35)

    -- self.selectNode = cc.Node:create()
    -- self:addChild(self.selectNode)
    -- self.selectNode:setVisible(false)
    -- self.selectNode.btn = nil

    self.btnbg = {
        "gameddz/ddz_btn_yellow.png",
        "gameddz/ddz_btn_blue.png"
    }

    self:init()
end

function ActionView:init()
 
end


function ActionView:getIsShow()
    return self:isVisible()
end

function ActionView:showAction(choices)
    self.is_first_chu_pai = false
    print(".....ActionView:showAction")
    printTable(choices,"xp66")

    if self.gamescene:getTableConf().ttype ~= HPGAMETYPE.JDDDZ then
        if self.gamescene:getDealerIndex() == self.gamescene:getMyIndex() then
            self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_JIA_BEI].img = "gameddz/btn_huiti.png"
        else
            self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_JIA_BEI].img = "gameddz/btn_tijiao.png"
        end
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
            self.is_first_chu_pai = v.is_first_chu_pai
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
                print(".........获得提示！")
                printTable(self.tipstable,"sjp3")
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
                for i,v in ipairs(btnlist) do
                    if v.data.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI then
                        table.remove(btnlist,i)
                        break
                    end
                end
                
                local pass_data = nil
                for i,v in ipairs(btnlist) do
                    if  v.data.act_type == poker_common_pb.EN_SDR_ACTION_PASS then
                        pass_data = v.data
                        break
                    end 
                end
                if pass_data ~= nil and btnlist[1] then
                    btnlist[1]:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function( ... )
                        Socketapi.request_do_actionforddz(pass_data.seat_index, pass_data.act_type,pass_data.action_token)
                        self:setVisible(false)
                        self.gamescene.mytable:setIsMyTurn(false)
                    end)))
                    
                end

                self.gamescene.mytable:showCannotPut()
            else
                --最后一张牌，要得起，就直接出
                -- if #self.gamescene:getHandTileByIdx(self.gamescene:getMyIndex()) == 1 then
                --     print("最后一张牌，要得起，就直接出")
                --     self.gamescene.mytable._pokers[1]:setSelected(true)
                --     self.gamescene.mytable:tryChupai(self,choices[1])
                --     return
                -- end

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
                self.btnNode:removeAllChildren()
                self.gamescene.mytable:setIsMyTurn(false)
            end
            
        end )
    end
    self:setVisible(true)
end

function ActionView:hide()
    self:setVisible(false)
    -- self.selectNode:setVisible(false)
    -- self.selectNode:removeAllChildren()
    -- self.selectNode.btn = nil
end

--出牌多种选择
function ActionView:showcanAction(tab,cards,data)
    print("showcanAction")

    printTable(tab,"xp68")
    printTable(cards,"xp68")
    
    local csb = cc.CSLoader:createNode("ui/ddz/bai/Node.csb")
    print("1111112")
    local totall  = #tab
    if totall == 0 then
        return 
    end
    if totall == 1 then
        self.gamescene.mytable:Chupai(tab[1],cards,data)
        return
    end
     WidgetUtils.addClickEvent(csb:getChildByName("btn"), function( )
            csb:removeFromParent()
        end)
    print("2222221")
    local totallcards = #cards
    local bg = csb:getChildByName("bg")
    bg:setContentSize(cc.size(100+60*totallcards,75+(totall*85)))
    for i,v in ipairs(tab) do
        local cardslocal = self.gamescene.Suanfuc:getrealcardsTab(cards,v)
        for i1,v1 in ipairs(cardslocal) do
            local pokerCard = LongCard.new(v1.value)
            if v.islai or pokerCard:getPokerValue() == LocalData_instance:getLaiZiValuer() then
                pokerCard:setisshowLai(true)
            else
                pokerCard:setisshowLai(false)
            end
            pokerCard:setScale(0.36)
            pokerCard:setPositionX((i1-(totallcards + 1) / 2)*60)
            pokerCard:setPositionY(68+(i-1)*83)
            csb:addChild(pokerCard)
        end
        local btn = WidgetUtils.createnullBtn(cc.size(68*totallcards,78))
        btn:setPositionY(68+(i-1)*83)
        csb:addChild(btn)
        WidgetUtils.addClickEvent(btn, function( )
            self.gamescene.mytable:Chupai(v,cards,data)
            csb:removeFromParent()
        end)
    end
    csb:setPositionY(-100)
    csb:getChildByName("title"):setPositionY(75+(totall*85)-10)
    self.btnNode:addChild(csb)
end
return ActionView