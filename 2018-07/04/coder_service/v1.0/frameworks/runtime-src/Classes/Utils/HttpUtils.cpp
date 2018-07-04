#include "HttpUtils.h"
#include "json/document.h"
#include "Utils/Player.h"

int HttpUtils::errorCode = 0;

/*
1���˺Ŵ���
	����
		��ַ��http://192.168.2.21:8080/user/account/create
		������POST
		������
			ʾ����{"mac":"fgdfsefdfsdfsdaf"}
			˵����mac��ȡ�������Բ���
	����
		ʾ����{"ret":0,"msg":"�����ɹ�","data":{"userName":"guest1","pwd":"dsfhsdkfhksda"}}
		˵����ret��ʾ���ش��룬Ϊ0ʱ��ʾ�ɹ���data�����ڴ���ʧ��ʱΪ��
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
2���˺���֤
	����
		��ַ��http://192.168.2.21:8080/user/account/certify
		������POST
		������
			ʾ����{"userName":"user22","pwd":"jfNBHryzDWBsif8KtUZGmQ=="}
			˵����pwd=base64(md5(�������))���ڷ��������ɵ�����£��ͻ��˽��������·�������ֱ���ϴ��Ϳ�����
	����
		ʾ����{"ret":0,"msg":"��֤�ɹ�","data":{"token":"TANDFSAJLALJLJSADFASFSD","userId":22}}
		˵����ret��ʾ���ش��룬Ϊ0ʱ��ʾ�ɹ���data��������֤ʧ��ʱΪ��
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
��ȡtcs��Ϣ
	����
		��ַ��http://192.168.2.21:8080/user/tcs/getinfo
		������POST
		������
			ʾ����{"token":"TANDFSAJLALJLJSADFASFSD","userId":22}
	����
		ʾ����{"ret":0,"msg":"�����ɹ�","data":{"userId":1001,"tcsId":1001,"nickName":"name1001","score":1001,"ranking":1}}
		˵����ret��ʾ���ش��룬Ϊ0ʱ��ʾ�ɹ���data��������֤ʧ��ʱΪ��
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
�ϴ�����
	����
		��ַ��http://192.168.2.21:8080/user/tcs/upscore
		������POST
		������
			ʾ����{"token":"TANDFSAJLALJLJSADFASFSD","tcsId":1001,"score":1000}
	����
	ʾ����{"ret":0,"msg":"�����ϴ��ɹ�","data":{"userId":1001,"tcsId":1001,"nickName":"name1001","score":1001,"ranking":1}}
	˵����ret��ʾ���ش��룬Ϊ0ʱ��ʾ�ɹ���data��������֤ʧ��ʱΪ��
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
�޸Ľ�ɫ�ǳ�
	����
		��ַ��http://192.168.2.21:8080/user/tcs/reNickName
		������POST
		������
			ʾ����{"token":"TANDFSAJLALJLJSADFASFSD","tcsId":1001,"nickName":"sdsafw"}
	����
		ʾ����{"ret":0,"msg":"�޸��ǳƳɹ�","data":{"userId":1001,"tcsId":1001,"nickName":"name1001","score":1001,"ranking":1}}
		˵����ret��ʾ���ش��룬Ϊ0ʱ��ʾ�ɹ���data��������֤ʧ��ʱΪ��
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
