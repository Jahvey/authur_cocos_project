
local ActionView = class("ActionView", require "app.ui.game.ActionView")
local PICWIDTH = 200
function ActionView:init()
    --wai  和 chi  都叫吃
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_DENG]= { sort = 2, img = "game/btn_ta.png" }
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_LIANG_LONG]= { sort = 2, img = "game/btn_lianglong.png" }
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_QIANG_ZHUANG]= { sort = 2, img = "game/btn_tiao2.png" }
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_CHI]= { sort = 2, img = "game/btn_chi.png" }
end
function ActionView:showAction(choices)
    -- print("..........ActionView:showAction(")
    -- printTable(choices, "xp")
    self:showHiddenBtn()
    
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_PASS].img = "game/btn_guo.png"

    self.selectNode:setVisible(false)
    self.selectNode:removeAllChildren()
    self.selectNode.btn = nil

    self.btnNode:removeAllChildren()
    

    local choices = clone(choices)

    for i = #choices, 1, -1 do
        if not self.ACTIONCONF[choices[i].act_type] then
            table.remove(choices, i)
        end
    end

    if #choices == 0 then
        return
    end

    ------------整合
    local choicesList = { }
    for k, v in pairs(choices) do
        if not choicesList[v.act_type] then
            local _list = { num = 1, act_type = v.act_type, list = { v } }
            choicesList[v.act_type] = _list
        else
            choicesList[v.act_type].num = choicesList[v.act_type].num + 1
            table.insert(choicesList[v.act_type].list, v)
        end
    end

    local endList = { }
    for k, v in pairs(choicesList) do
        table.insert(endList, v)
    end

    table.sort(endList, function(a, b)
        return self.ACTIONCONF[a.act_type].sort > self.ACTIONCONF[b.act_type].sort
    end )
    ------------整合结束
    -- print("..........ActionView: endList ")
    -- printTable(endList, "xp")
    -- 是否有选择坐庄
    for i, v in ipairs(endList) do
        if v.act_type == poker_common_pb.EN_SDR_ACTION_QIANG_ZHUANG then
            self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_PASS].img = self.huazhuangsrc
            break
        end
    end

    self:setVisible(true)
    self.btnNode:removeAllChildren()
    local half =(#endList + 1) / 2.0

    local btnList = { }
    for i, v in ipairs(endList) do

        local btn = ccui.Button:create(self.ACTIONCONF[v.act_type].img)
        :addTo(self.btnNode)
        :setAnchorPoint(cc.p(0.5, 0.5))
        :setPositionX((half - i) * PICWIDTH)
        :setTag(i)

        v.btn = btn

        if v.act_type  == poker_common_pb.EN_SDR_ACTION_PENG  and v.list[1].another_peng_index ~= nil then
        	print("v.another_peng_index  = ",v.another_peng_index)
        	self:getPengNode(btn,v)
        end

        table.insert(btnList, btn)
        WidgetUtils.addClickEvent(btn, function()
            self:commonAction(v)
        end )
    end
end


function ActionView:getPengNode(btn,info)

    printTable(info,"xp")
   
	-- info.another_peng_index = 0
	
    local maps = {
        [2] =
        {
            [0] = { "", "peng_dui" },
            [1] = { "peng_dui", "" },
        },
        [3] =
        {
            [0] = { "", "peng_xia", "peng_shang" },
            [1] = { "peng_shang", "", "peng_xia" },
            [2] = { "peng_xia", "peng_shang", "" },
        },
        [4] =
        {
            [0] = { "", "peng_xia", "peng_dui", "peng_shang" },
            [1] = { "peng_shang", "", "peng_xia", "peng_dui" },
            [2] = { "peng_dui", "peng_shang", "", "peng_xia" },
            [3] = { "peng_xia", "peng_dui", "peng_shang", "" },
        },
    }
   	
   	maps = maps[self.gamescene:getTableConf().seat_num]
   	maps = maps[self.gamescene:getMyIndex()]
   	local index = info.list[1].another_peng_index
    local iconName = maps[index+1]

    local baoType = ccui.ImageView:create("game/"..iconName..".png")
    if  baoType  then
    	baoType:setAnchorPoint(cc.p(0.5, 0))
    	baoType:setPositionX(baoType:getContentSize().width/2.0)
    	baoType:setPositionY(125)
    	btn:addChild(baoType)
    end

end

return ActionView