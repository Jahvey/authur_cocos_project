#pragma once

#include "cocos2d.h"
#include "ui/CocosGUI.h"
#include "GamePlay/GameDef.h"
USING_NS_CC;
using namespace ui;

class MainScene : public Layer
{
public:
	static Scene* createScene();
	virtual bool init();
	CREATE_FUNC(MainScene);

	virtual void onEnter();
	virtual void onExit();

	virtual void update(float delta);	
};
