//
//  DSButterworthFilter.cpp
//  RondoCore
//
//  Created by David Grunzweig on 2/9/15.
//  Copyright (c) 2015 Dysonics. All rights reserved.
//

#include "DSButterworthFilter.h"

void DSButterworthFilter::initialize()
{
    mCoeffs = (float*)malloc(5*sizeof(float));
}

void DSButterworthFilter::generateLowPassCoeffs(int cutoffFreq, int sampleRate, float Q)
{
    float omega = 2*M_PI*(float)cutoffFreq/sampleRate;
    float alpha = sinf(omega)/(2*Q);
    
//FYI: The relationship between bandwidth and Q is
//    1/Q = 2*sinh(ln(2)/2*BW*w0/sin(w0))     (digital filter w BLT)
//    or   1/Q = 2*sinh(ln(2)/2*BW)             (analog filter prototype)
//    
//    The relationship between shelf slope and Q is
//    1/Q = sqrt((A + 1/A)*(1/S - 1) + 2)
//    
//    2*sqrt(A)*alpha  =  sin(w0) * sqrt( (A^2 + 1)*(1/S - 1) + 2*A )
//    is a handy intermediate variable for shelving EQ filters.
    
//LPF:        H(s) = 1 / (s^2 + s/Q + 1)
    float b0 =  (1 - cosf(omega))/2;
    float b1 =   1 - cosf(omega);
    float b2 =  (1 - cosf(omega))/2;
    float a0 =   1 + alpha;
    float a1 =  -2*cosf(omega);
    float a2 =   1 - alpha;
    
    mCoeffs[0] = b0/a0; //b0
    mCoeffs[1] = b1/a0; //b1
    mCoeffs[2] = b2/a0; //b2
    mCoeffs[3] = a1/a0; //a1
    mCoeffs[4] = a2/a0; //a2
    
//notch:      H(s) = (s^2 + 1) / (s^2 + s/Q + 1)
//    
//    b0 =   1
//    b1 =  -2*cos(w0)
//    b2 =   1
//    a0 =   1 + alpha
//    a1 =  -2*cos(w0)
//    a2 =   1 - alpha
//    
//    
//    
//APF:        H(s) = (s^2 - s/Q + 1) / (s^2 + s/Q + 1)
//    
//    b0 =   1 - alpha
//    b1 =  -2*cos(w0)
//    b2 =   1 + alpha
//    a0 =   1 + alpha
//    a1 =  -2*cos(w0)
//    a2 =   1 - alpha
//    
//    
//    
//peakingEQ:  H(s) = (s^2 + s*(A/Q) + 1) / (s^2 + s/(A*Q) + 1)
//    
//    b0 =   1 + alpha*A
//    b1 =  -2*cos(w0)
//    b2 =   1 - alpha*A
//    a0 =   1 + alpha/A
//    a1 =  -2*cos(w0)
//    a2 =   1 - alpha/A
//    
//    
//    
//lowShelf: H(s) = A * (s^2 + (sqrt(A)/Q)*s + A)/(A*s^2 + (sqrt(A)/Q)*s + 1)
//    
//    b0 =    A*( (A+1) - (A-1)*cos(w0) + 2*sqrt(A)*alpha )
//    b1 =  2*A*( (A-1) - (A+1)*cos(w0)                   )
//    b2 =    A*( (A+1) - (A-1)*cos(w0) - 2*sqrt(A)*alpha )
//    a0 =        (A+1) + (A-1)*cos(w0) + 2*sqrt(A)*alpha
//    a1 =   -2*( (A-1) + (A+1)*cos(w0)                   )
//    a2 =        (A+1) + (A-1)*cos(w0) - 2*sqrt(A)*alpha
//    
//    
//    
//highShelf: H(s) = A * (A*s^2 + (sqrt(A)/Q)*s + 1)/(s^2 + (sqrt(A)/Q)*s + A)
//    
//    b0 =    A*( (A+1) + (A-1)*cos(w0) + 2*sqrt(A)*alpha )
//    b1 = -2*A*( (A-1) + (A+1)*cos(w0)                   )
//    b2 =    A*( (A+1) + (A-1)*cos(w0) - 2*sqrt(A)*alpha )
//    a0 =        (A+1) - (A-1)*cos(w0) + 2*sqrt(A)*alpha
//    a1 =    2*( (A-1) - (A+1)*cos(w0)                   )
//    a2 =        (A+1) - (A-1)*cos(w0) - 2*sqrt(A)*alpha
}

void DSButterworthFilter::generateHighPassCoeffs(int cutoffFreq, int sampleRate, float Q)
{
//HPF:        H(s) = s^2 / (s^2 + s/Q + 1)
    float omega = 2*M_PI*(float)cutoffFreq/sampleRate;
    float alpha = sinf(omega)/(2*Q);
    float b0 =  (1 + cosf(omega))/2;
    float b1 = -(1 + cosf(omega));
    float b2 =  (1 + cosf(omega))/2;
    float a0 =   1 + alpha;
    float a1 =  -2*cosf(omega);
    float a2 =   1 - alpha;

    mCoeffs[0] = b0/a0;
    mCoeffs[1] = b1/a0; //b1
    mCoeffs[2] = b2/a0; //b2
    mCoeffs[3] = a1/a0; //a1
    mCoeffs[4] = a2/a0; //a2
}
void DSButterworthFilter::generateBandPassCoeffs(int cutoffFreq, int sampleRate, float Q, float BW, float dBGain)
{
    float omega = 2*M_PI*(float)cutoffFreq/sampleRate;
    float alpha = sinf(omega)*sinh( log(2)/2 * BW * omega/sinf(omega) );
    
    if (dBGain == 0) {
        //BPF:        H(s) = (s/Q) / (s^2 + s/Q + 1)      (constant 0 dB peak gain)
        float b0 =   alpha;
        float b1 =   0;
        float b2 =  -alpha;
        float a0 =   1 + alpha;
        float a1 =  -2*cos(omega);
        float a2 =   1 - alpha;
        
        mCoeffs[0] = b0/a0;
        mCoeffs[1] = b1/a0; //b1
        mCoeffs[2] = b2/a0; //b2
        mCoeffs[3] = a1/a0; //a1
        mCoeffs[4] = a2/a0; //a2
    } else {
        //BPF:        H(s) = s / (s^2 + s/Q + 1)  (constant skirt gain, peak gain = Q)
        float b0 =   sin(omega)/2;//  =   Q*alpha
        float b1 =   0;
        float b2 =  -sin(omega)/2;//  =  -Q*alpha
        float a0 =   1 + alpha;
        float a1 =  -2*cos(omega);
        float a2 =   1 - alpha;
        
        mCoeffs[0] = b0/a0;
        mCoeffs[1] = b1/a0; //b1
        mCoeffs[2] = b2/a0; //b2
        mCoeffs[3] = a1/a0; //a1
        mCoeffs[4] = a2/a0; //a2
    }
}
