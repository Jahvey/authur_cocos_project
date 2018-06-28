-------------------------------------------------
--   TODO   创建房间UI
--   @author yc
--   Create Date 2016.10.26
-------------------------------------------------
local CreateRoomView = class("CreateRoomView",PopboxBaseView)
function CreateRoomView:ctor()
	self:initView()
	ComNoti_instance:addEventListener("3;2;1;1",self,self.createcallback)
end
function CreateRoomView:initView()
	self.widget = cc.CSLoader:createNode("ui/createroom/createRoomView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("closeBtn"), function( )
		print("返回大厅")
		LaypopManger_instance:back()
	end)
    self.fangtips  =  self.mainLayer:getChildByName("fangtips")
   self.gametype = cc.UserDefault:getInstance():getIntegerForKey("1niuniugametype",1)
   self.gameselect = {}
 	self.gameselect[1] = self.mainLayer:getChildByName("listview"):getChildByName("btn1")
 	self.gameselect[1]:setTag(1)
 	self.gameselect[2] = self.mainLayer:getChildByName("listview"):getChildByName("btn2")
 	self.gameselect[2]:setTag(2)
 	self.gameselect[3] = self.mainLayer:getChildByName("listview"):getChildByName("btn3")
 	self.gameselect[3]:setTag(3)
 	self.gameselect[4] = self.mainLayer:getChildByName("listview"):getChildByName("btn4")
 	self.gameselect[4]:setTag(4)
    self.gameselect[5] = self.mainLayer:getChildByName("listview"):getChildByName("btn5")
    self.gameselect[5]:setTag(5)

    self.gameselect[6] = self.mainLayer:getChildByName("listview"):getChildByName("btn6")
    self.gameselect[6]:setTag(6)

    self.gameselect[7] = self.mainLayer:getChildByName("listview"):getChildByName("btn7")
    self.gameselect[7]:setTag(7)

    self.gameselect[8] = self.mainLayer:getChildByName("listview"):getChildByName("btn8")
    self.gameselect[8]:setTag(8)
    self.gameselect[9] = self.mainLayer:getChildByName("listview"):getChildByName("btn9")
    self.gameselect[9]:setTag(9)

    local function selectgame(tag)
        self.gametype  = tag
        for i1,v1 in ipairs(self.gameselect) do
            if i1 == tag then
                v1:setEnabled(false)
                self.mainLayer:getChildByName("node"..i1):setVisible(true)
            else
                v1:setEnabled(true)
                self.mainLayer:getChildByName("node"..i1):setVisible(false)
            end
        end
        self:updatafang()
        for i=1,9 do
             ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node"..i):getChildByName("check61"),self.gamewanfa1,function( tag )
                    self.gamewanfa1 = tag
                end)
            ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node"..i):getChildByName("check62"),self.gamewanfa2,function( tag )
                self.gamewanfa2 = tag
            end)
        end
    end
    for i,v in ipairs(self.gameselect) do
        WidgetUtils.addClickEvent(v, function( )
            selectgame(v:getTag())
        end)
    end
    selectgame(self.gametype)
    WidgetUtils.addClickEvent(self.mainLayer:getChildByName("Button_1"), function( )
        self:creatbtncall()
    end)
    self.num11 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu11",1)
    self.num12 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu12",1)
    self.num13 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu13",1)
    self.num14 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu14",1)
    self.num15 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu15",1)
    self.num16 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu16",1)


    self.spec1 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniuspe1",1)
    self.spec2 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniuspe2",1)
    self.spec3 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniuspe3",1)
    self.spec4 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniuspe4",1)
    self.spec5 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniuspe5",1)
    self.spec6 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniuspe6",1)

    self.gamewanfa1 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniuwanfa1",1)
    self.gamewanfa2 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniuwanfa2",1)
    self.gamewanfa3 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniuwanfa3",1)

    self.num21 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu21",1)
    self.num22 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu22",1)
    self.num23 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu23",1)
    self.num24 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu24",1)

    self.num31 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu31",1)
    self.num32 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu32",1)
    self.num33 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu33",1)
    self.num34 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu34",1)
    self.num35 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu35",1)


    self.num41 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu41",1)
    self.num42 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu42",1)
    self.num43 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu43",1)
    self.num44 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu44",1)
    self.num45 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu45",1)
    -- self.num46 = cc.UserDefault:getInstance():getIntegerForKey("createniuniu46",1)
    self.num51 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu51",1)
    self.num52 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu52",1)
    self.num53 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu53",1)
    self.num54 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu54",1)
    self.num55 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu55",1)
    self.num56 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu56",1)


    self.num61 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu61",1)
    self.num62 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu62",1)
    self.num63 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu63",1)

    self.num71 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu71",1)
    self.num72 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu72",1)
    self.num73 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu73",1)

    self.num81 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu81",1)
    self.num82 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu82",1)
    self.num83 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu83",1)

    self.num91 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu91",1)
    self.num92 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu92",1)
    self.num93 = cc.UserDefault:getInstance():getIntegerForKey("11createniuniu93",1)


    self.check1 = {}
    self.check1[1] ={}
    self.check1[1][1] = self.mainLayer:getChildByName("node1"):getChildByName("check11")
    self.check1[1][1]:setTag(1)
    self.check1[1][2] = self.mainLayer:getChildByName("node1"):getChildByName("check12")
    self.check1[1][2]:setTag(2)
    self.check1[1][3] = self.mainLayer:getChildByName("node1"):getChildByName("check13")
    self.check1[1][3]:setTag(3)

    ComHelpFuc.selectall(self.check1[1],self.num11,function( tag )
        self.num11 = tag
    end)


    self.check1[2] ={}
    self.check1[2][1] = self.mainLayer:getChildByName("node1"):getChildByName("check21")
    self.check1[2][1]:setTag(1)
    self.check1[2][2] = self.mainLayer:getChildByName("node1"):getChildByName("check22")
    self.check1[2][2]:setTag(2)
    self.check1[2][3] = self.mainLayer:getChildByName("node1"):getChildByName("check23")
    self.check1[2][3]:setTag(3)

    ComHelpFuc.selectall(self.check1[2],self.num12,function( tag )
        self.num12 = tag
        self:updatafang(self.num12,self.num13)
    end)

    self.check1[3] ={}
    self.check1[3][1] = self.mainLayer:getChildByName("node1"):getChildByName("check31")
    self.check1[3][1]:setTag(1)
    self.check1[3][2] = self.mainLayer:getChildByName("node1"):getChildByName("check32")
    self.check1[3][2]:setTag(2)
    self.check1[3][3] = self.mainLayer:getChildByName("node1"):getChildByName("check33")
    self.check1[3][3]:setTag(3)
    self.check1[3][4] = self.mainLayer:getChildByName("node1"):getChildByName("check34")
    self.check1[3][4]:setTag(4)
    ComHelpFuc.selectall(self.check1[3],self.num13,function( tag )
        self.num13 = tag
         self:updatafang(self.num12,self.num13)
    end)

    self.check1[4] ={}
    self.check1[4][1] = self.mainLayer:getChildByName("node1"):getChildByName("check41")
    self.check1[4][1]:setTag(1)

    ComHelpFuc.selectall(self.check1[4],self.num14,function( tag )
        self.num14 = tag
    end)

    self.check1[5] ={}
    self.check1[5][1] = self.mainLayer:getChildByName("node1"):getChildByName("check51")
    self.check1[5][1]:setTag(1)
    self.check1[5][2] = self.mainLayer:getChildByName("node1"):getChildByName("check52")
    self.check1[5][2]:setTag(2)
    self.check1[5][3] = self.mainLayer:getChildByName("node1"):getChildByName("check53")
    self.check1[5][3]:setTag(3)
    self.check1[5][4] = self.mainLayer:getChildByName("node1"):getChildByName("check54")
    self.check1[5][4]:setTag(4)

    ComHelpFuc.selectall(self.check1[5],self.num15,function( tag )
        self.num15 = tag
    end)


    self.check1[6] ={}
    self.check1[6][1] = self.mainLayer:getChildByName("node1"):getChildByName("check71")
    self.check1[6][1]:setTag(1)
    self.check1[6][2] = self.mainLayer:getChildByName("node1"):getChildByName("check72")
    self.check1[6][2]:setTag(2)
    self.check1[6][3] = self.mainLayer:getChildByName("node1"):getChildByName("check73")
    self.check1[6][3]:setTag(3)
    self.check1[6][4] = self.mainLayer:getChildByName("node1"):getChildByName("check74")
    self.check1[6][4]:setTag(4)
    ComHelpFuc.selectall(self.check1[6],self.num16,function( tag )
        self.num16 = tag
    end)

    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node1"):getChildByName("check61"),self.gamewanfa1,function( tag )
        self.gamewanfa1 = tag
    end)
    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node1"):getChildByName("check62"),self.gamewanfa2,function( tag )
        self.gamewanfa2 = tag
    end)
    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node1"):getChildByName("check63"),self.gamewanfa3,function( tag )
        self.gamewanfa3 = tag
    end)

    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node1"):getChildByName("spec1"),self.spec1,function( tag )
        self.spec1 = tag
    end)
    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node1"):getChildByName("spec2"),self.spec2,function( tag )
        self.spec2 = tag
    end)
    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node1"):getChildByName("spec3"),self.spec3,function( tag )
        self.spec3 = tag
    end)

