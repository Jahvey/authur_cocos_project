#pragma once

#include "cocos2d.h"
#include "ui/CocosGUI.h"

USING_NS_CC;
using namespace ui;

class PopView : public LayerColor
{
public:

	PopView(Size size = Size::ZERO, bool mask = true);

	virtual ~PopView();

	virtual void show();

	virtual void dismiss();

	Layout *_contentView;

	virtual bool onTouchBegan(Touch *touch, Event *unused_event);

	void setSize(Size size);

	// ��������������Զ�dismiss
	void setAutoDismiss();

private:
	CC_DISALLOW_COPY_AND_ASSIGN(PopView);

protected:
	EventListenerTouchOneByOne *_listener;
};
