
#pragma once

#include "cocos2d.h"
USING_NS_CC;

#include "GamePlay/Food.h"

class FoodView : public Node
{
public:
	FoodView(Food *f);

	virtual void update(float delta);
	
private:
	Food *_food;
	Sprite *_spr;
};