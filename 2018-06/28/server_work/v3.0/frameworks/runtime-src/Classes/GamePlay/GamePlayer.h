#pragma once

#include "cocos2d.h"
USING_NS_CC;

#include "GamePlay/GameDef.h"
#include "GamePlay/JoystickView.h"
#include "GamePlay/InfoView.h"
#include "GamePlay/Snake.h"
#include "GamePlay/Food.h"
#include "GamePlay/SnakeAI.h"

class GamePlayer : public Layer
{
public:
	GamePlayer(int mode);

	static Scene * createScene(int mode);
	static GamePlayer *create(int mode);
	virtual bool init();

	virtual void onEnter() override;
	virtual void onExit() override;
	virtual void update(float delta);

protected:
	void updateCamera(float maxRadius);

	void initSaneks();
	Snake * newAiSnake(int length = 0);

	void randomFood();
	Food * getIdleFood();
	void addFood(float x, float y, int clr, int num);

	virtual void newSnakeView(Snake *s);
	virtual void newSnakeAI(Snake *s);

protected:
	int           _gameMode;
	float         _timeLeft;

	Size          _mapSize;
	Node         *_gameMap;
	JoystickView *_joystick;
	InfoView     *_infoView;
	
	float _newAiSnakeDelay;
	
	// Éß
	Snake *_mySnake;
	std::vector<Snake *> _allSnakes;

	// ÉßµÄAI
	std::vector<SnakeAI *> _allSnakeAi;

	// Ê³Îï
	std::vector<Food *> _allFoods;
	std::vector<Food *> _idleFoods;
};
