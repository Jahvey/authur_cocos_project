#pragma once

#include "PopView.h"

class SettingView : public PopView
{
public:
	SettingView();
private:
	ImageView* imageView;
	CheckBox* leftBtn;
	CheckBox* rightBtn;
};
