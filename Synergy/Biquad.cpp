
#include "Biquad.h"

void Biquad::initialize(int numFrames)
{
    mInputMemory = (float*)malloc(2*sizeof(float));
    mOutputMemory = (float*)malloc(2*sizeof(float));
    memset(mInputMemory, 0, 2);
    memset(mOutputMemory, 0, 2);
    mTempOutput = (float*)malloc((numFrames+2)*sizeof(float));
    mTempInput = (float*)malloc((numFrames+2)*sizeof(float));
    memset(mTempOutput, 0, numFrames+2);
    memset(mTempInput, 0, numFrames+2);
    isLowPass = true;
    butterworth.initialize();
}

void Biquad::createFilter(int cutOffFrequency, int sampleRate, float Q, int bandWidth, float gainDb, int taps, int filterType, int filterDesign)
{
    mCutoff = cutOffFrequency;
    mQ = Q;
    mSampleRate = sampleRate;
    if (filterDesign == kUseButtersworthFilter) {
        if (filterType == kBiQuadLowPassFilter)
            butterworth.generateLowPassCoeffs(cutOffFrequency, sampleRate, Q);
        else if (filterType == kBiQuadHighPassFilter)
            butterworth.generateHighPassCoeffs(cutOffFrequency, sampleRate, Q);
        else
            butterworth.generateBandPassCoeffs(cutOffFrequency, sampleRate, Q, bandWidth, gainDb);
    }
}

void Biquad::filterBuffer(float * buffer, int numFrames)
{

    cblas_scopy(2, mInputMemory, 1, mTempInput, 1);
    cblas_scopy(numFrames, buffer, 1, mTempInput+2, 1);
    
    cblas_scopy(2, mOutputMemory, 1, mTempOutput, 1);
    // Do the processing
    vDSP_deq22(mTempInput, 1, &butterworth.mCoeffs[0], mTempOutput, 1, numFrames);
//    for (int i = 2; i < numFrames+2; i++)
//    {
//        mTempOutput[i] = butterworth.mCoeffs[0]*mTempInput[i] + butterworth.mCoeffs[1] * mTempInput[i-1] + butterworth.mCoeffs[2] * mTempInput[i-2] - butterworth.mCoeffs[3] * mTempOutput[i-1] - butterworth.mCoeffs[4] * mTempOutput[i-2];
//    }
    
    // Copy the data
    cblas_scopy(2, buffer+numFrames-2, 1, mInputMemory, 1);
    
    //copy data to output
    cblas_scopy(numFrames, mTempOutput, 1, buffer, 1);
    
    //save output memory data
    cblas_scopy(2, mTempOutput+numFrames, 1, mOutputMemory, 1);
}

void Biquad::filterWithLFO(float * buffer, float * modulationBuffer, int numFrames)
{
    cblas_scopy(2, mInputMemory, 1, mTempInput, 1);
    cblas_scopy(numFrames, buffer, 1, mTempInput+2, 1);
    
    cblas_scopy(2, mOutputMemory, 1, mTempOutput, 1);
    // Do the processing
    for (int i = 2; i < numFrames+2; i++)
    {
        float fc = mCutoff+modulationBuffer[i];
        fc = fc < 20? 20: fc;
        if (isLowPass)
        {
            butterworth.generateLowPassCoeffs(fc, mSampleRate, mQ);
        } else {
            butterworth.generateHighPassCoeffs(fc, mSampleRate, mQ);
        }
        mTempOutput[i] = butterworth.mCoeffs[0]*mTempInput[i] + butterworth.mCoeffs[1] * mTempInput[i-1] + butterworth.mCoeffs[2] * mTempInput[i-2] - butterworth.mCoeffs[3] * mTempOutput[i-1] - butterworth.mCoeffs[4] * mTempOutput[i-2];
        mTempOutput[i] = mTempOutput[i] == NAN? 0: mTempOutput[i];
    }
    
    // Copy the data
    cblas_scopy(2, mTempInput+numFrames, 1, mInputMemory, 1);
    
    //copy data to output
    cblas_scopy(numFrames, mTempOutput, 1, buffer, 1);
    
    //save output memory data
    cblas_scopy(2, mTempOutput+numFrames, 1, mOutputMemory, 1);
}

