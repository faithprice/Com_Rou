function xEMA_Percents_all()
%This function generate all A Shares EMA relative position percentage
%input：none
%output: do the computation with existing table and insert the generated
%data.
%Since 881001.WI only starts from year 2000, I will create my own 'index code'
%to represent all trading A shares. Say '000000.X'
Index_Code = '000000.X';
db_conn=database('jrgc','wind','wind','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@192.168.120.8:1521:');
%This function do not deal with '.WI' index, they will be dealt by
%xEMA_Percents_Wind.

select = 'SELECT E.*';
from = strcat(' FROM FEDATA.AshareEMAs E');%, WIND.AIndexMembers M');
%where = strcat(' WHERE E.trade_dt>=','''',begin_date,'''',' AND E.trade_dt<','''',end_date,'''');
order_by = ' ORDER BY E.trade_dt';
sqlquery = strcat(select,from,order_by);
curs = exec(db_conn,sqlquery);
curs = fetch(curs);
fprintf('got the Data. \n')
selected_EMAs = curs.Data;
close(curs)

[num_of_records,b] = size(selected_EMAs);

%loop through selected_EMAs to ascertain the number of trading dates to deal with.
t_d='';
td_count = 0;
for j=1:num_of_records
    if strcmp(t_d,selected_EMAs{j,2}) ~= 1
        t_d = selected_EMAs{j,2};
        td_count = td_count + 1;
    end
end
fprintf('Total number of trading dates is %d .\n',td_count);

%to simplify code in the For loop, I deal with i=1 out of loop.
%The first trading day does contain more than one stock, we should be fine.
dates_num = 0;
current_td = selected_EMAs{1,2};
stock_count = 1;
position_count = cell2mat(selected_EMAs(1,4:12)) < selected_EMAs{1,3};
data_to_insert = cell(td_count,11);

for i=2:num_of_records
    if strcmp( current_td, selected_EMAs{i,2}) ~= 1
        %change of trading day, time to update data_to_insert.
        position_percents = position_count/stock_count;
        dates_num = dates_num + 1;
        data_to_insert(dates_num,:) = [{Index_Code,current_td},num2cell(position_percents)];
        current_td = selected_EMAs{i,2};
        stock_count = 0;
        position_count = zeros(1,9);
        if mod(dates_num,200)
            fprintf('one trading day processed! Date count = %d.\n',dates_num)
        end
    end
    position_count = position_count + (cell2mat(selected_EMAs(i,4:12)) < selected_EMAs{i,3});
    stock_count = stock_count + 1;
end

%after above loop, we have not deal with the last trading day,so here it
%is:
position_percents = position_count/stock_count;
dates_num = dates_num + 1;
data_to_insert(dates_num,:) = [{Index_Code,current_td},num2cell(position_percents)];

fprintf('one trading day processed! Date count = %d.\n',dates_num)
frpintf('Data done collecting, commencing insert.')

%specify the input of datainsert
table_name = 'FEDATA.EMAs_Percents';
col_names = {'Index_Code','Trade_dt','EMA_5','EMA_8','EMA_13','EMA_21','EMA_34','EMA_55','EMA_89','EMA_144','EMA_233'};
datainsert(db_conn,table_name,col_names,data_to_insert)
commit(db_conn)
close(db_conn)
end

