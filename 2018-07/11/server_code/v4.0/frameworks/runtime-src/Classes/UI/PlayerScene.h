#pragma once

#include "PopView.h"

class PlayerScene : public Layer
{
public:
	static Scene *createScene();

	virtual bool init();

private:
	void initUI();

private:
};

//////////////////////////////

class EditNicknameView : public PopView
{
public:
	EditNicknameView();
	virtual bool init();

private:
	void initUI();

public:
	std::function<void(const std::string)> renameCallback;
};


