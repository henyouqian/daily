#include "stdafx.h"
#include "taskCalc.h"
#include "clock.h"
#include "dmsUI.h"
#import "RobotVC.h"

namespace{
	int getDivNum(int num){
		std::vector<int> _vec;
		for ( int i = 2; i < num; ++i ){
			if ( i * i > num ){
				break;
			}
			if ( num%i == 0 ){
				_vec.push_back(i);
			}
		}
		if ( _vec.empty() ){
			return 0;
		}
		return _vec[rand()%(int)_vec.size()];
	}
	void swapNum(int& num1, int& num2){
		int temp = num1;
		num1 = num2;
		num2 = temp;
	}

	int LIMIT1 = 15;
	int LIMIT2 = 9;
	const int QUEST_NUM = 5;
}

CalcGame::CalcGame(Mode mode):_questNum(0), _isShow(true), _mode(mode){
	std::string font;

	if ( _mode == MODE_1P ){
		font = "arial.fnt";
	}else{
		font = "calibri20.fnt";
	}

	_pUIGrp = new lw::UIGroup;
	if ( _mode == MODE_2P_LEFT ){
		_pUIGrp->setOrient(lw::App::ORIENTATION_DOWN);
	}else if ( _mode == MODE_2P_RIGHT ){
		_pUIGrp->setOrient(lw::App::ORIENTATION_UP);
	}

	_pFontResult = lw::Font::create(font.c_str());
	_pFontResult->setAlign(lw::ALIGN_TOP_MID);

	_pClockFont = lw::Font::create(font.c_str());
	
	if ( _mode == MODE_1P ){
		_pClockFont->setPos(320, 5);
		_pFontResult->setPos(240.f, 140.f);
	}else{
		_pClockFont->setPos(240, 245);
		_pFontResult->setPos(160.f, 350.f);
	}

	_compEq = lw::Font::create(font.c_str());
	_compEq->setAlign(lw::ALIGN_TOP_MID);
	_compEq->setText(L"=");
	_compAdd = lw::Font::create(font.c_str());
	_compAdd->setAlign(lw::ALIGN_TOP_MID);
	_compAdd->setText(L"+");
	_compSub = lw::Font::create(font.c_str());
	_compSub->setAlign(lw::ALIGN_TOP_MID);
	_compSub->setText(L"-");
	_compMul = lw::Font::create(font.c_str());
	_compMul->setAlign(lw::ALIGN_TOP_MID);
	_compMul->setText(L"*");
	_compDiv = lw::Font::create(font.c_str());
	_compDiv->setAlign(lw::ALIGN_TOP_MID);
	_compDiv->setText(L"/");
	_compBrkL = lw::Font::create(font.c_str());
	_compBrkL->setAlign(lw::ALIGN_TOP_MID);
	_compBrkL->setText(L"(");
	_compBrkR = lw::Font::create(font.c_str());
	_compBrkR->setAlign(lw::ALIGN_TOP_MID);
	_compBrkR->setText(L")");

	_comp1 = lw::Font::create(font.c_str());
	_comp1->setAlign(lw::ALIGN_TOP_MID);
	_comp2 = lw::Font::create(font.c_str());
	_comp2->setAlign(lw::ALIGN_TOP_MID);
	_comp3 = lw::Font::create(font.c_str());
	_comp3->setAlign(lw::ALIGN_TOP_MID);
	_comp4 = lw::Font::create(font.c_str());
	_comp4->setAlign(lw::ALIGN_TOP_MID);


	float x1 = 50.f;
	float x2 = 160.f;
	float x3 = 270.f;
	float x4 = 20.f;
	float y1 = 80.f;
	float y2 = 240.f;
	float y3 = 5.f;
	float w1 = 90.f;
	float w2 = 160.f;
	float h1 = 150.f;
	float h2 = 60.f;

	if ( _mode == MODE_2P_LEFT || _mode == MODE_2P_RIGHT ){
		x1 = 60.f;
		x2 = 130.f;
		x3 = 200.f;
		x4 = 15.f;
		y1 = 320.f;
		y2 = 430.f;
		y3 = 245.f;
		w1 = 60.f;
		w2 = 80.f;
		h1 = 100.f;
		h2 = 40.f;
	}
	
    lw::Button9Def def("ui.png", 0, 0, 0, 2, 0, 0, 1, 1, 1, 1, 1, 1, "calibri20.fnt", GL_NEAREST);
	_pBtnOp1 = lw::UIButton::create9(def);
	_pBtnOp1->setPos(x1, y1);
	_pBtnOp1->setSize(w1, h1);
	_pBtnOp1->setText(L"op1");
	_pBtnOp1->setCallback(this);
	_pUIGrp->add(_pBtnOp1);

	_pBtnBrk1 = lw::UIButton::create9(def);
	_pBtnBrk1->setPos(x1, y2);
	_pBtnBrk1->setSize(w1, h2);
	_pBtnBrk1->setText(L"( )");
	_pBtnBrk1->setCallback(this);
	_pUIGrp->add(_pBtnBrk1);

	_pBtnOp2 = lw::UIButton::create9(def);
	_pBtnOp2->setPos(x2, y1);
	_pBtnOp2->setSize(w1, h1);
	_pBtnOp2->setText(L"op2");
	_pBtnOp2->setCallback(this);
	_pUIGrp->add(_pBtnOp2);

	_pBtnBrk2 = lw::UIButton::create9(def);
	_pBtnBrk2->setPos(x2, y2);
	_pBtnBrk2->setSize(w1, h2);
	_pBtnBrk2->setText(L"( )");
	_pBtnBrk2->setCallback(this);
	_pUIGrp->add(_pBtnBrk2);

	_pBtnOK = lw::UIButton::create9(def);
	_pBtnOK->setPos(x3, y1);
	_pBtnOK->setSize(w2, h1);
	_pBtnOK->setText(L"OK");
	_pBtnOK->setCallback(this);
	_pUIGrp->add(_pBtnOK);
	
	_pQuestNumFont = lw::Font::create(font.c_str());
	_pQuestNumFont->setPos(x4, y3);

	

	//reset();
}

