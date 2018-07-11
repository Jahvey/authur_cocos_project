
#include "GamePlay/GamePlayer.h"
#include "GamePlay/AreaSystem.h"
#include "GamePlay/SnakeView.h"
#include "GamePlay/FoodView.h"
#include "UI/ResultView.h"
#include "Utils/InitSnakeUtils.h"
#include "Utils/GameData.h"
#include "Utils/Player.h"

Scene * GamePlayer::createScene(int mode)
{
	auto scene = Scene::create();
	auto view = GamePlayer::create(mode);
	scene->addChild(view);
	return scene;
}

GamePlayer *GamePlayer::create(int mode)
{
	auto view = new GamePlayer(mode);
	view->init();
	view->autorelease();
	return view;
}

GamePlayer::GamePlayer(int mode)
{
	_gameMode = mode;
	_gameMap = nullptr;
	_joystick = nullptr;

	_mySnake = nullptr;
	_timeLeft = 300.f;
}

bool GamePlayer::init()
{
    if (!Layer::init())
        return false;
    
    auto winSize = Director::getInstance()->getWinSize();
	_mapSize = winSize * 4;
	_mapSize.width = fmax(_mapSize.width, 4600);
	_mapSize.height = fmax(_mapSize.height, 2600);
   
	// 游戏"地图"
	auto colorBG = LayerColor::create(Color4B(118, 28, 27, 255));
	addChild(colorBG);

	_gameMap = Node::create();
	_gameMap->setAnchorPoint(Vec2::ZERO);
	_gameMap->setPosition(Vec2::ZERO);
	addChild(_gameMap, 2);

	auto bg = Sprite::create("map_01.png");
	bg->setAnchorPoint(Vec2::ZERO);
	bg->setTextureRect(Rect(0, 0, _mapSize.width, _mapSize.height));
	_gameMap->addChild(bg);

	Texture2D::TexParams texParams;
	texParams.minFilter = GL_LINEAR;
	texParams.magFilter = GL_LINEAR;
	texParams.wrapS = GL_REPEAT;
	texParams.wrapT = GL_REPEAT;
	bg->getTexture()->setTexParameters(texParams);
    

	// 操作UI
	_joystick = JoystickView::create();
	addChild(_joystick, 20);

	// 排行信息
	_infoView = InfoView::create();
	addChild(_infoView, 100);

    return true;
}

void GamePlayer::onEnter()
{
	Layer::onEnter();

	_newAiSnakeDelay = 0;

	AreaSystem::getInstance();

	// 初始化所有蛇
	initSaneks();

	// 初始化所有食物
	for (int i = 0; i < FOOD_MAX_NUM; i++)
	{
		randomFood();
	}

	scheduleUpdate();
}

void GamePlayer::onExit()
{
	AreaSystem::destroyInstance();

	for (auto it = _allSnakeAi.begin(); it != _allSnakeAi.end(); it++)
	{
		delete *it;
	}

	for (auto it = _allSnakes.begin(); it != _allSnakes.end(); it++)
	{
		delete *it;
	}

	for (auto it = _allFoods.begin(); it != _allFoods.end(); it++)
	{
		delete *it;
	}

	Layer::onExit();
}

void GamePlayer::update(float delta)
{
	if (_mySnake != nullptr && _timeLeft <= 0)
	{
		_mySnake->setLive(false);
		_mySnake->m_disappear = true;
	}

	// 玩家操作
	if (_mySnake != nullptr)
	{
		if (_mySnake->isLive())
		{
			Vec2 dir = _joystick->getDir();
			if (!dir.isZero()) {
				_mySnake->setDir(dir);
			}
			_mySnake->setAccelerate(_joystick->isAccelerating());
		}
		else
		{
			auto view = new ResultView(_gameMode);
			view->setResult(_mySnake->getLength(), _mySnake->getKill());
			view->show();
			view->release();
			_mySnake = nullptr;
		}
	}

	// ai动作
	for (auto it = _allSnakeAi.begin(); it != _allSnakeAi.end(); )
	{
		auto ai = *it;
		if (ai->isLive()) 
		{
			ai->update(delta);
			it++;
		}
		else 
		{
			delete ai;
			it = _allSnakeAi.erase(it);
		}
	}

	// 死蛇变食物
	for (auto it = _allSnakes.begin(); it != _allSnakes.end(); it++)
	{
		auto snake = *it;
		if (!snake->isLive() && !snake->m_disappear)
		{
			int index = 0;
			auto body = snake->getFirstBody();
			while (body != nullptr)
			{
				int dx = 10 - cocos2d::random(0, 20);
				int dy = 10 - cocos2d::random(0, 20);
				int clr = FoodData::getInstance()->getSkinFood(snake->getSkin(), index);
				addFood(body->position.x + dx, body->position.y + dy, clr, SNAKE_PATH_PER_BODY / 2);
				body = snake->getNextBody();

				index++;
			}
		}
	}

	// 蛇的加速会"掉落"食物
	for (auto it = _allSnakes.begin(); it != _allSnakes.end(); it++)
	{
		if ((*it)->hasAccConsumed())
		{
			auto &d = (*it)->getAccConsumed();
			int clr = FoodData::getInstance()->getSkinFood((*it)->getSkin(), 0);
			addFood(d.x, d.y, clr, 1);
		}
	}

	//补充食物
	int foodCount = _allFoods.size() - _idleFoods.size();
	if (foodCount < FOOD_MAX_NUM)
	{
		randomFood();
	}

	// 删除死蛇
	for (auto it = _allSnakes.begin(); it != _allSnakes.end(); )
	{
		if (!(*it)->isLive()) 
		{
			(*it)->clear();
			delete (*it);
			it = _allSnakes.erase(it);
		}
		else
		{
			it++;
		}
	}

	// 补充AI
	_newAiSnakeDelay += delta;
	if (_newAiSnakeDelay >= CTRL_NEW_AI_DELAY)
	{
		int aiNumber = _allSnakes.size() - 1;
		if (aiNumber < SNAKE_MAX_AI)
		{
			_newAiSnakeDelay = 0;
			newAiSnake(SNAKE_MIN_LENGTH);
		}
	}

	// 蛇的动作（移动，检测碰撞，吃食物）
	float maxRadius = 0;

	for (auto it = _allSnakes.begin(); it != _allSnakes.end(); it++)
	{
		(*it)->move();
		(*it)->detech(_mapSize);
		(*it)->detech(_allSnakes);
		(*it)->detech();
		(*it)->update();

		maxRadius = fmax(maxRadius, (*it)->getRadius());
	}

	// 食物更新
	for (auto it = _allFoods.begin(); it != _allFoods.end(); it++)
	{
		Food *f = *it;
		if (f->isLive)
		{
			f->update(delta);
			if (!f->isLive)
			{
				_idleFoods.push_back(f);
			}
		}
	}

	// 刷新排行信息
	if (_mySnake != nullptr) {
		_infoView->setMySnakeInfo(_mySnake);
	}
	_infoView->setRankInfo(_allSnakes);

	if (_gameMode == 1)
	{
		_infoView->setTime(_timeLeft);
		_timeLeft -= delta;
	}

	// 镜头跟进
	updateCamera(maxRadius);
}