---------------------2-------------------------------

    self.check2 = {}
    self.check2[1] ={}
    self.check2[1][1] = self.mainLayer:getChildByName("node2"):getChildByName("check11")
    self.check2[1][1]:setTag(1)
    self.check2[1][2] = self.mainLayer:getChildByName("node2"):getChildByName("check12")
    self.check2[1][2]:setTag(2)
    self.check2[1][3] = self.mainLayer:getChildByName("node2"):getChildByName("check13")
    self.check2[1][3]:setTag(3)

    ComHelpFuc.selectall(self.check2[1],self.num21,function( tag )
        self.num21 = tag
    end)


    self.check2[2] ={}
    self.check2[2][1] = self.mainLayer:getChildByName("node2"):getChildByName("check21")
    self.check2[2][1]:setTag(1)
    self.check2[2][2] = self.mainLayer:getChildByName("node2"):getChildByName("check22")
    self.check2[2][2]:setTag(2)
    self.check2[2][3] = self.mainLayer:getChildByName("node2"):getChildByName("check23")
    self.check2[2][3]:setTag(3)

    ComHelpFuc.selectall(self.check2[2],self.num22,function( tag )
        self.num22 = tag
        self:updatafang(self.num22,self.num23)
    end)

    self.check2[3] ={}
    self.check2[3][1] = self.mainLayer:getChildByName("node2"):getChildByName("check31")
    self.check2[3][1]:setTag(1)
    self.check2[3][2] = self.mainLayer:getChildByName("node2"):getChildByName("check32")
    self.check2[3][2]:setTag(2)
    self.check2[3][3] = self.mainLayer:getChildByName("node2"):getChildByName("check33")
    self.check2[3][3]:setTag(3)
    self.check2[3][4] = self.mainLayer:getChildByName("node2"):getChildByName("check34")
    self.check2[3][4]:setTag(4)

    ComHelpFuc.selectall(self.check2[3],self.num23,function( tag )
        self.num23 = tag
        self:updatafang(self.num22,self.num23)
    end)

    self.check2[4] ={}
    self.check2[4][1] = self.mainLayer:getChildByName("node2"):getChildByName("check41")
    self.check2[4][1]:setTag(1)

    ComHelpFuc.selectall(self.check2[4],self.num24,function( tag )
        self.num24 = tag
    end)


    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node2"):getChildByName("check61"),self.gamewanfa1,function( tag )
        self.gamewanfa1 = tag
    end)
    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node2"):getChildByName("check62"),self.gamewanfa2,function( tag )
        self.gamewanfa2 = tag
    end)
    -- ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node2"):getChildByName("check63"),self.gamewanfa3,function( tag )
    --     self.gamewanfa3 = tag
    -- end)

    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node2"):getChildByName("spec1"),self.spec1,function( tag )
        self.spec1 = tag
    end)
    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node2"):getChildByName("spec2"),self.spec2,function( tag )
        self.spec2 = tag
    end)
    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node2"):getChildByName("spec3"),self.spec3,function( tag )
        self.spec3 = tag
    end)
    ---------------------------------3-------------------------
    self.check3 = {}
    self.check3[1] ={}
    self.check3[1][1] = self.mainLayer:getChildByName("node3"):getChildByName("check11")
    self.check3[1][1]:setTag(1)
    self.check3[1][2] = self.mainLayer:getChildByName("node3"):getChildByName("check12")
    self.check3[1][2]:setTag(2)
    self.check3[1][3] = self.mainLayer:getChildByName("node3"):getChildByName("check13")
    self.check3[1][3]:setTag(3)

    ComHelpFuc.selectall(self.check3[1],self.num31,function( tag )
        self.num31 = tag
    end)


    self.check3[2] ={}
    self.check3[2][1] = self.mainLayer:getChildByName("node3"):getChildByName("check21")
    self.check3[2][1]:setTag(1)
    self.check3[2][2] = self.mainLayer:getChildByName("node3"):getChildByName("check22")
    self.check3[2][2]:setTag(2)
    self.check3[2][3] = self.mainLayer:getChildByName("node3"):getChildByName("check23")
    self.check3[2][3]:setTag(3)

    ComHelpFuc.selectall(self.check3[2],self.num32,function( tag )
        self.num32 = tag
        self:updatafang(self.num32,self.num33)
    end)

    self.check3[3] ={}
    self.check3[3][1] = self.mainLayer:getChildByName("node3"):getChildByName("check31")
    self.check3[3][1]:setTag(1)
    self.check3[3][2] = self.mainLayer:getChildByName("node3"):getChildByName("check32")
    self.check3[3][2]:setTag(2)
    self.check3[3][3] = self.mainLayer:getChildByName("node3"):getChildByName("check33")
    self.check3[3][3]:setTag(3)
    self.check3[3][4] = self.mainLayer:getChildByName("node3"):getChildByName("check34")
    self.check3[3][4]:setTag(4)


    ComHelpFuc.selectall(self.check3[3],self.num33,function( tag )
        self.num33 = tag
        self:updatafang(self.num32,self.num33)
    end)

    self.check3[4] ={}
    self.check3[4][1] = self.mainLayer:getChildByName("node3"):getChildByName("check41")
    self.check3[4][1]:setTag(1)

    ComHelpFuc.selectall(self.check3[4],self.num34,function( tag )
        self.num34 = tag
    end)

    self.check3[5] ={}
    self.check3[5][1] = self.mainLayer:getChildByName("node3"):getChildByName("check51")
    self.check3[5][1]:setTag(1)
    self.check3[5][2] = self.mainLayer:getChildByName("node3"):getChildByName("check52")
    self.check3[5][2]:setTag(2)
    self.check3[5][3] = self.mainLayer:getChildByName("node3"):getChildByName("check53")
    self.check3[5][3]:setTag(3)
    self.check3[5][4] = self.mainLayer:getChildByName("node3"):getChildByName("check54")
    self.check3[5][4]:setTag(4)

    ComHelpFuc.selectall(self.check3[5],self.num35,function( tag )
        self.num35 = tag
    end)


    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node3"):getChildByName("check61"),self.gamewanfa1,function( tag )
        self.gamewanfa1 = tag
    end)
    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node3"):getChildByName("check62"),self.gamewanfa2,function( tag )
        self.gamewanfa2 = tag
    end)

    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node3"):getChildByName("spec1"),self.spec1,function( tag )
        self.spec1 = tag
    end)
    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node3"):getChildByName("spec2"),self.spec2,function( tag )
        self.spec2 = tag
    end)
    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node3"):getChildByName("spec3"),self.spec3,function( tag )
        self.spec3 = tag
    end)


    ------------------------4--------------------------

    self.check4 = {}
    self.check4[1] ={}
    self.check4[1][1] = self.mainLayer:getChildByName("node4"):getChildByName("check11")
    self.check4[1][1]:setTag(1)
    self.check4[1][2] = self.mainLayer:getChildByName("node4"):getChildByName("check12")
    self.check4[1][2]:setTag(2)
    self.check4[1][3] = self.mainLayer:getChildByName("node4"):getChildByName("check13")
    self.check4[1][3]:setTag(3)

    ComHelpFuc.selectall(self.check4[1],self.num41,function( tag )
        self.num41 = tag
        self:updatafang(self.num41,self.num42)
    end)


    self.check4[2] ={}
    self.check4[2][1] = self.mainLayer:getChildByName("node4"):getChildByName("check21")
    self.check4[2][1]:setTag(1)
    self.check4[2][2] = self.mainLayer:getChildByName("node4"):getChildByName("check22")
    self.check4[2][2]:setTag(2)
     self.check4[2][3] = self.mainLayer:getChildByName("node4"):getChildByName("check23")
    self.check4[2][3]:setTag(3)

    ComHelpFuc.selectall(self.check4[2],self.num42,function( tag )
        self.num42 = tag
        self:updatafang(self.num41,self.num42)
    end)

    self.check4[3] ={}
    self.check4[3][1] = self.mainLayer:getChildByName("node4"):getChildByName("check31")
    self.check4[3][1]:setTag(1)
    self.check4[3][2] = self.mainLayer:getChildByName("node4"):getChildByName("check32")
    self.check4[3][2]:setTag(2)
    self.check4[3][3] = self.mainLayer:getChildByName("node4"):getChildByName("check33")
    self.check4[3][3]:setTag(3)
    self.check4[3][4] = self.mainLayer:getChildByName("node4"):getChildByName("check34")
    self.check4[3][4]:setTag(4)

    ComHelpFuc.selectall(self.check4[3],self.num43,function( tag )
        self.num43 = tag
    end)

    self.check4[4] ={}
    self.check4[4][1] = self.mainLayer:getChildByName("node4"):getChildByName("check41")
    self.check4[4][1]:setTag(1)

    ComHelpFuc.selectall(self.check4[4],self.num44,function( tag )
        self.num44 = tag
    end)

    self.check4[5] ={}
    self.check4[5][1] = self.mainLayer:getChildByName("node4"):getChildByName("check51")
    self.check4[5][1]:setTag(1)
    self.check4[5][2] = self.mainLayer:getChildByName("node4"):getChildByName("check52")
    self.check4[5][2]:setTag(2)
    self.check4[5][3] = self.mainLayer:getChildByName("node4"):getChildByName("check53")
    self.check4[5][3]:setTag(3)
    self.check4[5][4] = self.mainLayer:getChildByName("node4"):getChildByName("check54")
    self.check4[5][4]:setTag(4)

    ComHelpFuc.selectall(self.check4[5],self.num45,function( tag )
        self.num45 = tag
    end)


    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node4"):getChildByName("check61"),self.gamewanfa1,function( tag )
        self.gamewanfa1 = tag
    end)
    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node4"):getChildByName("check62"),self.gamewanfa2,function( tag )
        self.gamewanfa2 = tag
    end)

    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node4"):getChildByName("spec1"),self.spec1,function( tag )
        self.spec1 = tag
    end)
    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node4"):getChildByName("spec2"),self.spec2,function( tag )
        self.spec2 = tag
    end)
    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node4"):getChildByName("spec3"),self.spec3,function( tag )
        self.spec3 = tag
    end)
    -----------------5--------------------------
    self.check5 = {}
    self.check5[1] ={}
    self.check5[1][1] = self.mainLayer:getChildByName("node5"):getChildByName("check11")
    self.check5[1][1]:setTag(1)
    self.check5[1][2] = self.mainLayer:getChildByName("node5"):getChildByName("check12")
    self.check5[1][2]:setTag(2)
    self.check5[1][3] = self.mainLayer:getChildByName("node5"):getChildByName("check13")
    self.check5[1][3]:setTag(3)

    ComHelpFuc.selectall(self.check5[1],self.num51,function( tag )
        self.num51 = tag
    end)


    self.check5[2] ={}
    self.check5[2][1] = self.mainLayer:getChildByName("node5"):getChildByName("check21")
    self.check5[2][1]:setTag(1)
    self.check5[2][2] = self.mainLayer:getChildByName("node5"):getChildByName("check22")
    self.check5[2][2]:setTag(2)
    self.check5[2][3] = self.mainLayer:getChildByName("node5"):getChildByName("check23")
    self.check5[2][3]:setTag(3)

    ComHelpFuc.selectall(self.check5[2],self.num52,function( tag )
        self.num52 = tag
        self:updatafang(self.num52,self.num53)
    end)

    self.check5[3] ={}
    self.check5[3][1] = self.mainLayer:getChildByName("node5"):getChildByName("check31")
    self.check5[3][1]:setTag(1)
    self.check5[3][2] = self.mainLayer:getChildByName("node5"):getChildByName("check32")
    self.check5[3][2]:setTag(2)
    self.check5[3][3] = self.mainLayer:getChildByName("node5"):getChildByName("check33")
    self.check5[3][3]:setTag(3)
    self.check5[3][4] = self.mainLayer:getChildByName("node5"):getChildByName("check34")
    self.check5[3][4]:setTag(4)


    ComHelpFuc.selectall(self.check5[3],self.num53,function( tag )
        self.num53 = tag
        self:updatafang(self.num52,self.num53)
    end)

    self.check5[4] ={}
    self.check5[4][1] = self.mainLayer:getChildByName("node5"):getChildByName("check41")
    self.check5[4][1]:setTag(1)
    print("self.num54:"..self.num54)
    ComHelpFuc.selectall(self.check5[4],self.num54,function( tag )
        self.num54 = tag
    end)

     self.check5[5] ={}
    self.check5[5][1] = self.mainLayer:getChildByName("node5"):getChildByName("check51")
    self.check5[5][1]:setTag(1)
    self.check5[5][2] = self.mainLayer:getChildByName("node5"):getChildByName("check52")
    self.check5[5][2]:setTag(2)
    self.check5[5][3] = self.mainLayer:getChildByName("node5"):getChildByName("check53")
    self.check5[5][3]:setTag(3)
    self.check5[5][4] = self.mainLayer:getChildByName("node5"):getChildByName("check54")
    self.check5[5][4]:setTag(4)

    ComHelpFuc.selectall(self.check5[5],self.num55,function( tag )
        self.num55 = tag
    end)

    self.check5[6] ={}
    self.check5[6][1] = self.mainLayer:getChildByName("node5"):getChildByName("check71")
    self.check5[6][1]:setTag(1)
    self.check5[6][2] = self.mainLayer:getChildByName("node5"):getChildByName("check72")
    self.check5[6][2]:setTag(2)
    self.check5[6][3] = self.mainLayer:getChildByName("node5"):getChildByName("check73")
    self.check5[6][3]:setTag(3)
    self.check5[6][4] = self.mainLayer:getChildByName("node5"):getChildByName("check74")
    self.check5[6][4]:setTag(4)
    ComHelpFuc.selectall(self.check5[6],self.num56,function( tag )
        self.num56 = tag
    end)

    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node5"):getChildByName("check61"),self.gamewanfa1,function( tag )
        self.gamewanfa1 = tag
    end)
    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node5"):getChildByName("check62"),self.gamewanfa2,function( tag )
        self.gamewanfa2 = tag
    end)
    -- ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node2"):getChildByName("check63"),self.gamewanfa3,function( tag )
    --     self.gamewanfa3 = tag
    -- end)

    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node5"):getChildByName("spec1"),self.spec1,function( tag )
        self.spec1 = tag
    end)
    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node5"):getChildByName("spec2"),self.spec2,function( tag )
        self.spec2 = tag
    end)
    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node5"):getChildByName("spec3"),self.spec3,function( tag )
        self.spec3 = tag
    end)

    for i=1,5 do
        for j=1,2 do
            if self.mainLayer:getChildByName("node"..i):getChildByName("wennode"..j) then
                print(i)
                print(j)
                local btn1 = self.mainLayer:getChildByName("node"..i):getChildByName("wennode"..j):getChildByName("btn")
                local shownode = self.mainLayer:getChildByName("node"..i):getChildByName("wennode"..j):getChildByName("shownode")
                WidgetUtils.addClickEvent(btn1, function( )
                    print("111111111")
                     shownode:setVisible(true)
                end)
                
                WidgetUtils.addClickEvent(shownode, function( )
                    shownode:setVisible(false)
                end)
            end
        end
    end


     -----------------6--------------------------
    self.check6 = {}
    self.check6[1] ={}
    self.check6[1][1] = self.mainLayer:getChildByName("node6"):getChildByName("check21")
    self.check6[1][1]:setTag(1)
    self.check6[1][2] = self.mainLayer:getChildByName("node6"):getChildByName("check22")
    self.check6[1][2]:setTag(2)
    self.check6[1][3] = self.mainLayer:getChildByName("node6"):getChildByName("check23")
    self.check6[1][3]:setTag(3)

    ComHelpFuc.selectall(self.check6[1],self.num61,function( tag )
        self.num61 = tag
        self:updatafang(self.num61,self.num62)
    end)


    self.check6[2] ={}
    self.check6[2][1] = self.mainLayer:getChildByName("node6"):getChildByName("check31")
    self.check6[2][1]:setTag(1)
    self.check6[2][2] = self.mainLayer:getChildByName("node6"):getChildByName("check32")
    self.check6[2][2]:setTag(2)


    self.check6[2][3] = self.mainLayer:getChildByName("node6"):getChildByName("check33")
    self.check6[2][3]:setTag(3)
    self.check6[2][4] = self.mainLayer:getChildByName("node6"):getChildByName("check34")
    self.check6[2][4]:setTag(4)

    ComHelpFuc.selectall(self.check6[2],self.num62,function( tag )
        self.num62 = tag
        self:updatafang(self.num61,self.num62)
    end)

    self.check6[3] ={}
    self.check6[3][1] = self.mainLayer:getChildByName("node6"):getChildByName("check71")
    self.check6[3][1]:setTag(1)
    self.check6[3][2] = self.mainLayer:getChildByName("node6"):getChildByName("check72")
    self.check6[3][2]:setTag(2)


    ComHelpFuc.selectall(self.check6[3],self.num63,function( tag )
        self.num63 = tag
    end)

    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node6"):getChildByName("check61"),self.gamewanfa1,function( tag )
        self.gamewanfa1 = tag
    end)
    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node6"):getChildByName("check62"),self.gamewanfa2,function( tag )
        self.gamewanfa2 = tag
    end)



     -----------------7--------------------------
    self.check7 = {}
    self.check7[1] ={}
    self.check7[1][1] = self.mainLayer:getChildByName("node7"):getChildByName("check21")
    self.check7[1][1]:setTag(1)
    self.check7[1][2] = self.mainLayer:getChildByName("node7"):getChildByName("check22")
    self.check7[1][2]:setTag(2)
    self.check7[1][3] = self.mainLayer:getChildByName("node7"):getChildByName("check23")
    self.check7[1][3]:setTag(3)

    ComHelpFuc.selectall(self.check7[1],self.num71,function( tag )
        self.num71 = tag
        self:updatafang(self.num71,self.num72)
    end)


    self.check7[2] ={}
    self.check7[2][1] = self.mainLayer:getChildByName("node7"):getChildByName("check31")
    self.check7[2][1]:setTag(1)
    self.check7[2][2] = self.mainLayer:getChildByName("node7"):getChildByName("check32")
    self.check7[2][2]:setTag(2)
    self.check7[2][3] = self.mainLayer:getChildByName("node7"):getChildByName("check33")
    self.check7[2][3]:setTag(3)
    self.check7[2][4] = self.mainLayer:getChildByName("node7"):getChildByName("check34")
    self.check7[2][4]:setTag(4)

    ComHelpFuc.selectall(self.check7[2],self.num72,function( tag )
        self.num72 = tag
        self:updatafang(self.num71,self.num72)
    end)

    self.check7[3] ={}
    self.check7[3][1] = self.mainLayer:getChildByName("node7"):getChildByName("check71")
    self.check7[3][1]:setTag(1)
    self.check7[3][2] = self.mainLayer:getChildByName("node7"):getChildByName("check72")
    self.check7[3][2]:setTag(2)

    ComHelpFuc.selectall(self.check7[3],self.num73,function( tag )
        self.num73 = tag
    end)

    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node7"):getChildByName("check61"),self.gamewanfa1,function( tag )
        self.gamewanfa1 = tag
    end)
    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node7"):getChildByName("check62"),self.gamewanfa2,function( tag )
        self.gamewanfa2 = tag
    end)


     -----------------8--------------------------
    self.check8 = {}
    self.check8[1] ={}
    self.check8[1][1] = self.mainLayer:getChildByName("node8"):getChildByName("check21")
    self.check8[1][1]:setTag(1)
    self.check8[1][2] = self.mainLayer:getChildByName("node8"):getChildByName("check22")
    self.check8[1][2]:setTag(2)
    self.check8[1][3] = self.mainLayer:getChildByName("node8"):getChildByName("check23")
    self.check8[1][3]:setTag(3)

    ComHelpFuc.selectall(self.check8[1],self.num81,function( tag )
        self.num81 = tag
        self:updatafang(self.num81,self.num82)
    end)


    self.check8[2] ={}
    self.check8[2][1] = self.mainLayer:getChildByName("node8"):getChildByName("check31")
    self.check8[2][1]:setTag(1)
    self.check8[2][2] = self.mainLayer:getChildByName("node8"):getChildByName("check32")
    self.check8[2][2]:setTag(2)
    self.check8[2][3] = self.mainLayer:getChildByName("node8"):getChildByName("check33")
    self.check8[2][3]:setTag(3)
    self.check8[2][4] = self.mainLayer:getChildByName("node8"):getChildByName("check34")
    self.check8[2][4]:setTag(4)

    ComHelpFuc.selectall(self.check8[2],self.num82,function( tag )
        self.num82 = tag
        self:updatafang(self.num81,self.num82)
    end)

    self.check8[3] ={}
    self.check8[3][1] = self.mainLayer:getChildByName("node8"):getChildByName("check71")
    self.check8[3][1]:setTag(1)
    self.check8[3][2] = self.mainLayer:getChildByName("node8"):getChildByName("check72")
    self.check8[3][2]:setTag(2)

    ComHelpFuc.selectall(self.check8[3],self.num83,function( tag )
        self.num83 = tag
    end)

    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node8"):getChildByName("check61"),self.gamewanfa1,function( tag )
        self.gamewanfa1 = tag
    end)
    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node8"):getChildByName("check62"),self.gamewanfa2,function( tag )
        self.gamewanfa2 = tag
    end)





     -----------------9--------------------------
    self.check9 = {}
    self.check9[1] ={}
    self.check9[1][1] = self.mainLayer:getChildByName("node9"):getChildByName("check21")
    self.check9[1][1]:setTag(1)
    self.check9[1][2] = self.mainLayer:getChildByName("node9"):getChildByName("check22")
    self.check9[1][2]:setTag(2)
    self.check9[1][3] = self.mainLayer:getChildByName("node9"):getChildByName("check23")
    self.check9[1][3]:setTag(3)

    ComHelpFuc.selectall(self.check9[1],self.num91,function( tag )
        self.num91 = tag
        self:updatafang(self.num91,self.num92)
    end)


    self.check9[2] ={}
    self.check9[2][1] = self.mainLayer:getChildByName("node9"):getChildByName("check31")
    self.check9[2][1]:setTag(1)
    self.check9[2][2] = self.mainLayer:getChildByName("node9"):getChildByName("check32")
    self.check9[2][2]:setTag(2)
    self.check9[2][3] = self.mainLayer:getChildByName("node9"):getChildByName("check33")
    self.check9[2][3]:setTag(3)
    self.check9[2][4] = self.mainLayer:getChildByName("node9"):getChildByName("check34")
    self.check9[2][4]:setTag(4)

    ComHelpFuc.selectall(self.check9[2],self.num92,function( tag )
        self.num92 = tag
        self:updatafang(self.num91,self.num92)
    end)

    self.check9[3] ={}
    self.check9[3][1] = self.mainLayer:getChildByName("node9"):getChildByName("check71")
    self.check9[3][1]:setTag(1)
    self.check9[3][2] = self.mainLayer:getChildByName("node9"):getChildByName("check72")
    self.check9[3][2]:setTag(2)

    ComHelpFuc.selectall(self.check9[3],self.num93,function( tag )
        self.num93 = tag
    end)

    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node9"):getChildByName("check61"),self.gamewanfa1,function( tag )
        self.gamewanfa1 = tag
    end)
    ComHelpFuc.selectsingle(self.mainLayer:getChildByName("node9"):getChildByName("check62"),self.gamewanfa2,function( tag )
        self.gamewanfa2 = tag
    end)




    self:updatafang()
    