CalcGame::~CalcGame(){
	delete _comp1;
	delete _comp2;
	delete _comp3;
	delete _comp4;
	delete _compEq;
	delete _compAdd;
	delete _compSub;
	delete _compMul;
	delete _compDiv;
	delete _compBrkL;
	delete _compBrkR;
	delete _pBtnOp1;
	delete _pBtnOp2;
	delete _pBtnOK;
	delete _pBtnBrk1;
	delete _pBtnBrk2;
	delete _pQuestNumFont;
	delete _pUIGrp;
	delete _pClockFont;
	delete _pFontResult;
}

void CalcGame::setDifficult(DIFFICULT diff){
	if ( diff == DIFF_EASY ){
		LIMIT1 = 6;
		LIMIT2 = 3;
	}else if ( diff == DIFF_NORMAL ){
		LIMIT1 = 10;
		LIMIT2 = 5;
	}else if ( diff == DIFF_HARD ){
		LIMIT1 = 15;
		LIMIT2 = 9;
	}
	 
}

void CalcGame::vOnDown(lw::UIButton* pButton){
	if ( pButton == _pBtnOK ){
		if ( checkFormula() ){
			if ( _questNum == QUEST_NUM ){
				_step = STEP_FINISH;
			}else{
				genFormula();
			}
		}
	}else if ( pButton == _pBtnOp1 ){
		_op1 = (Op)(_op1 + 1);
		if ( _op1 >= OP_NONE ){
			_op1 = OP_ADD;
		}
	}else if ( pButton == _pBtnOp2 ){
		_op2 = (Op)(_op2 + 1);
		if ( _op2 >= OP_NONE ){
			_op2 = OP_ADD;
		}
	}else if ( pButton == _pBtnBrk1 ){
		_precede = 1;
	}else if ( pButton == _pBtnBrk2 ){
		_precede = 2;
	}
	if ( _precede == 0 ){
		if ( _op1 != OP_NONE && _op2 == OP_NONE ){
			_precede = 1;
		}else if ( _op1 == OP_NONE && _op2 != OP_NONE ){
			_precede = 2;
		}
	}
}

