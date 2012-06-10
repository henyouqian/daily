#ifndef __TASK_YESORNO_H__
#define __TASK_YESORNO_H__

struct YNPatal;

class YNFlower{
public:
	YNFlower();
	~YNFlower();
    void reset();
	void setText(const wchar_t* text1, const wchar_t* text2);
	void main(float dt);
	void draw();
	bool onGesture(const lw::Gesture& gesture);

private:
	void onPatalLeave();
	lw::Sprite* _pSptHeart;
	std::vector<YNPatal*> _pSptPetals;
	lw::Font* _pFont1;
	lw::Font* _pFont2;
	bool _isFont1;
	float _posX, _posY;
	int _petalNum;
	float _t;
	float _heartV;
};

class TaskYesOrNo : public lw::Task, public lw::Singleton<TaskYesOrNo>, lw::ButtonCallback{
public:
	virtual void vBegin();
	virtual void vEnd();
	virtual void vMain(float dt);
	virtual void vDraw(float dt);
    virtual void vGesture(const lw::Gesture* pGst);
    virtual void vOnClick(lw::UIButton* pButton);

private:
	enum Step{
		STEP_PLAY,
		STEP_RESULT,
	};
	Step _step;
	YNFlower* _pFlower;
    lw::UIButton* _pBtnReset;
    lw::UIButton* _pBtnDms;
    lw::UIButton* _pBtnRobot;
};

extern "C" void robotView();


#endif //__TASK_YESORNO_H__