end

function CreateRoomView:updatafang()
    if self.gametype == 1 then
        self:updatafang1(self.num12,self.num13)
    elseif self.gametype == 2 then
        self:updatafang1(self.num22,self.num23)
    elseif self.gametype == 3 then
        self:updatafang1(self.num32,self.num33)
    elseif self.gametype == 4 then
        self:updatafang1(self.num42,self.num43)
    elseif self.gametype == 5 then
        self:updatafang1(self.num52,self.num53)
    elseif self.gametype == 6 then
        self:updatafang1(self.num61,self.num62)
     elseif self.gametype == 7 then
        self:updatafang1(self.num71,self.num72)
     elseif self.gametype == 8 then
        self:updatafang1(self.num81,self.num82)
     elseif self.gametype == 9 then
        self:updatafang1(self.num91,self.num92)
    end
end
function CreateRoomView:updatafang1(ju,type)
    if ju == 1 then
        if type == 1 or type == 4 then
             self.fangtips:setString("x3")
        else
            self.fangtips:setString("x1")
        end
    elseif ju == 2 then
        if type == 1 or type == 4 then
             self.fangtips:setString("x6")
        else
            self.fangtips:setString("x2")
        end
     elseif ju == 3 then
        if type == 1 or type == 4 then
             self.fangtips:setString("x9")
        else
            self.fangtips:setString("x3")
        end
    end
