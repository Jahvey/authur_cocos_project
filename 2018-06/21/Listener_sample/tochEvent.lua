---按钮点击事件注册
function WidgetUtils.addClickEvent(btn, func,notplayeffect,quicktouch)
    
    -- btn:setPressedActionEnabled(true)
    local iscantouch = true
    --是否可以执行
    local onbtn = function(sender,eventType)
        if eventType == ccui.TouchEventType.began then   --按钮 触摸开始处理
        
        end
        if eventType == ccui.TouchEventType.ended then   --按钮 触摸完成处理
            if notplayeffect == nil then
                AudioUtils.playEffect("audio_button_click",false)
            end
            if func then
               func()
            end
        end
           
        if eventType == ccui.TouchEventType.canceled then   --按钮 触摸取消处理
        end
        
        if eventType == ccui.TouchEventType.moved then    --按钮 触摸移动事件处理
        end
    end
    
    btn:addTouchEventListener(onbtn)
end


--调用按钮方式

WidgetUtils.addClickEvent(self.closeBtn, function( )
    LaypopManger_instance:back()
  end)