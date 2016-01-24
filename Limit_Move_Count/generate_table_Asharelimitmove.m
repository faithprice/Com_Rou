function generate_table_Asharelimitmove(begin_date,end_date)
%this script identify all stocks' daily limit move information.
%and insert them into table AShareLimitMove.

%we are gonna run though all stocks all trading dates.
%the problem we are gonna encounter are:
%1. there is no preclose. IPO 1st day. easy to deal with.
%2. also, there is problem when considering the stock divide etc.
%we have to bear with some error here, by using original price. without
%dealing with the stock divide day.
%3. the limit of daily move was imposed from year 19970101

%Here is the process we gonna do:
%Step 1. We do it in batch, 100 stocks at a time, so we will use multiple
%select statement to fetch required data.
%Step 2. fetch the original trading data. preclose,OHLC.
%Step 2. only fetch the data after '19970101'

db_conn=database('jrgc','wind','wind','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@192.168.120.8:1521:');

%let me try to do it in one stroke first.
select = 'SELECT P.s_info_windcode,P.trade_dt,P.s_dq_preclose,P.s_dq_open,P.s_dq_high,P.s_dq_low,P.s_dq_close';
from = ' FROM AShareEODPrices P';
where = strcat(' WHERE P.trade_dt>','''',begin_date,'''',' AND P.trade_dt<','''',end_date,'''');
sqlquery = strcat(select,from,where);
curs = exec(db_conn,sqlquery);
curs = fetch(curs);
all_data = curs.Data;
prices = cell2mat(all_data(:,3:7));
[a,b] = size(curs.Data);
close(curs)

%stock_code, trade_dt, OHLC status.
%we don't deal with tradestatus here. it will be dealt with when using this
%table. By jointly select other table.
data_to_insert = cell(a,6);

for i=1:a
    Trade_Data = prices(i,:);
    data_to_insert(i,:) = [all_data(i,1),all_data(i,2),num2cell(xStock_Limit_Move( all_data{i,1}, all_data{i,2},Trade_Data,db_conn))];
end

tablename = 'FEDATA.AShareLimitMove';
colnames = {'s_info_windcode','trade_dt','O_limit_move','H_limit_move','L_limit_move','C_limit_move'};
datainsert(db_conn,tablename,colnames,data_to_insert)
commit(db_conn)
close(curs)
close(db_conn)
end