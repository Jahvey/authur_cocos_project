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


    self.wheels=self.main_layer:getChildByName("bg"):getChildByName("wheels")
    self.award=self.main_layer:getChildByName("Img_award")

    self.text_num=self.btn_luckdraw:getChildByName("Text_num")

    self.btn_finish = self.main_layer:getChildByName("Node_1"):getChildByName("Button_finish")

    self.loadingbar1=self.main_layer:getChildByName("Node_1"):getChildByName("LoadingBar_1")
    self.text1=self.main_layer:getChildByName("Node_1"):getChildByName("msg1")
    self.target1=self.main_layer:getChildByName("Node_1"):getChildByName("target1")
    self.btn1_finish=self.main_layer:getChildByName("Node_1"):getChildByName("btn1_finish")


    self.btn_share = self.main_layer:getChildByName("Node_2"):getChildByName("Button_share")

    self.loadingbar2=self.main_layer:getChildByName("Node_2"):getChildByName("LoadingBar_2")
    self.text2=self.main_layer:getChildByName("Node_2"):getChildByName("msg2")
    self.target2=self.main_layer:getChildByName("Node_2"):getChildByName("target2")
    self.btn2_finish=self.main_layer:getChildByName("Node_2"):getChildByName("btn2_finish")


    self.btn_detail = self.main_layer:getChildByName("Button_detail")

    self.bg=self.main_layer:getChildByName("bg"):getChildByName("wheels")
    --查找转盘
    self.award=self.main_layer:getChildByName("Img_award")

    self.resultPools={}  --保存结果数据







    ComHttp.httpPOST(ComHttp.URL.WHEELGETCONF,{uid=LocalData_instance.uid},function(msg)
            self.chance=msg.chance
            

            self.text_num:setString("剩"..self.chance.."次")
        end)



    local arrthings={[1]={d=15,j="iphonex"},[2]={d=45,j="房卡五张"},[3]={d=75,j="红包88元"},[4]={d=105,j="房卡100张"},[5]={d=135,j="红包1元"},[6]={d=165,j="充电宝"},[7]={d=195,j="房卡20张"},[8]={d=225,j="红包5元"},[9]={d=255,j="房卡2张"},[10]={d=285,j="红包188元"},[11]={d=315,j="房卡10张"},[12]={d=345,j="iphonex"}}

    WidgetUtils.addClickEvent(self.btn_luckdraw, function ( )
        -- body


        ComHttp.httpPOST(ComHttp.URL.WHEELGETCONF,{uid=LocalData_instance.uid},function(msg)
        print("hehehhe...")
        printTable(msg,"sjp3")
        self.chance=msg.chance
        if self.chance <= 0 then
            LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "抽奖次数不足！"})
        return

        else if msg.status==1 then
            ComHttp.httpPOST(ComHttp.URL.WHEELGETPRIZE,{uid=LocalData_instance.uid},function(msg)
                printTable(msg,"sjp3")

                 self.wheels:setRotation(0)
                self.award:setRotation(0)

                 self.wheels:runAction(cc.Sequence:create(cc.EaseExponentialInOut:create(cc.RotateBy:create(2,360*5+arrthings[msg.ord].d)),cc.CallFunc:create(function()
                    LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "恭喜您获得"..arrthings[msg.ord].j})
                    end)))
                    self.award:runAction(cc.Sequence:create(cc.EaseExponentialInOut:create(cc.RotateBy:create(2,360*5+arrthings[msg.ord].d)),cc.CallFunc:create(function()
          
                    end)))
                self.redpacket=msg.redpacket
 
               self.text_num:setString("剩"..msg.chance.."次")
                end)
        end

        end



        end)
    -- if(self.sendajax~=true)then
    --     local chancestr=self.text_num:getString()
    --     self:showSmallLoading()
    --     ComHttp.httpPOST(ComHttp.URL.WHEELGETCONF,{uid = LocalData_instance.uid},function(msg)
    --         printTable(msg,"sjp3")
    --         if not WidgetUtils:nodeIsExist(self) then
    --             return
    --         end

    --         self:hideSmallLoading()

    --         if msg.status ~= 1 then
    --             return
    --         end

    --         self.count=msg.chance
    --         if(self.count==0) then

    --             self.count=3
    --         end

    --         printTable("self.count.."..self.count,"sjp3")

    --         self.sendajax=true   --表示ajax请求完成
    --         self.text_num:setString(chancestr)


    --     end)
    --     LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "你提现的请求已提交，您确定要抽奖吗？。"})

    -- end

    -- if(self.sendajax) then
    --     if(self.count<=0) then
    --         local priceStr=""
    --         for k,v in pairs(self.resultPools) do
    --             --print(k,v)
    --             priceStr=priceStr..","..v
    --         end
    --         LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "["..priceStr.."]"})
    --            -- LaypopManger_instance:PopBox("luckDrawMsgNodeView")
    --             self.btn_luckdraw:setEnabled(false)
    --     else
    --             self:LuckDraw(self.award,self.bg)
    --             print("抽奖"..(4-self.count).."次")
    --             self.text_num:setString("剩"..(self.count-1).."次")
    --             self.count=self.count-1
    --     end
    -- end



    end)
    WidgetUtils.addClickEvent(self.btn_exit, function ( )
        -- body
        LaypopManger_instance:back()
        --main_layer:setVisible(false)

    end)




    WidgetUtils.addClickEvent(self.btn_detail, function( )
         print("设置 fangkaNodeView")
        LaypopManger_instance:PopBox("fangkaNodeView",1,{numpackets=self.redpacket})

    end)

    self.num1=0
    WidgetUtils.addClickEvent(self.btn_finish, function (  )
        -- body

        if(self.num1~=3) then
            self.num1=self.num1+1
            self.loadingbar1:setPercent(33*self.num1)
            self.text1:setString(self.num1.."次")
            self.target1:setString(self.num1.."/3")

            LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "开始玩牌"})
        else  
            --todo
            self.btn_finish:setVisible(false)
        end
    end)

    self.num2=0
    WidgetUtils.addClickEvent(self.btn_share , function (  )
        -- body
        if(self.num2~=3) then
            self.num2=self.num2+1
            self.loadingbar2:setPercent(33*self.num2)
            self.text2:setString(self.num2.."次")
            self.target2:setString(self.num2.."/3")
            LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "开始分享"})

        else
                    --todo
            self.btn_share:setVisible(false)
        end

    end)


	self:addChild(self.widget)

