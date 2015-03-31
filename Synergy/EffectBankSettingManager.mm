//
//  EffectBankSettingManager.cpp
//  UWantBProducer
//
//  Created by David Grunzweig on 2/10/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#include "EffectBankSettingManager.h"

void EffectBankSettingManager::initialize()
{
    /*presets array
     0 = decayTime
     1 = sineLevel
     2 = triLevel
     3 = cutoff
     4 = q
     5 = LFOrate
     6 = filterType
     7 = echo feedback
     8 = echo time
     9 = echo mix
     */
    currentSettings = (float*)malloc(10*sizeof(float));
    memset(currentSettings, 0, 10);
    
    presets = (float**)malloc(4*sizeof(float*));
    presets[0] = (float*)malloc(10*sizeof(float));
    presets[1] = (float*)malloc(10*sizeof(float));
    presets[2] = (float*)malloc(10*sizeof(float));
    presets[3] = (float*)malloc(10*sizeof(float));
    
    //dubstep
    presets[0][0] = 1.0; //long decay time, sustained notes
    presets[0][1] = 1; //fat square wave
    presets[0][2] = 0; //no triangle
    presets[0][3] = .15; //low cutoff
    presets[0][4] = .25; //low Q
    presets[0][5] = .1; //Slow Fat LFO
    presets[0][6] = 0; //low pass filter
    presets[0][7] = 0; //no echo
    presets[0][8] = 0; // no time
    presets[0][9] = 0; //no mix

     //acid
     presets[1][0] = .45; //short choppy decay
     presets[1][1] = 0; //triangle wave or square
     presets[1][2] = 1; //triangle wave or square
     presets[1][3] = .8; //low cutoff
     presets[1][4] = .75; //agressive res
     presets[1][5] = 0; //no LFO
     presets[1][6] = 0; //low pass filter
     presets[1][7] = .5; //a little echo
     presets[1][8] = .25; //short repeat time
     presets[1][9] = .25; // a little mix

    //trance
     presets[2][0] = 1; //long decay
     presets[2][1] = 1; //usually a mix because it's a lead
     presets[2][2] = 1; //
     presets[2][3] = .5; //mid cut off
     presets[2][4] = .3; //some Q for edge
     presets[2][5] = 0; //no lfo or very shallow for tremelo
     presets[2][6] = 1; //high pass filter
     presets[2][7] = .5; //lots of echo to make it spacious
     presets[2][8] = .8; //long repeat
     presets[2][9] = .75; //high wet mix

    
    //subbass
     presets[3][0] = .5; //short decay
     presets[3][1] = 1.0; //uses square wave for fatness, not triangle
     presets[3][2] = 0; //no tri mix
     presets[3][3] = .1; //low cutoff
     presets[3][4] = .1; //low Q
     presets[3][5] = .5; //fast LFO for fm like wobble
     presets[3][6] = 0; //low pass filter
     presets[3][7] = 0; //no echo
     presets[3][8] = 0; //no echo
     presets[3][9] = 0; //no echo
    
    /*presets array
     0 = decayTime
     1 = squareLevel
     2 = triLevel
     3 = cutoff
     4 = q
     5 = LFOrate
     6 = filterType
     7 = echo feedback
     8 = echo time
     9 = echo mix
     */

}

void EffectBankSettingManager::loadPreset(int preset)
{
    mCurrentPreset = preset;
}
float EffectBankSettingManager::getCurrentSetting(int effectID, int effectParameter)
{
    int start = 0;
    if (effectID == 0)
        start = 0;
    else if (effectID == 1)
        start = 1;
    else if (effectID == 2)
        start = 3;
    else if (effectID == 3)
        start = 7;
     return currentSettings[start+effectParameter];

}

void EffectBankSettingManager::resetCurrentSettings()
{
    memset(currentSettings, 0, 10);
}

BOOL EffectBankSettingManager::checkSettingOfCurrentPreset(int effectID, int effectParameter, float value)
{
    if (mCurrentPreset != kEffectBankFreeMode){
        int start = 0;
        if (effectID == 0)
            start = 0;
        else if (effectID == 1)
            start = 1;
        else if (effectID == 2)
            start = 3;
        else if (effectID == 3)
            start = 7;
        currentSettings[start+effectParameter] = value;
        
        return (value > presets[mCurrentPreset][start+effectParameter] - .05 && value < presets[mCurrentPreset][start+effectParameter] + .05);
    } else {
        return false;
    }
    
}

