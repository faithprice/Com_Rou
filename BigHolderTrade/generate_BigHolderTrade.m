%generate historical data of Big Holder's trading.
%do the sum up every week.
%retrieve data from Wind.AshareMjrHolderTrade
db_conn = database('jrgc','wind','wind','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@192.168.120.8:1521:');

fileID = fopen('generate_BigHolderTrade.sql');
sqlquery = textscan(fileID,'%s','whitespace','');
sqlquery = char(sqlquery{1});
fclose(fileID);

curs = exec(db_conn,sqlquery);
curs = fetch(curs);
wind_code = curs.Data(:,1);
trans_start = curs.Data(:,2);
trans_end = curs.Data(:,3);
holder_type = str2num(cell2mat(curs.Data(:,4)));
transact_type = strcmp(curs.Data(:,5),'增持');
transact_quantity = cell2mat(curs.Data(:,6));
transact_price = cell2mat(curs.Data(:,7));
close(curs);

%about the computation, see the relevant note in evernote.

[a,b] = size(trans_end);

%to simplify the iteration of adding 7 days, we use numerical denotation of
%days first.
week_begin_day = datenum('19940807','yyyymmdd');
week_end_day = week_begin_day+7;

raw_data_to_insert = []; %date in num, three kind.
%we separate the type of transaction into 3 types, according to database
%data.

%initialize
individual = 0;
corporation = 0;
management = 0;
% for i = 1:a
%     if isnan(transact_quantity)
%         fprintf('order number is :%d\n',i)
%     end
% end
for i =1:a
    %see if current day is larger than week_end_day,if yes,modify
    %week_end_day until it is no smaller than current_day, and initialize
    %transact data accordingly.
    while datenum(trans_end{i},'yyyymmdd') > week_end_day
        raw_data_to_insert = [raw_data_to_insert;[week_end_day,individual,corporation,management]];
        week_end_day = week_end_day + 7;
        individual = 0;
        corporation = 0;
        management = 0;
    end
    %
    if transact_price(i)==0
        if strcmp(trans_start{i},'null') == 1
            begin_date = trans_end{i};
        end
        trading_avg_price = Average(wind_code{i}, begin_date,trans_end{i},db_conn);
    else
        trading_avg_price = transact_price(i);
    end
    individual = individual + trading_avg_price*transact_quantity(i)*sign(transact_type(i)-0.5)*(holder_type(i)==1);
	corporation = corporation + trading_avg_price*transact_quantity(i)*sign(transact_type(i)-0.5)*(holder_type(i)==2);
	management = management + trading_avg_price*transact_quantity(i)*sign(transact_type(i)-0.5)*(holder_type(i)==3); 
    if isnan(individual) || isnan(corporation) || isnan(management)
        fprintf('order number is :%d\n',i)
    end
end

%next we modify the date part in raw_data_to_insert.
[c,d]=size(raw_data_to_insert);
data_to_insert=cell(c,4);
for i = 1:c
    data_to_insert(i,1)={datestr(raw_data_to_insert(i,1),'yyyymmdd')};
    data_to_insert(i,2:4)=num2cell(raw_data_to_insert(i,2:4));
end

%Now insert
table_name = 'FEDATA.AShare_Big_Trading_W';
colnames = {'Trading_Date','Individual','corporal','management'};
datainsert(db_conn,table_name,colnames,data_to_insert);

close(curs)
close(db_conn)