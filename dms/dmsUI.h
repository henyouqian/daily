#ifndef __DMSUI_H__
#define __DMSUI_H__

void dmsUI();
void dmsUIClose();
void dmsUIDestroy();

typedef void (*FnDmsUICallback) (void);

void setDmsUIWillAppear(FnDmsUICallback fn);
void setDmsUIDidAppear(FnDmsUICallback fn);
void setDmsUIWillDisappear(FnDmsUICallback fn);
void setDmsUIDidDisappear(FnDmsUICallback fn);

#endif //__DMSUI_H__