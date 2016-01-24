function vol_avg_price = Average( wind_code, begin_date,end_date,db_conn )
%compute the volume weighted average price over a period of days.
%   compute the volume weighted average price over a period of days.
select = 'SELECT s_dq_avgprice';
from = ' FROM AShareEODPrices';
where = strcat(' WHERE trade_dt>=','''',begin_date,'''',' AND trade_dt<=','''',end_date,'''', ' AND s_info_windcode = ','''',wind_code,'''');
sqlquery = strcat(select,from,where);
curs = exec(db_conn,sqlquery);
curs = fetch(curs);
vol_avg_price = mean(cell2mat(curs.Data(:,1)));
close(curs)
end

