#pragma once

#include "cocos2d.h"
#include "ui/CocosGUI.h"

USING_NS_CC;
using namespace ui;

#include "GamePlay/SnakeView.h"

class SkinItem : public Widget
{
public:
	CREATE_FUNC(SkinItem);
	virtual bool init();
	void setSelected(bool sel);
	bool isSelected();

	void initWithSkin(const _SKINEDATA &skinData);

private:
	Sprite* selectImage;
};

