-------------------------------------------------
--   TODO   C++服务器请求接口
--   @author sjp
--   Create Date 2016.10.24
------------------------------------------------

Socketapi = {}
function Socketapi.joinhall()

    local msg = {keytype ="3;1;1",userid = LocalData_instance:getUid()}

	if SocketConnect_instance:send("3;1;1", msg) == false then
		-- SocketConnect_instance:start("218.244.138.174", 19012, false )
        SocketConnect_instance:start(LocalData_instance:getIp(), LocalData_instance:getPort(), false )
		SocketConnect_instance.lastmsg = msg 
		SocketConnect_instance.lastname = "3;1;1"
	end
end
--心跳readyaction
function Socketapi.sendheart()
	local msg = {keytype ="3;1;3"}
	SocketConnect_instance:send("3;1;3", msg)
end

--获取系统消息
function Socketapi.sendtotallmsg()
	local msg = {keytype ="3;1;8"}
	SocketConnect_instance:send("3;1;8", msg)
end

--排行榜
function Socketapi.sendgetrank(type)
	local msg = {keytype ="3;1;10",type = type}
	SocketConnect_instance:send("3;1;10", msg)
end
--公告
function Socketapi.sendggaomsg()
	local msg = {keytype ="3;1;5"}
	SocketConnect_instance:send("3;1;5", msg)
end
--重连
function Socketapi.reconjointable()
	local msg = {keytype ="3;2;2;1",userid = LocalData_instance:getUid()}
	SocketConnect_instance:send("3;2;2;1", msg)
end

function Socketapi.reconjointableforkutong()
	local msg = {keytype ="3;3;2;1",userid = LocalData_instance:getUid()}
	SocketConnect_instance:send("3;3;2;1", msg)
end

--创建房间
function Socketapi.createtable(taleinfo)
	taleinfo.keytype ="3;2;1;1"
	SocketConnect_instance:send("3;2;1;1", taleinfo)
end

--创建房间
function Socketapi.createtable1(taleinfo)
	taleinfo.keytype ="3;3;1;1"
	SocketConnect_instance:send("3;3;1;1", taleinfo)
end

function Socketapi.getdailikaif()
	local msg = {keytype ="3;2;1;3",}
	SocketConnect_instance:send("3;2;1;3", msg)
end

function Socketapi.getdailikaifforkutong()
	
	local msg = {keytype ="3;3;1;3",}
	SocketConnect_instance:send("3;3;1;3", msg)
end


function Socketapi.releasedailikaif(roomid)
	local msg = {keytype ="3;2;1;4",roomid = roomid}
	SocketConnect_instance:send("3;2;1;4", msg)
end

function Socketapi.releasedailikaifforkutong(roomid)
	local msg = {keytype ="3;3;1;4",roomid = roomid}
	SocketConnect_instance:send("3;3;1;4", msg)
end


function Socketapi.invitecode(invitecode)
	local msg = {keytype ="3;19;3",invitecode = tonumber(invitecode)}
	SocketConnect_instance:send("3;19;3", msg)
end
function Socketapi.getshoplist()
	local msg = {keytype ="3;19;2",}
	SocketConnect_instance:send("3;19;2", msg)
end

function Socketapi.getshopbuy(shopid)
	local msg = {keytype ="3;19;1",shopid = shopid}
	SocketConnect_instance:send("3;19;1", msg)
end
function Socketapi.zhuamsg()
	local msg = {keytype ="3;1;11;1" }
	SocketConnect_instance:send("3;1;11;1", msg)
end

function Socketapi.choumsg()
	local msg = {keytype ="3;1;11;2" }
	SocketConnect_instance:send("3;1;11;2", msg)
end
function Socketapi.renwu()
	local msg = {keytype ="3;2;4;1" }
	SocketConnect_instance:send("3;2;4;1", msg)
end

function Socketapi.sendggao()
	local msg = {keytype ="3;1;6"}
	SocketConnect_instance:send("3;1;6", msg)
end

function Socketapi.sendhuodong()
	local msg = {keytype ="3;1;6"}
	SocketConnect_instance:send("3;1;6", msg)
end
--加入房间
function Socketapi.jointable(roomnum)
	local msg = {keytype ="3;2;1;2",roomnum = roomnum}
	SocketConnect_instance:send("3;2;1;2", msg)