void CalcGame::genFormula(FormulaData& data){
	int rd = rand()%2;
	int num1 = 0;
	int num2 = 0;
	int res1 = 0;
	Op op1 = OP_NONE;

	if ( rd == 0 ){
		num1 = rand()%LIMIT1;
		num2 = rand()%LIMIT1;
		res1 = num1 + num2;
		rd = rand()%2;
		if ( rd == 0 ){ //add
			op1 = OP_ADD;
		}else{	//sub
			op1 = OP_SUB;
			swapNum(num1, res1);
		}
	}else{
		num1 = rand()%LIMIT2+1;
		num2 = rand()%LIMIT2+1;
		res1 = num1 * num2;
		rd = rand()%2;
		if ( rd == 0 ){ //mul
			op1 = OP_MUL;
		}else{	//div
			op1 = OP_DIV;
			swapNum(num1, res1);
		}
	}
	int sepNum = rand()%2;
	int num = 0;
	if ( sepNum == 0 ){	// first operand
		num = num1;
	}else{
		num = num2;
	}

	int num3 = getDivNum(num);

	Op op2 = OP_NONE;
	if ( num3 != 0 ){
		rd = rand()%4;
		if ( rd == 0 ){
			op2 = OP_ADD;
		}else if ( rd == 1 ){
			op2 = OP_SUB;
		}else if ( rd == 2 ){
			op2 = OP_MUL;
		}else if ( rd == 3 ){
			op2 = OP_DIV;
		}
	}else{
		rd = rand()%3;
		if ( rd == 0 ){
			op2 = OP_ADD;
		}else if ( rd == 1 ){
			op2 = OP_SUB;
		}else if ( rd == 2 ){
			op2 = OP_MUL;
		}
	}
	int res2;
	if ( op2 == OP_ADD ){
		num3 = rand()%LIMIT1;
		res2 = num+num3;
		op2 = OP_SUB;
	}else if ( op2 == OP_SUB ){
		if ( num == 0 ){
			num3 = 0;
		}else{
			num3 = rand()%min(num, LIMIT1);
		}
		res2 = num-num3;
		op2 = OP_ADD;
	}else if ( op2 == OP_MUL ){
		num3 = rand()%LIMIT2+1;
		res2 = num*num3;
		op2 = OP_DIV;
	}else if ( op2 == OP_DIV ){
		res2 = num/num3;
		op2 = OP_MUL;
	}

	data.num4 = res1;
	if ( num == num1 ){
		data.num1 = res2;
		data.num2 = num3;
		data.num3 = num2;
	}else{
		data.num1 = num1;
		data.num2 = res2;
		data.num3 = num3;
	}
}

void CalcGame::genFormula(){
	FormulaData fData;
	fData = TaskCalc::s().getFormula(_questNum);
	++_questNum;
	std::wstringstream ss;
	ss << "Quest:" << _questNum;
	_pQuestNumFont->setText(ss.str().c_str());

	_num1 = fData.num1;
	_num2 = fData.num2;
	_num3 = fData.num3;
	_num4 = fData.num4;

	{
		std::wstringstream ss;
		ss << _num1;
		_comp1->setText(ss.str().c_str());
	}
	{
		std::wstringstream ss;
		ss << _num2;
		_comp2->setText(ss.str().c_str());
	}
	{
		std::wstringstream ss;
		ss << _num3;
		_comp3->setText(ss.str().c_str());
	}
	{
		std::wstringstream ss;
		ss << _num4;
		_comp4->setText(ss.str().c_str());
	}

	_op1 = _op2 = OP_NONE;
	_precede = 0;
}

