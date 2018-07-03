
#pragma once

#include "cocos2d.h"
USING_NS_CC;

#include "GamePlay/AreaSystem.h"

class Snake;

class Food
{
public:
	Food();
	~Food();

	void update(float dt);
	void eatBySnake(Snake *s);
	void moveToSnakePosition(float dt);

	bool isAte() { return snake != nullptr; }

	void setLive(float x, float y, int clr, int num);

public:
	AreaObject area;
	bool areaClearFlag;

	Vec2 position;
	bool isLive;
	int  color;
	int  number;

	Snake *snake;
	Vec2   snakePosition;
};