end

--加入房间
function Socketapi.jointable1(roomnum)
	local msg = {keytype ="3;3;1;2",roomnum = roomnum}
	SocketConnect_instance:send("3;3;1;2", msg)
end
--战绩
function Socketapi.getzhanji()
	local msg = {keytype ="3;2;5;1",userid = LocalData_instance:getUid()}
	SocketConnect_instance:send("3;2;5;1", msg)
end
--战绩
function Socketapi.getzhanjiforkutong()
	local msg = {keytype ="3;3;5;1",userid = LocalData_instance:getUid()}
	SocketConnect_instance:send("3;3;5;1", msg)
end

--战绩局
function Socketapi.getzhanjiju(roomid)
	local msg = {keytype ="3;2;5;2",roomid = roomid}
	SocketConnect_instance:send("3;2;5;2", msg)
end
--录像
function Socketapi.getzhandata(curgamenums,roomid)
	local msg = {keytype ="3;2;6",roomid = roomid,curgamenums = curgamenums}
	SocketConnect_instance:send("3;2;6", msg)
end
-- actiontype(动作类型：-1:无操作 1:暗杠2:明杠3:听牌4:碰5:弯杠6胡牌
-- 7:出牌8:过)

--执行动作
function Socketapi.doaction(type,qiangbankertimes,betscore)
	local msg = {keytype ="3;2;2;2",actiontype = type,qiangbankertimes = qiangbankertimes,betscore=betscore}
	SocketConnect_instance:send("3;2;2;2",msg)
end

function Socketapi.doactionforkutong(type,cardtype,carddatas,num,real)
	local msg = {keytype ="3;3;2;2",actiontype = type,cardtype = cardtype,carddatas=carddatas,num = num,real =real}
	SocketConnect_instance:send("3;3;2;2",msg)
end

--准备
function Socketapi.readyaction(typexia)
	local msg = {keytype ="3;2;2;3"}
	if typexia then
		msg.type = 1
	else
		msg.type = 0
	end
	SocketConnect_instance:send("3;2;2;3",msg)
end

function Socketapi.readyaction1(typexia)
	local msg = {keytype ="3;3;2;3"}
	if typexia then
		msg.type = 1
	else
		msg.type = 0
	end
	SocketConnect_instance:send("3;3;2;3",msg)
end

--取消准备
function Socketapi.saziaciton()
	local msg = {keytype ="3;3;2;10"}
	SocketConnect_instance:send("3;3;2;10",msg)
end
--取消准备
function Socketapi.beiginaction()
	local msg = {keytype ="3;2;2;9"}
	SocketConnect_instance:send("3;2;2;9",msg)
end


--发送聊天消息
function Socketapi.sendchat(content)
	local msg = {keytype ="3;2;2;5",content = content}
	SocketConnect_instance:send("3;2;2;5",msg)
end


--发送解散消息
function Socketapi.sendjiesan()
	local msg = {keytype ="3;2;2;6"}
	SocketConnect_instance:send("3;2;2;6", msg)
end

--操作解散 0同意 1拒绝
function Socketapi.sendjiesanaction(typesure)
	local msg = {keytype ="3;2;2;7",type = typesure }
	SocketConnect_instance:send("3;2;2;7", msg)
end


function Socketapi.sendexit()
	local msg = {keytype ="3;2;2;8" }
	SocketConnect_instance:send("3;2;2;8", msg)
end


--发送解散消息
function Socketapi.sendjiesanforkutong()
	local msg = {keytype ="3;3;2;6"}
	SocketConnect_instance:send("3;3;2;6", msg)
end

--操作解散 0同意 1拒绝
function Socketapi.sendjiesanactionforkutong(typesure)
	local msg = {keytype ="3;3;2;7",type = typesure }
	SocketConnect_instance:send("3;3;2;7", msg)
end


function Socketapi.sendexitforkutong()
	local msg = {keytype ="3;3;2;8" }
	SocketConnect_instance:send("3;3;2;8", msg)
end




function Socketapi.sendagaingame()
	local msg = {keytype ="3;2;8" }
	SocketConnect_instance:send("3;2;8", msg)
end






