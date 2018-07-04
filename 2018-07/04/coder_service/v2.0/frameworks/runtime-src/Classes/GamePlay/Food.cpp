
#include "GamePlay/Food.h"
#include "GamePlay/Snake.h"
#include "GamePlay/GameDef.h"

Food::Food()
{
	area.userData = this;
	areaClearFlag = false;

	isLive = true;
	position.set(0, 0);
	color = 1;
	number = 1;
	snake = nullptr;
}

Food::~Food()
{

}

void Food::update(float dt)
{
	if (areaClearFlag) 
	{
		AreaSystem::getInstance()->removeObject(&area);
		areaClearFlag = false;
	}

	if (!isLive || snake == nullptr)
		return;

	if (!snake->isLive())
	{
		snake = nullptr;
		this->isLive = false;
		return;
	}
	else
	{
		moveToSnakePosition(dt);
	}
}

void Food::eatBySnake(Snake *s)
{
	if (snake == nullptr && isLive)
	{
		snake = s;
		snakePosition = s->getFirstBody()->position;
		areaClearFlag = true;
	}
}

void Food::moveToSnakePosition(float dt)
{
	float distance = dt * FOOD_MOVE_SPEED;
	if (position.getDistanceSq(snakePosition) <= (distance * distance))
	{
		position = snakePosition;
		isLive = false;

		snake->ateFood(this);
		snake = nullptr;
	}
	else
	{
		Vec2 v = snakePosition - position;
		v.normalize();
		v *= distance;
		position += v;
	}
}

void Food::setLive(float x, float y, int clr, int num)
{
	isLive = true;
	position.set(x, y);
	color = clr;
	number = num;

	position.set(x, y);

	area.position.set(x, y);
	AreaSystem::getInstance()->addObject(&area);
	areaClearFlag = false;

	snake = nullptr;
	snakePosition.setZero();
}

