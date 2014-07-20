function QC = GetQCodes (ByteStream)
% Extract the code values, frame by frame, from a ITU-T G.723.1
% coder byte stream (cell array).

% $Id: GetQCodes.m,v 1.6 2006/09/27 18:14:36 pkabal Exp $

NF = length (ByteStream);
QC = [];

% Decode the information
for (k = 1:NF)

  % Unpack the information into a bit buffer
  BitStream = Bytes2Bits (ByteStream{k});

  % Extract the mode bits
  QC(k).FType = ExtractBits (BitStream(1:2));

  if (QC(k).FType <= 2)     % Transmitted frame 
    % Extract the LSF indices (Note the reversed order)
    QC(k).LSFC(3) = ExtractBits (BitStream( 3:10));
    QC(k).LSFC(2) = ExtractBits (BitStream(11:18));
    QC(k).LSFC(1) = ExtractBits (BitStream(19:26));
  end

  if (QC(k).FType == 2)     % SID frame
    QC(k).GainC = ExtractBits (BitStream(27:32));
  end

  if (QC(k).FType <= 1)     % 5.3 or 6.3 kb/s
    % Extract the adaptive codebook lags
    QC(k).ACBLC(1) = ExtractBits (BitStream(27:33));
    QC(k).ACBLC(2) = ExtractBits (BitStream(34:35));
    QC(k).ACBLC(3) = ExtractBits (BitStream(36:42));
    QC(k).ACBLC(4) = ExtractBits (BitStream(43:44));

    % Extract the combined gains
    QC(k).CGC(1) = ExtractBits (BitStream(45:56));
    QC(k).CGC(2) = ExtractBits (BitStream(57:68));
    QC(k).CGC(3) = ExtractBits (BitStream(69:80));
    QC(k).CGC(4) = ExtractBits (BitStream(81:92));
  end

  if (QC(k).FType == 0)     % 6.3 kb/s
    % Extract the multipulse grid codes
    QC(k).MPGridC(1) = ExtractBits (BitStream(93));
    QC(k).MPGridC(2) = ExtractBits (BitStream(94));
    QC(k).MPGridC(3) = ExtractBits (BitStream(95));
    QC(k).MPGridC(4) = ExtractBits (BitStream(96));
    
    % Ignore the reserved bit, bit 97

    % Extract the multipulse pulse position codes
    QC(k).MPPosC(1) = ExtractBits (BitStream( 98:110));
    QC(k).MPPosC(2) = ExtractBits (BitStream(111:126));
    QC(k).MPPosC(3) = ExtractBits (BitStream(127:140));
    QC(k).MPPosC(4) = ExtractBits (BitStream(141:156));
    QC(k).MPPosC(5) = ExtractBits (BitStream(157:170));

    % Extract the multipulse sign codes
    QC(k).MPSignC(1) = ExtractBits (BitStream(171:176));
    QC(k).MPSignC(2) = ExtractBits (BitStream(177:181));
    QC(k).MPSignC(3) = ExtractBits (BitStream(182:187));
    QC(k).MPSignC(4) = ExtractBits (BitStream(188:192)); 
  
  elseif (QC(k).FType == 1) % 5.3 kb/s
    % Extract the ACELP grid codes
    QC(k).ACELPGridC(1) = ExtractBits (BitStream(93));
    QC(k).ACELPGridC(2) = ExtractBits (BitStream(94));
    QC(k).ACELPGridC(3) = ExtractBits (BitStream(95));
    QC(k).ACELPGridC(4) = ExtractBits (BitStream(96));

    % Extract the ACELP pulse position codes
    QC(k).ACELPPosC(1) = ExtractBits (BitStream( 97:108));
    QC(k).ACELPPosC(2) = ExtractBits (BitStream(109:120));
    QC(k).ACELPPosC(3) = ExtractBits (BitStream(121:132));
    QC(k).ACELPPosC(4) = ExtractBits (BitStream(133:144));

    % Extract the ACELP pulse sign codes
    QC(k).ACELPSignC(1) = ExtractBits (BitStream(145:148));
    QC(k).ACELPSignC(2) = ExtractBits (BitStream(149:152));
    QC(k).ACELPSignC(3) = ExtractBits (BitStream(153:156));
    QC(k).ACELPSignC(4) = ExtractBits (BitStream(157:160));
  end

end

return

%--------------------
function BitStream = Bytes2Bits (Bytes)
% BitStream is ordered from least significant bit to most significant bit

NB = length (Bytes);
BitStream = zeros (8 * NB, 1);

k = 1;
for (i = 1:NB)
  Mask = 1;
  for (j = 1:8)
    BitStream(k) = (bitand (Bytes(i), Mask) ~= 0);
    Mask = 2 * Mask;
    k = k + 1;
  end
end

return

%--------------------
function Code = ExtractBits (Bits)

Nb = length (Bits);
Code = 0;
Mask = 1;
for (i = 1:Nb)
  if (Bits(i) ~= 0)
    Code = Code + Mask;
  end
  Mask = 2 * Mask;
end

return
