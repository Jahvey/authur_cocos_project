#pragma once

#include "cocos2d.h"
USING_NS_CC;

class JoystickView : public Layer
{
public:
	static JoystickView* create();

	virtual bool init() override;
    
	virtual void onTouchesBegan(const std::vector<Touch*>& touches, Event *unused_event) override;
	virtual void onTouchesMoved(const std::vector<Touch*>& touches, Event *unused_event) override;
	virtual void onTouchesEnded(const std::vector<Touch*>& touches, Event *unused_event) override;
	virtual void onTouchesCancelled(const std::vector<Touch*>&touches, Event *unused_event) override;

	Vec2 getDir();
	bool isAccelerating() { return m_isAcc; }

protected:
	void setStickIconPosition(const Vec2 &touchPosition);

private:
	Vec2 m_stickPosition;
	Vec2 m_accPosition;
	Node *m_stickIcon;

	int m_stickTouchID;
	int m_accTouchID;

	bool m_isStick;
	bool m_isAcc;
};
