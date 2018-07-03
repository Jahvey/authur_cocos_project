#include "RankScene.h"
#include "Utils/HttpUtils.h"
#include "Utils/Player.h"
#include "UI/MainScene.h"

#define RANK_CELL_WIDTH		600

Scene* RankScene::createScene()
{
	auto scene = Scene::create();
	auto layer = RankScene::create();
	scene->addChild(layer);
	return scene;
}

bool RankScene::init()
{
	if (!Layer::init()) {
		return false;
	}

	m_gameMode = 0;
	m_rankMode = 0;
	Player::getInstance()->clearRankLists();

	initUI();
	updateRankUI(true);
	
	return true;
}

void RankScene::onEnterTransitionDidFinish()
{
	Layer::onEnterTransitionDidFinish();

	getEventDispatcher()->addCustomEventListener("http_update_rank", [&](EventCustom *evt) {
		int gameMode = 0;
		if (m_gameMode == gameMode) {
			m_tableView->reloadData();
		}
	});

	updateRankUI();
}

void RankScene::onExit()
{
	getEventDispatcher()->removeEventListenersForTarget(this);
	Layer::onExit();
}

void RankScene::initUI()
{
	//ui
	Size winSize = Director::getInstance()->getWinSize();

	auto bg = Sprite::create("home_bg.png");
	bg->setPosition(winSize.width / 2, winSize.height / 2);
	addChild(bg);

	m_btnLimit = Button::create("game_type_icon_endless_normal.png", "game_type_icon_endless_normal.png", "game_type_icon_endless_press.png");
	m_btnLimit->setPosition(Vec2((winSize.width - RANK_CELL_WIDTH) / 4, winSize.height / 2 + 80));
	m_btnLimit->addClickEventListener(CC_CALLBACK_1(RankScene::onButtonClick, this));
	addChild(m_btnLimit);

	m_btnTime = Button::create("game_type_icon_limit_normal.png", "game_type_icon_limit_normal.png", "game_type_icon_limit_press.png");
	m_btnTime->setPosition(Vec2((winSize.width - RANK_CELL_WIDTH) / 4, winSize.height / 2 - 80));
	m_btnTime->addClickEventListener(CC_CALLBACK_1(RankScene::onButtonClick, this));
	addChild(m_btnTime);

	/*
	m_btnLength = Button::create("rank_tab_1.png", "rank_tab_1.png", "rank_tab_2.png");
	m_btnLength->setTitleText("Length");
	m_btnLength->setTitleFontSize(32);
	m_btnLength->setPosition(Vec2(winSize.width / 2 - 128, winSize.height - 100));
	m_btnLength->addClickEventListener(CC_CALLBACK_1(RankScene::onButtonClick, this));
	addChild(m_btnLength);

	m_btnKill = Button::create("rank_tab_1.png", "rank_tab_1.png", "rank_tab_2.png");
	m_btnKill->setTitleText("Kill");
	m_btnKill->setTitleFontSize(32);
	m_btnKill->setPosition(Vec2(winSize.width / 2 + 128, winSize.height - 100));
	m_btnKill->addClickEventListener(CC_CALLBACK_1(RankScene::onButtonClick, this));
	addChild(m_btnKill);
	*/
	auto backBtn = Button::create("back_icon_small.png");
	backBtn->setPosition(Vec2(SCREEN_WIDTH - 60, 60));
	backBtn->addClickEventListener([&](Ref*)
	{
		auto scene = MainScene::createScene();
		Director::getInstance()->replaceScene(TransitionFade::create(0.3f, scene, Color3B(0, 0, 0)));
	});
	addChild(backBtn);

	auto listBG = ui::Scale9Sprite::create("setting_bg.png");
	listBG->setContentSize(Size(RANK_CELL_WIDTH, winSize.height - 300));
	listBG->setAnchorPoint(Vec2::ANCHOR_MIDDLE_TOP);
	listBG->setPosition(winSize.width * 0.5f, winSize.height - 200);
	addChild(listBG);

	m_tableView = TableView::create(this, listBG->getContentSize() - Size(20, 70));
	m_tableView->setDirection(extension::ScrollView::Direction::VERTICAL);
	m_tableView->setVerticalFillOrder(TableView::VerticalFillOrder::TOP_DOWN);
	m_tableView->setPosition(Vec2(10, 10));
	listBG->addChild(m_tableView);

}

