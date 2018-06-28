#pragma once

#include "cocos2d.h"
#include "ui/CocosGUI.h"
USING_NS_CC;
using namespace ui;

#include "GamePlay/Snake.h"

class InfoView : public Layer
{
public:
	static InfoView* create();

	virtual bool init() override;
    
	void setMySnakeInfo(Snake *s);
	void setRankInfo(const std::vector<Snake *> &snakes);
	void setTime(float seconds);

private:
	Label *_lengthLabel;
	Label *_killLabel;
	Label *_timeLabel;
	Label *_rankNameLabels[10];
	Label *_rankScoreLabels[10];
	std::vector<Snake *> _tempList;
};