end
function CreateRoomView:creatbtncall( )
    cc.UserDefault:getInstance():setIntegerForKey("1niuniugametype",self.gametype)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu11",self.num11)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu12",self.num12)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu13",self.num13)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu14",self.num14)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu15",self.num15)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu16",self.num16)

    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu21",self.num21)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu22",self.num22)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu23",self.num23)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu24",self.num24)
    -- cc.UserDefault:getInstance():setIntegerForKey("1createniuniu25",self.num24)

    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu31",self.num31)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu32",self.num32)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu33",self.num33)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu34",self.num34)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu35",self.num35)

    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu41",self.num41)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu42",self.num42)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu43",self.num43)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu44",self.num44)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu45",self.num45)

    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu51",self.num51)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu52",self.num52)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu53",self.num53)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu54",self.num54)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu55",self.num55)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu56",self.num55)

    cc.UserDefault:getInstance():setIntegerForKey("11createniuniuspe1", self.spec1)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniuspe2", self.spec2)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniuspe3", self.spec3)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniuspe4", self.spec4)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniuspe5", self.spec5)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniuspe6", self.spec6)

    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu61",self.num61)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu62",self.num62)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu63",self.num63)


    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu71",self.num71)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu72",self.num72)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu73",self.num73)


    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu81",self.num81)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu82",self.num82)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu83",self.num83)


    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu91",self.num91)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu92",self.num92)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniu93",self.num93)

    cc.UserDefault:getInstance():setIntegerForKey("11createniuniuwanfa1",self.gamewanfa1)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniuwanfa2",self.gamewanfa2)
    cc.UserDefault:getInstance():setIntegerForKey("11createniuniuwanfa3",self.gamewanfa3)



    local fentable = {1,2,4,5,10}
    local fentable1 = {1,2,3,4,5}
    local tableinf = {}
   -- tableinf.gameshunniutype = self.spec1
    tableinf.gamehuaniutype = self.spec2
    --tableinf.gamesamehuaniutype = self.spec3
    --tableinf.gamehuluniutype = self.spec4
    tableinf.gameboomniutype = self.spec5
    tableinf.gamewuxiaoniutype = self.spec6
    tableinf.gamejointype = self.gamewanfa1
    tableinf.gamecuocardtype = self.gamewanfa2

   if self.gametype == 1 then
        tableinf.gamediscoretype = fentable[self.num11]
        tableinf.gamenums = self.num12*10
        tableinf.gameusecoinstype = self.num13
        tableinf.gametimestype = self.num14
        tableinf.gameqiangbankertimes = self.num16
        tableinf.gamepushtimes = (self.num15-1)*5
        tableinf.gamebankertype =  self.gametype
        tableinf.gamejointype = self.gamewanfa1
        tableinf.gamecuocardtype = self.gamewanfa2
        tableinf.gamebetlimit = self.gamewanfa3
        Socketapi.createtable(tableinf)
    elseif self.gametype == 2 then
        tableinf.gamediscoretype = fentable1[self.num21]
        tableinf.gamenums = self.num22*10
        tableinf.gameusecoinstype = self.num23
        tableinf.gametimestype = self.num24
        tableinf.gamebankertype =  self.gametype
        tableinf.gamejointype = self.gamewanfa1
        tableinf.gamecuocardtype = self.gamewanfa2
        Socketapi.createtable(tableinf)
    elseif self.gametype == 3 then
        
        tableinf.gamediscoretype = fentable[self.num31]
        tableinf.gamenums = self.num32*10
        tableinf.gameusecoinstype = self.num33
        tableinf.gametimestype = self.num34
        tableinf.gamepushtimes = (self.num35-1)*5
        tableinf.gamebankertype =  self.gametype
        tableinf.gamejointype = self.gamewanfa1
        tableinf.gamecuocardtype = self.gamewanfa2
        tableinf.gamebetlimit = self.gamewanfa3
        Socketapi.createtable(tableinf)
    elseif self.gametype == 4 then 
        tableinf.gamediscoretype = fentable[self.num41]
        tableinf.gamenums = self.num42*10
        tableinf.gameusecoinstype = self.num43
        tableinf.gametimestype = self.num44
        tableinf.gamebankertype =  self.gametype
        tableinf.gamejointype = self.gamewanfa1
        tableinf.gamecuocardtype = self.gamewanfa2
        tableinf.gamepushtimes = (self.num45-1)*5

        Socketapi.createtable(tableinf)
    elseif self.gametype == 5 then 
         tableinf.gamediscoretype = fentable[self.num51]
        tableinf.gamenums = self.num52*10
        tableinf.gameusecoinstype = self.num53
        tableinf.gametimestype = self.num54

        tableinf.gamebankertype =  self.gametype
        tableinf.gamejointype = self.gamewanfa1
        tableinf.gamecuocardtype = self.gamewanfa2
        tableinf.gamepushtimes = (self.num55-1)*5

        local tabl = {0,50,100,150}
        tableinf.gamebankerscore = tabl[self.num56]
        Socketapi.createtable(tableinf)
    elseif self.gametype == 6 then 
         tableinf.gamenums = self.num61*10
         tableinf.gameusecoinstype = self.num62
         tableinf.gamecardnums = self.num63
           tableinf.gamebankertype =  self.gametype
         Socketapi.createtable(tableinf)

    elseif self.gametype == 7 then 
         tableinf.gamenums = self.num71*10
         tableinf.gameusecoinstype = self.num72
         tableinf.gamecardnums = self.num73
           tableinf.gamebankertype =  self.gametype
         Socketapi.createtable(tableinf)
    elseif self.gametype == 8 then 
         tableinf.gamenums = self.num81*10
         tableinf.gameusecoinstype = self.num82
         tableinf.gamecardnums = self.num83
           tableinf.gamebankertype =  self.gametype
         Socketapi.createtable(tableinf)
    elseif self.gametype == 9 then 
         tableinf.gamenums = self.num91*10
         tableinf.gameusecoinstype = self.num92
         tableinf.gamecardnums = self.num93
           tableinf.gamebankertype =  self.gametype
         Socketapi.createtable(tableinf)
   end
end

function CreateRoomView:createcallback( data )
    print("crate 111")
    --Notinode_instance:showLoading(false)
    if data.result == 0 then
        LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = data.info})
    else
          if data.gameusecoinstype == 4 then
            CommonUtils.copyfang(data.roomnum)
             LaypopManger_instance:PopBox("DaikaifangHelpView")
          end  
    end
end

return CreateRoomView