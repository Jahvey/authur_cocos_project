#include "PopViewManager.h"

#define POPVIEW_Z	10000

static PopViewManager *_singleInstance = nullptr;

PopViewManager* PopViewManager::getInstance()
{
	if (!_singleInstance)
	{
		_singleInstance = new PopViewManager();
	}

	return _singleInstance;
}

void PopViewManager::destroyInstance()
{
	CC_SAFE_DELETE(_singleInstance);
}

PopViewManager::PopViewManager()
{
}

PopViewManager::~PopViewManager()
{
	removeAllPopView();
}

bool PopViewManager::addPopView(PopView* view)
{
	Scene *scene = Director::getInstance()->getRunningScene();
	if (!scene)
		return false;

	scene->addChild(view, POPVIEW_Z);
	view->setPosition(Vec2::ZERO);

	_popViews.pushBack(view);
	return true;
}

PopView* PopViewManager::getTopView()
{
	PopView* curView = nullptr;
	if (_popViews.size() > 0)
	{
		curView = _popViews.back();
	}
	return curView;
}

void PopViewManager::removePopView(PopView* view)
{
	view->removeFromParentAndCleanup(true);
	_popViews.eraseObject(view);
}

void PopViewManager::removeAllPopView()
{
	for (ssize_t i = _popViews.size() - 1; i >= 0; --i)
	{
		PopView *view = _popViews.at(i);
		view->dismiss();
	}
}

void PopViewManager::clear()
{
	_popViews.clear();
}

void PopViewManager::removePopViewByTag(int tag)
{
	for (ssize_t i = _popViews.size() - 1; i >= 0; --i)
	{
		PopView *view = _popViews.at(i);
		if (view && view->getTag() == tag) 
		{
			view->dismiss();
			break;
		}
	}
}
