#include "SkinScene.h"
#include "GamePlay/GameDef.h"
#include "MainScene.h"
#include "Utils/GameData.h"
#include "Utils/Player.h"

Scene* SkinScene::createScene()
{
	auto scene = Scene::create();

	auto layer = SkinScene::create();

	scene->addChild(layer);

	return scene;
}

bool SkinScene::init()
{
	if (!Layer::init())
	{
		return false;
	}
	selectItem = nullptr;

	auto bg = Sprite::create("home_bg.png");
	bg->setPosition(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
	addChild(bg);

	auto skinLabel = Label::create("Skin", FONT_NAME, 30);
	skinLabel->setTextColor(Color4B::RED);
	skinLabel->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	skinLabel->setPosition(20, 580);
	addChild(skinLabel);

	auto iconBg = Scale9Sprite::create("gold_bg.png");
	iconBg->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	iconBg->setContentSize(Size(150, 34));
	iconBg->setPosition(120, 584);
	addChild(iconBg);

	auto icon = Sprite::create("skin_coin_icon.png");
	icon->setPosition(150,584);
	addChild(icon);

	auto countLabel = Label::create("1000", FONT_NAME, 20);
	countLabel->setTextColor(Color4B::RED);
	countLabel->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	countLabel->setPosition(180, 580);
	addChild(countLabel);

	auto scrollView = ScrollView::create();
	scrollView->setContentSize(Size(970, 440));
	scrollView->setAnchorPoint(Vec2(0.5, 0.5));
	scrollView->setScrollBarEnabled(false);
	scrollView->setBounceEnabled(true);
	scrollView->setPosition(Vec2(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2));
	addChild(scrollView);

	int count = SnakeSkinData::getSkins().size();
	int height = MAX(440, 300 * ((count + 4) / 5));

	int x = 0, y = 0;
	for (size_t i = 0; i < count; i++)
	{
		x = (i % 5) * 200;
		y = height - (i / 5 + 0.5) * 300;
		auto item = SkinItem::create();
		item->initWithSkin(SnakeSkinData::getSkin(i));
		item->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
		item->setPosition(Vec2(x, y));
		item->setTag(i);
		item->addClickEventListener([&](Ref* obj)
		{
			if (selectItem)
			{
				selectItem->setSelected(false);
			}
			selectItem = static_cast<SkinItem*>(obj);
			selectItem->setSelected(true);

			Player::getInstance()->setUsingSkin(selectItem->getTag());
		});
		scrollView->addChild(item);

		if (i == Player::getInstance()->getUsingSkin())
		{
			selectItem = item;
			selectItem->setSelected(true);
		}
	}
	scrollView->setInnerContainerSize(Size(200 * 5, height));

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