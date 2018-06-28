#pragma once

#include "cocos2d.h"
#include "PopView.h"

USING_NS_CC;

class PopViewManager : public Ref
{
public:
	virtual ~PopViewManager();

	static PopViewManager* getInstance();
	static void destroyInstance();

	PopView* getTopView();

	bool addPopView(PopView* view);

	void removePopView(PopView* view);

	void removeAllPopView();

	void clear();
	void removePopViewByTag(int tag);
private:
	PopViewManager();
	CC_DISALLOW_COPY_AND_ASSIGN(PopViewManager);

protected:
	Vector<PopView*> _popViews;
};

