function QC = FixForbiddenCodes (QC, Pitchpar)
% Change frames with illegal codes to error frames�ı䲻�Ϸ������ɴ���֡

% $Id: FixForbiddenCodes.m,v 1.2 2009/07/16 15:57:06 pkabal Exp $

NFrame = length (QC);
Err = zeros (NFrame, 1);
for (i = 1:NFrame)
  Err(i) = CheckQCErr (QC(i), Pitchpar);%�����һ֡��96��byte��û�л�֡
end

% Declare error frames��������֡��λ�ã���������֡����ȫ����0��
QCN = NullStruct (QC);
QCN.FType = 4;
I = (Err ~= 0);
QC(I) = QCN;

if (any (Err ~=0))
  warning ('G7231Decode - Changed frames with illegal codes to error frames');
end

return

% ----- -----
function Err = CheckQCErr (QC, Pitchpar)
% Check whether the data has "forbidden" values
% - The last 4 pitch lag values are forbidden 
% - The pitch coefficient index must be in bounds

ACBLC = QC.ACBLC;
CGC = QC.CGC;
FType = QC.FType;
LThr = Pitchpar.CBookThr;
Err = 0;

if (FType == 0)
  CBookI = NaN;     % MP frame
else
  CBookI = 2;       % ACELP frame
end

NSubframe = length (CGC);
for (i = 1:NSubframe)

  % Determine the codebook used ���ݲ���������ʲô�����뱾
  PMode = Pitchpar.PMode(i);
  if (PMode == 1)
    Lt = ACBLC(i) + Pitchpar.PMin(PMode);
    if (Lt > Pitchpar.PMax(PMode))
      Err = 1;
    end
    if (FType == 0)       % MP frame
      CBookI = (Lt >= LThr) + 1;
    end
  end
%�������룬����Ӧ�뱾���弤�����뱾��combineģʽ��ѹ������
  % Process the combined gain code, giving the adaptive codebook gain code
  % and the pulse gain code
  [gC, ACBbC] = ExtractVals (CGC(i), Pitchpar.GModV{CBookI});
  ACBbI = ACBbC + 1;

  % Determine the pitch coefficient vector / codebook indices
  if (ACBbI > size (Pitchpar.b{CBookI}, 2))
    Err = 1;
  end

end

return