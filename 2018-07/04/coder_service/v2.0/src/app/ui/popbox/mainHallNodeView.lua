require "app.baseui.PopboxBaseView"

require("app.module.HttpManager")
require("app.net.ComHttp")
HttpManager.regiterHttpUrl("WHEELGETCONF","/Activity3/turntable_config")

local mainHallNodeView= class("mainHallNodeView",PopboxBaseView)
function mainHallNodeView:ctor()
	self:initView()
	--self:initEvent()
end

--在弹出的窗口中的layer层中，将layer层的交互性 的选项勾选上，防止下层的触摸响应事件穿透到上层的layer中
--调用的时候必须要用self.别名的方式来调用相应的组件，原因不明
--不能写成initview，会跟父类的方法名字重名，而导致重载
function mainHallNodeView:initView()
	self.widget = cc.CSLoader:createNode("myui/raward/award.csb")


	self.main_layer = self.widget:getChildByName("main")
    -- self.btn_exit = self.main_node:getChildByName("Button_Exit")
    -- WidgetUtils.addClickEvent(self.btn_exit, function()
    --      print("设置 award关闭按钮")

    --     LaypopManger_instance:back()

    -- end)

    self.btn_exit = self.main_layer:getChildByName("Button_Exit")

    self.btn_luckdraw = self.main_layer:getChildByName("Button_LuckDraw")

    self.text_num=self.btn_luckdraw:getChildByName("Text_num")

    self.btn_finish = self.main_layer:getChildByName("Button_finish")
    self.btn_share = self.main_layer:getChildByName("Button_share")

    self.btn_share = self.main_layer:getChildByName("Button_share")

    self.btn_detail = self.main_layer:getChildByName("Button_detail")

    self.bg=self.main_layer:getChildByName("bg"):getChildByName("wheels")
    --查找转盘
    self.award=self.main_layer:getChildByName("Img_award")





    --抽奖次数
    self.count=1
    --标识是否发送了ajax请求
    self.sendajax=false
    WidgetUtils.addClickEvent(self.btn_luckdraw, function ( )
        -- body

    if(self.sendajax~=true)then
        local chancestr=self.text_num:getString()
        self:showSmallLoading()
        ComHttp.httpPOST(ComHttp.URL.WHEELGETCONF,{uid = LocalData_instance.uid},function(msg)
            printTable(msg,"sjp3")
            if not WidgetUtils:nodeIsExist(self) then
                return
            end

            self:hideSmallLoading()

            if msg.status ~= 1 then
                return
            end

            self.count=msg.chance
            if(self.count==0) then

                self.count=3
            end

            printTable("self.count.."..self.count,"sjp3")

            self.sendajax=true   --表示ajax请求完成
            self.text_num:setString(chancestr)


        end)
        LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "你提现的请求已提交，您确定要抽奖吗？。"})

    end

    if(self.sendajax) then
        if(self.count<=0) then
                LaypopManger_instance:PopBox("luckDrawMsgNodeView")
                self.btn_luckdraw:setEnabled(false)
        else
                self:LuckDraw(self.award,self.bg)
                print("抽奖"..(4-self.count).."次")
                self.text_num:setString("剩"..(self.count-1).."次")
                self.count=self.count-1
        end
    end
  --      if(self.count>3)   --多抽了一次奖
  --      then

  --      		 LaypopManger_instance:PopBox("luckDrawMsgNodeView")
  --      		 self.btn_luckdraw:setEnabled(false)

		-- else


         
		-- 	self:LuckDraw(self.award,self.bg)
  --  			print("抽奖"..(self.count).."次")
  --  			self.text_num:setString("剩"..(3-self.count).."次")
           

		-- end
		--  self.count=self.count+1


    end)
    WidgetUtils.addClickEvent(self.btn_exit, function ( )
        -- body
        LaypopManger_instance:back()
        --main_layer:setVisible(false)

    end)



    
    WidgetUtils.addClickEvent(self.btn_detail, function( )
         print("设置 fangkaNodeView")
        LaypopManger_instance:PopBox("fangkaNodeView")

    end)


	self:addChild(self.widget)

end



