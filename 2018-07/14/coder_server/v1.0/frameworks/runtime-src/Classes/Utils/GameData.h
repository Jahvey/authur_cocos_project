#pragma once

#include "cocos2d.h"
USING_NS_CC;

/* 皮肤数据结构 */
struct _SKINEDATA
{
	float headAnchorY;
	std::string head;
	std::string tail;
	std::vector<std::string> bodys;
};

/* 所有皮肤数据 */
class SnakeSkinData
{
public:
	static void initSkins(bool bClear = false);
	static void clearSkins() { s_vecSkins.clear(); }

	static const std::vector<_SKINEDATA> &getSkins() { return s_vecSkins; }
	static const _SKINEDATA &getSkin(int idx) { return s_vecSkins[idx]; }

protected:
	static std::vector<_SKINEDATA> s_vecSkins;
};

//////

struct _SKIN2FOOD
{
	int number;
	int indexs[3];
};


class FoodData
{
protected:
	FoodData();
	static FoodData *instance;

public:
	static FoodData *getInstance();

	void initWithFile(const char *fileName);

	int getRandomFood();
	int getSkinFood(int skin, int index);

protected:
	int m_totalNumber;
	int m_normalNumber;
	std::vector<_SKIN2FOOD> m_skin2foods;
};


