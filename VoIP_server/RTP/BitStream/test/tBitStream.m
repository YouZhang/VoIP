function tBitStream
% Read a bit file and then write the same data to another bit file.

% $Id: tBitStream.m,v 1.3 2009/07/16 16:01:58 pkabal Exp $

addpath ('../../BitStream');

FName0 = 'MA01_02.bit';
FName1 = 'MAtest.bit';

QC = ReadG7231Stream (FName0);
WriteG7231Stream (FName1, QC);

eval(['!FC ' FName0 ' ' FName1]);
delete(FName1);

return
