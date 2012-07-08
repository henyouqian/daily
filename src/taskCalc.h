#ifndef __TASK_CALC_H__
#define __TASK_CALC_H__

class CalcGame: public lw::ButtonCallback{
public:
	enum Mode{
		MODE_1P,
		MODE_2P_LEFT,
		MODE_2P_RIGHT,
	};
	CalcGame(Mode mode);
	~CalcGame();
	void reset();
	void main(float dt);
	void collect();
	virtual void vOnDown(lw::UIButton* pButton);

	void genFormula();
	bool checkFormula();

	struct FormulaData{
		int num1, num2, num3, num4;
	};
	static void genFormula(FormulaData& data);

	enum Step{
		STEP_PLAY,
		STEP_FINISH,
		STEP_WIN,
		STEP_LOSE,
		STEP_DRAW,
	};
	Step getStep(){
		return _step;
	}
	void setStep(Step step);
	void show(bool b);
	
	enum DIFFICULT{
		DIFF_EASY,
		DIFF_NORMAL,
		DIFF_HARD,
	};
	void setDifficult(DIFFICULT diff);

	

private:
	int _precede;

	enum Op{
		OP_ADD,
		OP_SUB,
		OP_MUL,
		OP_DIV,
		OP_NONE,
	};
	int _num1, _num2, _num3, _num4;
	Op _op1, _op2;
	lw::Font* _comp1, *_comp2, *_comp3, *_comp4;
	lw::Font *_compEq, *_compAdd, *_compSub, *_compMul, *_compDiv;
	lw::Font *_compBrkL, *_compBrkR;
	lw::UIButton* _pBtnOp1;
	lw::UIButton* _pBtnOp2;
	lw::UIButton* _pBtnOK;
	lw::UIButton* _pBtnBrk1;
	lw::UIButton* _pBtnBrk2;
	lw::Font* _pFontResult;
	lw::Font* _pQuestNumFont;
	int _questNum;
	lw::UIGroup* _pUIGrp;
	bool _isShow;
	Step _step;
	Mode _mode;
	float _t;
	lw::Font* _pClockFont;

private:
	void strOP(std::string& str, Op op);
};

class ExitBtn;

class TaskCalc : public lw::Task, public lw::CheckBoxCallback, public lw::ButtonCallback, public lw::Singleton<TaskCalc>{
public:
	virtual void vBegin();
	virtual void vEnd();
	virtual void vMain(float dt);
	virtual void vDraw(float dt);
	virtual bool vOnTouchEvent(std::vector<lw::TouchEvent>& events);
	virtual void vOnCheck(lw::UICheckBox* pCb, bool checked);
	virtual void vOnClick(lw::UIButton* pButton);

	const CalcGame::FormulaData& getFormula(int idx);

private:
	void reset();
	void startGame();
	CalcGame* _p1PGame;
	CalcGame* _pLeftGame;
	CalcGame* _pRightGame;

	enum Step{
		STEP_MODE,
		STEP_PLAY,
		STEP_FINISH,
	};
	Step _step;

	lw::UICheckBox* _pCb1p;
	lw::UICheckBox* _pCb2p;
	lw::UICheckBox* _pCbEasy;
	lw::UICheckBox* _pCbNormal;
	lw::UICheckBox* _pCbHard;
	lw::UIButton* _pBtnStart;
	lw::UIGroup* _pGrpMode;
	lw::UIButton* _pBtnQuit;
	lw::UIButton* _pBtnRetry;
	lw::UIGroup* _pGrpFinish;
	std::vector<CalcGame::FormulaData> _formulas;
    
    lw::UIButton* _pBtnDms;
    lw::UIButton* _pBtnRobot;
};


#endif //__TASK_CALC_H__