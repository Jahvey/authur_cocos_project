#pragma once

#include "PopView.h"

class ResultView : public PopView
{
public:
	ResultView(int mode);
	void setResult(int lenth, int kill);
private:
	int gameMode;
	Label* countLabel;
	Label* numLabel;
};
