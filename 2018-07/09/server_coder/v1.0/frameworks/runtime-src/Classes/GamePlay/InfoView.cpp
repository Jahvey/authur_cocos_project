#include "InfoView.h"

#define TOUCHPAD_RADIUS		74
#define STICK_RADIUS		30
#define STICK_MOVE_RADIUS	(TOUCHPAD_RADIUS - STICK_RADIUS)

InfoView* InfoView::create()
{
	auto view = new InfoView();
	view->init();
	view->autorelease();
	return view;
}

bool InfoView::init()
{
	if (!Layer::init())
		return false;

	auto winSize = Director::getInstance()->getWinSize();

	_lengthLabel = Label::createWithSystemFont("Length: 0", "Arial", 20);
	_lengthLabel->setTextColor(Color4B::WHITE);
	_lengthLabel->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	_lengthLabel->setPosition(10, winSize.height - 30);
	addChild(_lengthLabel);

	_killLabel = Label::createWithSystemFont("Kill: 0", "Arial", 20);
	_killLabel->setTextColor(Color4B::WHITE);
	_killLabel->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	_killLabel->setPosition(10, winSize.height - 60);
	addChild(_killLabel);

	////
	_timeLabel = Label::createWithSystemFont("", "Arial", 36);
	_timeLabel->setTextColor(Color4B::WHITE);
	_timeLabel->setPosition(winSize.width * 0.5f, winSize.height - 30);
	_timeLabel->setVisible(false);
	addChild(_timeLabel);

	/////

	auto bg = Scale9Sprite::create("bg_2.png");
	bg->setContentSize(Size(250, 40));
	bg->setAnchorPoint(Vec2::ANCHOR_TOP_RIGHT);
	bg->setPosition(winSize.width - 20, winSize.height - 50);
	addChild(bg);

	auto label = Label::createWithSystemFont("Rank", "Arial", 20);
	label->setTextColor(Color4B::GRAY);
	label->setPosition(125, 20);
	bg->addChild(label);

	bg = Scale9Sprite::create("bg_2.png");
	bg->setContentSize(Size(250, 250));
	bg->setAnchorPoint(Vec2::ANCHOR_TOP_RIGHT);
	bg->setPosition(winSize.width - 20, winSize.height - 150);
	addChild(bg);

	char buf[32];
	float y = bg->getContentSize().height - 20;
	for (int i = 0; i < 10; i++)
	{
		sprintf(buf, "%d", i + 1);

		label = Label::createWithSystemFont(buf, "Arial", 20);
		label->setTextColor(Color4B::GRAY);
		label->setPosition(20, y);
		bg->addChild(label);

		_rankNameLabels[i] = Label::createWithSystemFont("Rank", "Arial", 20);
		_rankNameLabels[i]->setTextColor(Color4B::GRAY);
		_rankNameLabels[i]->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
		_rankNameLabels[i]->setPosition(50, y);
		bg->addChild(_rankNameLabels[i]);

		_rankScoreLabels[i] = Label::createWithSystemFont("10", "Arial", 20);
		_rankScoreLabels[i]->setTextColor(Color4B::GRAY);
		_rankScoreLabels[i]->setAnchorPoint(Vec2::ANCHOR_MIDDLE_RIGHT);
		_rankScoreLabels[i]->setPosition(230, y);
		bg->addChild(_rankScoreLabels[i]);

		y -= 23;
	}

	return true;
}

void InfoView::setMySnakeInfo(Snake *s)
{
	char buf[128];

	sprintf(buf, "Length: %d", s->getLength());
	_lengthLabel->setString(buf);

	sprintf(buf, "Kill: %d", s->getKill());
	_killLabel->setString(buf);
}

void InfoView::setRankInfo(const std::vector<Snake *> &snakes)
{
	_tempList.clear();
	_tempList = snakes;

	std::sort(_tempList.begin(), _tempList.end(), [](Snake *s1, Snake *s2) {
		return s1->getLength() > s2->getLength();
	});

	char buf[32];
	for (int i = 0; i < 10 && i < _tempList.size(); i++)
	{
		if (i < _tempList.size())
		{
			auto s = _tempList[i];
			_rankNameLabels[i]->setString(s->name);
			sprintf(buf, "%d", s->getLength());
			_rankScoreLabels[i]->setString(buf);
			if (s->isPlayer())
			{
				_rankNameLabels[i]->setTextColor(Color4B::RED);
				_rankScoreLabels[i]->setTextColor(Color4B::RED);
			}
			else
			{
				_rankNameLabels[i]->setTextColor(Color4B::GRAY);
				_rankScoreLabels[i]->setTextColor(Color4B::GRAY);
			}
		}
		else
		{
			_rankNameLabels[i]->setString("");
			_rankScoreLabels[i]->setString("");
		}
	}
}

void InfoView::setTime(float seconds)
{
	seconds = fmax(seconds, 0);

	int min = (int)seconds / 60;
	int sec = (int)seconds % 60;

	char buf[32];
	sprintf(buf, "%02d:%02d", min, sec);
	_timeLabel->setString(buf);
	_timeLabel->setVisible(true);
}