void CalcGame::strOP(std::string& str, Op op){
	if ( op == OP_ADD ){
		str = "+";
	}else if ( op == OP_SUB ){
		str = "-";
	}else if ( op == OP_MUL ){
		str = "*";
	}else if ( op == OP_DIV ){
		str = "/";
	}
}

void CalcGame::setStep(Step step){
	_step = step;
	if ( step == STEP_WIN ){
		_pFontResult->setText(L"YOU WIN!");
	}else if ( step == STEP_LOSE ){
		_pFontResult->setText(L"YOU LOSE!");
	}else if ( step == STEP_DRAW){
		_pFontResult->setText(L"DRAW");
	}
}

void CalcGame::show(bool b){
	_isShow = b;
	_pUIGrp->show(b);
}

void CalcGame::reset(){
	_questNum = 0;
	_step = STEP_PLAY;
	genFormula();
	_t = 0.f;
}

void CalcGame::main(float dt){
	if ( _step == STEP_PLAY ){
		_t += dt;
	}
	std::wstring ss;
	Clock::toString(ss, (int)_t);
	_pClockFont->setText(ss.c_str());
}

bool CalcGame::checkFormula(){
	if ( _op1 != OP_NONE && _op2 != OP_NONE ){
		float r = 0;
		if ( _precede == 1 ){
			switch (_op1)
			{
			case OP_ADD:
				r = (float)_num1 + _num2;
				break;
			case OP_SUB:
				r = (float)_num1 - _num2;
				break;
			case OP_MUL:
				r = (float)_num1 * _num2;
				break;
			case OP_DIV:
				if ( _num2 == 0 ){
					return false;
				}
				r = (float)_num1 / _num2;
				break;
            default:
                break;
			}
			switch (_op2)
			{
			case OP_ADD:
				r = r + _num3;
				break;
			case OP_SUB:
				r = r - _num3;
				break;
			case OP_MUL:
				r = r * _num3;
				break;
			case OP_DIV:
				if ( _num3 == 0 ){
					return false;
				}
				r = r / _num3;
				break;
            default:
                break;
			}
		}else{
			switch (_op2)
			{
			case OP_ADD:
				r = (float)_num2 + _num3;
				break;
			case OP_SUB:
				r = (float)_num2 - _num3;
				break;
			case OP_MUL:
				r = (float)_num2 * _num3;
				break;
			case OP_DIV:
				if ( _num3 == 0 ){
					return false;
				}
				r = (float)_num2 / _num3;
				break;
            default:
                break;
			}
			switch (_op1)
			{
			case OP_ADD:
				r = _num1 + r;
				break;
			case OP_SUB:
				r = _num1 - r;
				break;
			case OP_MUL:
				r = _num1 * r;
				break;
			case OP_DIV:
				if ( r == 0 ){
					return false;
				}
				r = _num1 / r;
				break;
            default:
                break;
			}
		}
		if ( fabs(r - _num4) < 0.001f ){
			return true;
		}else{
			return false;
		}
	}else{
		return false;
	}
}

