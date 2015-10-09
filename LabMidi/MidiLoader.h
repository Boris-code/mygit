/********************************************************************
@file          AnalysisMidi.h
@copyright
@author        liubo(liubo@xiaoyezi.com)
@version       1.0
@date          15/9/9
@brief         Starts a paragraph that serves as a brief description
@detail        starts the detailed description.
*********************************************************************/
#pragma once

#include <stdio.h>
#include <vector>
#include <string>

using namespace std;

//每个音符
struct PitchEvent{
    int pitch;      //音高 决定用哪个音乐
    int velocity;   //力度
    bool isOn;       //是否按下
    int tick;       //时间
    int track;      //属于哪个音轨
};

//音轨
struct Track {
    std::vector<PitchEvent*> events;
};

struct Midi {
    std::vector<Track*> tracks;
    int tpq;  //音乐的速度  1个四分音符有多少个tick
    float tempo;   //曲子拍速 1分钟内4分音符的个数
};

class MidiLoader{
public:
    void load(const string &path);
    Midi getMidi();

private:
    Midi _customsMidi;

};
