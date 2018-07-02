#pragma once

#include "cocos2d.h"
USING_NS_CC;

#include "GamePlay/GamePlayer.h"

class MakeSnakeScene : public GamePlayer
{
public:
	MakeSnakeScene();

	static Scene * createScene();
	static MakeSnakeScene *create();
	virtual bool init();

	virtual void onEnter() override;
	virtual void onExit() override;
	virtual void update(float delta);

protected:
	void moveCamera(const Vec2 &dir);

	virtual void newSnakeView(Snake *s);

	void newSnakeFromData(const std::vector<Vec2> *data);


protected:
	int _mode;

	Label *_numberLabel;
};
