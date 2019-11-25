# Singing Voice Alignment for Singing Voice Correction

> Hangyu Li

## Overview

This project is mainly based on the method of speech signal processing to match and align the tracks sung by amateurs and professional singers with a two-stage method:

- First, according to Harvest Algorithm provided by WORLD, we extract the F0 pitch of the tracks sung by amateurs and professional singers and divide the VUV on the basis of F0. When the F0 curve disconnects for over a certain length of time, it is considered as a breath gap, thus divided into two sections. Finally, we get several blocks that are generally based on lines of lyric.
- Each segment of the track of amateurs and professional singers matches with each other according to the correlation between the length of time and the sound parameters. 
- Second level matching and aligning is performed within the matched first level amateur singers' blocks and professional singer's blocks. The time precision of the second level matching is around 25 ms, which is the same as the window length when performing STFT. The deDTW algorithm is used when performing the aligning task. The final result is derived by stretching and average-padding which adjust the length of the aligned tracks and broadcasting separately in both the left-ear channel and right-year channel respectively.

## Usage

- First all professional singer tracks (\*ref.wav) and amateur singer tracks (\*user[0-9].wav) are segmented one by one by calling `createF0.m(userSongPath, refSongPath, contextFilePath, minSegment)`. The corresponding F0 parameters are stored in ```contextFilePath```.
- Run `loopGenerate.m` to perform the whole process matching and alignment process. You can choose the speech parameters among {lpc, ltc, straight_sp}
- Generated songs are stored in `OTPT_deDTW` folder.
- For detailed notes, please refer to the notes below and the notes in the original codes.

## Function Description

- Folder LPC
  - The function of linear prediction coefficient calculation by lattice method. The function prototype comes from the speech signal processing of MATLAB
- Folder matlab_szy
  - All the basic functions of speech processing in MATLAB speech signal processing.
- Folder STRAIGHT
  - Calculate spectrum in the strength method, called by singingFeatureExtraction.m
- loopGenerate.m
  - Entry of the whole system, perform grid search on different config parameters and parameter ratio until the most appropriate alignment has been found. The aligned tracks are output in the left-ear channel and right-ear channel respectively.
- createF0.m
  - calculate userFile's and refFile's F0 curve
- segby0.m
  - segment F0 curves according to their unvoiced length to get first level match results
- segmentAlign.m
  - the first level match
- noteAlign.m
  - the second level match and alignment
- alignAudioFeature.m
  - align tracks according to the extracted speech parameters respectively with deDTW algorithm and compute the correlation
- singingFeatureExtraction.m
  - extract lpc, ltc, straight_spectrum features
