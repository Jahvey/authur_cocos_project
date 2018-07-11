#include "MainScene.h"
#include "GamePlay/GamePlayer.h"
#include "SkinScene.h"
#include "SettingView.h"
#include "RuleScene.h"
#include "RankScene.h"
#include "PlayerScene.h"
#include "Utils/Player.h"
#include "Utils/InitSnakeUtils.h"
#include "audio/include/SimpleAudioEngine.h"
using namespace CocosDenshion;

Scene* MainScene::createScene()
{
	auto scene = Scene::create();

	auto layer = MainScene::create();

	scene->addChild(layer);

	return scene;
}

bool MainScene::init()
{
	if (!Layer::init()) {
		return false;
	}
	SimpleAudioEngine::getInstance()->playBackgroundMusic("bg.mp3");
	Player::getInstance()->initFromConfig();
	SnakeSkinData::initSkins(true);
	FoodData::getInstance()->initWithFile("food.db");
	InitSnakeUtils::getInstance()->initWithFile("xxoo.bin");

	auto bg = Sprite::create("home_bg.jpg");
	bg->setPosition(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
	addChild(bg);

	auto endlessBtn = Button::create("home_endless_bt_normal.png", "");
	endlessBtn->setPosition(Vec2(SCREEN_WIDTH / 2 - 200, SCREEN_HEIGHT / 2 + 10));
	endlessBtn->addClickEventListener([&](Ref*)
	{
		auto scene = GamePlayer::createScene(0);
		Director::getInstance()->replaceScene(TransitionFade::create(0.3f, scene, Color3B(0, 0, 0)));
	});
	addChild(endlessBtn);

	auto limitedBtn = Button::create("home_challenge_bt_normal.png", "");
	limitedBtn->setPosition(Vec2(SCREEN_WIDTH / 2 + 200, SCREEN_HEIGHT / 2 + 10));
	limitedBtn->addClickEventListener([&](Ref*)
	{
		auto scene = GamePlayer::createScene(1);
		Director::getInstance()->replaceScene(TransitionFade::create(0.3f, scene, Color3B(0, 0, 0)));
	});
	addChild(limitedBtn);

	/*auto ruleBtn = Button::create("home_role_bt_normal.png", "home_role_bt_press.png");
	ruleBtn->setPosition(Vec2(SCREEN_WIDTH / 2 - 300, 80));
	ruleBtn->addClickEventListener([&](Ref*)
	{
		auto scene = RuleScene::createScene();
		Director::getInstance()->replaceScene(TransitionFade::create(0.3f, scene, Color3B(0, 0, 0)));
	});
	addChild(ruleBtn);

	auto rankBtn = Button::create("home_rank_bt_normal.png", "home_rank_bt_press.png");
	rankBtn->setPosition(Vec2(SCREEN_WIDTH / 2, 80));
	rankBtn->addClickEventListener([&](Ref*)
	{
		auto scene = RankScene::createScene();
		Director::getInstance()->replaceScene(TransitionFade::create(0.3f, scene, Color3B(0, 0, 0)));
	});
	addChild(rankBtn);

	auto skinBtn = Button::create("home_skin_bt_normal.png", "home_skin_bt_press.png");
	skinBtn->setPosition(Vec2(SCREEN_WIDTH / 2 + 300, 80));
	skinBtn->addClickEventListener([&](Ref*)
	{
		auto scene = SkinScene::createScene();
		Director::getInstance()->replaceScene(TransitionFade::create(0.3f, scene, Color3B(0, 0, 0)));
	});
	addChild(skinBtn);*/

	auto settingBtn = Button::create("home_setting_bt_normal.png", "");
	settingBtn->setPosition(Vec2(SCREEN_WIDTH - 80, SCREEN_HEIGHT - 80));
	settingBtn->addClickEventListener([&](Ref*)
	{
		auto view = new SettingView();
		view->show();
		view->release();

	});
	addChild(settingBtn);

	/*auto headIconBG = Sprite::create("head_icon_mask.png");
	headIconBG->setPosition(Vec2(80, SCREEN_HEIGHT - 80));
	addChild(headIconBG);

	auto headIconBtn = Button::create("default_head_icon.png", "default_head_icon.png");
	headIconBtn->setPosition(headIconBG->getPosition());
	headIconBtn->setScale(94.f / headIconBtn->getContentSize().width);
	addChild(headIconBtn, 2);
	headIconBtn->addClickEventListener([&](Ref*)
	{
		auto scene = PlayerScene::createScene();
		Director::getInstance()->replaceScene(TransitionFade::create(0.3f, scene, Color3B(0, 0, 0)));
	});

	auto nameLabel = Label::createWithSystemFont(Player::getInstance()->getNickname(), "Arial", 24);
	nameLabel->setTextColor(Color4B::RED);
	nameLabel->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	nameLabel->setPosition(headIconBtn->getPosition() + Vec2(60, 0));
	addChild(nameLabel, 2);*/

	return true;
}

void MainScene::onEnter()
{
	Layer::onEnter();
}
void MainScene::onExit()
{
	Layer::onExit();
}

void MainScene::update(float delta)
{
	Layer::update(delta);
}