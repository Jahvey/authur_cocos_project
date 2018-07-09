#pragma once

#include "cocos2d.h"
USING_NS_CC;

#include "GamePlay/Snake.h"

class InitSnakeUtils
{
private:
	InitSnakeUtils();
	static InitSnakeUtils *instance;

public:
	~InitSnakeUtils();
	static InitSnakeUtils *getInstance();
	static void destroyInstance();
	
	void initWithFile(const char *fileName);
	void writeToFile(const char *fileName);

	void addSnake(Snake *s);
	void addSnakes(const std::vector<Snake *> &snakes);

	unsigned int getSnakeNumber() { return _snakes.size(); }
	const std::vector<std::vector<Vec2>> &getAllData() { return _snakes; }
	const std::vector<Vec2> *getRandomSnakeData();

private:
	int readInt(unsigned char *&pReader);
	float readFloat(unsigned char *&pReader);
	void writeInt(unsigned char *&pWriter, int val);
	void writeFloat(unsigned char *&pWriter, float val);

private:
	std::vector<std::vector<Vec2>> _snakes;
};