void CalcGame::collect(){
	if ( !_isShow ){
		return;
	}

	if ( _step == STEP_PLAY ){
		if ( _mode == MODE_1P ){
			float x = 50.f;
			float y = 40.f;
			float stepX = 100;
			float brkOffset = 20;
			if ( _precede == 1 ){
				_compBrkL->setPos(x-brkOffset, y);
				_compBrkL->collect();
			}
			_comp1->setPos(x, y);
			_comp1->collect();
			switch (_op1)
			{
			case OP_ADD:
				_compAdd->setPos(x+stepX/2.f, y);
				_compAdd->collect();
				break;
			case OP_SUB:
				_compSub->setPos(x+stepX/2.f, y);
				_compSub->collect();
				break;
			case OP_MUL:
				_compMul->setPos(x+stepX/2.f, y);
				_compMul->collect();
				break;
			case OP_DIV:
				_compDiv->setPos(x+stepX/2.f, y);
				_compDiv->collect();
				break;
			default:
				break;
			}
			x += stepX;
			if ( _precede == 2 ){
				_compBrkL->setPos(x-brkOffset, y);
				_compBrkL->collect();
			}
			_comp2->setPos(x, y);
			_comp2->collect();
			if ( _precede == 1 ){
				_compBrkR->setPos(x+brkOffset, y);
				_compBrkR->collect();
			}
			switch (_op2)
			{
			case OP_ADD:
				_compAdd->setPos(x+stepX/2.f, y);
				_compAdd->collect();
				break;
			case OP_SUB:
				_compSub->setPos(x+stepX/2.f, y);
				_compSub->collect();
				break;
			case OP_MUL:
				_compMul->setPos(x+stepX/2.f, y);
				_compMul->collect();
				break;
			case OP_DIV:
				_compDiv->setPos(x+stepX/2.f, y);
				_compDiv->collect();
				break;
			default:
				break;
			}
			x += stepX;
			_comp3->setPos(x, y);
			_comp3->collect();
			if ( _precede == 2 ){
				_compBrkR->setPos(x+brkOffset, y);
				_compBrkR->collect();
			}
			_compEq->setPos(x+stepX/2.f, y);
			_compEq->collect();
			x += stepX;
			_comp4->setPos(x, y);
			_comp4->collect();
			_pQuestNumFont->collect();
			_pClockFont->collect();
		}else{
			if ( _mode == MODE_2P_LEFT ){
				lw::Sprite::flush();
				lw::App::s().setOrient(lw::App::ORIENTATION_DOWN);
			}else if ( _mode == MODE_2P_RIGHT ){
				lw::Sprite::flush();
				lw::App::s().setOrient(lw::App::ORIENTATION_UP);
			}

			float x = 50.f;
			float y = 40.f+240.f;
			float stepX = 70;
			float brkOffset = 20;
			if ( _precede == 1 ){
				_compBrkL->setPos(x-brkOffset, y);
				_compBrkL->collect();
			}
			_comp1->setPos(x, y);
			_comp1->collect();
			switch (_op1)
			{
			case OP_ADD:
				_compAdd->setPos(x+stepX/2.f, y);
				_compAdd->collect();
				break;
			case OP_SUB:
				_compSub->setPos(x+stepX/2.f, y);
				_compSub->collect();
				break;
			case OP_MUL:
				_compMul->setPos(x+stepX/2.f, y);
				_compMul->collect();
				break;
			case OP_DIV:
				_compDiv->setPos(x+stepX/2.f, y);
				_compDiv->collect();
				break;
			default:
				break;
			}
			x += stepX;
			if ( _precede == 2 ){
				_compBrkL->setPos(x-brkOffset, y);
				_compBrkL->collect();
			}
			_comp2->setPos(x, y);
			_comp2->collect();
			if ( _precede == 1 ){
				_compBrkR->setPos(x+brkOffset, y);
				_compBrkR->collect();
			}
			switch (_op2)
			{
			case OP_ADD:
				_compAdd->setPos(x+stepX/2.f, y);
				_compAdd->collect();
				break;
			case OP_SUB:
				_compSub->setPos(x+stepX/2.f, y);
				_compSub->collect();
				break;
			case OP_MUL:
				_compMul->setPos(x+stepX/2.f, y);
				_compMul->collect();
				break;
			case OP_DIV:
				_compDiv->setPos(x+stepX/2.f, y);
				_compDiv->collect();
				break;
			default:
				break;
			}
			x += stepX;
			_comp3->setPos(x, y);
			_comp3->collect();
			if ( _precede == 2 ){
				_compBrkR->setPos(x+brkOffset, y);
				_compBrkR->collect();
			}
			_compEq->setPos(x+stepX/2.f, y);
			_compEq->collect();
			x += stepX;
			_comp4->setPos(x, y);
			_comp4->collect();
			_pQuestNumFont->collect();
			_pClockFont->collect();
			if ( _mode == MODE_2P_LEFT || _mode == MODE_2P_RIGHT ){
				lw::Sprite::flush();
				lw::App::s().popOrient();
			}
		}
		_pUIGrp->draw();
	}else if ( _step == STEP_WIN || _step == STEP_LOSE || _step == STEP_DRAW ){
		if ( _mode == MODE_2P_LEFT ){
			lw::Sprite::flush();
			lw::App::s().setOrient(lw::App::ORIENTATION_DOWN);
		}else if ( _mode == MODE_2P_RIGHT ){
			lw::Sprite::flush();
			lw::App::s().setOrient(lw::App::ORIENTATION_UP);
		}
		_pFontResult->collect();
		if ( _mode == MODE_2P_LEFT || _mode == MODE_2P_RIGHT ){
			lw::Sprite::flush();
			lw::App::s().popOrient();
		}
	}
}

