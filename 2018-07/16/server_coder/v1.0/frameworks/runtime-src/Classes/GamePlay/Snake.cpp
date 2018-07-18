#include "GamePlay/Snake.h"
#include "GamePlay/GameDef.h"
#include "GamePlay/Food.h"

Snake::Snake(int tag, int skin)
{
	m_isPlayer = false;
	m_tag = tag;
	m_isLive = true;
	m_skin = skin;
	m_length = 0;
	m_kill = 0;
	m_disappear = false;

	m_headIndex = 0;

	m_dir.set(1, 0);
	m_isAcc = false;
	m_accMoveCount = 0;
	
	m_radius = SNAKE_MIN_RADIUS;

	// AIœ‡πÿ
	nearSnake = nullptr;
	bigFoodCount = 0;

	int id = cocos2d::random(1, 10000);
	char buf[64];
	sprintf(buf, "Guest%4d", id);
	name = buf;
}

Snake::~Snake()
{
	for (auto it = m_bodyList.begin(); it != m_bodyList.end(); it++)
	{
		delete (*it);
	}
}

void Snake::clear()
{
}

void Snake::init(float x, float y, int length)
{
	float angle = cocos2d::random(0, 360);
	m_dir.rotate(Vec2::ZERO, CC_DEGREES_TO_RADIANS(angle));

	Vec2 position(x, y);
	Vec2 dir = m_dir;
	dir.negate();
	m_headIndex = 0;
	if (length == 0) {
		length = cocos2d::random(31, 310);
	}
	for (int i = 0; i < length; i++)
	{
		addBody(position, angle);

		dir.rotate(Vec2::ZERO, CC_DEGREES_TO_RADIANS(cocos2d::rand_minus1_1() * 8));
		dir.normalize();
		position += dir * SNAKE_PATH_PIXEL;

		angle = dir.getAngle() + 180;
		angle = angle >= 360 ? angle - 360 : angle;
	}

	m_kill = 0;
	m_length = length;

	updateAABB();
}

void Snake::initWithPlace(const Vec2 &pos, const Vec2 &dir)
{
	setDir(dir);

	m_headIndex = 0;
	for (int i = 0; i < SNAKE_MIN_LENGTH; i++)
	{
		addBody(pos);
	}

	m_kill = 0;
	m_length = SNAKE_MIN_LENGTH;

	updateAABB();
}

void Snake::init(const std::vector<Vec2> *data)
{
	if (data->empty())
		return;

	m_headIndex = 0;

	auto it = data->begin();
	m_dir = *it;

	Vec2 position(-1, 0);
	float angle = CC_RADIANS_TO_DEGREES(m_dir.getAngle());
	while (++it != data->end())
	{
		if (position.x == -1)
		{
			addBody(*it, angle);
		}	
		else
		{
			angle = (position - *it).getAngle();
			addBody(*it, CC_RADIANS_TO_DEGREES(angle));
		}
		position = *it;
	}

	m_kill = 0;
	m_length = data->size();

	updateAABB();
}

void Snake::setDir(const Vec2 &dir)
{
	float angle = m_dir.getAngle(dir);
	angle = CC_RADIANS_TO_DEGREES(angle);
	if (angle < 0) {
		angle = fmax(angle, -8);
	} else if (angle > 0) {
		angle = fmin(angle, 8);
	}

	if (angle != 0)
	{
		m_dir = m_dir.rotateByAngle(Vec2::ZERO, CC_DEGREES_TO_RADIANS(angle));
		m_dir.normalize();
	}
}

void Snake::update()
{
	m_radius = SNAKE_MIN_RADIUS + m_length * SNAKE_INC_RADIUS;
	m_radius = fmin(m_radius, SNAKE_MAX_RADIUS);
}

void Snake::move()
{
	if (!isLive())
		return;

	Vec2 velocity = m_dir * SNAKE_PATH_PIXEL;
	Vec2 nextPosition = m_bodyList[m_headIndex]->position;

	int moveCount = m_isAcc ? 2 : 1;
	if (m_bodyList.size() <= SNAKE_MIN_LENGTH) {
		moveCount = 1;
	}

	for (int i = 0; i < moveCount; i++)
	{
		m_headIndex -= 1;
		if (m_headIndex < 0) {
			m_headIndex = m_bodyList.size() - 1;
		}

		nextPosition += velocity;

		m_bodyList[m_headIndex]->position = nextPosition;
		m_bodyList[m_headIndex]->angle = CC_RADIANS_TO_DEGREES(m_dir.getAngle());
	}

	clearAccConsumed();
	if (moveCount > 1)
	{
		m_accMoveCount++;
		if (m_accMoveCount > SNAKE_ACC_CONSUMED)
		{
			m_accMoveCount = 0;
			m_length--;

			int tailIndex = m_headIndex - 1;
			if (tailIndex < 0) {
				tailIndex = m_bodyList.size() - 1;
			}
			auto tail = m_bodyList[tailIndex];

			setAccConsumed(tail->position);

			if (m_length < m_bodyList.size())
			{
				m_bodyList.erase(m_bodyList.begin() + tailIndex);
				if (m_headIndex > tailIndex) {
					m_headIndex--;
				}

				delete tail;
			}
		}
	}

	updateAABB();
}

