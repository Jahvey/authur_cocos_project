#include "PlayerScene.h"
#include "MainScene.h"
#include "GamePlay/GameDef.h"
#include "Utils/Player.h"
#include "Utils/HttpUtils.h"

Scene *PlayerScene::createScene()
{
	auto view = new PlayerScene;
	view->init();
	
	auto scene = Scene::create();
	scene->addChild(view);
	view->release();

	return scene;
}

bool PlayerScene::init()
{
	if (!Layer::init())
		return false;

	initUI();

	return true;
}

void PlayerScene::initUI()
{
	auto background = Sprite::create("home_bg.png");
	background->setPosition(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
	addChild(background);

	// 返回按钮
	auto backButton = Button::create("back_icon_small.png");
	backButton->setPosition(Vec2(SCREEN_WIDTH - 60, 60));
	backButton->addClickEventListener([&](Ref*)
	{
		auto scene = MainScene::createScene();
		Director::getInstance()->replaceScene(TransitionFade::create(0.3f, scene, Color3B(0, 0, 0)));
	});
	addChild(backButton);

	// 人物信息
	Size size(400, 500);

	auto bg = ui::Scale9Sprite::create("setting_bg.png");
	bg->setContentSize(size);
	bg->setPosition(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
	addChild(bg, 2);


	//head
	auto headIconBG = Sprite::create("head_icon_mask.png");
	headIconBG->setPosition(Vec2(80, size.height - 80));
	bg->addChild(headIconBG);

	auto headIconBtn = Button::create("default_head_icon.png", "default_head_icon.png");
	headIconBtn->setPosition(headIconBG->getPosition());
	headIconBtn->setScale(94.f / headIconBtn->getContentSize().width);
	bg->addChild(headIconBtn, 2);
	headIconBtn->addClickEventListener([&](Ref*)
	{
	//	auto view = PlayerScene::create();
	//	view->show();
	});

	auto nameLabel = Label::createWithSystemFont(Player::getInstance()->getNickname(), "Arial", 24);
	nameLabel->setTextColor(Color4B::RED);
	nameLabel->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	nameLabel->setPosition(headIconBtn->getPosition() + Vec2(60, 0));
	bg->addChild(nameLabel, 2);


	auto editNameButton = Button::create("btn_edit.png");
	editNameButton->setPosition(Vec2(size.width - 60, size.height - 80));
	bg->addChild(editNameButton);
	editNameButton->addClickEventListener([nameLabel](Ref*)
	{
		auto view = new EditNicknameView;
		view->init();
		view->show();
		view->release();

		view->renameCallback = [nameLabel](const std::string &name) {
			nameLabel->setString(name);
		};
	});
	
	char buf[32];
	auto player = Player::getInstance();

	// 无限模式

	Label *label = Label::createWithTTF("Unlimit mode:", FONT_NAME, 20);
	label->setTextColor(Color4B::ORANGE);
	label->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	label->setPosition(20, size.height - 200);
	bg->addChild(label);

	label = Label::createWithTTF("Length:", "fonts/Marker Felt.ttf", 18);
	label->setTextColor(Color4B::BLUE);
	label->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	label->setPosition(40, size.height - 230);
	bg->addChild(label);

	sprintf(buf, "%d", player->getHighestScore(0, 0));
	label = Label::createWithTTF(buf, "fonts/Marker Felt.ttf", 18);
	label->setTextColor(Color4B::GRAY);
	label->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	label->setPosition(240, size.height - 230);
	bg->addChild(label);

	label = Label::createWithTTF("Kill:", "fonts/Marker Felt.ttf", 18);
	label->setTextColor(Color4B::BLUE);
	label->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	label->setPosition(40, size.height - 250);
	bg->addChild(label);

	sprintf(buf, "%d", player->getHighestScore(0, 1));
	label = Label::createWithTTF(buf, "fonts/Marker Felt.ttf", 18);
	label->setTextColor(Color4B::GRAY);
	label->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	label->setPosition(240, size.height - 250);
	bg->addChild(label);

	// 限时模式
	label = Label::createWithTTF("Limit mode:", FONT_NAME, 20);
	label->setTextColor(Color4B::ORANGE);
	label->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	label->setPosition(20, size.height - 300);
	bg->addChild(label);

	label = Label::createWithTTF("Length:", "fonts/Marker Felt.ttf", 18);
	label->setTextColor(Color4B::BLUE);
	label->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	label->setPosition(40, size.height - 330);
	bg->addChild(label);

	sprintf(buf, "%d", player->getHighestScore(1, 0));
	label = Label::createWithTTF(buf, "fonts/Marker Felt.ttf", 18);
	label->setTextColor(Color4B::GRAY);
	label->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	label->setPosition(240, size.height - 330);
	bg->addChild(label);

	label = Label::createWithTTF("Kill:", "fonts/Marker Felt.ttf", 18);
	label->setTextColor(Color4B::BLUE);
	label->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	label->setPosition(40, size.height - 350);
	bg->addChild(label);

	sprintf(buf, "%d", player->getHighestScore(1, 1));
	label = Label::createWithTTF(buf, "fonts/Marker Felt.ttf", 18);
	label->setTextColor(Color4B::GRAY);
	label->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	label->setPosition(240, size.height - 350);
	bg->addChild(label);
}


//////////////////////////////////


EditNicknameView::EditNicknameView()
: PopView(Size(400, 300))
, renameCallback(nullptr)
{

}

bool EditNicknameView::init()
{
	PopView::init();

	initUI();

	return true;
}

void EditNicknameView::initUI()
{
	setAutoDismiss();
	auto &size = _contentView->getContentSize();

	auto bg = ui::Scale9Sprite::create("setting_bg.png");
	bg->setContentSize(size);
	bg->setAnchorPoint(Vec2::ANCHOR_BOTTOM_LEFT);
	_contentView->addChild(bg);

	auto editBox = ui::EditBox::create(Size(200, 30), "bg_2.png");
//	editBox->setText(Player::getInstance()->getNickname().c_str());
	editBox->setFontSize(20);
	editBox->setPlaceHolder("Please enter nickname.");
	editBox->setPlaceholderFontSize(20);
	editBox->setMaxLength(32);
	editBox->setPosition(Vec2(size.width / 2, size.height - 100));
	bg->addChild(editBox);

	auto btnOK = Button::create("gold_bg.png");
	btnOK->setTitleText("OK");
	btnOK->setTitleFontSize(20);
	btnOK->setPosition(Vec2(size.width / 2, 30));
	bg->addChild(btnOK);

	btnOK->addClickEventListener([&,editBox](Ref *ref) {
		std::string name = editBox->getText();
		if (!name.empty())
		{
			HttpUtils::sendRequest_changeNickname(name.c_str());
			Player::getInstance()->setNickname(name.c_str());
			if (renameCallback != nullptr) {
				renameCallback(name);
			}
			dismiss();
		}
	});
}
