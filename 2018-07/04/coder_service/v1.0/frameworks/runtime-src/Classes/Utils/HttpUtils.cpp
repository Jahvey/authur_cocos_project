#include "HttpUtils.h"
#include "json/document.h"
#include "Utils/Player.h"

int HttpUtils::errorCode = 0;

/*
1、账号创建
	请求
		地址：http://192.168.2.21:8080/user/account/create
		方法：POST
		参数：
			示例：{"mac":"fgdfsefdfsdfsdaf"}
			说明：mac获取不到可以不传
	返回
		示例：{"ret":0,"msg":"创建成功","data":{"userName":"guest1","pwd":"dsfhsdkfhksda"}}
		说明：ret表示返回代码，为0时表示成功，data参数在创建失败时为空
*/
void HttpUtils::sendRequest_createAccount()
{
	HttpRequest *request = new HttpRequest;
	request->setRequestType(HttpRequest::Type::POST);
	request->setUrl("http://192.168.2.21:8080/user/account/create");
	request->setResponseCallback([](HttpClient* client, HttpResponse* response)
	{
		onResponse(client, response, [](rapidjson::Value &data)
		{
			std::string str;
			str += "userName=";
			str += data["userName"].GetString();
			str += "&pwd=";
			str += data["pwd"].GetString();

			Player::getInstance()->setAccount(str.c_str());
		});
	});

	errorCode = 0;
	HttpClient::getInstance()->send(request);
}

/*
2、账号验证
	请求
		地址：http://192.168.2.21:8080/user/account/certify
		方法：POST
		参数：
			示例：{"userName":"user22","pwd":"jfNBHryzDWBsif8KtUZGmQ=="}
			说明：pwd=base64(md5(玩家密码))，在服务器生成的情况下，客户端讲服务器下发的密码直接上传就可以了
	返回
		示例：{"ret":0,"msg":"验证成功","data":{"token":"TANDFSAJLALJLJSADFASFSD","userId":22}}
		说明：ret表示返回代码，为0时表示成功，data参数在验证失败时为空
*/
void HttpUtils::sendRequest_loginAccount()
{
	auto &account = Player::getInstance()->getAccount();

	HttpRequest *request = new HttpRequest;
	request->setRequestType(HttpRequest::Type::POST);
	request->setUrl("http://192.168.2.21:8080/user/account/certify");
	request->setRequestData(account.c_str(), account.size());
	request->setResponseCallback([](HttpClient* client, HttpResponse* response)
	{
		onResponse(client, response, [](rapidjson::Value &data)
		{
			Player::getInstance()->setToken(data["token"].GetString());
			Player::getInstance()->setUserId(data["userId"].GetInt());
		});
	});

	errorCode = 0;
	HttpClient::getInstance()->send(request);
}

/*
获取tcs信息
	请求
		地址：http://192.168.2.21:8080/user/tcs/getinfo
		方法：POST
		参数：
			示例：{"token":"TANDFSAJLALJLJSADFASFSD","userId":22}
	返回
		示例：{"ret":0,"msg":"创建成功","data":{"userId":1001,"tcsId":1001,"nickName":"name1001","score":1001,"ranking":1}}
		说明：ret表示返回代码，为0时表示成功，data参数在验证失败时为空
*/
void HttpUtils::sendRequest_getInfo()
{
	char buf[256];
	sprintf(
		buf,
		"token=%s&userId=%d",
		Player::getInstance()->getToken().c_str(),
		Player::getInstance()->getUserId()
	);

	HttpRequest *request = new HttpRequest;
	request->setRequestType(HttpRequest::Type::POST);
	request->setUrl("http://192.168.2.21:8080/user/tcs/getinfo");
	request->setRequestData(buf, strlen(buf));
	request->setResponseCallback([](HttpClient* client, HttpResponse* response)
	{
		onResponse(client, response, [](rapidjson::Value &data)
		{
			auto player = Player::getInstance();
			player->setGameId(data["tcsId"].GetInt());
			if (player->getNickname().empty()) {
				player->setNickname(data["nickName"].GetString());
			}
		});
	});

	errorCode = 0;
	HttpClient::getInstance()->send(request);
}

