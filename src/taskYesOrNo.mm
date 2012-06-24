#include "stdafx.h"
#include "taskYesOrNo.h"
#include "dmsUI.h"
#import "RobotVC.h"


void showTask(){
    TaskYesOrNo::s().show(true);
}

void hideTask(){
    TaskYesOrNo::s().show(false);
} 

struct YNPatal{
	YNPatal(){
		reset();
	}
	~YNPatal(){
		delete pSprite;
	}
    void reset(){
        rotSpd = 0.f;
        touchX = -1;
        touchY = -1;
        gesId = -1;
        isLeave = false;
        v[0] = 0.f;
		v[1] = 0.f;
    }
    
	lw::Sprite* pSprite;
	float posX0, posY0;
	float rotSpd;
	cml::Vector2 v;
	int touchX, touchY;
	int gesId;
	int id;
	float dir;
	bool isLeave;
};

YNFlower::YNFlower():_t(9999.f), _heartV(0){
	_posX = 160.f;
	_posY = 240.f;

	_isFont1 = false;//cml::random_binary()!=0;

	_pSptHeart = lw::Sprite::create("YNFlower.png");
	_pSptHeart->setUV(0, 0, 44, 44);
	_pSptHeart->setAnchor(22, 22);
	_pSptHeart->setPos(_posX, _posY);
	_pSptHeart->setScale(1.2f, 1.2f);

    lw::Color clr(255, 100, 0, 255);
	_pFont1 = lw::Font::create("arial.fnt");
	_pFont1->setAlign(lw::ALIGN_MID_MID);
	_pFont1->setColor(clr);
	_pFont2 = lw::Font::create("arial.fnt");
	_pFont2->setAlign(lw::ALIGN_MID_MID);
	_pFont2->setColor(clr);
    _pFont1->setText(L"Yes");
	_pFont2->setText(L"No");
    
    reset();
}
YNFlower::~YNFlower(){
	delete _pSptHeart;
	std::vector<YNPatal*>::iterator it = _pSptPetals.begin();
	std::vector<YNPatal*>::iterator itEnd = _pSptPetals.end();
	for ( ; it != itEnd; ++it ){
		delete *it;
	}
	delete _pFont1;
	delete _pFont2;
}

void YNFlower::reset(){
    _t = 9999.f;
    _heartV = 0.f;
    _isFont1 = false;
    _pSptHeart->setPos(_posX, _posY);
    
    std::vector<YNPatal*>::iterator it = _pSptPetals.begin();
	std::vector<YNPatal*>::iterator itEnd = _pSptPetals.end();
	for ( ; it != itEnd; ++it ){
		delete *it;
	}
    _pSptPetals.clear();
    
    _petalNum = cml::random_integer(18, 19);
    for ( int i = 0; i < _petalNum; ++i ){
		YNPatal* pPatal = new YNPatal;
		lw::Sprite* p = lw::Sprite::create("YNFlower.png");
		p->setUV(48, 0, 110, 24);
		p->setAnchor(-15, 12);
		p->setPos(_posX, _posY);
		p->setRotate((float)M_PI*2.f/_petalNum*i+cml::random_float(-.03f, .03f));
		p->setScale(cml::random_float(.95f, 1.f), cml::random_float(.9f, 1.1f));
		pPatal->pSprite = p;
		pPatal->id = i;
		pPatal->dir = p->getRotate();
		pPatal->posX0 = _posX;
		pPatal->posY0 = _posY;
		_pSptPetals.push_back(pPatal);
	}
}

