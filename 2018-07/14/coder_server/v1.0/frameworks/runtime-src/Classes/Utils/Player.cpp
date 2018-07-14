#include "Player.h"

Player *Player::instance = nullptr;

Player *Player::getInstance()
{
	if (instance == nullptr)
		instance = new Player;
	return instance;
}

Player::Player()
{
}

Player::~Player()
{
}

void Player::initFromConfig()
{
	auto pUd = UserDefault::getInstance();

	m_account = pUd->getStringForKey("player_account");
	m_nickname = "Me";
	m_coins = pUd->getIntegerForKey("player_coin", 0);
	m_usingSkin = cocos2d::random(0,4);

	m_highestScores[0] = pUd->getIntegerForKey("player_highscore_0", 0);
	m_highestScores[1] = pUd->getIntegerForKey("player_highscore_1", 0);
	m_highestScores[2] = pUd->getIntegerForKey("player_highscore_2", 0);
	m_highestScores[3] = pUd->getIntegerForKey("player_highscore_3", 0);
}

void Player::setAccount(const char *account)
{
	m_account = account;
	UserDefault::getInstance()->setStringForKey("player_account", m_account);
	UserDefault::getInstance()->flush();
}

void Player::setNickname(const char *nickname)
{
	m_nickname = nickname;
	UserDefault::getInstance()->setStringForKey("player_nickname", m_nickname);
	UserDefault::getInstance()->flush();
}

void Player::setUsingSkin(int skin)
{
	m_usingSkin = skin;
	UserDefault::getInstance()->setIntegerForKey("player_skin", m_usingSkin);
	UserDefault::getInstance()->flush();
}

void Player::setCoins(int coins)
{
	m_coins = coins;
	UserDefault::getInstance()->setIntegerForKey("player_coin", m_coins);
	UserDefault::getInstance()->flush();
}

void Player::setHighestScore(int gameMode, int scoreType, int value)
{
	int idx = gameMode * 2 + scoreType;
	if (m_highestScores[idx] >= value)
		return;

	m_highestScores[idx] = value;

	char buf[32];
	sprintf(buf, "player_highscore_%d", idx);
	UserDefault::getInstance()->setIntegerForKey(buf, value);
	UserDefault::getInstance()->flush();
}

std::vector<_RANKITEM> *Player::getRankList(int rankId)
{
	auto it = g_rankDict.find(rankId);
	if (it != g_rankDict.end()) {
		return it->second;
	}
	else {
		auto li = new std::vector<_RANKITEM>();
		g_rankDict.insert(std::make_pair(rankId, li));
		return li;
	}
}

void Player::clearRankLists()
{
	for (auto it = g_rankDict.begin(); it != g_rankDict.end(); it++)
	{
		it->second->clear();
	}
}
