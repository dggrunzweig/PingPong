//
//  lfo.h
//  UWantBProducer
//
//  Created by David Grunzweig on 2/3/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#ifndef __UWantBProducer__lfo__
#define __UWantBProducer__lfo__

#include <stdio.h>
#include "effectSuperClass.h"

class lfo
{
    int mSampleRate;
    float mNumFrames;
    float * mModulationBuffer;
    int mPosition;
    
public:
    void initialize(float modRate, float modDepth, UInt32 sampleRate, UInt32 mNumFrames);
    void getModulationBuffer(float * buffer);
    float mModDepth;
    float mModRate;
};

#endif /* defined(__UWantBProducer__lfo__) */
