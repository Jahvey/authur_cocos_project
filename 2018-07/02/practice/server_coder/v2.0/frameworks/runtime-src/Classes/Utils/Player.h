#pragma once

#include "cocos2d.h"
USING_NS_CC;

struct _RANKITEM
{
	std::string nickname;
	int score;
};


class Player
{
protected:
	Player();
	static Player *instance;
	
public:
	~Player();
	static Player *getInstance();

	void initFromConfig();

	void setAccount(const char *account);
	const std::string &getAccount() { return m_account; }

	void setToken(const char *token) { m_token = token; }
	const std::string &getToken() { return m_token; }

	void setUserId(int id) { m_userId = id; }
	int  getUserId() { return m_userId; }

	void setGameId(int id) { m_gameId = id; }
	int  getGameId() { return m_gameId; }

	void setNickname(const char *nickname);
	const std::string &getNickname() { return m_nickname; }
	
	void setUsingSkin(int skin);
	int  getUsingSkin() { return m_usingSkin; }

	void setCoins(int coins);
	int  getCoins() { return m_coins; }
	
	void setHighestScore(int gameMode, int scoreType, int value);
	int  getHighestScore(int gameMode, int scoreType) {
		return m_highestScores[gameMode * 2 + scoreType];
	}

protected:
	std::string m_account;
	std::string m_token;
	int m_userId;
	int m_gameId;

	std::string m_nickname;
	int m_coins;
	int m_usingSkin;

	int m_highestScores[4];

public:
	std::map<int, std::vector<_RANKITEM> *> g_rankDict;
	std::vector<_RANKITEM> *getRankList(int rankId);
	void clearRankLists();
};
