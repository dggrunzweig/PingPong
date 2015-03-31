//
//  Biquad.h
//
//  Created by David Grunzweig on 2/9/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#ifndef __Biquad__
#define __Biquad__

#include <stdio.h>
#import "DSButterworthFilter.h"
#import <Accelerate/Accelerate.h>
enum filterDesign {
    kUseButtersworthFilter = 0,
    kUseChebychevFilter = 1,
};

enum filterType {
    kBiQuadHighPassFilter = 0,
    kBiQuadLowPassFilter = 1,
    kBiQuadBandPassFilter = 2,
};

class Biquad
{
private:
    float*  mInputMemory;
    float*  mOutputMemory;
    DSButterworthFilter butterworth;
    float* mTempOutput;
    float* mTempInput;
    int mSampleRate;
    int mQ;
public:
    int mCutoff;
    bool isLowPass;
    void initialize(int numFrames);
    void createFilter(int cutOffFrequency, int sampleRate, float Q, int bandWidth, float gainDb, int taps, int filterType, int filterDesign);
    void filterBuffer(float * buffer, int numFrames);
    void filterWithLFO(float * buffer, float * modulationBuffer, int numFrames);

};

#endif /* defined(__Biquad__) */
