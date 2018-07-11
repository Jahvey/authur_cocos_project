#include "ResultView.h"
#include "GamePlay/GameDef.h"
#include "MainScene.h"
#include "GamePlay/GamePlayer.h"
#include "audio/include/SimpleAudioEngine.h"
#include "Utils/Player.h"
#include "Utils/HttpUtils.h"
using namespace CocosDenshion;

ResultView::ResultView(int mode) 
: PopView(Size(638, 468), true)
, gameMode(mode)
{
	auto bg = Sprite::create("result_bg.png");
	bg->setAnchorPoint(Vec2(0, 0));
	bg->setPosition(0, 0);
	_contentView->addChild(bg);
	countLabel = Label::create("1000", FONT_NAME, 40);
	countLabel->setAnchorPoint(Vec2::ANCHOR_MIDDLE);
	countLabel->setTextColor(Color4B::RED);
	countLabel->setPosition(340, 290);
	_contentView->addChild(countLabel);

	numLabel = Label::create("100", FONT_NAME, 40);
	numLabel->setAnchorPoint(Vec2::ANCHOR_MIDDLE);
	numLabel->setTextColor(Color4B::RED);
	numLabel->setPosition(340, 190);
	_contentView->addChild(numLabel);

	auto backBtn = Button::create("back_icon_normal.png");
	backBtn->setPosition(Vec2(200, 80));
	backBtn->addClickEventListener([&](Ref*)
	{
		auto scene = MainScene::createScene();
		Director::getInstance()->replaceScene(TransitionFade::create(0.3f, scene, Color3B(0, 0, 0)));
	});
	_contentView->addChild(backBtn);

	auto retartBtn = Button::create("restart_icon.png");
	retartBtn->setPosition(Vec2(450, 80));
	retartBtn->addClickEventListener([&](Ref*)
	{
		auto scene = GamePlayer::createScene(gameMode);
		Director::getInstance()->replaceScene(scene);
	});
	_contentView->addChild(retartBtn);
}

void ResultView::setResult(int lenth, int kill)
{
	char buf[128];

	sprintf(buf, "%d", lenth);
	countLabel->setString(buf);
	sprintf(buf, "%d", kill);
	numLabel->setString(buf);

	////
	int myBestLength = Player::getInstance()->getHighestScore(gameMode, 0);
	if (lenth > myBestLength)
	{
		Player::getInstance()->setHighestScore(gameMode, 0, lenth);
		HttpUtils::sendRequest_uploadScore(gameMode, 0, lenth);
	}

	int myBestKill = Player::getInstance()->getHighestScore(gameMode, 1);
	if (kill > myBestKill)
	{
		Player::getInstance()->setHighestScore(gameMode, 1, kill);
	}
}