/*
上传积分
	请求
		地址：http://192.168.2.21:8080/user/tcs/upscore
		方法：POST
		参数：
			示例：{"token":"TANDFSAJLALJLJSADFASFSD","tcsId":1001,"score":1000}
	返回
	示例：{"ret":0,"msg":"积分上传成功","data":{"userId":1001,"tcsId":1001,"nickName":"name1001","score":1001,"ranking":1}}
	说明：ret表示返回代码，为0时表示成功，data参数在验证失败时为空
*/
void HttpUtils::sendRequest_uploadScore(int gameMode, int scoreType, int scoreValue)
{
	const char *rankTypeNames[2] = {
		"unlimited_mode",
		"limited_mode"
	};

	char buf[256];
	sprintf(
		buf,
		"token=%s&tcsId=%d&rankType=%s&score=%d",
		Player::getInstance()->getToken().c_str(),
		Player::getInstance()->getGameId(),
		rankTypeNames[gameMode],
		scoreValue
	);

	HttpRequest *request = new HttpRequest;
	request->setRequestType(HttpRequest::Type::POST);
	request->setUrl("http://192.168.2.21:8080/user/tcs/upscore");
	request->setRequestData(buf, strlen(buf));

	errorCode = 0;
	HttpClient::getInstance()->send(request);
}

void HttpUtils::sendRequest_downloadScore(int gameMode, int scoreType)
{
	const char *rankTypeNames[2] = {
		"unlimited_mode",
		"limited_mode"
	};

	char buf[256];
	sprintf(
		buf,
		"token=%s&tcsId=%d&rankType=%s",
		Player::getInstance()->getToken().c_str(),
		Player::getInstance()->getGameId(),
		rankTypeNames[gameMode]
	);

	HttpRequest *request = new HttpRequest;
	request->setRequestType(HttpRequest::Type::POST);
	request->setUrl("http://192.168.2.21:8080/user/tcs/scoreRanking");
	request->setRequestData(buf, strlen(buf));
	request->setResponseCallback([gameMode](HttpClient* client, HttpResponse* response)
	{
		onResponse(client, response, [gameMode](rapidjson::Value &data)
		{
			rapidjson::Value &rankList = data["rankList"];
			if (!rankList.IsArray())
				return;

			log("--------------------------------------");
			log(data["rankType"].GetString());

			auto rl = Player::getInstance()->getRankList(gameMode);
			rl->clear();

			_RANKITEM ritem;

			for (int i = 0; i < rankList.Capacity(); i++)
			{
				rapidjson::Value &rk = rankList[i];

				ritem.nickname = rk["nickName"].GetString();
				ritem.score = rk["score"].GetInt();
				rl->push_back(ritem);

				log("%d  %s  %d", rk["ranking"].GetInt(), rk["nickName"].GetString(), rk["score"].GetInt());
			}

			Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("http_update_rank", (void *)gameMode);
		});
	});

	errorCode = 0;
	HttpClient::getInstance()->send(request);
}

/*
修改角色昵称
	请求
		地址：http://192.168.2.21:8080/user/tcs/reNickName
		方法：POST
		参数：
			示例：{"token":"TANDFSAJLALJLJSADFASFSD","tcsId":1001,"nickName":"sdsafw"}
	返回
		示例：{"ret":0,"msg":"修改昵称成功","data":{"userId":1001,"tcsId":1001,"nickName":"name1001","score":1001,"ranking":1}}
		说明：ret表示返回代码，为0时表示成功，data参数在验证失败时为空
*/
void HttpUtils::sendRequest_changeNickname(const char *nickname)
{
	char buf[256];
	sprintf(
		buf,
		"token=%s&tcsId=%d&nickName=%s",
		Player::getInstance()->getToken().c_str(),
		Player::getInstance()->getGameId(),
		nickname
	);

	HttpRequest *request = new HttpRequest;
	request->setRequestType(HttpRequest::Type::POST);
	request->setUrl("http://192.168.2.21:8080/user/tcs/reNickName");
	request->setRequestData(buf, strlen(buf));
	
	errorCode = 0;
	HttpClient::getInstance()->send(request);
}

void HttpUtils::onResponse(HttpClient* client, HttpResponse* response, httpSuccessCallback callback)
{
	if (!response->isSucceed())
	{
		log("Http response failed.");
		errorCode = HttpUtils::ErrorCode::RESPONSE_FAILED;
		return;
	}

	rapidjson::Document json;
	parseResponseData(response, json);

	int ret = json["ret"].GetInt();
	if (ret != 0)
	{
		log("Error: %s", json["msg"].GetString());
		errorCode = HttpUtils::ErrorCode::RET_FAILED;
		return;
	}

	rapidjson::Value &data = json["data"];

	if (callback != nullptr) {
		callback(data);
	}

	errorCode = HttpUtils::ErrorCode::RET_SUCCESS;
}

void HttpUtils::parseResponseData(HttpResponse *response, rapidjson::Document &json)
{
	auto pData = response->getResponseData();
	char *buffer = new char[pData->size() + 1];
	buffer[pData->size()] = '\0';

	for (unsigned int i = 0; i < pData->size(); i++)
	{
		buffer[i] = (*pData)[i];
	}

	log(buffer);
	json.Parse<0>(buffer);

	delete[] buffer;
}
