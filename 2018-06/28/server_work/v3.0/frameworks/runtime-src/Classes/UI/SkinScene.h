#pragma once

#include "cocos2d.h"
#include "ui/CocosGUI.h"
#include "SkinItem.h"
USING_NS_CC;
using namespace ui;

class SkinScene : public Layer
{
public:
	static Scene* createScene();
	virtual bool init();
	CREATE_FUNC(SkinScene);
private:
	SkinItem* selectItem;
};
