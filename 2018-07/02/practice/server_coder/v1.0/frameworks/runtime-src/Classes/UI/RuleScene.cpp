#include "RuleScene.h"
#include "GamePlay/GameDef.h"
#include "MainScene.h"

Scene* RuleScene::createScene()
{
	auto scene = Scene::create();

	auto layer = RuleScene::create();

	scene->addChild(layer);

	return scene;
}

bool RuleScene::init()
{
	if (!Layer::init())
	{
		return false;
	}

	auto pageView = PageView::create();
	pageView->setContentSize(Size(1334, 750));
	pageView->addPage(ImageView::create("guide_1.png"));
	pageView->addPage(ImageView::create("guide_2.png"));
	pageView->addPage(ImageView::create("guide_3.png"));
	pageView->setAnchorPoint(Vec2(0.5, 0.5));
	pageView->setPosition(Vec2(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2));
	addChild(pageView);

	auto backBtn = Button::create("back_icon_small.png");
	backBtn->setPosition(Vec2(SCREEN_WIDTH - 60, 60));
	backBtn->addClickEventListener([&](Ref*)
	{
		auto scene = MainScene::createScene();
		Director::getInstance()->replaceScene(TransitionFade::create(0.3f, scene, Color3B(0, 0, 0)));
	});
	addChild(backBtn);

	return true;
}