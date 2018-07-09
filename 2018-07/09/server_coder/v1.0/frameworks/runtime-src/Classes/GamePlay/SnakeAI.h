#pragma once

#include "cocos2d.h"
USING_NS_CC;

#include "Snake.h"

struct SnakeAIDef
{
	Snake *snake;
	Size mapSize;
};


class SnakeAI
{
public:
	SnakeAI(const SnakeAIDef &def);
	~SnakeAI();

	void update(float dt);

	bool isLive() { return m_snake != nullptr; }

private:
	bool checkNearSnake(float dt);
	bool checkBigFood(float dt);
	bool checkMapBorder(float dt);
	bool randomMove(float dt);

	int getNegativeOne() { return cocos2d::random(0, 100) > 50 ? 1 : -1; }
	int getRandomAngle(int min, int max) { return cocos2d::random(min, max) * getNegativeOne(); }

private:
	Snake *m_snake;

	Vec2  m_moveDir;
	bool  m_bAcc;

	// 随机转向移动
	float m_randomMoveInterval;
	float m_randomMoveElapse;
	
	// 查检地图边缘
	Size  m_mapSize;
	int   m_checkMapState;
	float m_checkMapInterval;
	float m_checkMapElapse;
	Vec2  m_offBoderDir;

	float m_nearSnakeElapse;
	float m_bigFoodElapse;
};

