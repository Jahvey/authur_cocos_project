#include "InitSnakeUtils.h"
#include "GamePlay/GameDef.h"


InitSnakeUtils *InitSnakeUtils::instance = nullptr;

InitSnakeUtils *InitSnakeUtils::getInstance()
{
	if (instance == nullptr) {
		instance = new InitSnakeUtils;
	}
	return instance;
}

void InitSnakeUtils::destroyInstance()
{
	if (instance)
	{
		delete instance;
		instance = nullptr;
	}
}

InitSnakeUtils::InitSnakeUtils()
{
}

InitSnakeUtils::~InitSnakeUtils()
{
}

void InitSnakeUtils::initWithFile(const char *fileName)
{
	if (!_snakes.empty())
		return;

	Data data = FileUtils::getInstance()->getDataFromFile(fileName);
	unsigned char *pReader = data.getBytes();
	
	if (pReader == nullptr || data.getSize() == 0)
		return;

	int snakeNumber = readInt(pReader);
	if (snakeNumber == 0)
		return;
	
#if 0
	auto tmpReader = pReader;
	unsigned int size = 4 + snakeNumber * 4;
	for (int i = 0; i < snakeNumber; i++)
	{
		size += readInt(tmpReader) * 8;
	}

	if (size != data.getSize())
	{
		log("Error: The calculated size is larger than real size. %d > %d ", size, data.getSize());
		return;
	}
#endif

	auto pBodyReader = pReader + snakeNumber * 4;

	for (int i = 0; i < snakeNumber; i++)
	{
		_snakes.push_back(std::vector<Vec2>());
		auto &bodys = _snakes.back();

		int length = readInt(pReader);		
		for (int j = 0; j < length; j++)
		{
			float x = readFloat(pBodyReader);
			float y = readFloat(pBodyReader);
			bodys.push_back(Vec2(x, y));
		}
	}

	std::sort(_snakes.begin(), _snakes.end(), [](const std::vector<Vec2> &s1, const std::vector<Vec2> &s2){
		return s1.size() < s2.size();
	});

}

void InitSnakeUtils::writeToFile(const char *fileName)
{
	int snakeNumber = _snakes.size();
	if (snakeNumber == 0)
		return;

	unsigned int size = 4 + snakeNumber * 4;
	for (int i = 0; i < snakeNumber; i++)
	{
		size += _snakes[i].size() * 8;
	}

	unsigned char *buffer = (unsigned char *)malloc(size);

	// 写进buffer
	unsigned char *pWriter = buffer;
	writeInt(pWriter, snakeNumber);
	
	for (int i = 0; i < snakeNumber; i++)
	{
		writeInt(pWriter, _snakes[i].size());
	}

	for (int i = 0; i < snakeNumber; i++)
	{
		for (auto it = _snakes[i].begin(); it != _snakes[i].end(); it++)
		{
			writeFloat(pWriter, (*it).x);
			writeFloat(pWriter, (*it).y);
		}
	}


	// 写进文件
	Data data;
	data.copy(buffer, size);
	FileUtils::getInstance()->writeDataToFile(data, fileName);

	free(buffer);
}

int InitSnakeUtils::readInt(unsigned char *&pReader)
{
	int ret = *((int *)pReader);
	pReader += 4;
	return ret;
}

float InitSnakeUtils::readFloat(unsigned char *&pReader)
{
	float ret = *((float *)pReader);
	pReader += 4;
	return ret;
}

void InitSnakeUtils::writeInt(unsigned char *&pWriter, int val)
{
	*((int *)pWriter) = val;
	pWriter += 4;
}

void InitSnakeUtils::writeFloat(unsigned char *&pWriter, float val)
{
	*((float *)pWriter) = val;
	pWriter += 4;
}

void InitSnakeUtils::addSnake(Snake *s)
{
	_snakes.push_back(std::vector<Vec2>());
	auto &bodys = _snakes.back();

	bodys.push_back(s->getDir());

	int index = s->m_headIndex;
	for (int i = 0; i < s->m_bodyList.size(); i++)
	{
		bodys.push_back(s->m_bodyList[index]->position);
		index = (index + 1) % s->m_bodyList.size();
	}
}

void InitSnakeUtils::addSnakes(const std::vector<Snake *> &snakes)
{
	_snakes.clear();
	for (auto it = snakes.begin(); it != snakes.end(); it++)
	{
		addSnake(*it);
	}
}

const std::vector<Vec2> *InitSnakeUtils::getRandomSnakeData()
{
	if (_snakes.empty())
		return nullptr;

	int idx = cocos2d::random(0, (int)_snakes.size());
	return &_snakes[idx];
}
