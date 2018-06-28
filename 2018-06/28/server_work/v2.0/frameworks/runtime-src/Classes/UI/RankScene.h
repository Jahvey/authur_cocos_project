#pragma once

#include "cocos2d.h"
#include "ui/CocosGUI.h"
#include "cocos-ext.h"

USING_NS_CC;
USING_NS_CC_EXT;
using namespace ui;

#include "Utils/Player.h"

class RankScene : public Layer, public TableViewDataSource
{
public:
	static Scene* createScene();
	virtual bool init();
	CREATE_FUNC(RankScene);

	virtual void onEnterTransitionDidFinish() override;
	virtual void onExit() override;

public:
	void onButtonClick(Ref *btn);

	virtual Size cellSizeForTable(TableView *table);
	TableViewCell* tableCellAtIndex(TableView *table, ssize_t idx);
	virtual ssize_t numberOfCellsInTableView(TableView *table);

private:
	void initUI();
	void updateRankUI(bool onlyUI = false);

private:
	int m_gameMode;
	int m_rankMode;

	Button *m_btnLimit;
	Button *m_btnTime;
//	Button *m_btnLength;
//	Button *m_btnKill;

	TableView *m_tableView;
};

class RankTableCell : public TableViewCell
{
public:
	static RankTableCell *create();

	virtual bool init() override;

	void setInfo(int idx, const _RANKITEM &rd);

private:
	Label *m_idxLabel;
	ImageView *m_headIcon;
	Label *m_nameLabel;
	Label *m_valueLabel;
};