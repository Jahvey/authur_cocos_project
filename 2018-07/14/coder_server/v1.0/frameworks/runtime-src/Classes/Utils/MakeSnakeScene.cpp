
#include "MakeSnakeScene.h"
#include "Utils/InitSnakeUtils.h"
#include "GamePlay/SnakeView.h"
#include "UI/MainScene.h"

Scene * MakeSnakeScene::createScene()
{
	auto scene = Scene::create();
	auto view = MakeSnakeScene::create();
	scene->addChild(view);
	return scene;
}

MakeSnakeScene *MakeSnakeScene::create()
{
	auto view = new MakeSnakeScene;
	view->init();
	view->autorelease();
	return view;
}

MakeSnakeScene::MakeSnakeScene()
: GamePlayer(0)
{
}

bool MakeSnakeScene::init()
{
    if (!GamePlayer::init())
        return false;
    
	_infoView->removeFromParent();

    auto winSize = Director::getInstance()->getWinSize();


	_numberLabel = Label::createWithSystemFont("", "Arial", 20);
	_numberLabel->setTextColor(Color4B::GRAY);
	_numberLabel->setAnchorPoint(Vec2::ANCHOR_MIDDLE_LEFT);
	_numberLabel->setPosition(10, winSize.height - 30);
	addChild(_numberLabel, 1000);


	/////
	auto btnBack = Button::create("back_icon_small.png");
	btnBack->setPosition(Vec2(SCREEN_WIDTH - 50, SCREEN_HEIGHT - 50));
	btnBack->addClickEventListener([&](Ref*)
	{
		auto scene = MainScene::createScene();
		Director::getInstance()->replaceScene(TransitionFade::create(0.3f, scene, Color3B(0, 0, 0)));
	});
	addChild(btnBack, 1000);


	auto btnMode = Button::create("gold_bg.png");
	btnMode->setPosition(Vec2(SCREEN_WIDTH - 150, SCREEN_HEIGHT - 50));
	btnMode->setTitleText("Mode");
	btnMode->addClickEventListener([&](Ref*)
	{
		_mode = 1 - _mode;
	});
	addChild(btnMode, 1000);


	auto btnNewSnake = Button::create("gold_bg.png");
	btnNewSnake->setPosition(Vec2(SCREEN_WIDTH - 250, SCREEN_HEIGHT - 50));
	btnNewSnake->setTitleText("New");
	btnNewSnake->addClickEventListener([&](Ref*)
	{
		_newAiSnakeDelay = 1;
	});
	addChild(btnNewSnake, 1000);


	auto btnDone = Button::create("gold_bg.png");
	btnDone->setPosition(Vec2(SCREEN_WIDTH - 350, SCREEN_HEIGHT - 50));
	btnDone->setTitleText("Done");
	btnDone->addClickEventListener([&](Ref*)
	{
		InitSnakeUtils::getInstance()->addSnakes(_allSnakes);
		InitSnakeUtils::getInstance()->writeToFile("xxoo.bin");
	});
	addChild(btnDone, 1000);


    return true;
}

void MakeSnakeScene::onEnter()
{
	Layer::onEnter();

	_mode = 0;
	_newAiSnakeDelay = 0;
	_mySnake = nullptr;


	InitSnakeUtils::getInstance()->initWithFile("xxoo.bin");
	auto datas = InitSnakeUtils::getInstance()->getAllData();
	for (auto it = datas.begin(); it != datas.end(); it++)
	{
		newSnakeFromData(&(*it));
	}

	scheduleUpdate();
}

void MakeSnakeScene::onExit()
{
	for (auto it = _allSnakes.begin(); it != _allSnakes.end(); it++)
	{
		delete *it;
	}

	Layer::onExit();
}

void MakeSnakeScene::update(float delta)
{
	if (_mySnake != nullptr && !_mySnake->isLive())
		_mySnake = nullptr;

	// ¸üÐÂ¾µÍ·
	Vec2 dir = _joystick->getDir();
	if (!dir.isZero())
	{
		if (_mode == 0) {
			moveCamera(dir);
		}
		else if (_mySnake != nullptr) {
			_mySnake->setDir(dir);
		}
	}

	if (_mode == 1 && _mySnake != nullptr) {
		_mySnake->setAccelerate(_joystick->isAccelerating());
	}

	
	// É¾³ýËÀÉß
	for (auto it = _allSnakes.begin(); it != _allSnakes.end();)
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

	// ²¹³äAI
	if (_newAiSnakeDelay == 1)
	{
		_newAiSnakeDelay = 0;


		float x = cocos2d::random(400.f, _mapSize.width - 400);
		float y = cocos2d::random(400.f, _mapSize.height - 400);

		auto snake = new Snake(1, cocos2d::random(1, 5));
		snake->init(x, y, 31);
		_allSnakes.push_back(snake);

		newSnakeView(snake);

		_mySnake = snake;
	}

	//
	if (_mode == 1 && _mySnake != nullptr)
	{
		if (!dir.isZero())
		{
			_mySnake->move();
		}
	}

	if (_mode == 1)
	{
		updateCamera(1);
	}

	char buf[128];
	sprintf(buf, "Number: %d", _allSnakes.size());
	_numberLabel->setString(buf);
}

void MakeSnakeScene::moveCamera(const Vec2 &dir)
{
	Vec2 moveDir = dir;
	moveDir.negate();
	moveDir.normalize();

	Vec2 screenPosition = _gameMap->getPosition() + moveDir * 20;
	_gameMap->setPosition(screenPosition);
}

void MakeSnakeScene::newSnakeView(Snake *s)
{
	auto view = new SnakeView(s);
	view->setAnchorPoint(Vec2::ANCHOR_BOTTOM_LEFT);
	view->setPosition(Vec2::ZERO);
	_gameMap->addChild(view, 3);
	view->release();

	view->setDevMode([&,s,view](Ref *ref) {
		view->removeFromParent();
		s->setLive(false);
		update(0.016f);
	});
}

void MakeSnakeScene::newSnakeFromData(const std::vector<Vec2> *data)
{
	auto snake = new Snake(1, cocos2d::random(1, 5));
	snake->init(data);
	_allSnakes.push_back(snake);

	newSnakeView(snake);
}
