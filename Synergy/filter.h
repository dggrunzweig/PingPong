//
//  filter.h
//  UWantBProducer
//
//  Created by David Grunzweig on 2/3/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#ifndef __UWantBProducer__filter__
#define __UWantBProducer__filter__

#include <stdio.h>
#include "lfo.h"
#include "Biquad.h"

enum filterParameters
{
    kSetCutOffFrequency = 0,
    kSetResonanceFrequency = 1,
    kSetLFORate = 2,
    kSetFilterType = 3,
    kUseLowPass = 4,
    kUseHighPass = 5,
};

class filter
{
    lfo mLFO;
    bool mLFOon;
    UInt32 mCutOffFrequency;
    float mResonance;
    int mSampleRate;
    int mNumFrames;
    float * filterBuffer;
    float * modulationBuffer;
    Biquad biquadFilter;
    bool isLowPass;
    
public:
    void initialize(int numFrames, int sampleRate, int cutoffFrequency, bool LFOon);
    void setLFOStatus(float modDepth, float modRate, bool On);
    void applyEffect(float * buffer);
    void setEffectParameter(UInt32 parameter, float value);
    void getEffectParameter(int effectParameterID, float value);

};


#endif /* defined(__UWantBProducer__filter__) */
