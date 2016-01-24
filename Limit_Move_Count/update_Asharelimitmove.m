%this script update table: Asharelimitmove.

%Since we don't need last day's data here,(already have it in column
%preclose),we do not need to separately process existing stock's new data
%and new IPO's data. just select all new trading day that not in
%ASharelimitmove is ok.

%we only need to slightly modify generate_table_Asharelimitmove.m

db_conn=database('jrgc','wind','wind','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@192.168.120.8:1521:');
select = 'SELECT P.s_info_windcode,P.trade_dt,P.s_dq_preclose,P.s_dq_open,P.s_dq_high,P.s_dq_low,P.s_dq_close';
from = ' FROM WIND.AShareEODPrices P';
where = strcat(' WHERE P.trade_dt>(SELECT max(trade_dt) FROM FEDATA.AShareLimitMove)');
sqlquery = strcat(select,from,where);
curs = exec(db_conn,sqlquery);
curs = fetch(curs);
all_data = curs.Data;
prices = cell2mat(all_data(:,3:7));
[a,b] = size(curs.Data);
close(curs)

data_to_insert = cell(a,6);

for i=1:a
    Trade_Data = prices(i,:);
    data_to_insert(i,:) = [all_data(i,1),all_data(i,2),num2cell(xStock_Limit_Move( all_data{i,1}, all_data{i,2},Trade_Data,db_conn))];
end

tablename = 'FEDATA.AShareLimitMove';
colnames = {'s_info_windcode','trade_dt','O_limit_move','H_limit_move','L_limit_move','C_limit_move'};
datainsert(db_conn,tablename,colnames,data_to_insert)
fprintf('Inserted %d rows of data.\n',a)
commit(db_conn)
close(curs)
close(db_conn)

