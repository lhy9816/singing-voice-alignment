# Singing Voice Alignment for Singing Voice Correction

> 作者 李航宇

## 综述

本项目主要依据语音信号处理的方法，对业余人员唱的音轨和专业歌手的音轨进行匹配对齐。采用的方法主要为两段式匹配法，即

+ 首先根据WORLD提供的Harvest算法将业余人员和专业歌手唱的音轨进行F0音高的提取，在F0的基础上进行vuv的划分，当F0曲线断开超过一定时长后认定此处为换气，前后拆为两段，最后得到大体上按照一句歌词为一段的音轨。
+ 对业余人员和专业歌手的音轨的每一段进行按照时长和声音参数相关性的匹配，得到一级段落匹配。
+ 对已经匹配的业余人员和专业歌手的一级段落内部进行二级匹配，二级匹配的精度是窗长，大概在25ms左右，由deDTW算法进行对声音参数的对齐，最后经由拉伸与补零将业余歌手和专业歌手的音轨调至同样时长并分别经由左右耳道播放，得到最终的匹配结果。

## 使用方法

+ 首先对所有的专业歌手音轨(\*ref.wav)和业余歌手音轨(\*user[0-9].wav)进行一一的分段，调用`createF0(userSongPath, refSongPath, contextFilePath, minSegment)`来预先F0参数并存在contextFilePath路径下。
+ 调用`loopGenerate`脚本进行alignment，其中config为可供选择的feature种类，有{lpc, ltc, straight_sp} 。
+ 最后生成的音频在`OTPT_deDTW`文件夹中。
+ 详细函数注释请见函数下方以及句中注释。

## 函数说明

+ 文件夹LPC
  + 里面是利用格型法进行线性预测系数计算的函数，函数原型来自＜matlab语音信号处理＞
+ 文件夹matlab_szy
  + 里面存有所有＜matlab语音信号处理＞中所有语音处理基本函数，这里会调用里面的frame2time函数
+ STRAIGHT
  + 里面是STRAIGHT方法中计算spectrum的代码，由singingFeatureExtraction.m调用
+ loopGenerate.m
  +  按照循环模式对所有待对齐歌曲进行对齐，对不同的configs参数以及选取参数的贡献比值ratio进行grid search
     找到最合适的参数搭配，并生成对齐后的user段和reference段，分别输出与左声道和右声道
+ createF0.m
  + 计算userFile和refFile的F0曲线
+ segby0.m
  + 根据F0曲线unvoiced的时长与阈值的大小关系来分割F0曲线，获得第一级音频段
+ segmentAlign.m
  + 第一级段间匹配
+ findNextMatch.m
  + 段间匹配时确定userSong与refSong当前应该匹配的段落
+ noteAlign.m
  + 第二级段内匹配
+ alignAudioFeature.m
  + 将提取出的声学参数进行deDTW的对齐与计算相关性
+ singingFeatureExtraction.m
  + 音频的lpc, ltc, straight_spectrum声学参数提取