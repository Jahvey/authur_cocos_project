
#include "GameData.h"
#include "json/document.h"

std::vector<_SKINEDATA> SnakeSkinData::s_vecSkins;

void SnakeSkinData::initSkins(bool bClear)
{
	if (!s_vecSkins.empty() && !bClear)
		return;

	clearSkins();

	std::string jsonStr = FileUtils::getInstance()->getStringFromFile("skin.db");
	
	rapidjson::Document readDoc;
	readDoc.Parse<0>(jsonStr.c_str());

	if (readDoc.HasParseError())
	{
		log("Parse json file 'skin.db' failed. -> %d", readDoc.GetParseError());
		return;
	}

	if (!readDoc.IsArray())
		return;

	for (int i = 0; i < readDoc.Capacity(); i++)
	{
		rapidjson::Value &skin = readDoc[i];
		if (!skin.IsObject())
			continue;

		s_vecSkins.push_back(_SKINEDATA());
		auto &sd = s_vecSkins.back();
		
		if (skin.HasMember("headAnchorY"))
			sd.headAnchorY = (float)skin["headAnchorY"].GetDouble();
		else
			sd.headAnchorY = 0.5f;

		sd.head = skin["head"].GetString();
		
		if (skin.HasMember("tail")) 
		{
			sd.tail = skin["tail"].GetString();
		}

		rapidjson::Value &body = skin["body"];
		for (int j = 0; j < body.Capacity(); j++)
		{
			sd.bodys.push_back(std::string(body[j].GetString()));
		}
	}
}

////////////////////////////////////

FoodData *FoodData::instance = nullptr;

FoodData *FoodData::getInstance()
{
	if (instance == nullptr)
		instance = new FoodData;
	return instance;
}

FoodData::FoodData()
{
	m_totalNumber = 0;
	m_normalNumber = 0;
}

void FoodData::initWithFile(const char *fileName)
{
	std::string jsonStr = FileUtils::getInstance()->getStringFromFile(fileName);

	rapidjson::Document readDoc;
	readDoc.Parse<0>(jsonStr.c_str());

	if (readDoc.HasParseError())
	{
		log("Parse json file 'skin.db' failed. -> %d", readDoc.GetParseError());
		return;
	}

	if (!readDoc.IsObject())
		return;

	if (readDoc.HasMember("totalNumber"))
	{
		m_totalNumber = readDoc["totalNumber"].GetInt();
	}

	if (readDoc.HasMember("normalNumber"))
	{
		m_normalNumber = readDoc["normalNumber"].GetInt();
	}

	if (readDoc.HasMember("skin2food"))
	{
		rapidjson::Value &skin2food = readDoc["skin2food"];
	
		m_skin2foods.clear();
		for (int i = 0; i < skin2food.Capacity(); i++)
		{
			m_skin2foods.push_back(_SKIN2FOOD());
			auto &mbf = m_skin2foods.back();

			rapidjson::Value &bf = skin2food[i];
			for (int j = 0; j < bf.Capacity(); j++)
			{
				mbf.indexs[j] = bf[j].GetInt();
			}
			mbf.number = bf.Capacity();
		}
	}
}

int FoodData::getRandomFood()
{
	if (m_normalNumber == 0)
		return 1;
	else
		return cocos2d::random(1, m_normalNumber);
}

int FoodData::getSkinFood(int skin, int index)
{
	if (skin >= m_skin2foods.size())
		return 1;

	auto &s2f = m_skin2foods[skin];
	index = index % s2f.number;
	return s2f.indexs[index];
}