void Snake::detech()
{
	if (!isLive())
		return;

	bigFoodCount = 0;

	auto head = getFirstBody();
	AreaSystem::getInstance()->queryCollisions(head->position, m_radius * 2, [&](AreaObject *obj)
	{
		Food *f = (Food *)obj->userData;
		f->eatBySnake(this);

		if (f->number > 1)
		{
			bigFoodCount++;
			bigFoodXY = f->position;
		}

		return true;
	});
}

void Snake::detech(std::vector<Food *> &foods)
{
	if (!isLive())
		return;

	bigFoodCount = 0;

	auto head = getFirstBody();

	for (auto it = foods.begin(); it != foods.end(); it++)
	{
		auto food = *it;

		if (!food->isLive || food->isAte())
			continue;

		float disSQ = m_radius * m_radius;
		if (head->position.distanceSquared(food->position) <= disSQ)
		{
			food->eatBySnake(this);

			if (food->number > 1)
			{
				bigFoodCount++;
				bigFoodXY = food->position;
			}
		}
	}
}

void Snake::detech(std::vector<Snake *> &snakes)
{
	nearSnake = nullptr;
	float lastDis = 100000;

	if (!isLive())
		return;

	auto head = getFirstBody();
	for (auto it = snakes.begin(); it != snakes.end(); it++)
	{
		auto other = *it;
		if (other == this || !other->isLive())
			continue;

		if (!checkAABB(other))
			continue;

		auto body = other->getFirstBody();
		float minDisSQ = (this->getRadius() + other->getRadius()) * (this->getRadius() + other->getRadius());
		float minDisSQ_AI = minDisSQ * 4;
		while (body != nullptr)
		{
			float disSQ = head->position.distanceSquared(body->position);
			
			if (disSQ <= minDisSQ_AI && disSQ < lastDis)
			{
				lastDis = disSQ;
				nearSnake = other;
				nearSnakeBodyXY = body->position;
			}

			if (disSQ < minDisSQ)
			{
				if (body == other->getFirstBody())
				{
					if (this->getLength() >= other->getLength()) {
						other->setLive(false);
						m_kill++;
					}
					else {
						this->setLive(false);
						other->m_kill++;
					}
				}
				else
				{
					setLive(false);
					other->m_kill++;
				}
				break;
			}

			body = other->getNextBody();
		}
	}
}

void Snake::detech(const Size &mapSize)
{
	if (!isLive())
		return;

	auto head = getFirstBody();
	if (head->position.x < m_radius || head->position.x >(mapSize.width - m_radius)
		|| head->position.y < m_radius || head->position.y >(mapSize.height - m_radius))
	{
		setLive(false);
	}
}

void Snake::addBody(const Vec2 &pos)
{
	addBody(pos, CC_RADIANS_TO_DEGREES(m_dir.getAngle()));
}

void Snake::addBody(const Vec2 &pos, float angle)
{
	m_length++;

	if (m_bodyList.size() >= SNAKE_MAX_LENGTH)
		return;

	auto body = new Body();
	body->position = pos;
	body->angle = angle;

	m_bodyList.insert(m_bodyList.begin() + m_headIndex, body);
	if (m_bodyList.size() == 1) {
		m_headIndex = 0;
	}
	else {
		m_headIndex += 1;
	}
}

const Snake::Body *Snake::getFirstBody()
{
	m_iterCount = 0;
	m_iterIndex = m_headIndex;

	return getNextBody();
}

const Snake::Body *Snake::getNextBody()
{
	if (m_iterCount >= m_bodyList.size())
		return nullptr;

	auto ret = m_bodyList.at(m_iterIndex);

	m_iterCount += SNAKE_PATH_PER_BODY;
	m_iterIndex += SNAKE_PATH_PER_BODY;
	if (m_iterIndex >= m_bodyList.size()) {
		m_iterIndex -= m_bodyList.size();
	}
	
	return ret;
}

void Snake::ateFood(Food *f)
{
	int tailIndex = m_headIndex - 1;
	if (tailIndex < 0) {
		tailIndex = m_bodyList.size() - 1;
	}

	auto body = m_bodyList.at(tailIndex);
	Vec2 pos = body->position;
	Vec2 dir(1, 0);
	dir.rotateByAngle(Vec2::ZERO, body->angle);
	dir.negate();

	for (int i = 0; i < f->number; i++)
	{
		pos += dir;
		addBody(pos, body->angle);
	}
}

