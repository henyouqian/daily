#ifndef __SAVE_H__
#define __SAVE_H__

bool svGet(const char* key, std::string& outValue);
bool svSet(const char* key, const char* value);

template <class T> 
void svValue(T &value, const std::string &s) {
    std::stringstream ss(s);
    ss >> value;
}

template <class T> 
const char* svString(T &value) {
    std::stringstream ss;
    ss << value;
    return ss.str().c_str();
}

#endif //__SAVE_H__