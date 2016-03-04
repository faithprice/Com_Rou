function CLMS = consecutive_limit_move_stocks( ref_day,ref_end_day,up_down,count)
%%We count the number of stocks that limit move in a consecutive way.
%   此处显示详细说明

%We have an auxillary table that records all limit move of all stocks
%OHLC.
%so we only need to compute all the C data, and adds them up.
%all stocks that get a full sum is valid for our purpose.

db_conn=database('jrgc','wind','wind','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@192.168.120.8:1521:');
select = 'SELECT s_info_windcode,trade_dt,C_limit_move';
from = ' FROM FEDATA.AShareLimitmove L';
where = strcat(' WHERE L.trade_dt<=','''',ref_day,'''',' AND L.trade_dt>=','''',ref_end_day,'''');
sqlquery = strcat(select,from,where);
curs = exec(db_conn,sqlquery);
curs = fetch(curs);
all_data = curs.Data;

close(db_conn);
end

