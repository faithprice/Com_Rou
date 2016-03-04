%generate the ratio between margin buy,margin repay and total trading amount of  every
%single stock,

%
db_conn=database('jrgc','wind','wind','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@192.168.120.8:1521:');
select = 'SELECT M.s_info_windcode,M.trade_dt,M.s_Margin_purchwithborrowmoney,nvl(M.s_margin_repaymenttobroker,0), P.s_dq_amount';
from = ' FROM AshareMarginTrade M, AshareEODPrices P';
where = ' WHERE M.s_info_windcode=P.s_info_windcode AND M.trade_dt=P.trade_dt AND P.s_dq_amount<>0';
order = ' ORDER BY M.trade_dt';
sqlquery = strcat(select, from, where,order);
curs = exec(db_conn,sqlquery);
curs = fetch(curs);
margin_data = curs.Data;
margin_trading = cell2mat(curs.Data(:,3:4));

%note that the unit of margin buying is 1, the unit of trading amount is
%10000, remember to multiply 10000 to the latter.
total_amount = cell2mat(curs.Data(:,5))*10000;
[a,b] = size(margin_data);
fprintf('Total rows are: %d\n',a);
close(curs)

%stock_code, tradt_dt, ratio.
data_to_insert = cell(a,4);
table_name = 'FEDATA.AShare_MarginTrading_Pct';
col_names = {'s_info_windcode','trade_dt','margin_buy_Pct','margin_repay_pct'};
row_count = 0;
margin_buy_daily = 0;
margin_repay_daily = 0;
normal_amount_daily = 0;
td = '';
overall_data_to_insert = {};
for i=1:a
    if strcmp(td,margin_data{i,2}) ~= 1
        if i ~= 1
            overall_data_to_insert = [overall_data_to_insert; ['000000.X',td,{num2str(margin_buy_daily/normal_amount_daily*100,'%4.2f'),num2str(margin_repay_daily/normal_amount_daily*100,'%4.2f')}]];
        end
        td = margin_data{i,2};
        margin_buy_daily = 0;
        margin_repay_daily = 0;
        normal_amount_daily = 0;
    end
    data_to_insert(i,:) = [margin_data(i,1),margin_data(i,2),{num2str(margin_trading(i,1)/total_amount(i)*100,'%4.2f'),num2str(margin_trading(i,2)/total_amount(i)*100,'%4.2f')}];
    row_count = row_count + 1; 
    margin_buy_daily = margin_buy_daily + margin_trading(i,1);
    margin_repay_daily = margin_repay_daily + margin_trading(i,2);
    normal_amount_daily = normal_amount_daily + total_amount(i);
    if mod(row_count,100000)==0
        fprintf('This many one hundred thousands lines prepared: %d.\n',row_count/100000);
    end
end
%insert(db_conn,table_name,col_names,data_to_insert);
overall_data_to_insert = [overall_data_to_insert; ['000000.X',td,{num2str(margin_buy_daily/normal_amount_daily*100,'%4.2f'),num2str(margin_repay_daily/normal_amount_daily*100,'%4.2f')}]];
[c1,d1] = size(overall_data_to_insert);
%insert(db_conn,table_name,col_names,overalldata_to_insert);
[a1,b1] = size(data_to_insert);
for i=1:a1
    sqlquery=strcat('INSERT INTO FEDATA.AShare_MarginTrading_Pct VALUES(','''',data_to_insert{i,1},'''',',','''',data_to_insert{i,2},'''',',',data_to_insert{i,3},',',data_to_insert{i,4},')');
    curs=exec(db_conn,sqlquery);
    commit(db_conn)
    close(curs);
    if mod(i,10000)==0
        fprintf('%d\n',i)
    end
end
[c1,d1] = size(overall_data_to_insert);
for i=1:c1
    sqlquery=strcat('INSERT INTO FEDATA.AShare_MarginTrading_Pct VALUES(','''',overall_data_to_insert{i,1},'''',',','''',overall_data_to_insert{i,2},'''',',',overall_data_to_insert{i,3},',',overall_data_to_insert{i,4},')');
    curs=exec(db_conn,sqlquery);
    commit(db_conn)
    close(curs);
end
commit(db_conn)
close(db_conn)
fprintf('All done, byebye.\n')