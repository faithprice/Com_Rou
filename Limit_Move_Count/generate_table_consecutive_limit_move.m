%function generate_table_consecutive_limit_move()
%根据已生成的Asharelimitmove表计算股票连续涨跌停的情况。
%   连续3涨提的记为3，连续3跌停的记为-3等等以此类推。不涨停也不跌停的记为0.
%   本函数先从数据库中提取已有的数据，然后逐个股票生成数据，最后把生成的数据一起插入数据库表

%Part 1 : retrieve data.
db_conn = database('jrgc','wind','wind','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@192.168.120.8:1521:');
% fileID = fopen('generate_BigHolderTrade.sql');
% sqlquery = textscan(fileID,'%s','whitespace','');
% sqlquery = char(sqlquery{1});
% fclose(fileID);
sqlquery = 'SELECT s_info_windcode,trade_dt,C_limit_move FROM FEDATA.Asharelimitmove ORDER BY s_info_windcode,trade_dt';
curs=exec(db_conn,sqlquery);
curs=fetch(curs);
all_data = curs.Data;
close(curs);

%Part 2: loop throught retrieved data.
%the form of processed data is: windcode,trade_dt,number of consecutive
%limit move.
[a,b] = size(all_data);
target_data = cell(a,b);
current_stock = '000001.SZ';
target_data(1,:) = all_data(1,:);
last_number = all_data{1,3};
for i =2:a
    if strcmp(all_data{i,1},current_stock)
        if last_number*all_data{i,3}>0
            target_data(i,:) = [all_data(i,1:2),num2cell(last_number+all_data{i,3})];
        else
            target_data(i,:) = all_data(i,:);
        end
    else
        target_data(i,:) = all_data(i,:);
        current_stock = all_data{i,1};
    end
    last_number = target_data{i,3};
end

%Part 3: Insert the calculated data;
tablename = 'FEDATA.AShareLianBanCount';
colnames = {'s_info_windcode','trade_dt','lianban_count'};
datainsert(db_conn,tablename,colnames,target_data)
commit(db_conn)
close(curs)
close(db_conn)
%end