void TaskCalc::vBegin(){
#ifdef WIN32
	srand(GetTickCount());
#endif
#ifdef __APPLE__
	srand(clock());
#endif

	lw::UISetAutoDraw(false);
    lw::App::s().setOrient(lw::App::ORIENTATION_RIGHT);

	_p1PGame = new CalcGame(CalcGame::MODE_1P);
	_pLeftGame = new CalcGame(CalcGame::MODE_2P_LEFT);
	_pRightGame = new CalcGame(CalcGame::MODE_2P_RIGHT);

	float x0 = 30;
	float x = x0;
	float y = 30;
	float w = 210;
	float h = 100;
	_pGrpMode = new lw::UIGroup;
    lw::CheckBox9Def def("ui.png", 0, 0, 0, 2, 0, 0, 1, 1, 1, 1, 1, 1, "calibri20.fnt", GL_NEAREST);
	_pCb1p = lw::UICheckBox::create9(def);
	_pCb1p->setPos(x, y);
	_pCb1p->setSize(w, h);
	_pCb1p->setText(L"1P");
	_pCb1p->setCheckOnly();
	_pCb1p->setCallback(this);
	_pGrpMode->add(_pCb1p);
	_pCb1p->check(true);
	x += w-1;
	_pCb2p = lw::UICheckBox::create9(def);
	_pCb2p->setPos(x, y);
	_pCb2p->setSize(w-1, h);
	_pCb2p->setText(L"2P");
	_pCb2p->setCheckOnly();
	_pCb2p->setCallback(this);
	_pGrpMode->add(_pCb2p);

	x = x0;
	y += h-1;
	w = 140;
	_pCbEasy = lw::UICheckBox::create9(def);
	_pCbEasy->setPos(x, y);
	_pCbEasy->setSize(w, h);
	_pCbEasy->setText(L"Easy");
	_pCbEasy->setCheckOnly();
	_pCbEasy->setCallback(this);
	_pGrpMode->add(_pCbEasy);
	_pCbEasy->check(true);
	x += w-1;
	_pCbNormal = lw::UICheckBox::create9(def);
	_pCbNormal->setPos(x, y);
	_pCbNormal->setSize(w, h);
	_pCbNormal->setText(L"Normal");
	_pCbNormal->setCheckOnly();
	_pCbNormal->setCallback(this);
	_pGrpMode->add(_pCbNormal);
	x += w-1;
	_pCbHard = lw::UICheckBox::create9(def);
	_pCbHard->setPos(x, y);
	_pCbHard->setSize(w, h);
	_pCbHard->setText(L"Hard");
	_pCbHard->setCheckOnly();
	_pCbHard->setCallback(this);
	_pGrpMode->add(_pCbHard);

	x = x0;
	y += h+20;
	h = 60;
    lw::Button9Def btnDefSimple9("ui.png", 0, 0, 0, 2, 0, 0, 1, 1, 1, 1, 1, 1, "calibri20.fnt", GL_NEAREST);
    
	_pBtnDms = lw::UIButton::create9(btnDefSimple9);
    _pBtnDms->setPos(20, y);
	_pBtnDms->setSize(60, h);
	_pBtnDms->setText(L"Dms");
	_pBtnDms->setCallback(this);
    _pGrpMode->add(_pBtnDms);
    
    _pBtnRobot = lw::UIButton::create9(btnDefSimple9);
    _pBtnRobot->setPos(130, y);
	_pBtnRobot->setSize(60, h);
	_pBtnRobot->setText(L"Robot");
	_pBtnRobot->setCallback(this);
    _pGrpMode->add(_pBtnRobot);

	x = 308.f;
	_pBtnStart = lw::UIButton::create9(btnDefSimple9);
	_pBtnStart->setPos(x, y);
	_pBtnStart->setSize(w, h);
	_pBtnStart->setText(L"Start");
	_pBtnStart->setCallback(this);
	_pGrpMode->add(_pBtnStart);


	_pGrpFinish = new lw::UIGroup;

	_pBtnQuit = lw::UIButton::create9(btnDefSimple9);
	_pBtnQuit->setPos(x0, y);
	_pBtnQuit->setSize(w, h);
	_pBtnQuit->setText(L"Quit");
	_pBtnQuit->setCallback(this);
	_pGrpFinish->add(_pBtnQuit);

	_pBtnRetry = lw::UIButton::create9(btnDefSimple9);
	_pBtnRetry->setPos(480.f-x0-w, y);
	_pBtnRetry->setSize(w, h);
	_pBtnRetry->setText(L"Retry");
	_pBtnRetry->setCallback(this);
	_pGrpFinish->add(_pBtnRetry);

	reset();
}