function mainHallNodeView:LuckDraw(award,bg)
	local totalCount = 12  -- 转盘总奖项数
    local roundCountMin = 2  -- 转动最小圈数
    local roundCountMax = 11  -- 转动最大圈数

    local singleAngle = 360 / totalCount  -- 所有奖项概率相同时 这样计算每个奖项占的角度 如果概率不同，可以使用table数组来处理
    local offsetAngle = 7  -- 为了避免不必要的麻烦，在接近2个奖项的交界处，左右偏移n角度的位置，统统不停留 否则停在交界线上，很难解释清楚 这个值必须小于最小奖项所占角度的1/2


	-- 设置随机数种子  正常情况下这应该在初始化时做  而不是在调用函数时
   	math.randomseed(os.time()) 

	-- 默认随机奖项
   	if stopId == nil or stopId < totalCount then
        stopId =  math.random(math.random(totalCount-7),totalCount) -- 产生1-totalCount之间的整数
   	end


    -- 转盘停止位置的最小角度 不同概率时，直接把之前的项相加即可
    local angleMin = (stopId-1) * singleAngle

    -- 转盘转动圈数 目前随机 正常情况下可加入力量元素 根据 移动距离*参数 计算转动圈数
    local roundCount = math.random(roundCountMin, roundCountMax) -- 产生roundCountMin-roundCountMax之间的整数

    -- 检查一下跳过角度是否合法 当前奖项角度-2*跳过角度 结果必须>0  TODO
    -- 转动角度
    local angleTotal = 360*roundCount + angleMin + math.random(offsetAngle, singleAngle-offsetAngle)  -- 避免掉offsetAngle角度的停留，防止停留在交界线上

    -- 打印数据
    print('stopId:'..stopId)
    print('angleMin:'..angleMin)
    print('roundCount:'..roundCount)
    print('angleTotal:'..angleTotal)

    --print("self.award1="..self.award)
	-- 复位转盘
	bg:setRotation(0)
	award:setRotation(0)
--print("self.award2="..self.award)

-- 开始旋转动作  使用EaseExponentialOut(迅速加速，然后慢慢减速)
	bg:runAction(cc.EaseExponentialOut:create(cc.RotateBy:create(3.0, angleTotal)))
	award:runAction(cc.EaseExponentialOut:create(cc.RotateBy:create(3.0, angleTotal)))


end


-- function mainHallNodeView:startWheelAnimation()
-- 	-- self.finger:runAction(cc.RotateBy(360,1))
-- 	if self.isturnning then
-- 		return
-- 	end
-- 	self.animationnode:removeAllChildren()
-- 	self.isturnning = true
-- 	local function getLightIndex(idx)
-- 		local idxtable = {}
-- 		table.insert(idxtable,idx)
-- 		table.insert(idxtable,(idx-1) > 0 and idx-1 or idx-1 + 12 )
-- 		table.insert(idxtable,(idx-2) > 0 and idx-2 or idx-2 + 12 )

-- 		return idxtable
-- 	end
-- 	local function update()
-- 		if not self.isturnning then
-- 			return
-- 		end

-- 		local angle = self.finger:getRotation()%360
-- 		local index = math.ceil(angle/30)

-- 		local idxtable = getLightIndex(index)

-- 		for i,v in ipairs(self.lighttable) do
-- 			v:setVisible(false)
-- 		end

-- 		for i,v in ipairs(idxtable) do
-- 			if self.lighttable[v] then
-- 				self.lighttable[v]:setVisible(true)
-- 				self.lighttable[v]:setOpacity(255)
-- 				if i == 2 then
-- 					self.lighttable[v]:setOpacity(255*0.8)
-- 				end
-- 				if i == 3 then
-- 					self.lighttable[v]:setOpacity(255*0.3)
-- 				end
-- 			end
-- 		end
-- 	end

-- 	if self.schedulerScript then
-- 		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerScript)
-- 		self.schedulerScrip = nil
-- 	end

-- 	self.schedulerScript = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0.02, false)

-- 	-- local action = cc.Sequence:create(cc.)
-- 	local startangle = self.finger:getRotation()
-- 	startangle = startangle%360
-- 	self.finger:setRotation(startangle)
-- 	self.finger.startangle = startangle
-- 	self.finger:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateBy:create(0.3,360),cc.CallFunc:create(function ()
-- 		self.finger:setRotation(startangle)
-- 	end))))
-- end
-- function mainHallNodeView:errorStop()
-- 	self.isturnning = false
-- 	self.finger:stopAllActions()
-- 	for i,v in ipairs(self.lighttable) do
-- 		v:setVisible(false)
-- 	end
-- 	if self.schedulerScript then
-- 		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerScript)
-- 		self.schedulerScrip = nil
-- 	end
-- 	LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "出错啦，请重试"})
-- 	-- self:getConf()
-- end
function mainHallNodeView:initEvent()

end

return mainHallNodeView