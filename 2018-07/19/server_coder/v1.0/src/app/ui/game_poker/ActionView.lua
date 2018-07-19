
local ActionView = class("ActionView", require "app.ui.game.ActionView")

function ActionView:init()
	self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_WAI]= { sort = 2, img = "game/btn_zhan.png" }
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_PAO]= { sort = 2, img = "game/btn_zou.png" }
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_CHI] = { sort = 2, img = "game/btn_chi.png" }
end

-- 生成某操作下的选择项
function ActionView:createSelectNode(_tab)
    print("........生成某操作下的选择项")
    printTable(_tab, "xp")

    local node = cc.Node:create()
    local btn = ccui.Button:create("common/null.png", "game/action_btn_bg.png", "common/null.png", ccui.TextureResType.localType)
    btn:setAnchorPoint(cc.p(0.5, 0.5))
    btn:setScale9Enabled(true)
    btn:setContentSize(cc.size(50, 76 +(#_tab.col_info.cards - 1) * 40))
    btn:setPositionX(0)
    btn:setPositionY(0)

    WidgetUtils.addClickEvent(btn, function()
        self:sendAction(_tab)
    end )
    node:addChild(btn)

     --生成牌
    for i, v in ipairs(_tab.col_info.cards) do
        local pai = self.gamescene:createCardSprite(CARDTYPE.MYHAND, v)
        pai:setAnchorPoint(cc.p(0.5, 0.5))
        pai:setPositionX(0)
        pai:setScale(0.5)

        print("....=",(((#_tab.col_info.cards) + 1) / 2.0) - i)

        pai:setPositionY(((#_tab.col_info.cards + 1) / 2.0 - i) * 40)
        -- 牌的高度+上下距离
        pai:addTo(node)

        if self.gamescene:getIsJiangCard(v) then
            pai:showJiang()
        end
    end



    return node
end

return ActionView