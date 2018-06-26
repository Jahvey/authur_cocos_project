
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

MainScene.RESOURCE_FILENAME = "Layer.csb"


MainScene.RESOURCE_BINDING={
    
    ["ListView_1"]={["varname"]="list1"}

}




function MainScene:onCreate()
    printf("resource node = %s", tostring(self:getResourceNode()))
    
    --[[ you can create scene with following comment code instead of using csb file.
    -- add background image
    display.newSprite("HelloWorld.png")
        :move(display.center)
        :addTo(self)

    -- add HelloWorld label
    cc.Label:createWithSystemFont("Hello World", "Arial", 40)
        :move(display.cx, display.cy + 200)
        :addTo(self)
    ]]


    local table1={"1","2","3","4","5"}
    --for i=1,3 do
    for k,v in pairs(table1) do
        --print("i:···"..i)
        local  base_layer = cc.CSLoader:createNode("Node.csb")

        local  item2= base_layer:getChildByName("item")
        item2:removeFromParent() --注意：item2原来有其父节点，必须要首先将item从其父节点中移除，才能添加成功
        local  btn1 = item2:getChildByName("Button_1")
        local ck1 = item2:getChildByName("CheckBox_1")
        local img1 = item2:getChildByName("image_1")
        local text1 = item2:getChildByName("Text_1")
        text1:setString("text=="..v)
        print("text1:getString()  "..text1:getString())
        --print("base_layer pos "..base_layer.getPosition().." "..item2.getPosition())
        btn1:setName("text"..v)
        print("···"..btn1:getName())
        --self.ListView_1:addChild(item1)
        --self.lv1:addChild(item2)
        self.list1:setItemsMargin(50)
        --self.list1:refreshView()

        self.list1:pushBackCustomItem(item2)

    end








end


function MainScene:initListView1( )
    -- body


            -- Node* node = CSLoader::createNode("cocosui/UIEditorTest/UIListView/New/resV.csb");
        -- Node* child = node->getChildByTag(5);
        -- child->removeFromParent();
        -- _layout = dynamic_cast<Layout*>(child);
        -- _touchGroup->addChild(_layout);

        -- this->configureGUIScene();
        -- auto listView1 = dynamic_cast<ListView*>(Helper::seekWidgetByName(_layout, "ListView1"));
        -- auto listView2 = dynamic_cast<ListView*>(Helper::seekWidgetByName(_layout, "ListView2"));
        -- auto listView3 = dynamic_cast<ListView*>(Helper::seekWidgetByName(_layout, "ListView3"));
        -- setupListView(listView1);
        -- setupListView(listView2);
        -- setupListView(listView3);


    local  base_layer = cc.CSLoader:createNode("Layer1.csb")
    local  bg = base_layer:getChildByName("background_1")
    local listView = bg:getChildByName("ListView_1") --获取listView的值
    --listView:removeFromParent()



    -- auto item0 = Text::create();
    -- item0->setString(StringUtils::format("Item margin: %d", static_cast<int>(itemMargin)));
    -- listView->addChild(item0);

    -- auto item1 = Layout::create();
    -- auto checkbox = CheckBox::create("selected01.png", "selected01.png", "selected02.png", "selected01.png", "selected01.png");
    -- checkbox->setPosition(Vec2(checkbox->getCustomSize().width / 2, checkbox->getCustomSize().height / 2));
    -- item1->addChild(checkbox);
    local btn1 = listView:getChildByName("Button_1")
    local ck1 = listView:getChildByName("CheckBox_1")
    ck1:setSelected(true)
    --btn1:setVisible(true)

    self:addChild(base_layer)
end

function MainScene:setupListView(listView) 
    -- body

    -- float scale = 0.5f;
    -- float itemMargin = listView->getItemsMargin();

    -- auto item0 = Text::create();
    -- item0->setString(StringUtils::format("Item margin: %d", static_cast<int>(itemMargin)));
    -- listView->addChild(item0);

    -- auto item1 = Layout::create();
    -- auto checkbox = CheckBox::create("selected01.png", "selected01.png", "selected02.png", "selected01.png", "selected01.png");
    -- checkbox->setPosition(Vec2(checkbox->getCustomSize().width / 2, checkbox->getCustomSize().height / 2));
    -- item1->addChild(checkbox);
    -- auto checkboxText = Text::create();
    -- checkboxText->setString("CheckBox");
    -- checkboxText->setFontSize(checkbox->getCustomSize().width * .8f);
    -- checkboxText->setPosition(Vec2(checkbox->getCustomSize().width + checkboxText->getCustomSize().width / 2, checkbox->getCustomSize().height / 2));
    -- item1->addChild(checkboxText);
    -- float item1Width = scale * (checkbox->getCustomSize().width + checkboxText->getCustomSize().width);
    -- float item1Height = scale * checkbox->getCustomSize().height;
    -- item1->setContentSize(Size(item1Width, item1Height));
    -- item1->setScale(scale);
    -- listView->addChild(item1);

    -- auto item2 = Text::create();
    -- item2->setString("Text2");
    -- item2->setFontSize(checkbox->getCustomSize().width * .4f);
    -- item2->setTextColor(Color4B(0, 255, 0, 255));
    -- listView->addChild(item2);

    -- auto item3 = Layout::create();
    -- auto imageview0 = ImageView::create("image.png");
    -- auto imageview1 = ImageView::create("image.png");
    -- imageview1->setPositionX(imageview1->getCustomSize().width * 2);
    -- imageview0->setAnchorPoint(Vec2(0, 0));
    -- imageview1->setAnchorPoint(Vec2(0, 0));
    -- item3->setContentSize(Size(imageview0->getCustomSize().width * 3 * scale, imageview0->getCustomSize().height * scale));
    -- item3->addChild(imageview0);
    -- item3->addChild(imageview1);
    -- item3->setScale(scale);
    -- listView->addChild(item3);

    -- auto item4 = Button::create("button.png", "button_p.png");
    -- item4->setTitleText("Button");
    -- listView->pushBackCustomItem(item4);

    -- auto itemModel = Text::create();
    -- itemModel->setTextColor(Color4B(255, 0, 0, 125));
    -- itemModel->setString("List item model");
    -- listView->setItemModel(itemModel);
    -- listView->pushBackDefaultItem();
    -- listView->pushBackDefaultItem();


end






return MainScene
