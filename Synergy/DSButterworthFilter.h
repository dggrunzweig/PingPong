//
//  DSButterworthFilter.h
//  RondoCore
//
//  Created by David Grunzweig on 2/9/15.
//  Copyright (c) 2015 Dysonics. All rights reserved.
//

#ifndef __RondoCore__DSButterworthFilter__
#define __RondoCore__DSButterworthFilter__

#include <stdio.h>
#import <Accelerate/Accelerate.h>
//#import "Biquad.h"

class DSButterworthFilter
{
public:
    float * mCoeffs;
    void initialize();
    void generateLowPassCoeffs(int cutoffFreq, int sampleRate, float Q);
    void generateHighPassCoeffs(int cutoffFreq, int sampleRate, float Q);
    void generateBandPassCoeffs(int cutoffFreq, int sampleRate, float Q, float BW, float dBGain);
};

#endif /* defined(__RondoCore__DSButterworthFilter__) */
