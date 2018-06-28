#include "LoadingScene.h"

#include "audio/include/SimpleAudioEngine.h"
#include "GamePlay/GameDef.h"
#include "Utils/GameData.h"
#include "Utils/InitSnakeUtils.h"
#include "Utils/Player.h"
#include "Utils/HttpUtils.h"
#include "UI/MainScene.h"

using namespace CocosDenshion;

Scene* LoadingScene::createScene()
{
	auto scene = Scene::create();
	auto layer = LoadingScene::create();
	scene->addChild(layer);
	return scene;
}

bool LoadingScene::init()
{
	if (!Layer::init()) {
		return false;
	}

	auto bg = Sprite::create("home_bg.png");
	bg->setPosition(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
	addChild(bg);

	auto title = Sprite::create("game_name_icon.png");
	title->setPosition(SCREEN_WIDTH / 2, SCREEN_HEIGHT - 200);
	addChild(title, 2);

	_bar = LoadingBar::create("loading_bg2.png", 10);
	_bar->setScale9Enabled(true);
	_bar->setContentSize(Size(SCREEN_WIDTH * 0.5, 22));
	_bar->setPosition(Vec2(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.3));
	addChild(_bar, 3);

	return true;
}

void LoadingScene::onEnter()
{
	Layer::onEnter();

	_lodingStep = 0;
	schedule(CC_SCHEDULE_SELECTOR(LoadingScene::OnLoading), 0.1f);
}

void LoadingScene::OnLoading(float delta)
{
	switch (_lodingStep)
	{
	case 0: // 读取本地配置
		Player::getInstance()->initFromConfig();
#if 0
		if (Player::getInstance()->getAccount().empty()) {
			setLoadingStep(1);
		}
		else {
			setLoadingStep(3);
		}
#else
		setLoadingStep(10);
#endif
		break;

	case 1: // 创建账号
		HttpUtils::sendRequest_createAccount();
		setBarPercent(20);
		setLoadingStep(2);
		break;

	case 2: // 等待创建账号返回
		if (HttpUtils::getErrorCode() == HttpUtils::ErrorCode::RET_SUCCESS) {
			setLoadingStep(3);
		}
		else if (HttpUtils::getErrorCode() == HttpUtils::ErrorCode::RET_FAILED 
			|| HttpUtils::getErrorCode() == HttpUtils::ErrorCode::RESPONSE_FAILED) {
			setLoadingStep(1);
		}
		break;

	case 3: // 已拥有账号，去服务器验证
		HttpUtils::sendRequest_loginAccount();
		setBarPercent(30);
		setLoadingStep(4);
		break;

	case 4: // 等待验证结果
		if (HttpUtils::getErrorCode() == HttpUtils::ErrorCode::RET_SUCCESS) {
			setLoadingStep(5);
		}
		else if (HttpUtils::getErrorCode() == HttpUtils::ErrorCode::RET_FAILED) {
			setLoadingStep(1);
		}
		else if (HttpUtils::getErrorCode() == HttpUtils::ErrorCode::RESPONSE_FAILED) {
			setLoadingStep(3);
		}
		break;

	case 5: // 验证账号完成
		HttpUtils::sendRequest_getInfo();
		setBarPercent(50);
		setLoadingStep(6);
		break;

	case 6: // 等待获取信息
		if (HttpUtils::getErrorCode() == HttpUtils::ErrorCode::RET_SUCCESS) {
			setLoadingStep(10);
		}
		else if (HttpUtils::getErrorCode() == HttpUtils::ErrorCode::RET_FAILED) {
			setLoadingStep(3);
		}
		else if (HttpUtils::getErrorCode() == HttpUtils::ErrorCode::RESPONSE_FAILED) {
			setLoadingStep(5);
		}
		break;

	case 10:
		SnakeSkinData::initSkins(true);
		setBarPercent(60);
		setLoadingStep(11);
		break;

	case 11:
		FoodData::getInstance()->initWithFile("food.db");
		setBarPercent(70);
		setLoadingStep(12);
		break;

	case 12:
		InitSnakeUtils::getInstance()->initWithFile("xxoo.bin");
		setBarPercent(80);
		setLoadingStep(20);
		break;

	
	case 20:
		if (UserDefault::getInstance()->getBoolForKey(SETTING_MUSIC))
		{
			SimpleAudioEngine::getInstance()->playBackgroundMusic("bg.mp3");
		}
		else
		{
			SimpleAudioEngine::getInstance()->stopBackgroundMusic();
		}

		if (UserDefault::getInstance()->getBoolForKey(SETTING_EFFECT))
		{
			SimpleAudioEngine::getInstance()->setEffectsVolume(1);
		}
		else
		{
			SimpleAudioEngine::getInstance()->setEffectsVolume(0);
		}
		setBarPercent(100);
		setLoadingStep(21);
		break;

	case 21:
		unscheduleAllCallbacks();
		auto scene = MainScene::createScene();
		Director::getInstance()->replaceScene(scene);
		break;
	}
}