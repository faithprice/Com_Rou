%The program computes all EMAs of All A Shares.

%EMA Periods
C_LOOKBACK_PERIOD = [5,8,13,21,34,55,89,144,233]; 
num_of_EMA = length(C_LOOKBACK_PERIOD); 

%get all stocks' historical daily close price.
db_conn=database('jrgc','wind','wind','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@192.168.120.8:1521:');
sqlquery='Select AshareEODprices.s_info_windcode,AshareEODprices.trade_dt,AshareEODprices.s_dq_tradestatus,AshareEODprices.s_dq_adjclose From AshareEODprices Order By s_info_windcode,trade_dt';
curs=exec(db_conn,sqlquery);
curs=fetch(curs);
prices = curs.Data;
num_of_record = length(prices);
close(curs);
curs = 1;

%We use datainsert function to insert data to db in batch.
data_to_insert = cell(1000000,12);
row_num = 0;

%initializing
p_code = '';
table_name = 'FEDATA.AshareEMAs';
col_names = {'S_INFO_WINDCODE','Trade_DT','s_dq_adjclose','EMA_5','EMA_8','EMA_13','EMA_21','EMA_34','EMA_55','EMA_89','EMA_144','EMA_233'};

for i = 1:num_of_record
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
    if row_num == 1000000 || i == num_of_record
        %if there is 1 million rows in data_to_insert, insert it, then
        %reset it to empty cell(1000000,12)
        %Note that we insert the first row_num rows, so it cover both cases :
        % row_num = 1000000 and i = num_of_record.
        datainsert(db_conn,table_name,col_names,data_to_insert(1:row_num,:)); 
        commit(db_conn)
        fprintf('One million records have been inserted, WooHoo!\n')
        data_to_insert = cell(1000000,12);
        row_num = 0;
    end
end
close(db_conn)