local GameTable = class("GameTable", require("app.ui.game_base_cdd.GameTable"))
function GameTable:updateDiZhuCards(isShow,pokers)
    self.diPaiView:setVisible(false)
end
-- function GameTable:showniu(niuvalue)
-- 	 local info = self.gamescene:getSeatInfoByIdx(self:getTableIndex())
-- 	 info.niuvalue = niuvalue
-- 	 if niuvalue and niuvalue > 0 then
-- 	 	self.icon:getChildByName("niunode"):setVisible(true)
-- 	 	self.icon:getChildByName("niuicon"):setVisible(true)
-- 	 	if niuvalue == 2 then
-- 	 		self.icon:getChildByName("niunode"):getChildByName("icon1"):getChildByName("icon"):setVisible(true)
-- 	 		self.icon:getChildByName("niunode"):getChildByName("icon2"):getChildByName("icon"):setVisible(false)
-- 	 	elseif niuvalue == 3 then
-- 	 		self.icon:getChildByName("niunode"):getChildByName("icon1"):getChildByName("icon"):setVisible(false)
-- 	 		self.icon:getChildByName("niunode"):getChildByName("icon2"):getChildByName("icon"):setVisible(true)
-- 	 	elseif niuvalue == 5 then
-- 	 		self.icon:getChildByName("niunode"):getChildByName("icon1"):getChildByName("icon"):setVisible(true)
-- 	 		self.icon:getChildByName("niunode"):getChildByName("icon2"):getChildByName("icon"):setVisible(true)
-- 	 	end
-- 	 else
-- 	 	self.icon:getChildByName("niunode"):setVisible(false)
-- 	 	self.icon:getChildByName("niuicon"):setVisible(false)
-- 	 end
-- end
return GameTable