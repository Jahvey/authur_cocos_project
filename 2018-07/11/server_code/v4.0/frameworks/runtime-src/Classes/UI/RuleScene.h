#pragma once

#include "cocos2d.h"
#include "ui/CocosGUI.h"
USING_NS_CC;
using namespace ui;

class RuleScene : public Layer
{
public:
	static Scene* createScene();
	virtual bool init();
	CREATE_FUNC(RuleScene);
};
