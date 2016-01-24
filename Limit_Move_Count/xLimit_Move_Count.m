function [ limit_up_percentage,limit_down_percentage ] = xLimit_Move_Count(Index_Code,Trading_Date,db_conn)
%xLimit_Move_Count count percentage of limit moves on specific A Share
%Index Components, on specific Trading Date.
%   use function xLimit_Move_ID to do the computation.

%We better get all the data from database in one move. Which is far less time
%consuming. 

%we restrict the domain of accepted index inside SH and SZ stock indexes.
%exclude WIND stock indexes.
select =  'Select P.s_info_windcode ,P.s_dq_preclose preC,P.s_dq_open O,P.s_dq_high H,P.s_dq_low L,P.s_dq_close C ';
from = ' From AShareEODPrices P,AIndexMembers M';
where = strcat(' Where M.s_info_windcode=','''',Index_Code,'''',' AND P.trade_dt=',Trading_Date,' AND M.s_con_windcode=P.s_info_windcode AND M.s_con_indate<=',Trading_Date,' AND (M.cur_sign=1 OR M.s_con_outdate>=',Trading_Date,')');
sqlquery = strcat(select,from,where);
curs = exec(db_conn,sqlquery);
curs = fetch(curs);
prices = curs.Data;
num_of_stocks = length(curs.Data);
close(curs)

natural_count=[0,0,0,0];
abs_count=[0,0,0,0];

%cell2mat is also a slow function, we use it as less as we can.
Stocks_Prices=cell2mat(curs.Data(:,2:6));
for i=1:num_of_stocks
    temp = xLimit_Move_ID(Stocks_Prices(i,:),prices{i,1},Trading_Date,db_conn);
    natural_count=natural_count+temp;
    abs_count=abs_count+abs(temp);
end
%Use natural_count and abs_count for auxillary computing.
limit_up_percentage = (abs_count+natural_count)/2;
limit_down_percentage = (abs_count-natural_count)/2;

end

