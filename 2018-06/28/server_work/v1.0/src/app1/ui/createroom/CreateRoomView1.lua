-------------------------------------------------
--   TODO   创建房间UI
--   @author yc
--   Create Date 2016.10.26
-------------------------------------------------
local CreateRoomView = class("CreateRoomView",PopboxBaseView)
function CreateRoomView:ctor()
	self:initView()
	ComNoti_instance:addEventListener("3;3;1;1",self,self.createcallback)
end
function CreateRoomView:initView()
	self.widget = cc.CSLoader:createNode("ui/createroom/createRoomViewforpoker.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("closeBtn"), function( )
		print("返回大厅")
		LaypopManger_instance:back()
	end)

     WidgetUtils.addClickEvent(self.mainLayer:getChildByName("Button_1"), function( )
        self:creatbtncall()
    end)
    self.fangtips  =  self.mainLayer:getChildByName("fangtips")

    self.num11 = cc.UserDefault:getInstance():getIntegerForKey("22createniuniu11",1)
    self.num12 = cc.UserDefault:getInstance():getIntegerForKey("22createniuniu12",1)
    self.num13 = cc.UserDefault:getInstance():getIntegerForKey("22createniuniu13",1)


    self.num14 = cc.UserDefault:getInstance():getIntegerForKey("22createniuniu14",1)
    self.num15 = cc.UserDefault:getInstance():getIntegerForKey("22createniuniu15",1)
    self.num16 = cc.UserDefault:getInstance():getIntegerForKey("22createniuniu16",1)
    self.num17 = cc.UserDefault:getInstance():getIntegerForKey("22createniuniu17",1)

    self.spec = cc.UserDefault:getInstance():getIntegerForKey("22createniuniuspe",0)

    self.check1 = {}
    self.check1[1] ={}
    self.check1[1][1] = self.mainLayer:getChildByName("node1"):getChildByName("check11")
    self.check1[1][1]:setTag(1)
    self.check1[1][2] = self.mainLayer:getChildByName("node1"):getChildByName("check12")
    self.check1[1][2]:setTag(2)
    self.check1[1][3] = self.mainLayer:getChildByName("node1"):getChildByName("check13")
    self.check1[1][3]:setTag(3)
    self.check1[1][3]:setVisible(false)

    ComHelpFuc.selectall(self.check1[1],self.num11,function( tag )
        self.num11 = tag
        self:updatafang()
    end)


    self.check1[2] ={}
    self.check1[2][1] = self.mainLayer:getChildByName("node1"):getChildByName("check21")
    self.check1[2][1]:setTag(1)
    self.check1[2][2] = self.mainLayer:getChildByName("node1"):getChildByName("check22")
    self.check1[2][2]:setTag(2)

    ComHelpFuc.selectall(self.check1[2],self.num12,function( tag )
        self.num12 = tag
        self:updatafang()
    end)

    self.check1[3] ={}
    self.check1[3][1] = self.mainLayer:getChildByName("node1"):getChildByName("check31")
    self.check1[3][1]:setTag(1)
    self.check1[3][2] = self.mainLayer:getChildByName("node1"):getChildByName("check32")
    self.check1[3][2]:setTag(2)
    ComHelpFuc.selectall(self.check1[3],self.num13,function( tag )
        self.num13 = tag
        self:updatashowtype()
    end)


     self.check1[4] ={}
    self.check1[4][1] = self.mainLayer:getChildByName("node1"):getChildByName("check41")
    self.check1[4][1]:setTag(1)
    self.check1[4][2] = self.mainLayer:getChildByName("node1"):getChildByName("check42")
    self.check1[4][2]:setTag(2)
    ComHelpFuc.selectall(self.check1[4],self.num14,function( tag )
        self.num14 = tag
        self:updatashowtype()
    end)



     self.check1[5] ={}
    self.check1[5][1] = self.mainLayer:getChildByName("node1"):getChildByName("check51")
    self.check1[5][1]:setTag(1)
    self.check1[5][2] = self.mainLayer:getChildByName("node1"):getChildByName("check52")
    self.check1[5][2]:setTag(2)
    ComHelpFuc.selectall(self.check1[5],self.num15,function( tag )
        self.num15 = tag
    end)




     self.check1[6] ={}
    self.check1[6][1] = self.mainLayer:getChildByName("node1"):getChildByName("check61")
    self.check1[6][1]:setTag(1)
    self.check1[6][2] = self.mainLayer:getChildByName("node1"):getChildByName("check62")
    self.check1[6][2]:setTag(2)
    ComHelpFuc.selectall(self.check1[6],self.num16,function( tag )
        self.num16 = tag
        self:updatashowtype()
    end)


     self.check1[7] ={}
    self.check1[7][1] = self.mainLayer:getChildByName("node1"):getChildByName("check71")
    self.check1[7][1]:setTag(1)
    self.check1[7][2] = self.mainLayer:getChildByName("node1"):getChildByName("check72")
    self.check1[7][2]:setTag(2)
    ComHelpFuc.selectall(self.check1[7],self.num17,function( tag )
        self.num17 = tag
        self:updatashowtype()
    end)
    
    


    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node1"):getChildByName("spec"),self.spec,function( tag )
        self.spec = tag
        self:updatashowtype()
    end)




    self:updatafang()
    self:updatashowtype()