void RankScene::onButtonClick(Ref *btn)
{
	if (btn == m_btnLimit && m_gameMode != 0)
	{
		m_gameMode = 0;
		updateRankUI();
	}
	else if (btn == m_btnTime && m_gameMode != 1)
	{
		m_gameMode = 1;
		updateRankUI();
	}
}

void RankScene::updateRankUI(bool onlyUI)
{
	// 更新按钮状态
	m_btnLimit->setBright(m_gameMode == 0);
	m_btnTime->setBright(m_gameMode == 1);

/*	m_btnLength->setBright(m_rankMode == 0);
	m_btnLength->setTitleColor(m_rankMode == 0 ? Color3B::WHITE : Color3B::RED);
	m_btnKill->setBright(m_rankMode == 1);
	m_btnKill->setTitleColor(m_rankMode == 1 ? Color3B::WHITE : Color3B::RED);
*/

	if (onlyUI)
		return;

	// 更新列表
	auto rl = Player::getInstance()->getRankList(m_gameMode);
	if (rl->empty()) {
		HttpUtils::sendRequest_downloadScore(m_gameMode, 0);
	}
	else {
		m_tableView->reloadData();
	}
}

Size RankScene::cellSizeForTable(TableView *table)
{
	return Size(RANK_CELL_WIDTH - 20, 40);
}

ssize_t RankScene::numberOfCellsInTableView(TableView *table)
{
	auto rankList = Player::getInstance()->getRankList(m_gameMode);
	return rankList->size();
}

TableViewCell* RankScene::tableCellAtIndex(TableView *table, ssize_t idx)
{
	RankTableCell *cell = (RankTableCell *)table->dequeueCell();
	if (cell == nullptr) {
		cell = RankTableCell::create();
	}

	auto rankList = Player::getInstance()->getRankList(m_gameMode);
	cell->setInfo(idx, rankList->at(idx));

	return cell;
}

/////////////////////


RankTableCell* RankTableCell::create()
{
	RankTableCell* widget = new (std::nothrow) RankTableCell();
	if (widget && widget->init())
	{
		widget->autorelease();
		return widget;
	}
	CC_SAFE_DELETE(widget);
	return nullptr;
}

bool RankTableCell::init()
{
	if (!TableViewCell::init())
		return false;

	Size size(RANK_CELL_WIDTH - 20, 40);
	setContentSize(size);

	m_idxLabel = Label::createWithSystemFont("", "Airal", 18);
	m_idxLabel->setTextColor(Color4B::GRAY);
	m_idxLabel->setPosition(40, size.height / 2);
	addChild(m_idxLabel);

	m_headIcon = ImageView::create("default_head_icon.png");
	m_headIcon->setScale(30 / m_headIcon->getContentSize().height);
	m_headIcon->setPosition(Vec2(100, size.height / 2));
	addChild(m_headIcon);

	m_nameLabel = Label::createWithSystemFont("", "Airal", 18);
	m_nameLabel->setTextColor(Color4B::GRAY);
	m_nameLabel->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	m_nameLabel->setPosition(200, size.height / 2);
	addChild(m_nameLabel);

	m_valueLabel = Label::createWithSystemFont("", "Airal", 18);
	m_valueLabel->setTextColor(Color4B::GRAY);
	m_valueLabel->setPosition(500, size.height / 2);
	addChild(m_valueLabel);

	return true;
}


void RankTableCell::setInfo(int idx, const _RANKITEM &rd)
{
	char buf[32];
	
	//itoa(idx + 1, buf, 10);
	m_idxLabel->setString(buf);

	m_nameLabel->setString(rd.nickname);

	//itoa(rd.score, buf, 10);
	m_valueLabel->setString(buf);
}

