close all;
string_1 = '1.bmp';
string_2 = '2.bmp';
string_3 = '3.bmp';
string_4 = '4.bmp';
string_5 = 'week12test.bmp';
load symcodes.mat -ascii
tc_uc=[65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,32,201,202,204];%大写字母模式
tc_lc=[97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,32,205,202,204];%小写字母模式
tc_mi=[48,49,50,51,52,53,54,55,56,57,38,13,09,44,58,35,45,46,36,47,43,37,42,61,94,203,32,201,200,204];%混合型模式
tc_do=[59,60,62,64,91,92,93,95,96,126,33,13,09,44,58,10,45,46,36,47,34,124,42,40,41,63,123,125,39,200];%标点型模式
%数字模式码表
nc_tb=[48,49,50,51,52,53,54,55,56,57];
for i = 1 : 4
    code_calculate = decoding(strcat(num2str(mod(i, 4)+1), '.bmp'));

    %解码码字转换
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

    %开始解码，暂时不支持字节型模式，只支持文本模式和数字模式
    codelen=decode(1);
    mode=11;%2->数字型、3->字节型、11->文本模式大写型、12->文本模式小写型、13->文本模式混合型、14->文本模式标点型
    premode=[0,0];%用于转移模式时记录模式值,第一个值表示当前是否为转移模式，第二个值表示要返回的模式值
    tcbyte=zeros(1,2);%用于记录文本模式时的高低位数据，第一个值表示高位数据，第二个值表示低位数据
    valueindex=[0,0];%用于记录字节模式和数字模式的缓存序列，其中第一个值表示序列是否有效及何种模式0->无效、1->数字模式、2->字节模式，第二个值表示序列起始位置
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

            %数字模式解码
            if valueindex(1)==1
%                 caches=decode(valueindex(2):(i-1));
%                 len=size(caches,2);
                curvalues=zeros(1,15);
                for k=1:15:len
                    if (k+14)<len %当前组大于15个码字
                        curvalues = caches(k:k+14);
                    else          %当前组不足15个码字
                        curvalues(k+15-len:15) = caches(k:len);
                    end
                    %开始解码
                    longnum=0;
                    for x=1:15
                        %必须用符号运算，否则有效数最多只有16位
                        longnum = longnum+curvalues(x)*sym(9^(15-x))*(100^(15-x));
                    end
                    tempstr=char(longnum);
                    str = strcat(str, tempstr(2:end));
                end
            end

            valueindex = [0,0];

        else

            %文本模式解码
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
                %文本模式解码结束

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
%     disp(['解码后的数据为：',str])
end