end
function CreateRoomView:updatashowtype(  )
   if self.num13 == 1 and self.num14 == 1 then
         self.mainLayer:getChildByName("node1"):getChildByName("check11"):getChildByName("text"):setString("4局")
         self.mainLayer:getChildByName("node1"):getChildByName("check12"):getChildByName("text"):setString("8局")
         self.mainLayer:getChildByName("node1"):getChildByName("check13"):getChildByName("text"):setString("12局")
    else
        self.mainLayer:getChildByName("node1"):getChildByName("check11"):getChildByName("text"):setString("10局")
        self.mainLayer:getChildByName("node1"):getChildByName("check12"):getChildByName("text"):setString("20局")
        self.mainLayer:getChildByName("node1"):getChildByName("check13"):getChildByName("text"):setString("30局")
   end
end
function CreateRoomView:updatafang(ju,type)
    if self.num12 == 1 then
        if self.num11 == 1 then
           self.fangtips:setString("x1")
        elseif self.num11 == 2 then
            self.fangtips:setString("x2")
         elseif self.num11 == 3 then
            self.fangtips:setString("x3")
        end
    else
        if self.num11 == 1 then
           self.fangtips:setString("x4")
        elseif self.num11 == 2 then
            self.fangtips:setString("x8")
         elseif self.num11 == 3 then
            self.fangtips:setString("x12")
        end
    end
end
function CreateRoomView:creatbtncall( )

    cc.UserDefault:getInstance():setIntegerForKey("22createniuniu11",self.num11)
    cc.UserDefault:getInstance():setIntegerForKey("22createniuniu12",self.num12)
    cc.UserDefault:getInstance():setIntegerForKey("22createniuniu13",self.num13)

    cc.UserDefault:getInstance():setIntegerForKey("22createniuniu14",self.num14)
    cc.UserDefault:getInstance():setIntegerForKey("22createniuniu15",self.num15)
    cc.UserDefault:getInstance():setIntegerForKey("22createniuniu16",self.num16)
    cc.UserDefault:getInstance():setIntegerForKey("22createniuniu17",self.num17)

    cc.UserDefault:getInstance():setIntegerForKey("22createniuniuspe",self.spec)
    local tableinf = {}
    if self.num13 == 1 and self.num14 == 1 then
        tableinf.gamenums = 4*self.num11
    else
        tableinf.gamenums = 10*self.num11
    end
    tableinf.gameplayernums = 4
    local re = {2,4}
    tableinf.gameusecoinstype = re[self.num12]
    
    tableinf.gameplaytype = self.num14
    tableinf.gamejokertype = self.num15
    tableinf.gamerewardtype = self.num16
    tableinf.gamebirdtype = self.num17
    tableinf.gameglobaltype =self.spec

    Socketapi.createtable1(tableinf)
end

function CreateRoomView:createcallback( data )
    print("crate 111")
    --Notinode_instance:showLoading(false)
    if data.result == 0 then
        LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = data.info})
    else
          if data.gameusecoinstype == 4 then
             LaypopManger_instance:PopBox("DaikaifangHelpView",2)
          end  
    end
end

return CreateRoomView