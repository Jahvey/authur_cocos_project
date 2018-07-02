
#include "SnakeAI.h"


SnakeAI::SnakeAI(const SnakeAIDef &def)
{
	m_snake = def.snake;

	m_randomMoveInterval = cocos2d::random(0.5f, 1.5f);
	m_randomMoveElapse = 0;

	m_mapSize = def.mapSize;
	m_checkMapState = 0;
	m_checkMapInterval = cocos2d::random(0.2f, 0.5f);
	m_checkMapElapse = 0;

	m_nearSnakeElapse = 0;
	m_bigFoodElapse = 0;
}

SnakeAI::~SnakeAI()
{
	m_snake = nullptr;
}

void SnakeAI::update(float dt)
{
	if (m_snake == nullptr)
		return;

	if (!m_snake->isLive()) {
		m_snake = nullptr;
		return;
	}

	bool bForce = false;
	m_bAcc = false;

	if (!bForce) {
		bForce = checkNearSnake(dt);
	}

	if (!bForce) {
		bForce = checkBigFood(dt);
	}

	if (!bForce) {
		bForce = checkMapBorder(dt);
	}

	if (!bForce) {
		bForce = randomMove(dt);
	}

	m_snake->setDir(m_moveDir);
	m_snake->setAccelerate(m_bAcc);
}

bool SnakeAI::checkNearSnake(float dt)
{
	if (m_snake->nearSnake != nullptr && m_nearSnakeElapse <= 0)
	{
		auto &headXY = m_snake->getFirstBody()->position;
		m_moveDir = m_snake->nearSnakeBodyXY - headXY;
		m_moveDir.negate();

		m_nearSnakeElapse = 0.2f;

		return true;
	}

	if (m_nearSnakeElapse > 0)
	{
		m_nearSnakeElapse -= dt;
		return true;
	}
	
	return false;
}

bool SnakeAI::checkBigFood(float dt)
{
	if (m_snake->bigFoodCount > 1)
	{
		m_bAcc = true;
		m_moveDir = m_snake->bigFoodXY - m_snake->getFirstBody()->position;

		m_bigFoodElapse = 3;

		return true;
	}

	if (m_bigFoodElapse > 0)
	{
		m_bigFoodElapse--;
		m_bAcc = true;
		return true;
	}

	return false;
}

bool SnakeAI::checkMapBorder(float dt)
{
	if (m_checkMapState == 0)
	{
		int radius = cocos2d::random(50, 80);
		auto &headXY = m_snake->getFirstBody()->position;
		
		Vec2 axis(0, 0);
		if (headXY.x <= radius || headXY.x >= (m_mapSize.width - radius))
			axis.set(0, 1);
		else if (headXY.y <= radius || headXY.y >= (m_mapSize.height - radius))
			axis.set(1, 0);

		if (!axis.isZero())
		{
			float angle = axis.getAngle(m_snake->getDir());
			m_moveDir = axis.rotateByAngle(Vec2::ZERO, -angle);
			m_offBoderDir = m_moveDir;

			m_checkMapState = 1;
			m_checkMapElapse = 0;
		}
	}
	else if (m_checkMapState == 1)
	{
#if 0
		m_checkMapElapse += dt;
		if (m_checkMapElapse >= m_checkMapInterval)
		{
			m_checkMapState = 0;
		}
#else
		if (m_moveDir == m_offBoderDir)
		{
			if (m_snake->getDir() == m_offBoderDir)
			{
				m_checkMapState = 0;
			}
		}
		else
		{
			m_checkMapState = 0;
		}
#endif
	}
	
	return m_checkMapState == 1;
}

bool SnakeAI::randomMove(float dt)
{
	m_randomMoveElapse += dt;
	
	if (m_randomMoveElapse >= m_randomMoveInterval)
	{
		m_randomMoveElapse -= m_randomMoveInterval;
#if 1
		int angle = cocos2d::random(0, 360);
		m_moveDir.set(1, 0);
		m_moveDir = m_moveDir.rotateByAngle(Vec2::ZERO, CC_DEGREES_TO_RADIANS(angle));
#else
		m_moveDir.rotate(Vec2::ZERO, CC_DEGREES_TO_RADIANS(cocos2d::rand_minus1_1() * cocos2d::random(30, 120)));
#endif
		return true;
	}

	return false;
}

