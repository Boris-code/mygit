//
// AnalysisMidi.cpp
// Piano
//
// Created by liubo on 15/9/9.
//
//

#include "MidiLoader.h"

#include "LabMidiSong.h"
#include "LabMidiCommand.h"
#include "LabMidiEvent.h"
#include "LabMidiUtil.h"

#include "cocos2d.h"

USING_NS_CC;

void MidiLoader::load(const string &path){
//    Midi _customsMidi;

    Lab::MidiSong song;
    std::string pathForMidi = FileUtils::getInstance()->fullPathForFilename(path);
    const Data &midiData = FileUtils::getInstance()->getDataFromFile(pathForMidi);
    song.parse(midiData.getBytes(), midiData.getSize(), true); //初始化song

    int tpq = 0; //音乐的速度


    //tracks 音轨
    if (song.tracks != nullptr) {
        //preprocess midi track
        bool firstTrackHasChannelEvent = false;
        std::vector<Lab::SetTempoEvent*> tempoEvents;
        Lab::MidiTrack *firstTrack = (*song.tracks)[0];
        for (int e = 0; e < firstTrack->events.size(); e++) {
            Lab::MidiEvent *midiEvent = firstTrack->events[e];
            if (midiEvent->eventType == Lab::MIDI_EventChannel) {
                firstTrackHasChannelEvent = true;
            } else if (midiEvent->eventType == Lab::MIDI_EventSetTempo) {
                Lab::SetTempoEvent *setTempoEvent = static_cast<Lab::SetTempoEvent *>(midiEvent);
                tempoEvents.push_back(setTempoEvent);
            }
        }

        if (!firstTrackHasChannelEvent) {
            song.tracks->erase(song.tracks->begin());
        }

        tpq = song.ticksPerBeat;

        _customsMidi.tpq = tpq;

        for (int i = 0; i < song.tracks->size(); i++) {
            Lab::MidiTrack *midiTrack = (*song.tracks)[i];
            int totalTicks = 0;
            Track* track = new Track;
            _customsMidi.tracks.push_back(track);

            for (int j = 0; j < midiTrack->events.size(); j++) {
                Lab::MidiEvent *midiEvent = midiTrack->events[j];
                totalTicks += midiEvent->deltatime;
                if (midiEvent->eventType == Lab::MIDI_EventChannel) {
                    Lab::ChannelEvent *channelEvent = static_cast<Lab::ChannelEvent *>(midiEvent);
                    int byte = channelEvent->midiCommand & 0xF0;
                    switch (byte) {
                        case 0x80:{//键子抬起
                            break;
                        }
                        case 0x90: {//键子按下
                            PitchEvent *pitchEvent = new PitchEvent;
                            pitchEvent->pitch = channelEvent->param1;  //音高
                            pitchEvent->velocity = channelEvent->param2;  //力度
                            pitchEvent->tick = totalTicks; //时间
                            pitchEvent->track = i;
                            pitchEvent->isOn=pitchEvent->velocity>0?true:false;
                            track->events.push_back(pitchEvent);
                            break;
                        }
                        default:
                            break;
                    }
                } else if (midiEvent->eventType == Lab::MIDI_EventSetTempo) {
                    Lab::SetTempoEvent *setTempoEvent = static_cast<Lab::SetTempoEvent *>(midiEvent);
                    tempoEvents.push_back(setTempoEvent);
                }
            }
        }

        if (tempoEvents.size() > 0) {
            _customsMidi.tempo = (60.0 * 1000 * 1000) / tempoEvents[0]->microsecondsPerBeat;
        } else {
            _customsMidi.tempo = 120;
        }

    }
}

Midi MidiLoader::getMidi(){

    return _customsMidi;
}
