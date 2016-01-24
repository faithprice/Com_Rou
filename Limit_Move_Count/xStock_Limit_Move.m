function [ LMM ] = xStock_Limit_Move( Stock_Windcode, Trade_Dt,Trade_Data,db_conn)
%this function compute single stocks' single day OHLC limit move status.
%   the input Trade_Data comprise preClose、OHLC、trade_status, (1,6) number matrix.
%   the output is a (1,4) number matrix.
%   LMM stands for limit move mark.

[PreClose,Open,High,Low,Close]=deal(Trade_Data(1),Trade_Data(2),Trade_Data(3),Trade_Data(4),Trade_Data(5));
%fprintf('preClose :%d\n',PreClose);

PLMP = xLimit_Move_Prices(PreClose);
normal_limit_up_price = PLMP(1);
normal_limit_down_price = PLMP(2);
ST_limit_up_price = PLMP(3);
ST_limit_down_price = PLMP(4);
up_limit_status = ([Open,High,Low,Close] == normal_limit_up_price);
down_limit_status = ([Open,High,Low,Close] == normal_limit_down_price);
st_up_limit_status = ([Open,High,Low,Close] == ST_limit_up_price);
st_down_limit_status = ([Open,High,Low,Close] == ST_limit_down_price);

% if high and low are within ST limit price range, should return [0,0,0,0]
if High < ST_limit_up_price && Low > ST_limit_down_price
    LMM = [0,0,0,0];
else
    if High > ST_limit_up_price || Low < ST_limit_down_price
        LMM = up_limit_status - down_limit_status;
    else
        sqlquery = strcat('Select s_type_st,entry_dt,remove_dt From AshareST Where s_info_windcode=','''',Stock_Windcode,'''');
        curs = exec(db_conn,sqlquery);
        curs = fetch(curs);
        [a,b] = size(curs.Data);
        close(curs)
        ST_proved = 0;
        for i = 1:a
            if strcmp(curs.Data{i,1},'S') ~= 1
                continue
            else
                if str2double(curs.Data{i,2}) > str2double(Trade_Dt)
                    continue
                else
                    if strcmp(curs.Data{i,3},'null') == 1 || str2double(curs.Data{i,3}) > str2double(Trade_Dt)
                        ST_proved = 1;
                    else
                        continue
                    end
                end
            end
        end
        if ST_proved == 1
            LMM = st_up_limit_status - st_down_limit_status;
        else
            LMM = up_limit_status - down_limit_status;
        end
    end
end

