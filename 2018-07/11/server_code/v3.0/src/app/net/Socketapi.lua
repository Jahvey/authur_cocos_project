-------------------------------------------------
--   TODO   C++服务器请求接口
--   @author sjp
--   Create Date 2016.10.24
------------------------------------------------

Socketapi = {}

function Socketapi.login(typ,uuid)
	print("login type:"..typ)
	-- print("login type:"..acc)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_login
    -- 微信登录类型为10
    if typ == poker_common_pb.EN_Accout_Weixin then
        typ = 10
    end
    request.acc_type = typ
    -- 微信登录
    if typ == 10 then
        request.account = LocalData_instance:getAccount()
    -- 游客登录   
    else
        if device.platform == "ios" then
            request.account = LocalData_instance:getopenUDID()
           -- request.account = "ddz_0001"
            -- request.account = "huapai_10086" --测试茶馆
        elseif  device.platform == "android" then
            request.account = LocalData_instance:getopenUDID()
            -- request.account = uuid
        else
            request.account = uuid or LocalData_instance:getopenUDID()
            -- request.account = "ddz_0001"
            -- request.account = "ddz_0002"
            -- request.account = "ddz_0003"
            -- request.account = "huapai_10086" --测试茶馆
        end
    end 
    
    if LocalData_instance:getToken() then
    	request.token = LocalData_instance:getToken()
    end	

    if LocalData_instance:getSex() then
    	request.gender = LocalData_instance:getSex()
    end	
    if LocalData_instance:getPic() then
    	request.pic_url =  LocalData_instance:getPic()
    end
    if  LocalData_instance:getNick() then
    	request.nick = LocalData_instance:getNick()
    end
    if LocalData_instance:getUid() then
    	request.uid = LocalData_instance:getUid()
    end	

    -- request.token = "4c63fab7d795dd2342e4c582a5ace206"
    -- request.account = "oh7AXtxYesMgJgHBzn--dEcnyuyI"
    -- request.acc_type = 10
    --request.account = "ooo00004"
    SocketConnect_instance.lastmsg = msg 
    SocketConnect_instance.lastname = "cs_request_login"

    LocalData_instance:setlist_ip(nil)
    LocalData_instance:setIsTokenError(false)
	if SocketConnect_instance:send("cs_request_login", msg) == false then
         SocketConnect_instance:start()
	end
end

function Socketapi.sendRequestConnectIP()
    release_print("。。。。。。。。。。。。。。请求 RequestConnectIP game ip 地址！")
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_connect_ip
    request.uid = LocalData_instance:getUid()
    request.request_connect_ip = LocalData_instance:getconnect_ip()
    SocketConnect_instance:send("cs_request_connect_ip", msg)
end

function Socketapi.updatainfo(nick_name,pic_url,gender)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_update_user_info

    request.nick_name = nick_name
    request.pic_url = pic_url
    request.gender = gender
    SocketConnect_instance:send("cs_request_update_user_info", msg)
end
-- 发送心跳包 
function Socketapi.sendRequestHeartBeat()
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_heart_beat
    request._is_present_in_parent = true
    Notinode_instance.sendServerTime = os.time()
    SocketConnect_instance:send("cs_request_heart_beat", msg)     
end

-- 请求创建牌桌
function Socketapi.requestCreateTable(tab)
	print("Socketapi.requestCreateTable")

    printTable(tab,"xp")

	local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_sdr_create_table    

    request.ztype = tab.ztype
    request.ttype = tab.ttype

    for k,v in pairs(tab) do
        if k ~= "ztype" and k ~= "ttype" then
            request.conf[k] = v
        end
    end

    print("..........cs_request_sdr_create_table")
    printTable(tab,"xp")

    SocketConnect_instance:send("cs_request_sdr_create_table", msg)
end
-- 请求进入牌桌
function Socketapi.requestEnterTable(tid)
	print("Socketapi.requestEnterTable == ",tid)
    userdata={}
    userdata.cid=2
    userdata.pid=9
    userdata.json={
        ["type"]="2.跳转房间"

    }
    CommonUtils.sends(userdata)
	local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_sdr_enter_table
    request.tid = tonumber(tid)
    -- request.ztype = cc.UserDefault:getInstance():getIntegerForKey("select_gametype",5) 

    SocketConnect_instance:send("cs_request_sdr_enter_table", msg)

    Notinode_instance:showLoading(true,9)

end
function Socketapi.request_ready(bool, isMingPai)
    print("......request_ready")

    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_ready_for_game

    request.state = bool
    if isMingPai then
        request.is_ming_pai_start = isMingPai
    end
	SocketConnect_instance:send("cs_request_ready_for_game", msg)
end

