close all;
string_1 = '1.bmp';
string_2 = '2.bmp';
string_3 = '3.bmp';
string_4 = '4.bmp';
string_5 = 'week12test.bmp';
load symcodes.mat -ascii
tc_uc=[65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,32,201,202,204];%��д��ĸģʽ
tc_lc=[97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,32,205,202,204];%Сд��ĸģʽ
tc_mi=[48,49,50,51,52,53,54,55,56,57,38,13,09,44,58,35,45,46,36,47,43,37,42,61,94,203,32,201,200,204];%�����ģʽ
tc_do=[59,60,62,64,91,92,93,95,96,126,33,13,09,44,58,10,45,46,36,47,34,124,42,40,41,63,123,125,39,200];%�����ģʽ
%����ģʽ���
nc_tb=[48,49,50,51,52,53,54,55,56,57];
for i = 1 : 4
    code_calculate = decoding(strcat(num2str(mod(i, 4)+1), '.bmp'));

    %��������ת��
    [row,col] = size(code_calculate);
    code_calculate = code_calculate(1:row, 17:col-17);
    [row,col] = size(code_calculate);
    decode = zeros(1, round(row*col/8));

    k = 1;
    for i=1:row
        for j=1:8:col
            temp = 0;
            for p = 0:7
                temp = temp + code_calculate(i, j+p)*10^(7-p);
            end
            for m=1:3
                for n=1:929
                    if symcodes(m,n)==temp
                        decode(k)=n-1;
                        k=k+1;
                        break;
                    end
                end
            end
        end
    end

    %��ʼ���룬��ʱ��֧���ֽ���ģʽ��ֻ֧���ı�ģʽ������ģʽ
    codelen=decode(1);
    mode=11;%2->�����͡�3->�ֽ��͡�11->�ı�ģʽ��д�͡�12->�ı�ģʽСд�͡�13->�ı�ģʽ����͡�14->�ı�ģʽ�����
    premode=[0,0];%����ת��ģʽʱ��¼ģʽֵ,��һ��ֵ��ʾ��ǰ�Ƿ�Ϊת��ģʽ���ڶ���ֵ��ʾҪ���ص�ģʽֵ
    tcbyte=zeros(1,2);%���ڼ�¼�ı�ģʽʱ�ĸߵ�λ���ݣ���һ��ֵ��ʾ��λ���ݣ��ڶ���ֵ��ʾ��λ����
    valueindex=[0,0];%���ڼ�¼�ֽ�ģʽ������ģʽ�Ļ������У����е�һ��ֵ��ʾ�����Ƿ���Ч������ģʽ0->��Ч��1->����ģʽ��2->�ֽ�ģʽ���ڶ���ֵ��ʾ������ʼλ��
    str='';
    for i=2:codelen
        if decode(i)>=900
            if decode(i)==900
                mode=11;
            elseif decode(i)==902
                mode=2;
            elseif (decode(i)==901) || (decode(i)==924) || (decode(i)==913)
                mode=3;
            end

            %����ģʽ����
            if valueindex(1)==1
%                 caches=decode(valueindex(2):(i-1));
%                 len=size(caches,2);
                curvalues=zeros(1,15);
                for k=1:15:len
                    if (k+14)<len %��ǰ�����15������
                        curvalues = caches(k:k+14);
                    else          %��ǰ�鲻��15������
                        curvalues(k+15-len:15) = caches(k:len);
                    end
                    %��ʼ����
                    longnum=0;
                    for x=1:15
                        %�����÷������㣬������Ч�����ֻ��16λ
                        longnum = longnum+curvalues(x)*sym(9^(15-x))*(100^(15-x));
                    end
                    tempstr=char(longnum);
                    str = strcat(str, tempstr(2:end));
                end
            end

            valueindex = [0,0];

        else

            %�ı�ģʽ����
            if mode>10
                tcbyte(1)=floor(decode(i)/30);
                tcbyte(2)=decode(i) - tcbyte(1)*30;
                for j=1:2
                    if mode==11
                        if premode(1)==1
                            mode=premode(2);
                            premode(1)=0;
                        end
                        if tc_uc(tcbyte(j)+1)==201
                            mode=12;
                        elseif tc_uc(tcbyte(j)+1)==202
                            mode=13;
                        elseif tc_uc(tcbyte(j)+1)==204
                            premode(1)=1;
                            premode(2)=mode;
                            mode=14;
                        else
                            str = strcat(str,char(tc_uc(tcbyte(j)+1)));
                        end
                    elseif mode==12
                        if premode(1)==1
                            mode=premode(2);
                            premode(1)=0;
                        end
                        if tc_lc(tcbyte(j)+1)==205
                            premode(1)=1;
                            premode(2)=mode;
                            mode=11;
                        elseif tc_lc(tcbyte(j)+1)==202
                            mode=13;
                        elseif tc_lc(tcbyte(j)+1)==204
                            premode(1)=1;
                            premode(2)=mode;
                            mode=14;
                        else
                            str = strcat(str,char(tc_lc(tcbyte(j)+1)));
                        end
                    elseif mode==13
                        if premode(1)==1
                            mode=premode(2);
                            premode(1)=0;
                        end
                        if tc_mi(tcbyte(j)+1)==200
                            mode=11;
                        elseif tc_mi(tcbyte(j)+1)==201
                            mode=12;
                        elseif tc_mi(tcbyte(j)+1)==203
                            mode=14;
                        elseif tc_mi(tcbyte(j)+1)==204
                            premode(1)=1;
                            premode(2)=mode;
                            mode=14;
                        else
                            str = strcat(str,char(tc_mi(tcbyte(j)+1)));
                        end
                    elseif mode==14
                        if premode(1)==1
                            mode=premode(2);
                            premode(1)=0;
                        end
                        if tc_do(tcbyte(j)+1)==200
                            mode=11;
                        else
                            str = strcat(str,char(tc_do(tcbyte(j)+1)));
                        end
                    end
                end
                %�ı�ģʽ�������

            elseif mode==2
                if valueindex(1)==0
                    valueindex(1)=1;
                    valueindex(2)=i;
                end
            elseif mode==3
                if valueindex(1)==0
                    valueindex(1)=2;
                    valueindex(2)=i;
                end
            end
        end
    end
%     disp(['����������Ϊ��',str])
end