void Snake::updateAABB()
{
	bl.set(100000, 100000);
	rt.set(0, 0);

	auto body = getFirstBody();
	while (body != nullptr)
	{
		bl.x = fmin(bl.x, body->position.x - m_radius);
		bl.y = fmin(bl.y, body->position.y - m_radius);
		rt.x = fmax(rt.x, body->position.x + m_radius);
		rt.y = fmax(rt.y, body->position.y + m_radius);

		body = getNextBody();
	}
}

bool Snake::checkAABB(const Snake *other)
{
	auto head = getFirstBody();
	
	Vec2 bl_(head->position.x - m_radius, head->position.y - m_radius);
	Vec2 rt_(head->position.x + m_radius, head->position.y + m_radius);

	return !(rt_.x < other->bl.x || other->rt.x < bl_.x || rt_.y < other->bl.y || other->rt.y < bl_.y);
}

//////////////////////////////////////////////////////////////////////////////////////

SnakePhysicsComponent::SnakePhysicsComponent(const Size &mapSize)
: m_mapSize(mapSize)
, m_aabbDirtyFlag(true)
{
}

void SnakePhysicsComponent::update(Snake &snake, std::vector<Snake *> &otherSnakes)
{
	if (!snake.isLive())
		return;

	move(snake);

	detechCollision(snake);
	detechCollision(snake, otherSnakes);
	detechCollision(snake, AreaSystem::getInstance());
}

void SnakePhysicsComponent::move(Snake &snake)
{
	m_aabbDirtyFlag = true;
}

void SnakePhysicsComponent::detechCollision(Snake &snake)
{
	if (!snake.isLive())
		return;
}

void SnakePhysicsComponent::detechCollision(Snake &snake, std::vector<Snake *> &otherSnakes)
{
//	nearSnake = nullptr;
//	float lastDis = 100000;

	if (!snake.isLive())
		return;

	updateAABB(snake);

	auto head = snake.getFirstBody();
	for (auto it = otherSnakes.begin(); it != otherSnakes.end(); it++)
	{
		auto other = *it;
		if (other == &snake || !other->isLive())
			continue;

		if (!checkAABB(other))
			continue;

		float minDisSQ = (snake.getRadius() + other->getRadius()) * (snake.getRadius() + other->getRadius());
		float minDisSQ_AI = minDisSQ * 4;
		
		auto body = other->getFirstBody();
		while (body != nullptr)
		{
			float disSQ = head->position.distanceSquared(body->position);

			/*	if (disSQ <= minDisSQ_AI && disSQ < lastDis)
				{
				lastDis = disSQ;
				nearSnake = other;
				nearSnakeBodyXY = body->position;
				}*/

			if (disSQ < minDisSQ)
			{
				onCollision(&snake, other);
				break;
			}

			body = other->getNextBody();
		}
	}
}

void SnakePhysicsComponent::detechCollision(Snake &snake, AreaSystem *foods)
{
	if (!snake.isLive())
		return;
}

void SnakePhysicsComponent::onCollision(Snake *snake, Snake *other)
{
	/*if (body == other->getFirstBody())
	{
	if (snake->getLength() >= other->getLength()) {
	other->setLive(false);
	m_kill++;
	}
	else {
	snake->setLive(false);
	other->m_kill++;
	}
	}
	else
	{
	snake->setLive(false);
	other->m_kill++;
	}*/
}

void SnakePhysicsComponent::updateAABB(Snake &snake)
{
	if (!m_aabbDirtyFlag)
		return;
	m_aabbDirtyFlag = false;

	m_lb.set(100000, 100000);
	m_rt.set(0, 0);

	auto body = snake.getFirstBody();
	while (body != nullptr)
	{
		m_lb.x = fmin(m_lb.x, body->position.x - snake.m_radius);
		m_lb.y = fmin(m_lb.y, body->position.y - snake.m_radius);
		m_rt.x = fmax(m_rt.x, body->position.x + snake.m_radius);
		m_rt.y = fmax(m_rt.y, body->position.y + snake.m_radius);

		body = snake.getNextBody();
	}
}

bool SnakePhysicsComponent::checkAABB(Snake *other)
{
	//auto head = other->getFirstBody();

	//Vec2 bl_(head->position.x - m_radius, head->position.y - m_radius);
	//Vec2 rt_(head->position.x + m_radius, head->position.y + m_radius);

	//return !(rt_.x < other->bl.x || other->rt.x < bl_.x || rt_.y < other->bl.y || other->rt.y < bl_.y);
	return false;
}
