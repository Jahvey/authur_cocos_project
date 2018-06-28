#include "GamePlay/AreaSystem.h"
#include "GamePlay/GameDef.h"

static const Vec2 s_5DirVec[5] = 
{
	Vec2(-1, 1), Vec2(1, 1),
	Vec2(0, 0),
	Vec2(-1, -1), Vec2(1, -1)
};

AreaSystem *AreaSystem::_instance = nullptr;

AreaSystem *AreaSystem::getInstance()
{
	if (_instance == nullptr)
	{
		_instance = new AreaSystem;
	}
	return _instance;
}

void AreaSystem::destroyInstance()
{
	if (_instance != nullptr)
	{
		delete _instance;
		_instance = nullptr;
	}
}

AreaSystem::AreaSystem()
{
	_areaWidth = AREA_WIDTH;
	_areaHeight = AREA_HEIGHT;
}

AreaSystem::~AreaSystem()
{
	for (auto it = _areas.begin(); it != _areas.end(); it++)
	{
		delete it->second;
	}
}

void AreaSystem::addObject(AreaObject *obj)
{
	int areaIndex = getAreaIndex(obj->position);
	auto li = getAreaList(areaIndex);
	li->push_back(obj);
}

void AreaSystem::removeObject(AreaObject *obj)
{
	int areaIndex = getAreaIndex(obj->position);
	auto it = _areas.find(areaIndex);
	if (it != _areas.end())
	{
		it->second->remove(obj);
	}
}

void AreaSystem::queryCollisions(const Vec2 &position, float radius, areaQueryCallback callback)
{
	int buffer[5];
	int bufferLength = 0;

	float disQ = radius * radius;

	for (int i = 0; i < 5; i++)
	{
		Vec2 pos = position + s_5DirVec[i] * radius;
		int index = getAreaIndex(pos);

		bool bDone = false;
		for (int j = 0; j < bufferLength; j++)
		{
			if (buffer[j] == index)
			{
				bDone = true;
				break;
			}
		}

		if (bDone) continue;
		buffer[bufferLength++] = index;

		auto it = _areas.find(index);
		if (it == _areas.end())
			continue;

		for (auto j = it->second->begin(); j != it->second->end(); j++)
		{
			if (position.distanceSquared((*j)->position) <= disQ)
			{
				if (!callback(*j))
					break;
			}
		}
	}
}

std::list<AreaObject *> * AreaSystem::getAreaList(int areaIndex)
{
	auto it = _areas.find(areaIndex);
	if (it != _areas.end()) 
	{
		return it->second;
	}
	else
	{
		auto li = new std::list<AreaObject *>();
		_areas.insert(std::make_pair(areaIndex, li));
		return li;
	}
}
