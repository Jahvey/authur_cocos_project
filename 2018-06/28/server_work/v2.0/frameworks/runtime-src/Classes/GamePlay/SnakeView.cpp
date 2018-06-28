
#include "SnakeView.h"
#include "json/document.h"

SnakeView::SnakeView(Snake *s)
{
	_btnDel = nullptr;
	m_tailSpr = nullptr;

	m_snake = s;
	initUI();
}

SnakeView::~SnakeView()
{
	m_snake = nullptr;
	if (m_tailSpr != nullptr) 
	{
		m_tailSpr->release();
	}
}

void SnakeView::initUI()
{
	// 名称
	_nameLabel = Label::createWithSystemFont(m_snake->name, "Arial", 20);
	_nameLabel->setTextColor(Color4B::RED);
	addChild(_nameLabel, 10000);

	auto &skinData = SnakeSkinData::getSkin(m_snake->getSkin());

	// 头
	m_headNode = Node::create();
	m_headNode->setContentSize(Size(50, 50));
	m_headNode->setAnchorPoint(Vec2::ANCHOR_MIDDLE);
	addChild(m_headNode, 1000);
	
	Sprite *spr = Sprite::create(skinData.head);
	spr->setAnchorPoint(Vec2(0.5, skinData.headAnchorY));
	spr->setPosition(m_headNode->getContentSize().width / 2, m_headNode->getContentSize().height * skinData.headAnchorY);
	m_headNode->addChild(spr);

	// 尾
	if (!skinData.tail.empty())
	{
		m_tailSpr = Sprite::create(skinData.tail);
		m_tailSpr->setAnchorPoint(Vec2::ANCHOR_MIDDLE_TOP);
		m_tailSpr->retain();
	}

#ifdef DRAW_AABB
	m_aabbNode = DrawNode::create();
	addChild(m_aabbNode, 1001);
#endif
}

void SnakeView::onEnter()
{
	Node::onEnter();
	scheduleUpdate();
}

void SnakeView::update(float dt)
{
	if (m_snake == nullptr || !m_snake->isLive())
	{
		m_snake = nullptr;
		runAction(RemoveSelf::create(true));
		return;
	}

	
	auto body = m_snake->getFirstBody();
	if (body == nullptr)
		return;

	// 显示名称
	_nameLabel->setPosition(body->position.x, body->position.y + 50);

	// 其它非正式UI
	if (_btnDel != nullptr) {
		_btnDel->setPosition(Vec2(body->position.x, body->position.y + 70));
	}

	/*** 显示蛇身体 ***/
	float scale = m_snake->getRadius() / 25;
	auto &skinData = SnakeSkinData::getSkin(m_snake->getSkin());
	
	// 蛇头
	m_headNode->setScale(scale);
	m_headNode->setPosition(body->position);
	m_headNode->setRotation(-(body->angle - 90));

	// 蛇身
	unsigned int idx = 0;
	while ((body = m_snake->getNextBody()) != nullptr)
	{
		Sprite *spr = nullptr;
		if (idx < m_bodys.size()) {
			spr = (Sprite *)m_bodys.at(idx);
		}
		else {
			spr = Sprite::create(getImage(skinData, idx));
			addChild(spr, 999 - idx);
			m_bodys.push_back(spr);
		}
		spr->setScale(scale);
		spr->setPosition(body->position);
		spr->setRotation(-(body->angle - 90));

		idx++;
	}

	int left = m_bodys.size() - idx;
	for (int i = 0; i < left; i++)
	{
		auto spr = m_bodys.back();
		spr->removeFromParent();
		m_bodys.pop_back();
	}

	// 蛇尾
	if (m_tailSpr != nullptr)
	{
		if (m_tailSpr->getParent() != nullptr) {
			m_tailSpr->removeFromParent();
		}
		
		auto lastBody = m_bodys.back();
		m_tailSpr->setPosition(lastBody->getContentSize().width / 2, 0);
		lastBody->addChild(m_tailSpr);
	}

#ifdef DRAW_AABB
	m_aabbNode->clear();
	m_aabbNode->drawRect(m_snake->bl, m_snake->rt, Color4F::GREEN);
#endif
}

const char *SnakeView::getImage(const _SKINEDATA &skinData, int index)
{
	int bodyStyleNumber = skinData.bodys.size();
	return skinData.bodys.at(index % bodyStyleNumber).c_str();
}

void SnakeView::setDevMode(std::function<void(Ref*)> callback)
{
	_btnDel = Button::create("share_gain_close_icon.png");
	addChild(_btnDel, 10000);

	_btnDel->addClickEventListener(callback);
}
