//
//  lfo.cpp
//  UWantBProducer
//
//  Created by David Grunzweig on 2/3/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#include "lfo.h"

void lfo::initialize(float modRate, float modDepth, UInt32 sampleRate, UInt32 numFrames)
{
    mModRate = modRate;
    mModDepth = modDepth;
    mSampleRate = sampleRate;
    mNumFrames = numFrames;
    mPosition = 0;
}
void lfo::getModulationBuffer(float * buffer)
{
    for (int i = 0; i < mNumFrames; ++i)
    {
        if (mPosition + i > FLT_MAX)
            mPosition = 0;
        buffer[i] = mModDepth*sinf(2*M_PI*mModRate*((float)(mPosition+i)/mSampleRate));
    }
    mPosition += mNumFrames;
}