-- 操作类型
function Socketapi.request_do_action(seat_index,act_type,dest_card,cards,token,choice_token)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_sdr_do_action
    
    request.seat_index = seat_index
    request.act_type = act_type
    -- print("act_type:",act_type)
    if dest_card then
        -- print("dest_card:",dest_card)
        request.dest_card = dest_card
    else
        print("dest_card  为空") 
    end 
    if cards and type(cards) == "table" then
        for i,v in ipairs(cards) do
            request.cards:append(tonumber(v))
        end
    end 
    if token then
        -- print("token:",token)
        request.token  = token
    end

    if choice_token then
        -- print("token:",token)
        request.choice_token  = choice_token
    end

    -- 用于打牌 记录col row
    local json_msg_id = nil
    if msg_data and type(msg_data) == "table"then
        json_msg_id = msg_data.col 
    end
	SocketConnect_instance:send("cs_request_sdr_do_action", msg,{json_msg_id = json_msg_id})
    
end

function Socketapi.request_do_actionforddz(seat_index,act_type,token,cardtype,cards,real,num)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_sdr_do_action
    
    request.seat_index = seat_index
    request.act_type = act_type
    -- print("act_type:",act_type)
    if cards and type(cards) == "table" then
        for i,v in ipairs(cards) do
            request.cards:append(tonumber(v))
        end
    end 
    if cardtype then
        request.cardtype = cardtype
    end
    if real then
        request.real = real
    end
    if num then
        request.num = num
    end

    if token then
        -- print("token:",token)
        request.token  = token
    end

    SocketConnect_instance:send("cs_request_sdr_do_action", msg,{json_msg_id = json_msg_id})
    
    
end

--温江玩法特有
function Socketapi.request_selectpiao(bol)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_select_piao
    request.is_piao = bol
    SocketConnect_instance:send("cs_request_select_piao", msg)
end
--温江玩法特有
function Socketapi.request_releaseroom(bol,is_start)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_dissolve_table
    request.choice = bol
    request.is_start = is_start
    SocketConnect_instance:send("cs_request_dissolve_table", msg)
end
-- 发送消息
-- idx,page魔法表情专用
---------------------------------------------------------------------------------------------
function Socketapi.sendChat(type,str,idx,page)
    local msg = poker_msg_pb.PBCSMsg()
    msg.cs_request_chat.ctype = type or 0 -- 0 表情与文字 1.魔法表情 2语音
    msg.cs_request_chat.message = str or ""
    local json_msg = nil
    if type == 1 then
        msg.cs_request_chat.BigFaceChannel = page or 1
        msg.cs_request_chat.BigFaceID = idx
        local tab = {}
        tab.page = msg.cs_request_chat.BigFaceChannel
        tab.id = idx
        tab.msg = str
        local jsonstr = json.encode(tab)
        json_msg = jsonstr
    elseif type == 0 or type == 2 then
        local tab = {}
        tab.message = msg.cs_request_chat.message
        local jsonstr = json.encode(tab)
        json_msg = jsonstr 
    end
    -- print("======json_msg===",json_msg)
    -- print("发送："..msg.cs_request_chat.ctype)
    SocketConnect_instance:send("cs_request_chat", msg,{json_msg_id = tonumber(msg.cs_request_chat.ctype),json_msg = json_msg})
end

-- 战绩
function Socketapi.requestUserRecord()
    print("请求战绩")
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_user_record
    request.game_type = 2
    SocketConnect_instance:send("cs_request_user_record", msg)
end
-- 牌桌记录
function Socketapi.requestTableRecord()
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_table_record
    request._is_present_in_parent = true
    SocketConnect_instance:send("cs_request_table_record", msg)
end
-- 弃胡
function Socketapi.requestFPFAbandonHu()
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_fpf_abandon_hu
    request._is_present_in_parent = true
    SocketConnect_instance:send("cs_request_fpf_abandon_hu", msg) 
end
-- 返回大厅
function Socketapi.requestLogoutTable()
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_logout_table
    request._is_present_in_parent = true
    SocketConnect_instance:send("cs_request_logout_table", msg) 
end
--分享 战绩
function Socketapi.cs_request_replay_code(recordid,round,stamp)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_replay_code
    request.game_type = 60
    request.recordid = recordid
    request.round = round
    request.stamp = stamp
    SocketConnect_instance:send("cs_request_replay_code", msg)
end
 
--获取分享战绩
function  Socketapi.cs_request_replay_code_data(code)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_replay_code_data
    request.replay_code = code
    SocketConnect_instance:send("cs_request_replay_code_data", msg)
end

-- 请求回放
-- table[631978] game_type[1] recordid[2714326328141530] stamp[1486350721] round_size[6]
function Socketapi.requestTableFlowRecord(tab)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_table_flow_record
    if tab then
        request.recordid = tab.recordid
        request.round = tab.round
        request.stamp = tab.stamp
        request.game_type = tab.game_type
    else
        print("...........................请求回放")
        request.recordid = 793380757258577
        request.round = 8
        request.stamp = os.time()-3600*48
        request.game_type = 60
    end 
    SocketConnect_instance:send("cs_request_table_flow_record", msg) 
end
-- 设置是否离线
function Socketapi.requestOffline(bol)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_off_line
    request.is_offline = bol
    SocketConnect_instance:send("cs_request_off_line", msg)  
end




--------------------club-------------------------

