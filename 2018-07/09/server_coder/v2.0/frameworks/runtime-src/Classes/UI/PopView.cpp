#include "PopView.h"
#include "PopViewManager.h"
#include "GamePlay/GameDef.h"

PopView::PopView(Size size, bool mask)
{
	GLubyte alpha = mask ? 100 : 0;
	initWithColor(Color4B(0, 0, 0, alpha), SCREEN_WIDTH, SCREEN_HEIGHT);

	_contentView = Layout::create();
	_contentView->setContentSize(size);
	_contentView->setClippingEnabled(true);
	_contentView->setPosition(Vec2((SCREEN_WIDTH - size.width) / 2, (SCREEN_HEIGHT - size.height) / 2));
	addChild(_contentView);

	_listener = EventListenerTouchOneByOne::create();
	_listener->setSwallowTouches(true);
	_listener->onTouchBegan = CC_CALLBACK_2(PopView::onTouchBegan, this);
	_eventDispatcher->addEventListenerWithSceneGraphPriority(_listener, this);
}

PopView::~PopView()
{
}

void PopView::show()
{
	PopViewManager::getInstance()->addPopView(this);
	setScale(0);
	runAction(Sequence::create(ScaleTo::create(0.2f, 1.2f), ScaleTo::create(0.1f, 1.0f), nullptr));
}

void PopView::dismiss()
{
	PopViewManager::getInstance()->removePopView(this);
}

bool PopView::onTouchBegan(Touch *touch, Event *unused_event)
{
	return true;
}

void PopView::setSize(Size size)
{
	_contentView->setContentSize(size);
	_contentView->setPosition(Vec2((SCREEN_WIDTH - size.width) / 2, (SCREEN_HEIGHT - size.height) / 2));
}

void PopView::setAutoDismiss()
{
	if (_listener->onTouchEnded == nullptr)
	{
		_listener->onTouchEnded = [&](Touch *touch, Event *unused_event) {
			if (!_contentView->getBoundingBox().containsPoint(touch->getLocation()))
			{
				dismiss();
			}
		};
	}
}
