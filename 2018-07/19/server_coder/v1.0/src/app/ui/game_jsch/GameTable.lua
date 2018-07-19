local GameTable = class("GameTable", require("app.ui.game.GameTable"))


function GameTable:xiaoHuPaiAction(data,hidenAnimation)
    if hidenAnimation then
    	local piao = self.icon:getChildByName("piao"):setVisible(true)
        piao:setTexture("game/icon_xiao.png")
        return
    end
   	self:setBao(3)
    AudioUtils.playVoice("xiaohu", self.gamescene:getSexByIndex(self:getTableIndex()))
end

return GameTable