end



-- function mainHallNodeView:LuckDraw(award,bg)
--     self.pricePools={"0.5元","房卡5张","红包88元","房卡100张" --
--     ,"红包1元","充电宝","房卡20张","红包5元","房卡2张",--
--     "红包188元","房卡10张","iPhoneX"}
    
--     -- print("pricePools size is:="..table.getn(self.pricePools))
--     -- print(self.pricePools[4])
--     -- print(self.pricePools[7])
--     -- print(self.pricePools[10])
-- 	local totalCount = 12  -- 转盘总奖项数
--     local roundCountMin = 2  -- 转动最小圈数
--     local roundCountMax = 11  -- 转动最大圈数

--     local singleAngle = 360 / totalCount  -- 所有奖项概率相同时 这样计算每个奖项占的角度 如果概率不同，可以使用table数组来处理
--     local offsetAngle = 7  -- 为了避免不必要的麻烦，在接近2个奖项的交界处，左右偏移n角度的位置，统统不停留 否则停在交界线上，很难解释清楚 这个值必须小于最小奖项所占角度的1/2


-- 	-- 设置随机数种子  正常情况下这应该在初始化时做  而不是在调用函数时
--    	math.randomseed(os.time()) 

-- 	-- 默认随机奖项
--    	if stopId == nil or stopId < totalCount then
--         stopId =  math.random(math.random(totalCount-7),totalCount) -- 产生1-totalCount之间的整数
--    	end


--     -- 转盘停止位置的最小角度 不同概率时，直接把之前的项相加即可
--     local angleMin = (stopId-1) * singleAngle

--     -- 转盘转动圈数 目前随机 正常情况下可加入力量元素 根据 移动距离*参数 计算转动圈数
--     local roundCount = math.random(roundCountMin, roundCountMax) -- 产生roundCountMin-roundCountMax之间的整数

--     -- 检查一下跳过角度是否合法 当前奖项角度-2*跳过角度 结果必须>0  TODO
--     -- 转动角度
--     local angleTotal = 360*roundCount + angleMin + math.random(offsetAngle, singleAngle-offsetAngle)  -- 避免掉offsetAngle角度的停留，防止停留在交界线上

--     -- 打印数据
--     print('stopId:'..stopId)
--     print('angleMin:'..angleMin)
--     print('roundCount:'..roundCount)
--     print('angleTotal:'..angleTotal)
--     table.insert(self.resultPools,self.pricePools[stopId])

--     --print("self.award1="..self.award)
-- 	-- 复位转盘
-- 	bg:setRotation(0)
-- 	award:setRotation(0)
-- --print("self.award2="..self.award)

-- -- 开始旋转动作  使用EaseExponentialOut(迅速加速，然后慢慢减速)
-- 	bg:runAction(cc.EaseExponentialOut:create(cc.RotateBy:create(3.0, angleTotal)))
-- 	award:runAction(cc.EaseExponentialOut:create(cc.RotateBy:create(3.0, angleTotal)))


-- end



function mainHallNodeView:initEvent()

end

return mainHallNodeView