function Socketapi.requestgetCluelist()
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_tea_bar_list
    request._is_present_in_parent = true
    SocketConnect_instance:send("cs_request_tea_bar_list", msg)
end


function Socketapi.requestcreateclube(name,desc,pay_type)
    print("requestcreateclube",name,desc,pay_type)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_create_tea_bar
    request.name = name
    request.desc = desc
    request.pay_type = pay_type
    SocketConnect_instance:send("cs_request_create_tea_bar", msg)
end

function Socketapi.requestgetclubeinfo(tbid)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_tea_bar_info
    request.tbid = tbid
    SocketConnect_instance:send("cs_request_tea_bar_info", msg)
end
function Socketapi.requestjoinclube(tbid)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_apply_join_tea_bar
    request.tbid = tbid
    SocketConnect_instance:send("cs_request_apply_join_tea_bar", msg)
end


function Socketapi.requestenterclube(tbid,is_refresh)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_enter_tea_bar
    request.tbid = tbid
    request.is_refresh = is_refresh
    
    SocketConnect_instance:send("cs_request_enter_tea_bar", msg)
end

function Socketapi.requestmsgclube(tbid)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_tea_bar_message
    request.tbid = tbid
    SocketConnect_instance:send("cs_request_tea_bar_message", msg)
end

function Socketapi.requestmsgselect(if_agree,tbid,uid)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_agree_user_join_tea_bar
    request.tbid = tbid
    request.if_agree = if_agree
    request.uid = uid
    SocketConnect_instance:send("cs_request_agree_user_join_tea_bar", msg)
end


function Socketapi.requestgetuserlistinfo(tbid,date_type)
    print(tbid,date_type)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_get_tea_bar_user_list
    request.tbid = tbid
    request.date_type = date_type
    SocketConnect_instance:send("cs_request_get_tea_bar_user_list", msg)
end


function Socketapi.requestaddfangclue(tbid,num)
    print(tbid,date_type)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_put_chips_to_tea_bar
    request.tbid = tbid
    request.addchips = num
    SocketConnect_instance:send("cs_request_put_chips_to_tea_bar", msg)
end


function Socketapi.requesttableinfoclue(tbid,tid)
    print(tbid,date_type)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_table_detail
    request.tid = tid
    request.tbid = tbid
    SocketConnect_instance:send("cs_request_table_detail", msg)
end


function Socketapi.requestremoveroleclue(tbid,uid)
    print(tbid,date_type)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_remove_user
    request.tbid = tbid
    request.uid = uid
    SocketConnect_instance:send("cs_request_remove_user", msg)
end

function Socketapi.requestsetjiesuannum( tbid,uid,date_type,settle_num)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_modify_settle_num
    request.tbid = tbid
    request.uid = uid
    request.date_type = date_type
    request.settle_num = settle_num
    SocketConnect_instance:send("cs_request_modify_settle_num", msg)
end
function Socketapi.requestresetinfoclue(tbid,desc,payType)
    print(tbid,date_type)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_modify_tea_bar_desc
    request.tbid = tbid
    request.desc = desc
    request.pay_type = payType
    SocketConnect_instance:send("cs_request_modify_tea_bar_desc", msg)
end


function Socketapi.requestreleasseclue(tbid)
    print(tbid,date_type)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_free_tea_bar
    request.tbid = tbid
    --request.desc = desc
    SocketConnect_instance:send("cs_request_free_tea_bar", msg)
end


function Socketapi.requestgetpaijuclub(tbid)
    print(tbid,date_type)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_statistics_table_record_list
    request.tbid = tbid
    SocketConnect_instance:send("cs_request_statistics_table_record_list", msg)
end


function Socketapi.requestgettablejiesuantableinfoclub(tbid,statistics_id)
    print(tbid,date_type)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_tea_bar_statistics
    --request.tbid = tbid
    request.statistics_id = statistics_id
    SocketConnect_instance:send("cs_request_tea_bar_statistics", msg)
end


function Socketapi.requestgettablejiesuantableclub(tbid,statistics_id)
    print(tbid,date_type)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_tea_bar_table_settle
    request.tbid = tbid
    request.statistics_id = statistics_id
    SocketConnect_instance:send("cs_request_tea_bar_table_settle", msg)
end

function Socketapi.requestgettablejiesuantableclub(tbid,statistics_id)
    print(tbid,date_type)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_tea_bar_table_settle
    request.tbid = tbid
    request.statistics_id = statistics_id
    SocketConnect_instance:send("cs_request_tea_bar_table_settle", msg)
end

function Socketapi.requestreleaseroomclub(tid)
    print(tbid,date_type)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_dissolve_tea_bar_table
    request.tid = tid
    
    SocketConnect_instance:send("cs_request_dissolve_tea_bar_table", msg)
end

function Socketapi.cs_request_apply_drop_tea_bar(tbid)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_apply_drop_tea_bar
    request.tbid = tbid
    
    SocketConnect_instance:send("cs_request_apply_drop_tea_bar", msg)
end
------------club----------