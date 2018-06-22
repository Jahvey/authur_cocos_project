local RankView = class("RankView")  
  
function RankView:ctor()  
    self:init();  
end  
  
function RankView:init()  
    --加载Rank.json文件  
    self.m_uiRoot = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/Rank.json");  
  
    local panelMain = self.m_uiRoot:getChildByName("Panel_Main");  
  
    --获得滚动层  
    self.m_scrollViewRankList = panelMain:getChildByName("ScrollView_RankList");  
  
    --获得列表项  
    self.m_panelRankItem = self.m_scrollViewRankList:getChildByName("Panel_RankItem");  
    --引用计数加1，记住retain，必定会release(引用计数减1)  
    self.m_panelRankItem:retain();  
    --列表项从父节点中移除  
    self.m_panelRankItem:removeFromParent();  
  
    self:resetScrollViewRankList();  
end  
  
function RankView:resetScrollViewRankList()  
    --创建10个列表项  
    local iTotalNum = 10;   
    local iTotalHeight = 0;  --内容高  
    for i = 1, iTotalNum do  
        local panelRankItem = self.m_panelRankItem:clone();  
        local imageRankNum = panelRankItem:getChildByName("Image_RankNum");  
        local labelRankNum = imageRankNum:getChildByName("Label_RankNum");  
        labelRankNum:setString(i);  
  
        --getLayoutParameter():getMargin()，获得布局的Margin  
        iTotalHeight = iTotalHeight + panelRankItem:getContentSize().height + panelRankItem:getLayoutParameter():getMargin().bottom;  
  
        --添加到滚动层  
        self.m_scrollViewRankList:addChild(panelRankItem);  
    end  
    --设置滚动层内容的大小  
    self.m_scrollViewRankList:setInnerContainerSize(cc.size(self.m_scrollViewRankList:getContentSize().width, iTotalHeight));  
    --是否显示滚动条  
    --self.m_scrollViewRankList:setScrollBarEnabled(false);  
  
    --别忘了，引用计数减1  
    self.m_panelRankItem:release();  
end  
  
return RankView 