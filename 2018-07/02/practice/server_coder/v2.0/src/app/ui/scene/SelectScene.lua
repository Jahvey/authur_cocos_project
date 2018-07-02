-- local poslocal = cc.p(-65.58,189.33)
local SelectScene = class("SelectScene",function()
    return cc.Scene:create()
end)

function SelectScene:ctor(ishall)

    package.loaded["app.ui.login.LoginView"] = nil
    package.loaded["app.ui.scene.LoginScene"] = nil
    cc.FileUtils:getInstance():purgeCachedEntries()


    cc.UserDefault:getInstance():setIntegerForKey("OPEN_CITY",1)
	local widget = cc.CSLoader:createNode("ui/city/CitySelect.csb")
    self.widget = widget
    self:addChild(self.widget)

	self:getScalePos()

    self.mainlayer = widget:getChildByName("main")
    -- self:setBgScale(widget:getChildByName("bg"))
    local bg = widget:getChildByName("bg")
    bg:setScale9Enabled(true)
    bg:setCapInsets(cc.rect(0,0,1280,720))
    bg:setContentSize(cc.size(display.width,display.height))

    self:setScalepos(self.mainlayer)
    bg:setPosition(cc.p(display.cx,display.cy))
    
    self.closebtn = self.mainlayer:getChildByName("closebtn")
     WidgetUtils.addClickEvent(self.closebtn, function()
        if ishall then
            glApp:enterSceneByName("MainScene")
        else
            glApp:enterScene("LoginScene")
        end
    end)

    self.scrollview = self.mainlayer:getChildByName("mid"):getChildByName("scrollview")
    self.gamenode = self.scrollview:getChildByName("node")

    self.gamebtn = self.mainlayer:getChildByName("mid"):getChildByName("btn")
    self.gamebtn:setVisible(false)

    self.listView = self.mainlayer:getChildByName("mid"):getChildByName("list")
    self.cell = self.mainlayer:getChildByName("mid"):getChildByName("cell")
    self.cell:setVisible(false)

    self.listView:setItemModel(self.cell)
    -- 

    local function clickbtn(localindex, realindex)

        for i,v in ipairs(CM_INSTANCE:getUsableCity()) do
           local item = self.listView:getItem(i-1)
           local btn = item:getChildByName("btn")
           if localindex == v then
                btn:setEnabled(false)
                btn:getChildByName("1"):setVisible(false)
                btn:getChildByName("2"):setVisible(true)
           else
                btn:setEnabled(true)
                btn:getChildByName("1"):setVisible(true)
                btn:getChildByName("2"):setVisible(false)
           end
        end

        self.gamenode:removeAllChildren()

        local _list = {}
         for i,v in ipairs(CM_INSTANCE:getUsableCity()) do
            if v == localindex then
               _list = CM_INSTANCE:getCITYCONF(v).list
            end
         end

        for i,v in ipairs(_list) do
            local btn  = self.gamebtn:clone()
            btn:setVisible(true)
            self.gamenode:addChild(btn)
            -- btn:setPosition(cc.p(poslocal.x+(i-1)%2*311,poslocal.y-math.floor((i-1)/2)*95))
            btn:setPosition(cc.p((i-1)%2*311+16,-math.floor((i-1)/2)*95))
            WidgetUtils.addClickEvent(btn, function()
                if v.open == 1 then
                    self:SelectGame(localindex, realindex)
                else
                    LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "未开放,敬请期待",sureCallFunc = function() 
                    end})
                end
            end)
            btn:getChildByName("name"):setString(v.name)
            if v.open == 1 then
                btn:getChildByName("open"):setVisible(true)
            else
                btn:getChildByName("open"):setVisible(false)
            end
        end

        local totalheight = math.ceil(#_list/2)*95

        self.scrollview:setInnerContainerSize(cc.size(self.scrollview:getContentSize().width,math.max(self.scrollview:getContentSize().height,totalheight)))
        self.gamenode:setPositionY(math.max(self.scrollview:getContentSize().height,totalheight))
        self.scrollview:jumpToTop()
    end

    for i,v in ipairs(CM_INSTANCE:getUsableCity()) do
   
        self.listView:pushBackDefaultItem()
        local item = self.listView:getItem(i-1)
        item:setVisible(true)
        -- item.typeindex = v

        local btn = item:getChildByName("btn")
        WidgetUtils.addClickEvent(btn, function()
             clickbtn(v,v)
        end)
        btn:getChildByName("1"):ignoreContentAdaptWithSize(true):loadTexture("city/city_"..v.."_off.png")
        btn:getChildByName("2"):ignoreContentAdaptWithSize(true):loadTexture("city/city_"..v.."_on.png")
    end

    self.listView:setScrollBarEnabled(false)

    print("GAME_CITY_SELECT:"..GAME_CITY_SELECT)
    print("GAME_LOCAL_CITY:"..GAME_LOCAL_CITY)

    clickbtn(GAME_LOCAL_CITY,GAME_CITY_SELECT)
    if GAME_LOCAL_CITY >=6 then
        self.listView:jumpToBottom()
    end
end
function SelectScene:init()

end

function SelectScene:getScalePos()
    local size = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local xscale =  size.width/1280
    local yscale = size.height/720
    local offxscale = 1
    local offyscale = 1
    if xscale > yscale then
        offxscale =  1*xscale/yscale
    else
        offyscale  = 1*yscale/xscale
    end
    self.offxscale = offxscale
    self.offyscale = offyscale
end
--界面适配
function SelectScene:setScalepos(node)
    local children = node:getChildren()
    if children then
        for i,v in ipairs(children) do
            local x = v:getPositionX()
            local y = v:getPositionY()
            v:setPositionX(x*self.offxscale)
            v:setPositionY(y*self.offyscale)
        end
    end
    --node:setPosition(display.cx,display.cy)
end
function SelectScene:setBgScale(bg)
    if self.offxscale >self.offyscale then
        bg:setScale(self.offxscale)
    else
        bg:setScale(self.offyscale)
    end
end

function SelectScene:SelectGame(localindex, realindex)
    if LocalData_instance then
        LocalData_instance:reset()
    end
    if SocketConnect_instance then
        SocketConnect_instance:closeSocket()
    end
    if Notinode_instance then
        Notinode_instance:setisLogin(false)
    end

	cc.UserDefault:getInstance():setIntegerForKey("CITY_SELECT_SERVER",realindex)
    cc.UserDefault:getInstance():setIntegerForKey("CITY_SELECT_CITY",localindex)
    cc.FileUtils:getInstance():purgeCachedEntries()
    glApp:enterScene("LoginScene")

end
return SelectScene
