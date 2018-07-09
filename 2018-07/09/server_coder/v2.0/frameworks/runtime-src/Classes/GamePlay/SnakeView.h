#pragma once

#include "cocos2d.h"
#include "ui/CocosGUI.h"
USING_NS_CC;
using namespace ui;

#include "Snake.h"
#include "Utils/GameData.h"

//#define DRAW_AABB

class SnakeView : public Node
{
public:
	SnakeView(Snake *s);
	virtual ~SnakeView();

	virtual void onEnter() override;
	virtual void update(float dt);

	void setDevMode(std::function<void(Ref*)> callback);

protected:
	void initUI();
	const char *getImage(const _SKINEDATA &skinData, int index);
	
private:
	Label *_nameLabel;
	Button  *_btnDel;

	Snake *m_snake;
	std::vector<Node *> m_bodys;
	Sprite *m_tailSpr;
	Node   *m_headNode;

#ifdef DRAW_AABB
	DrawNode *m_aabbNode;
#endif
};