void GamePlayer::updateCamera(float maxRadius)
{
	if (_mySnake == nullptr)
		return;

	// 太大，镜头拉远
	_gameMap->setScale(fmin(1, 40 / maxRadius));
	
	// 地图位置
	auto &winSize = Director::getInstance()->getWinSize();
	auto headPosition = _mySnake->getFirstBody()->position * _gameMap->getScale();

	Vec2 screenPosition = headPosition - Vec2(winSize.width / 2, winSize.height / 2);
	screenPosition.negate();

	_gameMap->setPosition(screenPosition);
}

Snake * GamePlayer::newAiSnake(int length)
{
	float x = cocos2d::random(400.f, _mapSize.width - 400);
	float y = cocos2d::random(400.f, _mapSize.height - 400);

	auto snake = new Snake(1, cocos2d::random(0, 4));
	snake->init(x, y, length);
	_allSnakes.push_back(snake);

	
	newSnakeView(snake);
	newSnakeAI(snake);

	return snake;
}

void GamePlayer::newSnakeView(Snake *s)
{
	auto view = new SnakeView(s);
	view->setAnchorPoint(Vec2::ANCHOR_BOTTOM_LEFT);
	view->setPosition(Vec2::ZERO);
	_gameMap->addChild(view, 3);
	view->release();
}

void GamePlayer::newSnakeAI(Snake *s)
{
	SnakeAIDef def;
	def.snake = s;
	def.mapSize = _mapSize;

	auto ai = new SnakeAI(def);
	_allSnakeAi.push_back(ai);
}

void GamePlayer::randomFood()
{
	int x = cocos2d::random(40, ((int)_mapSize.width) - 40);
	int y = cocos2d::random(40, ((int)_mapSize.height) - 40);
	int clr = FoodData::getInstance()->getRandomFood();

	addFood(x, y, clr, 1);
}


Food * GamePlayer::getIdleFood()
{
	Food *f = nullptr;
	if (_idleFoods.size() > 0)
	{
		f = _idleFoods.back();
		_idleFoods.pop_back();
	}
	else
	{
		f = new Food;
		_allFoods.push_back(f);
	}

	return f;
}

void GamePlayer::addFood(float x, float y, int clr, int num)
{
	auto f = getIdleFood();
	f->setLive(x, y, clr, num);

	auto view = new FoodView(f);
	_gameMap->addChild(view, 2);
	view->release();
}

void GamePlayer::initSaneks()
{
	auto &datas = InitSnakeUtils::getInstance()->getAllData();
	int number = datas.size();
	
	// 玩家蛇
	int myNumber = 0;
	for (auto it = datas.begin(); it != datas.end(); it++)
	{
		if ((*it).size() > (31+1))
			break;
		myNumber++;
	}

	_mySnake = new Snake(1, Player::getInstance()->getUsingSkin());
	_mySnake->m_isPlayer = true;
	_mySnake->name = Player::getInstance()->getNickname();
	_mySnake->init(&datas[cocos2d::random(0, myNumber - 1)]);
	_allSnakes.push_back(_mySnake);
	newSnakeView(_mySnake);

	// AI蛇
	int aiNumber = number - myNumber;
	int *buffer = new int[aiNumber];

	for (int i = 0; i < aiNumber; i++)
		buffer[i] = i + myNumber;

	for (int i = 0; i < aiNumber; i++)
		buffer[i] = buffer[cocos2d::random(0, aiNumber - 1)];

	for (int i = 0; i < SNAKE_MAX_AI; i++)
	{
		auto snake = new Snake(1, cocos2d::random(0, 4));
		snake->init(&datas[buffer[i]]);
		_allSnakes.push_back(snake);

		newSnakeView(snake);
		newSnakeAI(snake);
	}

	delete[] buffer;
}


