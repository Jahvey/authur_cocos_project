-- 长牌场景
local GameScene = class("GameScene", require "app.ui.game_poker.GameScene")
-- 背景 根据设置选择及时更换
function GameScene:setbgstype()
    local typestylse = cc.UserDefault:getInstance():getIntegerForKey("bg_type_poker", 1)
    -- 界面变化
    self.UILayer:setbgstype(typestylse)
    -- 牌变化
    for k, v in pairs(self.tablelist) do
        v:setbgstype(typestylse)
    end
end
return GameScene