void YNFlower::setText(const wchar_t* text1, const wchar_t* text2){
	_pFont1->setText(text1);
	_pFont2->setText(text2);
}
void YNFlower::main(float dt){
	std::vector<YNPatal*>::iterator it = _pSptPetals.begin();
	std::vector<YNPatal*>::iterator itEnd = _pSptPetals.end();
	float rot, x, y;
	bool heartFall = true;
	for ( ; it != itEnd; ++it ){
		if ( (*it)->rotSpd != 0.f ){
			rot = (*it)->pSprite->getRotate();
			rot += (*it)->rotSpd;
			(*it)->pSprite->setRotate(rot);
			(*it)->pSprite->getPos(x, y);
			x += (*it)->v[0];
			y += (*it)->v[1];
			(*it)->pSprite->setPos(x, y);
			(*it)->v[1] += 0.1f;
		}
		if ( !(*it)->isLeave ){
			heartFall = false;
		}
	}
	if ( heartFall ){
		_pSptHeart->getPos(x, y);
		_heartV += .1f;
		y += _heartV;
		_pSptHeart->setPos(x, y);
	}
	_t += dt;
}
void YNFlower::draw(){
	std::vector<YNPatal*>::iterator it = _pSptPetals.begin();
	std::vector<YNPatal*>::iterator itEnd = _pSptPetals.end();
	for ( ; it != itEnd; ++it ){
		(*it)->pSprite->collect();
	}
	_pSptHeart->collect();
	lw::Font* pFont = NULL;
	if ( _isFont1 ){
		pFont = _pFont1;
	}else{
		pFont = _pFont2;
	}
	if ( _heartV > 0.f ){
		pFont->setPos(_posX, _posY);
	}else{
		pFont->setPos(_posX, _posY-_t*.1f);
	}
	
	pFont->collect();
}
bool YNFlower::onGesture(const lw::Gesture& gesture){
	const lw::TouchEvent& evt = gesture.evt;
	if ( evt.type == lw::TouchEvent::TOUCH ){
		cml::Vector2 v;
		v[0] = evt.x-_posX;
		v[1] = evt.y-_posY;
		cml::Vector2 v1;
		v1[0] = 1.f;
		v1[1] = 0.f;
		float agl = (float)cml::signed_angle_2D(v1, v);
		if ( agl < 0.f ){
			agl += (float)M_PI*2.f;
		}
		float dist = v.length();
		int id = -1;
		if ( dist > 25.f && dist < 120.f ){
			std::vector<YNPatal*>::iterator it = _pSptPetals.begin();
			std::vector<YNPatal*>::iterator itEnd = _pSptPetals.end();
            std::vector<YNPatal*>::iterator itClosest = itEnd;
            float closestAngle = 99999.f;
            float dLimit = (float)M_PI/8.f;
			for ( ; it != itEnd; ++it ){
                if ( (*it)->isLeave ){
                    continue;
                }
                float d = fabs((*it)->dir-agl);
                if ( d >= 2.f*(float)M_PI-dLimit ){
                    d = 2.f*(float)M_PI - d;
                }
                if ( d < closestAngle ){
                    closestAngle = d;
                    itClosest = it;
                }
			}
            if ( itClosest != itEnd && closestAngle <= dLimit ){
                id = ((*itClosest)->id);
                (*itClosest)->gesId = gesture.id;
                (*itClosest)->touchX = evt.x;
                (*itClosest)->touchY = evt.y;
            }
            
		}
	}else if ( evt.type == lw::TouchEvent::UNTOUCH ){
		std::vector<YNPatal*>::iterator it = _pSptPetals.begin();
		std::vector<YNPatal*>::iterator itEnd = _pSptPetals.end();
		for ( ; it != itEnd; ++it ){
			if ( (*it)->gesId == gesture.id ){
				(*it)->gesId = -1;
				if ( (*it)->isLeave ){
					(*it)->rotSpd = cml::random_float(-.002f, .002f);
				}
				break;
			}
		}
	}else if ( evt.type == lw::TouchEvent::MOVE ){
		std::vector<YNPatal*>::iterator it = _pSptPetals.begin();
		std::vector<YNPatal*>::iterator itEnd = _pSptPetals.end();
		for ( ; it != itEnd; ++it ){
			if ( (*it)->gesId == gesture.id ){
				cml::Vector2 v;
				v[0] = evt.x - (float)(*it)->touchX;
				v[1] = evt.y - (float)(*it)->touchY;
				if ( v.length() > 20.f && !(*it)->isLeave ){
					(*it)->isLeave = true;
					onPatalLeave();
				}
				if ( (*it)->isLeave ){
					(*it)->pSprite->setPos((*it)->posX0+v[0], (*it)->posY0+v[1]);
				}
				break;
			}
		}
	}
	
	return false;
}

void YNFlower::onPatalLeave(){
	_t = 0.f;
	_isFont1 = !_isFont1;
}

void TaskYesOrNo::vBegin(){
    lw::srand();
    lw::App::s().setOrient(lw::App::ORIENTATION_UP);
	_pFlower = new YNFlower();
    
    lw::Button9Def def("ui.png", 0, 0, 0, 2, 0, 0, 1, 1, 1, 1, 1, 1, "calibri20.fnt", GL_NEAREST);
    _pBtnReset = lw::UIButton::create9(def);
    _pBtnReset->setPos(250, 400);
	_pBtnReset->setSize(60, 60);
	_pBtnReset->setText(L"Reset");
	_pBtnReset->setCallback(this);
    
    _pBtnDms = lw::UIButton::create9(def);
    _pBtnDms->setPos(20, 400);
	_pBtnDms->setSize(60, 60);
	_pBtnDms->setText(L"Dms");
	_pBtnDms->setCallback(this);
    
    _pBtnRobot = lw::UIButton::create9(def);
    _pBtnRobot->setPos(130, 400);
	_pBtnRobot->setSize(60, 60);
	_pBtnRobot->setText(L"Robot");
	_pBtnRobot->setCallback(this);
    
    setDmsUIWillDisappear(showTask);
    setDmsUIDidAppear(hideTask);
}

void TaskYesOrNo::vEnd(){
	delete _pFlower;
    delete _pBtnReset;
    robotViewDestroy();
    lw::App::s().popOrient();
}

void TaskYesOrNo::vMain(float dt){
	_pFlower->main(dt);
}

void TaskYesOrNo::vDraw(float dt){
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	if ( _step == STEP_PLAY ){
		_pFlower->draw();
	}
}

void TaskYesOrNo::vGesture(const lw::Gesture* pGst){
    _pFlower->onGesture(*pGst);
}

void TaskYesOrNo::vOnClick(lw::UIButton* pButton){
    if ( _pBtnReset == pButton ){
        _pFlower->reset();
    }else if ( _pBtnDms == pButton ){
        dmsUI();
    }else if ( _pBtnRobot == pButton ){
        robotView();
    }
}