function [ avg_return ] = EMAs_Prediction( Index_Code,Target_Date,predict_length)
%predict on average what happened after the 20 similarest history trading dates.
%   Using function Find_Previous_Nearest_Points to help find the dates.
db_conn = database('jrgc','wind','wind','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@192.168.120.8:1521:');
candidate_dates = Find_Previous_Nearest_Points(Index_Code,Target_Date,'euclidean');

%find the earliest date in candidate_dates
start_date = datestr(min(datenum(candidate_dates,'yyyymmdd')),'yyyymmdd');

%then select the historical prices from this start_date.
sqlquery = strcat('SELECT P.trade_dt,P.s_dq_close FROM AIndexEODPrices P WHERE P.trade_dt>=','''',start_date,'''');
curs = exec(db_conn,sqlquery);
curs = fetch(curs);
data_to_use = curs.Data;
[a,b] = size(data_to_use);
returns=[];
numify_candidates = datenum(candidate_dates,'yyyymmdd');
numify_data_to_use_date = datenum(data_to_use(:,1),'yyyymmdd');
numify_data_to_use_price = cell2mat(data_to_use(:,2));
numify_target_date = datenum(Target_Date,'yyyymmdd');
for i = 1:20
    for j = 1:a
        if numify_candidates(i)==numify_data_to_use_date(j) && numify_data_to_use_date(j)+predict_length <= numify_target_date
            returns=[returns;(numify_data_to_use_price(j+round(predict_length*9/14))/numify_data_to_use_price(j)-1)*100];
        end
    end
end
avg_return=mean(returns);
close(db_conn)
end