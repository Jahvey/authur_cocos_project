#pragma once

#include "cocos2d.h"
USING_NS_CC;

#include "network/HttpClient.h"
using namespace cocos2d::network;

#include "json/document.h"

typedef std::function<void(rapidjson::Value &)> httpSuccessCallback;

class HttpUtils
{
public:
	enum ErrorCode
	{
		RESPONSE_FAILED = 1,
		RET_SUCCESS,
		RET_FAILED,
	};

public:
	static void sendRequest_createAccount();
	static void sendRequest_loginAccount();
	static void sendRequest_getInfo();
	static void sendRequest_uploadScore(int gameMode, int scoreType, int scoreValue);
	static void sendRequest_downloadScore(int gameMode, int scoreType);
	static void sendRequest_changeNickname(const char *nickname);

	static void onResponse(HttpClient* client, HttpResponse* response, httpSuccessCallback callback = nullptr);
	static void parseResponseData(HttpResponse *response, rapidjson::Document &json);
	static int getErrorCode() { return errorCode; }
	
protected:
	static int errorCode;
};
