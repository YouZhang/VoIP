function [Chinese] = isChinese(ch)
% ����GB2312���ַ�����������ƽʱ��˵����λ����һ�����ֶ�Ӧ�������ֽڡ� ÿ���ֽڶ��Ǵ���A0��ʮ������,��160����
% ��������һ���ֽڴ���A0�����ڶ����ֽ�С��A0����ô��Ӧ�����Ǻ��֣���������GB2312)
info = unicode2native(ch,'GB2312');
bytes = size(info,2);
Chinese = 0;
if (bytes == 2)
    if(info(1)>160 & info(2)>160)
        Chinese = 1;
    end
end