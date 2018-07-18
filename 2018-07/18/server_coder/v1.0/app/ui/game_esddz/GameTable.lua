local GameTable = class("GameTable", require("app.ui.game_base_cdd.GameTable"))

function GameTable:showjiaodizhu(  )
    self.jiaonode:setVisible(true)
    self.jiaonode:getChildByName("jiao"):setTexture("gameddz/act_maipai.png")
    self.jiaonode:getChildByName("bujiao"):setTexture("gameddz/act_bumai.png")
    
    self.jiaonode:getChildByName("jiao"):setVisible(true)
    self.jiaonode:getChildByName("bujiao"):setVisible(false)
    
    AudioUtils.playVoice("ddz_maipai",self.gamescene:getSexByIndex(self.tableidx))
end
function GameTable:showbujiaodizhu(  )
    self.jiaonode:setVisible(true)
    self.jiaonode:getChildByName("jiao"):setTexture("gameddz/act_maipai.png")
    self.jiaonode:getChildByName("bujiao"):setTexture("gameddz/act_bumai.png")

    self.jiaonode:getChildByName("jiao"):setVisible(false)
    self.jiaonode:getChildByName("bujiao"):setVisible(true)
    AudioUtils.playVoice("ddz_bumai",self.gamescene:getSexByIndex(self.tableidx))
end
-- 买牌动画，直接展示
function GameTable:buyOrSellPaiAction(isHong,hidenAnimation,_fun)

    print(".......buyOrSellPaiAction ＝ isHong ",isHong)
    printTable(data)
    if hidenAnimation then
        return
    end

    print(".......buyOrSellPaiAction ＝  ")

    self.showcardnode:setVisible(true)
    self.showcardnode:setScale(0.6)

    pokerStr = "gameddz/act_sell_hei.png"
    if  isHong then
        pokerStr = "gameddz/act_buy_hong.png"
        AudioUtils.playVoice("ddz_maipai", self.gamescene:getSexByIndex(self:getTableIndex()))
    else
        AudioUtils.playVoice("ddz_bumai", self.gamescene:getSexByIndex(self:getTableIndex()))
    end

    local pokerCard = ccui.ImageView:create(pokerStr)
    pokerCard:setName("kou_card")
    pokerCard:setPositionY(self.cardheight/2)
    pokerCard:setPositionX(0)

    if self.localpos == 2 then
        pokerCard:setPositionX(-55*0.4)
    elseif self.localpos == 2 then
        pokerCard:setPositionX(55*0.4)
    end
    self.showcardnode:addChild(pokerCard)


    local act1 = cc.ScaleTo:create(0.15, 1.2)
    local act2 = cc.DelayTime:create(0.15)
    local act3 = cc.ScaleTo:create(0.075, 1)

    pokerCard:runAction(cc.Sequence:create(act1, act2, act3, cc.CallFunc:create( function()
        -- self:playPaiVoice(value)
        -- self.showcardnode:setScale(1.0)
        if isHong then
        	if _fun then
        		_fun()
        	end
        else
        	self.gamescene:deleteAction("买卖牌结束！")	
        end

    end )))
end


return GameTable