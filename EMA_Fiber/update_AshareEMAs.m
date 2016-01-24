%This script updates TABLE: AShareEMAs
db_conn=database('jrgc','wind','wind','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@192.168.120.8:1521:');
tablename = 'FEDATA.AshareEMAs';
colnames = {'S_INFO_WINDCODE','Trade_DT','s_dq_adjclose','EMA_5','EMA_8','EMA_13','EMA_21','EMA_34','EMA_55','EMA_89','EMA_144','EMA_233'};

C_LOOKBACK_PERIOD = [5,8,13,21,34,55,89,144,233];
num_of_EMA=length(C_LOOKBACK_PERIOD);

%We take the new stock data that the stock exist in AShareEMAs,but
%AShareEODPrices have newer trading data.
%This Part does not include the case that before the update there is new
%stock IPO，it will be processed at next part.

select = 'Select P.s_info_windcode,P.trade_dt,P.s_dq_tradestatus,P.s_dq_adjclose,A2.EMA_5,A2.EMA_8,A2.EMA_13,A2.EMA_21,A2.EMA_34,A2.EMA_55,A2.EMA_89,A2.EMA_144,A2.EMA_233 ';
from = ' From WIND.AshareEODPrices P INNER JOIN (Select A1.* From Fedata.AShareEMAs A1 Where (A1.s_info_windcode,A1.trade_dt) IN (Select s_info_windcode,max(trade_dt) From Fedata.AShareEMAs Group By s_info_windcode)) A2 ';
on = ' ON P.s_info_windcode = A2.s_info_windcode AND P.trade_dt >A2.trade_dt';
order = ' Order By P.s_info_windcode, P.trade_dt';

sqlquery = strcat(select,from,on,order);
curs=exec(db_conn,sqlquery);
curs=fetch(curs);
prices = curs.Data;
close(curs);
fprintf('Got Data, go on working. \n')

insert_data_count = 0;
[num_of_data,b] = size(curs.Data);
p_code = '';
data_to_insert={};

%b=1 means there is no data retrieved, then we will skip this part.
if b == 1
    fprintf('No existing stock need to be updated!\n')
else
    for i = 1:num_of_data
        %first,see if it's new stock, if yes, set last_EMAs,do nothing
        %about current_EMAs.
        if strcmp( p_code, prices{i,1}) ~= 1
            p_code = prices{i,1};
            %A catch here.when changed stock,use the EMA stored at the tail
            %of prices.
            last_EMAs = cell2mat(prices(i,5:13));
        end
        if strcmp(prices{i,3},'停牌') == 1
            current_EMAs = last_EMAs;
        else
            current_EMAs = jCalcEMAs( prices{i,4}, last_EMAs,C_LOOKBACK_PERIOD ) ;
            last_EMAs = current_EMAs;
        end
        %Since the increment data should not be huge,so I indulge myself to
        %do a little on-the-fly list-modification.
        data_to_insert = [data_to_insert;[{p_code,prices{i,2},prices{i,4}},num2cell(current_EMAs)]];
        insert_data_count = insert_data_count + 1;
    end
end
datainsert(db_conn,tablename,colnames,data_to_insert);
commit(db_conn)
close(curs)
fprintf('Number of Pre-existing stocks'' inserted Data: %d\n',insert_data_count);

%This part deal with new IPO stock.
sqlquery='SELECT P.s_info_windcode, P.trade_dt,P.s_dq_tradestatus,P.s_dq_adjclose FROM Wind.AShareEODPrices P WHERE P.s_info_windcode NOT IN (SELECT DISTINCT(s_info_windcode) FROM FEDATA.AShareEMAs)';
curs = exec(db_conn,sqlquery);
curs = fetch(curs);
prices = curs.Data;
close(curs)

[num_of_new_IPOdata,d] = size(curs.Data);
data_to_insert = cell(num_of_new_IPOdata,12);
row_num = 0;

p_code = '';
if d == 1
    fprintf('No new IPO in this period!\n');
else
    insert_data_count = 0;
    for i = 1:num_of_new_IPOdata       
        if strcmp( p_code, prices{i,1}) ~= 1
            p_code = prices{i,1};
            last_EMAs = ones(1,num_of_EMA) * prices{i,4};
        end
        if strcmp(prices{i,3},'停牌') == 1
            current_EMAs = last_EMAs;
        else
            current_EMAs = jCalcEMAs( prices{i,4}, last_EMAs,C_LOOKBACK_PERIOD ) ;
            last_EMAs = current_EMAs;
        end
        row_num = row_num + 1;
        data_to_insert(row_num,:) = [{p_code,prices{i,2},prices{i,4}},num2cell(current_EMAs)];
    end
    datainsert(db_conn,tablename,colnames,data_to_insert);
    fprintf('Number of IPO Inserted Data: %d\n',insert_data_count);
    commit(db_conn)
    close(curs)
end
close(db_conn)