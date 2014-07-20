clc,clear;
[sound,fs,nbit] = wavread('test_wav_3.wav');
% wavplay(sound,fs);
% wavwrite(sound,fs/2,nbit,'test_8k.wav');
% [sound_2,fs_2,nbit] = wavread('test_8k.wav');
% wavplay(sound_2,fs);
sound_8k=resample(sound,fs/2,fs);
% wavplay(sound_8k,fs/2);
wavwrite(sound_8k,fs/2,nbit,'test_8k.wav');