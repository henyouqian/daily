#ifndef __SAVE_H__
#define __SAVE_H__

bool svGet(const char* key, std::string& outValue);
bool svSet(const char* key, const char* value);

#endif //__SAVE_H__