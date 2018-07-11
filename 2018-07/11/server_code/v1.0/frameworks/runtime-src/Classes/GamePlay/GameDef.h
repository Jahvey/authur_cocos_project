#pragma once

#define SNAKE_MAX_NUMBER			16
#define SNAKE_MAX_AI				10
#define SNAKE_MIN_RADIUS			25
#define SNAKE_MAX_RADIUS			50
#define SNAKE_INC_RADIUS			(0.01f)
#define SNAKE_MIN_LENGTH			31
#define SNAKE_MAX_LENGTH			4000
#define SNAKE_PATH_PIXEL			6
#define SNAKE_PATH_PER_BODY			6
#define SNAKE_ACC_CONSUMED			4

#define TAG_MAX_NUMBER				16
#define TAG_SNAKE_NUMBER			15
#define TAG_FOOD					0x1000

#define AREA_WIDTH					300
#define AREA_HEIGHT					300

#define FOOD_MAX_NUM				500
#define FOOD_EAT_RADIUS				200
#define FOOD_MOVE_SPEED				400
#define FOOD_MIN_SIZE				16
#define FOOD_MAX_SIZE				32
#define FOOD_INC_SIZE				5
#define FOOD_MIN_VALUE				1
#define FOOD_MAX_VALUE				6

#define CTRL_NEW_AI_DELAY			1.f

#define SCREEN_WIDTH  (Director::getInstance()->getOpenGLView()->getVisibleSize().width)
#define SCREEN_HEIGHT (Director::getInstance()->getOpenGLView()->getVisibleSize().height)
#define FONT_NAME "fonts/default.ttf"
#define SETTING_MUSIC "SETTING_MUSIC"
#define SETTING_EFFECT "SETTING_EFFECT"
#define SETTING_OPERATION "SETTING_OPERATION"
