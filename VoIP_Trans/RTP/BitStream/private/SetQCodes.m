function ByteStream = SetQCodes (QC)
% Set the code values (given frame by frame) into a ITU-T G.723.1
% coder byte stream (cell array);

% $Id: SetQCodes.m,v 1.6 2009/07/12 21:12:59 pkabal Exp $

NF = size (QC, 2);

% Encode the information
for (k = 1:NF)

  switch (QC(k).FType)%速率选择
    case 0    % High rate 高速
      NB = 24;
    case 1    % Low rate 低速
      NB = 20;
    case 2    % SID frame如果业务帧中只包含噪声，发射机发送一个SID（静默指示符）帧，然后停止发射信号。以后，每一个SACCH周期中发送一个新的SID帧。等到检测到话音或数据再开始发射。
      NB = 4;
    otherwise % Untransmitted frame 不传输
      NB = 1;
  end

  BitStream = zeros (8 * NB, 1); %

  BitStream(1:2) = SetBits (QC(k).FType, 2);

  if (QC(k).FType ~= 3)     % Transmitted frame
    % Set the LSF indices (Note the reversed order)
    BitStream( 3:10) = SetBits (QC(k).LSFC(3), 8);
    BitStream(11:18) = SetBits (QC(k).LSFC(2), 8);
    BitStream(19:26) = SetBits (QC(k).LSFC(1), 8);
  end

  if (QC(k).FType == 2)     % SID frame
    BitStream(27:32) = SetBits (QC(k).NoiseGainC, 6);
  end

  if (QC(k).FType <= 1)     % 5.3 or 6.3 kb/s
    % Set the adaptive codebook lags
    BitStream(27:33) = SetBits (QC(k).ACBLC(1), 7);
    BitStream(34:35) = SetBits (QC(k).ACBLC(2), 2);
    BitStream(36:42) = SetBits (QC(k).ACBLC(3), 7);
    BitStream(43:44) = SetBits (QC(k).ACBLC(4), 2);

    % Set the combined gains
    BitStream(45:56) = SetBits (QC(k).CGC(1), 12);
    BitStream(57:68) = SetBits (QC(k).CGC(2), 12);
    BitStream(69:80) = SetBits (QC(k).CGC(3), 12);
    BitStream(81:92) = SetBits (QC(k).CGC(4), 12);
  end

  if (QC(k).FType == 0)     % 6.3 kb/s
    % Set the multipulse grid codes
    BitStream(93) = SetBits (QC(k).MPGridC(1), 1);
    BitStream(94) = SetBits (QC(k).MPGridC(2), 1);
    BitStream(95) = SetBits (QC(k).MPGridC(3), 1);
    BitStream(96) = SetBits (QC(k).MPGridC(4), 1);
    
    % Reserved bit
    BitStream(97) = SetBits (0, 1);

    % Set the multipulse position code
    BitStream( 98:110) = SetBits (QC(k).MPPosC(1), 13);
    BitStream(111:126) = SetBits (QC(k).MPPosC(2), 16);
    BitStream(127:140) = SetBits (QC(k).MPPosC(3), 14);
    BitStream(141:156) = SetBits (QC(k).MPPosC(4), 16);
    BitStream(157:170) = SetBits (QC(k).MPPosC(5), 14);

    % Set the multipulse sign codes
    BitStream(171:176) = SetBits (QC(k).MPSignC(1), 6);
    BitStream(177:181) = SetBits (QC(k).MPSignC(2), 5);
    BitStream(182:187) = SetBits (QC(k).MPSignC(3), 6);
    BitStream(188:192) = SetBits (QC(k).MPSignC(4), 5);

  elseif (QC(k).FType == 1) % 5.3 kb/s
    % Set the ACELP grid codes
    BitStream(93) = SetBits (QC(k).ACELPGridC(1), 1);
    BitStream(94) = SetBits (QC(k).ACELPGridC(2), 1);
    BitStream(95) = SetBits (QC(k).ACELPGridC(3), 1);
    BitStream(96) = SetBits (QC(k).ACELPGridC(4), 1);

    % Set the ACELP pulse position code
    BitStream( 97:108) = SetBits (QC(k).ACELPPosC(1), 12);
    BitStream(109:120) = SetBits (QC(k).ACELPPosC(2), 12);
    BitStream(121:132) = SetBits (QC(k).ACELPPosC(3), 12);
    BitStream(133:144) = SetBits (QC(k).ACELPPosC(4), 12);

    % Set the ACELP pulse sign codes
    BitStream(145:148) = SetBits (QC(k).ACELPSignC(1), 4);
    BitStream(149:152) = SetBits (QC(k).ACELPSignC(2), 4);
    BitStream(153:156) = SetBits (QC(k).ACELPSignC(3), 4);
    BitStream(157:160) = SetBits (QC(k).ACELPSignC(4), 4);
  end

  ByteStream{k} = Bits2Bytes (BitStream);

end

return

%--------------------
function Bytes = Bits2Bytes (BitStream)

Nb = length (BitStream);
NB = ceil (Nb / 8);
Bytes = zeros (NB, 1);

k = 1;
for (i = 1:NB)
  Mask = 1;
  for (j = 1:8)
    if (k <= Nb)
      if (BitStream(k) ~= 0)
        Bytes(i) = bitor (Bytes(i), Mask);
      end
    end
    Mask = 2 * Mask;
    k = k + 1;
  end
end

return

%--------------------
function Bits = SetBits (Code, Nb)

% Error check
if (Code < 0 || Code >= 2^Nb)
  error ('SetBits: Code out of range');
end

Mask = 1;
Bits = zeros (Nb, 1);
for (i = 1:Nb)
  if (bitand (Code, Mask) ~= 0)
    Bits(i) = 1;
  end
  Mask = 2 * Mask;
end

return
