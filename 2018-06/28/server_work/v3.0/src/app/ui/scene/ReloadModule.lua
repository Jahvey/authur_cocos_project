local ReloadModule = class("ReloadModule")

function ReloadModule:ctor()
    
end

function ReloadModule:reload()
    cc.FileUtils:getInstance():purgeCachedEntries()
    print("-------------------------------------------------------------------------------------------")

    if ComNoti_instance then
        print("ComNoti_instance".."cunzai")
        ComNoti_instance = nil
    end
    if LocalData_instance then
        LocalData_instance = nil
    end

    if LaypopManger_instance then
        print("LaypopManger_instance".."cunzai")
        LaypopManger_instance = nil
    end
    if DataNotice_instance then
         print("DataNotice_instance".."cunzai")
        DataNotice_instance = nil
    end
    if SocketConnect_instance  then
        print("SocketConnect_instance".."cunzai")
        SocketConnect_instance = nil
    end

    if CM_INSTANCE  then
        print("GT_INSTANCE".."cunzai")
        CM_INSTANCE = nil
    end
    if GT_INSTANCE  then
        print("GT_INSTANCE".."cunzai")
        GT_INSTANCE = nil
    end

    if Notinode_instance then
        print("Notinode_instance".."cunzai")
        local chilren = Notinode_instance:getChildren()
        if chilren then
            for i,v in ipairs(chilren) do
                v:removeFromParent()
               
            end
        end
        Notinode_instance:removeFromParent()
        Notinode_instance = nil
    end

    package.loaded["config"] = nil
    require "config"
    print("版本:"..CONFIG_REC_VERSION)
    require "app.help.ComNoti"
    package.loaded["poker_msg_pb"] = nil
    package.loaded["poker_data_pb"] = nil
    package.loaded["poker_common_pb"] = nil
    package.loaded["poker_msg_ss_pb"] = nil
    package.loaded["poker_msg_cs_pb"] = nil
    package.loaded["poker_msg_log_pb"] = nil
    package.loaded["poker_config_pb"] = nil
    package.loaded["poker_msg_basic_pb"] = nil

   for k,v in pairs(package.loaded) do
        --print(k)
        if string.find(k,"app.") or  string.find(k,"app/") then
            print(k)
            package.loaded[k] = nil
            --require(k)
        end
    end

    package.loaded["app.ui.scene.LoginScene"] = nil
    cc.FileUtils:getInstance():purgeCachedEntries()

    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
end

return ReloadModule