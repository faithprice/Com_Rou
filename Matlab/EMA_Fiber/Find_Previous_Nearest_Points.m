function [ Similar_Dates_In_History ] = Find_Previous_Nearest_Points(Target_Index,Target_Date,DistF)
%This script find the previous nearest points use distance definition is DistF
db_conn=database('jrgc','wind','wind','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@192.168.120.8:1521:');
select = 'SELECT E.*';
from = strcat(' FROM FEDATA.EMAs_Percents E');
where = strcat(' WHERE E.index_code=','''',Target_Index,'''',' AND E.trade_dt<=','''',Target_Date,'''');
order_by = ' ORDER BY E.trade_dt';
sqlquery = strcat(select,from,where,order_by);
curs=exec(db_conn,sqlquery);
curs=fetch(curs);
All_Previous_Points=curs.Data;
close(curs);

%The last point in All_Previous_Points is the point in question.

[a,b]=size(All_Previous_Points);
length_of_history = a-1;

%compute the distances, sort the distances, use the second column to store the 
distances=zeros(length_of_history,2);

for i=1:length_of_history
    X=[cell2mat(All_Previous_Points(i,3:end));cell2mat(All_Previous_Points(a,3:end))];
    distances(i,1)=pdist(X,DistF);
    distances(i,2)=i;
end
temp=sortrows(distances,1);
Similar_Dates_In_History=All_Previous_Points(temp(1:20,2),2);
close(db_conn)

end