#include "SkinItem.h"

bool SkinItem::init()
{
	if (!Widget::init())
	{
		return false;
	}
	auto bg = Sprite::create("skin_item.png");
	bg->setAnchorPoint(Vec2::ANCHOR_BOTTOM_LEFT);
	bg->setPosition(0, 0);
	addChild(bg);

	setContentSize(bg->getContentSize());
	setAnchorPoint(Vec2::ANCHOR_BOTTOM_LEFT);
	setTouchEnabled(true);

	selectImage = Sprite::create("skin_in_use_icon.png");
	selectImage->setAnchorPoint(Vec2::ANCHOR_TOP_RIGHT);
	selectImage->setPosition(bg->getContentSize());
	selectImage->setVisible(false);
	addChild(selectImage);
	return true;
}

void SkinItem::initWithSkin(const _SKINEDATA &skinData)
{
	// Œ≤
	if (!skinData.tail.empty())
	{
		auto tail = Sprite::create(skinData.tail);
		tail->setScale(0.8f);
		tail->setAnchorPoint(Vec2::ANCHOR_MIDDLE_TOP);
		tail->setPosition(86, 94);
		addChild(tail);
	}
	
	// …Ì
	for (int i = 0; i < 4; i++)
	{
		auto image = skinData.bodys.at(i % skinData.bodys.size()).c_str();
		auto spr = Sprite::create(image);
		spr->setPosition(86, 110 + i * 32);
		spr->setScale(0.8f);
		addChild(spr);
	}
	
	// Õ∑
	auto head = Node::create();
	head->setContentSize(Size(50, 50));
	head->setScale(0.8f);
	head->setAnchorPoint(Vec2::ANCHOR_MIDDLE);
	head->setPosition(86, 238);
	addChild(head);

	auto sprHead = Sprite::create(skinData.head);
	sprHead->setAnchorPoint(Vec2(0.5f, skinData.headAnchorY));
	sprHead->setPosition(head->getContentSize().width / 2, head->getContentSize().height * skinData.headAnchorY);
	head->addChild(sprHead);
}

void SkinItem::setSelected(bool sel)
{
	selectImage->setVisible(sel);
}

bool SkinItem::isSelected()
{
	return selectImage->isVisible();
}