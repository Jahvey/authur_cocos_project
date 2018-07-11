#ifndef AREA_SYSTEM_H
#define AREA_SYSTEM_H

#include "cocos2d.h"
USING_NS_CC;

// ��������
class AreaObject
{
public:
	Vec2 position;
	void *userData;
};

// ��ѯ�ص��ӿ�
typedef std::function<bool(AreaObject *obj2)> areaQueryCallback;

// ����ϵͳ
class AreaSystem
{
private:
	AreaSystem();
	static AreaSystem *_instance;

public:
	~AreaSystem();
	static AreaSystem *getInstance();
	static void destroyInstance();

	void addObject(AreaObject *obj);
	void removeObject(AreaObject *obj);

	void queryCollisions(const Vec2 &position, float radius, areaQueryCallback callback);

	void setAreaSize(int width, int height) {
		_areaWidth = width;
		_areaHeight = height;
	}

private:
	std::list<AreaObject *> * getAreaList(int areaIndex);
	int getAreaIndex(const Vec2 &pos) {
		return (((int)pos.x) / _areaWidth) + (((int)pos.y) / _areaHeight) * 1000;
	}

private:
	int _areaWidth;
	int _areaHeight;

	std::map<int, std::list<AreaObject *> *> _areas;
};

#endif
