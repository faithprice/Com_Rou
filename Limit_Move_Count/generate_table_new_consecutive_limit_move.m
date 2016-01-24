%function generate_table_consecutive_limit_move()
%本文档对连板的计算方法做了修改。体现在：
%1. 新股上市没开过板的连板不计入。
%2. 停牌后复牌，如果一字板，不计入，开板后方开始计入。

%实现方法：设置一个trigger，trigger为0时涨跌停板不计入，为1时方计入。
%新股上市和停牌trigger都置为0，仅当不再一字板时再置为1，即H不等于L时。

%本文档基于已计算获得的数据做修改，不再自主做大部分计算。
%除了FEDATA.AshareLianBanCount之外，我们还需要WIND.AshareEODPrices这个表的trade_status和High,Low.
%前者的日期范围小，前者left join后者即可。

%Part 1 : retrieve data.
db_conn = database('jrgc','wind','wind','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@192.168.120.8:1521:');
fileID = fopen('modify_LianBanCount.sql');
sqlquery = textscan(fileID,'%s','whitespace','');
sqlquery = char(sqlquery{1});
fclose(fileID);

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

