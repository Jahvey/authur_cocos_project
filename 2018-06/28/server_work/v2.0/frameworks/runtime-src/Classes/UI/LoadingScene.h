#pragma once

#include "cocos2d.h"
#include "ui/CocosGUI.h"

USING_NS_CC;
using namespace ui;


class LoadingScene : public Layer
{
public:
	static Scene* createScene();
	virtual bool init();
	CREATE_FUNC(LoadingScene);

	virtual void onEnter();

	void OnLoading(float delta);

protected:
	void setBarPercent(float percent) { _bar->setPercent(percent); }
	void setLoadingStep(int step) { _lodingStep = step; }

private:
	LoadingBar *_bar;
	int _lodingStep;
};
