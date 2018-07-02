#include "SettingView.h"
#include "GamePlay/GameDef.h"
#include "audio/include/SimpleAudioEngine.h"
using namespace CocosDenshion;

SettingView::SettingView() :PopView(Size(874, 492), true)
{
	_contentView->setClippingEnabled(false);

	auto bg = Sprite::create("setting_bg.png");
	bg->setAnchorPoint(Vec2(0, 0));
	bg->setPosition(0, 0);
	_contentView->addChild(bg);

	auto musicBtn = CheckBox::create("unchoose_icon.png", "choose_icon.png");
	musicBtn->setPosition(Vec2(70, 300));
	musicBtn->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	musicBtn->addEventListener([&](Ref*, CheckBox::EventType type)
	{
		if (type == CheckBox::EventType::SELECTED)
		{
			SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
			UserDefault::getInstance()->setBoolForKey(SETTING_MUSIC, true);
		}
		else
		{
			SimpleAudioEngine::getInstance()->stopBackgroundMusic();
			UserDefault::getInstance()->setBoolForKey(SETTING_MUSIC, false);
		}
	});
	_contentView->addChild(musicBtn);

	auto effectBtn = CheckBox::create("unchoose_icon.png", "choose_icon.png");
	effectBtn->setPosition(Vec2(70, 185));
	effectBtn->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	effectBtn->addEventListener([&](Ref*, CheckBox::EventType type)
	{
		if (type == CheckBox::EventType::SELECTED)
		{
			SimpleAudioEngine::getInstance()->setEffectsVolume(1);
			UserDefault::getInstance()->setBoolForKey(SETTING_EFFECT, true);
		}
		else
		{
			SimpleAudioEngine::getInstance()->setEffectsVolume(0);
			UserDefault::getInstance()->setBoolForKey(SETTING_EFFECT, false);
		}
	});
	_contentView->addChild(effectBtn);

	leftBtn = CheckBox::create("unchoose_icon.png", "choose_icon.png");
	leftBtn->setPosition(Vec2(480, 300));
	leftBtn->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	leftBtn->addEventListener([&](Ref*, CheckBox::EventType type)
	{
		if (type == CheckBox::EventType::SELECTED)
		{
			imageView->loadTexture("operate_left_show_image.png");
			rightBtn->setSelected(false);
			UserDefault::getInstance()->setBoolForKey(SETTING_OPERATION, true);
		}
		else
		{
			leftBtn->setSelected(true);
		}
	});
	_contentView->addChild(leftBtn);

	rightBtn = CheckBox::create("unchoose_icon.png", "choose_icon.png");
	rightBtn->setPosition(Vec2(680, 300));
	rightBtn->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	rightBtn->addEventListener([&](Ref*, CheckBox::EventType type)
	{
		if (type == CheckBox::EventType::SELECTED)
		{
			imageView->loadTexture("operate_right_show_image.png");
			leftBtn->setSelected(false);
			UserDefault::getInstance()->setBoolForKey(SETTING_OPERATION, false);
		}
		else
		{
			rightBtn->setSelected(true);
		}
	});
	_contentView->addChild(rightBtn);

	imageView = ImageView::create("operate_left_show_image.png");
	imageView->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	imageView->setPosition(Vec2(520,140));
	_contentView->addChild(imageView);

	auto closeBtn = Button::create("share_gain_close_icon.png");
	closeBtn->setPosition(Vec2(860, 460));
	closeBtn->addClickEventListener([&](Ref*)
	{
		dismiss();

	});
	_contentView->addChild(closeBtn);

	if (UserDefault::getInstance()->getBoolForKey(SETTING_MUSIC))
	{
		musicBtn->setSelected(true);
	}

	if (UserDefault::getInstance()->getBoolForKey(SETTING_EFFECT))
	{
		effectBtn->setSelected(true);
	}

	if (UserDefault::getInstance()->getBoolForKey(SETTING_OPERATION))
	{
		imageView->loadTexture("operate_left_show_image.png");
		leftBtn->setSelected(true);
	}
	else
	{
		imageView->loadTexture("operate_right_show_image.png");
		rightBtn->setSelected(true);
	}
}