void TaskCalc::reset(){
	_step = STEP_MODE;
	_pLeftGame->show(false);
	_pGrpMode->show(true);
	_pGrpFinish->show(false);
}

void TaskCalc::startGame(){
	_step = STEP_PLAY;
	_pGrpMode->show(false);
	_pGrpFinish->show(false);
	
	if ( _pCb1p->isChecked() ){
		_p1PGame->show(true);
		_pLeftGame->show(false);
		_pRightGame->show(false);
        if ( _pCbEasy->isChecked() ){
            _p1PGame->setDifficult(CalcGame::DIFF_EASY);
        }else if ( _pCbNormal->isChecked() ){
            _p1PGame->setDifficult(CalcGame::DIFF_NORMAL);
        }else if ( _pCbHard->isChecked() ){
            _p1PGame->setDifficult(CalcGame::DIFF_HARD);
        }
		_formulas.clear();
		for ( int i = 0; i < QUEST_NUM; ++i ){
			CalcGame::FormulaData data;
			CalcGame::genFormula(data);
			_formulas.push_back(data);
		}
		_p1PGame->reset();
	}else if ( _pCb2p->isChecked() ){
		_p1PGame->show(false);
		_pLeftGame->show(true);
		_pRightGame->show(true);
        if ( _pCbEasy->isChecked() ){
            _pLeftGame->setDifficult(CalcGame::DIFF_EASY);
            _pRightGame->setDifficult(CalcGame::DIFF_EASY);
        }else if ( _pCbNormal->isChecked() ){
            _pLeftGame->setDifficult(CalcGame::DIFF_NORMAL);
            _pRightGame->setDifficult(CalcGame::DIFF_NORMAL);
        }else if ( _pCbHard->isChecked() ){
            _pLeftGame->setDifficult(CalcGame::DIFF_HARD);
            _pRightGame->setDifficult(CalcGame::DIFF_HARD);
        }
		_formulas.clear();
		for ( int i = 0; i < QUEST_NUM; ++i ){
			CalcGame::FormulaData data;
			CalcGame::genFormula(data);
			_formulas.push_back(data);
		}
		_pLeftGame->reset();
		_pRightGame->reset();
	}
	
}

