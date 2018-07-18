#pragma once;

#include "cocos2d.h"
USING_NS_CC;

#include "GamePlay/AreaSystem.h"

class Food;

class Snake
{
public:
	struct Body
	{
		Vec2   position;
		float  angle;
	};

public:
	Snake(int tag, int skin);
	~Snake();

	void init(float x, float y, int length = 0);
	void init(const std::vector<Vec2> *data);
	void initWithPlace(const Vec2 &pos, const Vec2 &dir);
	
	void move();
	void detech();
	void detech(std::vector<Snake *> &snakes);
	void detech(const Size &mapSize);
	void detech(std::vector<Food *> &foods);
	void clear();
	void update();

	void addBody(const Vec2 &pos);
	void addBody(const Vec2 &pos, float angle);

	const Body *getFirstBody();
	const Body *getNextBody();

	void ateFood(Food *f);

	void setDir(const Vec2 &dir);
	void setAccelerate(bool bAcc) { m_isAcc = bAcc; }
	
	bool isLive() { return m_isLive; }
	void setLive(bool bLive) { m_isLive = bLive; }

	const Vec2 &getDir() { return m_dir; }
	float getRadius() { return m_radius; }
	int getLength() { return m_length; }
	int getKill() { return m_kill; }
	int getSkin() { return m_skin; }

	void setAccConsumed(const Vec2 &pos) { 
		m_bAccConsumed = true;
		m_accConsumedPosition = pos; 
	}
	void clearAccConsumed() { m_bAccConsumed = false; }
	bool hasAccConsumed() { return m_bAccConsumed; }
	const Vec2 &getAccConsumed() { return m_accConsumedPosition; }

	bool isPlayer() { return m_isPlayer; }

public:
	bool m_isPlayer;
	bool m_isLive;
	int  m_tag;
	int  m_skin;
	int  m_length;
	int  m_kill;
	bool m_disappear;

	std::vector<Body *> m_bodyList;
	int m_headIndex;

	Vec2  m_dir;
	bool  m_isAcc;
	float m_radius;
	int   m_accMoveCount;

	unsigned int m_iterCount;
	unsigned int m_iterIndex;

	bool m_bAccConsumed;
	Vec2 m_accConsumedPosition;

public:
	std::string name;

	Vec2 bl;
	Vec2 rt;
	void updateAABB();
	bool checkAABB(const Snake *other);

	// 一些AI用到的信息	
public:
	Snake *nearSnake;
	Vec2   nearSnakeBodyXY;
	int    bigFoodCount;
	Vec2   bigFoodXY;
};


///////////////////////////////////////////

class SnakePhysicsComponent
{
public:
	SnakePhysicsComponent(const Size &mapSize);
	~SnakePhysicsComponent() {}

	void update(Snake &snake, std::vector<Snake *> &otherSnakes);

protected:
	void updateAABB(Snake &snake);
	bool checkAABB(Snake *other);

	void move(Snake &snake);
	void detechCollision(Snake &snake);
	void detechCollision(Snake &snake, std::vector<Snake *> &otherSnakes);
	void detechCollision(Snake &snake, AreaSystem *foods);

	void onCollision(Snake *snake, Snake *other);

protected:
	Size m_mapSize;
	bool m_aabbDirtyFlag;
	Vec2 m_lb;
	Vec2 m_rt;
};
