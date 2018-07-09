
#include "GamePlay/FoodView.h"
#include "GamePlay/GameDef.h"

FoodView::FoodView(Food *f)
:_food(f)
{
	char buf[64];
	sprintf(buf, "food%d.png", _food->color);

	_spr = Sprite::create(buf);
	_spr->setScale((f->number == 1 ? 16 : 28) / _spr->getContentSize().width);
	addChild(_spr);

	setPosition(_food->position);

	scheduleUpdate();
}

void FoodView::update(float delta)
{
	if (_food == nullptr)
	{
		removeFromParent();
		return;
	}

	if (!_food->isLive)
	{
		_food = nullptr;
		removeFromParent();
	}
	else
	{
		setPosition(_food->position);
	}
}
