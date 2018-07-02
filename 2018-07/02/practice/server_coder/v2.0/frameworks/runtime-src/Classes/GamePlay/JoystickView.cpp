#include "JoystickView.h"
#include "GameDef.h"

#define TOUCHPAD_RADIUS		74
#define STICK_RADIUS		30
#define STICK_MOVE_RADIUS	(TOUCHPAD_RADIUS - STICK_RADIUS)

JoystickView* JoystickView::create()
{
	auto view = new JoystickView();
	view->init();
	view->autorelease();
	return view;
}

bool JoystickView::init()
{
	if (!Layer::init())
		return false;
    
	auto winSize = Director::getInstance()->getWinSize();

	m_isStick = false;
	m_isAcc = false;
	m_stickPosition.set(winSize.width - 160, 140);
	m_accPosition.set(160, 140);
	if (UserDefault::getInstance()->getBoolForKey(SETTING_OPERATION))
	{
		m_stickPosition.set(160, 140);
		m_accPosition.set(winSize.width - 160, 140);
	}

	// 摇杆
	auto stickBG = Sprite::create("touchpad_bg.png");
	stickBG->setScale((TOUCHPAD_RADIUS * 2) / stickBG->getContentSize().width);
	stickBG->setPosition(m_stickPosition);
	addChild(stickBG);

	m_stickIcon = Sprite::create("secend_icon.png");
	m_stickIcon->setScale((STICK_RADIUS * 2) / m_stickIcon->getContentSize().width);
	m_stickIcon->setPosition(m_stickPosition);
	addChild(m_stickIcon, 2);

	// 加速
	auto btnAcc = Sprite::create("speedup.png");
	btnAcc->setScale((TOUCHPAD_RADIUS * 2) / btnAcc->getContentSize().width);
	btnAcc->setPosition(m_accPosition);
	addChild(btnAcc);


	// 点击事件
	auto touchEvent = EventListenerTouchAllAtOnce::create();
	touchEvent->onTouchesBegan = CC_CALLBACK_2(JoystickView::onTouchesBegan, this);
	touchEvent->onTouchesMoved = CC_CALLBACK_2(JoystickView::onTouchesMoved, this);
	touchEvent->onTouchesEnded = CC_CALLBACK_2(JoystickView::onTouchesEnded, this);
	touchEvent->onTouchesCancelled = CC_CALLBACK_2(JoystickView::onTouchesCancelled, this);
	getEventDispatcher()->addEventListenerWithSceneGraphPriority(touchEvent, this);

    return true;
}

void JoystickView::onTouchesBegan(const std::vector<Touch*>& touches, Event *unused_event)
{
	for (auto it = touches.begin(); it != touches.end(); it++)
	{
		Vec2 touchPosition = (*it)->getLocation();
		if (!m_isStick && m_stickPosition.getDistance(touchPosition) <= TOUCHPAD_RADIUS)
		{
			m_isStick = true;
			m_stickTouchID = (*it)->getID();
			setStickIconPosition(touchPosition);
		}
		else if (!m_isAcc && m_accPosition.getDistance(touchPosition) <= TOUCHPAD_RADIUS)
		{
			m_isAcc = true;
			m_accTouchID = (*it)->getID();
		}
	}
}

void JoystickView::onTouchesMoved(const std::vector<Touch*>& touches, Event *unused_event)
{
	for (auto it = touches.begin(); it != touches.end(); it++)
	{
		int touchID = (*it)->getID();

		if (m_isStick && touchID == m_stickTouchID)
		{
			setStickIconPosition((*it)->getLocation());
		}
	}
}

void JoystickView::onTouchesEnded(const std::vector<Touch*>& touches, Event *unused_event)
{
	for (auto it = touches.begin(); it != touches.end(); it++)
	{
		int touchID = (*it)->getID();
		if (m_isStick && touchID == m_stickTouchID)
		{
			m_stickIcon->setPosition(m_stickPosition);
			m_isStick = false;
		}
		else if (m_isAcc && touchID == m_accTouchID)
		{
			m_isAcc = false;
		}
	}
}

void JoystickView::onTouchesCancelled(const std::vector<Touch*>&touches, Event *unused_event)
{
	for (auto it = touches.begin(); it != touches.end(); it++)
	{
		int touchID = (*it)->getID();
		if (m_isStick && touchID == m_stickTouchID)
		{
			m_stickIcon->setPosition(m_stickPosition);
			m_isStick = false;
		}
		else if (m_isAcc && touchID == m_accTouchID)
		{
			m_isAcc = false;
		}
	}
}

Vec2 JoystickView::getDir()
{
	if (m_isStick)
	{
		Vec2 dir = m_stickIcon->getPosition() - m_stickPosition;
		return (dir.length() < 5) ? Vec2::ZERO : dir;
	}
	else
	{
		return Vec2::ZERO;
	}
}

void JoystickView::setStickIconPosition(const Vec2 &touchPosition)
{
	Vec2 dir = touchPosition - m_stickPosition;
	if (dir.length() > STICK_MOVE_RADIUS)
	{
		dir.normalize();
		dir *= STICK_MOVE_RADIUS;
		dir += m_stickPosition;
		m_stickIcon->setPosition(dir);
	}
	else
	{
		m_stickIcon->setPosition(touchPosition);
	}
}