void TaskCalc::vEnd(){
	delete _p1PGame;
	delete _pLeftGame;
	delete _pRightGame;
	delete _pCb1p;
	delete _pCb2p;
	delete _pCbEasy;
	delete _pCbNormal;
	delete _pCbHard;
	delete _pBtnStart;
	delete _pGrpMode;
	delete _pGrpFinish;
	delete _pBtnQuit;
	delete _pBtnRetry;
	lw::UISetAutoDraw(true);
    lw::App::s().popOrient();
    
    delete _pBtnDms;
    delete _pBtnRobot;
}

void TaskCalc::vMain(float dt){
	if ( _step == STEP_PLAY ){
		if ( _pCb1p->isChecked() ){
			_p1PGame->main(dt);
			CalcGame::Step step = _p1PGame->getStep();
			if ( step == CalcGame::STEP_FINISH ){
				_p1PGame->setStep(CalcGame::STEP_WIN);
				_pGrpFinish->show(true);
				_step = STEP_FINISH;
			}
		}else if ( _pCb2p->isChecked() ){
			_pLeftGame->main(dt);
			_pRightGame->main(dt);

			CalcGame::Step stepLeft = _pLeftGame->getStep();
			CalcGame::Step stepRight = _pRightGame->getStep();
			if ( stepLeft == CalcGame::STEP_FINISH ){
				if ( stepRight == CalcGame::STEP_FINISH ){
					_pLeftGame->setStep(CalcGame::STEP_DRAW);
					_pRightGame->setStep(CalcGame::STEP_DRAW);
				}else{
					_pLeftGame->setStep(CalcGame::STEP_WIN);
					_pRightGame->setStep(CalcGame::STEP_LOSE);
				}
				_step = STEP_FINISH;
				_pGrpFinish->show(true);
			}else if ( stepRight == CalcGame::STEP_FINISH ){
				_pLeftGame->setStep(CalcGame::STEP_LOSE);
				_pRightGame->setStep(CalcGame::STEP_WIN);
				_step = STEP_FINISH;
				_pGrpFinish->show(true);
			}
		}
	}
}

void TaskCalc::vDraw(float dt){
	glClearColor(0.2f, 0.2f, 0.2f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

	glDisable(GL_LIGHTING);
	glDepthMask(GL_FALSE);

	if ( _step == STEP_MODE ){
		_pGrpMode->draw();
	}else if ( _step == STEP_PLAY ){
		_p1PGame->collect();
		_pLeftGame->collect();
		_pRightGame->collect();
	}else if ( _step == STEP_FINISH ){
		_p1PGame->collect();
		_pLeftGame->collect();
		_pRightGame->collect();
		//lw::App::s().setOrient(lw::App::ORIENTATION_RIGHT);
		_pGrpFinish->draw();
		//lw::Sprite::flush();
	}
}

void TaskCalc::vOnCheck(lw::UICheckBox* pCb, bool checked){
	if ( pCb == _pCb1p ){
		_pCb2p->check(false);
	}else if ( pCb == _pCb2p ){
		_pCb1p->check(false);
	}else if ( pCb == _pCbEasy ){
		_pCbNormal->check(false);
		_pCbHard->check(false);
	}else if ( pCb == _pCbNormal ){
		_pCbEasy->check(false);
		_pCbHard->check(false);
	}else if ( pCb == _pCbHard ){
		_pCbNormal->check(false);
		_pCbEasy->check(false);
	}
}

void TaskCalc::vOnClick(lw::UIButton* pButton){
	if ( pButton == _pBtnStart || pButton == _pBtnRetry  ){
		startGame();
	}else if ( pButton == _pBtnDms ) {
        dmsUI();
	}else if ( pButton == _pBtnRobot ) {
        robotView();
	}
}

bool TaskCalc::vOnTouchEvent(std::vector<lw::TouchEvent>& events){
	return false;
}

const CalcGame::FormulaData& TaskCalc::getFormula(int idx){
	lwassert( idx >= 0 && idx < (int)_formulas.size() );
	return _formulas[idx];
}