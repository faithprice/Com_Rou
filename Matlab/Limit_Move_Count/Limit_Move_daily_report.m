%This script generate a report relate to limit move of whole market.

current_date = '20160115';
db_conn=database('jrgc','wind','wind','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@192.168.120.8:1521:');


select ='SELECT O_Limit_Move,H_Limit_Move,L_Limit_Move,C_Limit_Move';
from = ' FROM FEDATA.AShareLimitMove ';
where = strcat(' WHERE trade_dt=','''',current_date,'''');
sqlquery = strcat(select,from,where);
curs = exec(db_conn,sqlquery);
curs = fetch(curs);
OHLC_limit_data = cell2mat(curs.Data);
[a,b] = size(OHLC_limit_data);

N_sum = sum(OHLC_limit_data);
Abs_sum = sum(abs(OHLC_limit_data));
Limit_Up_Count = (N_sum+Abs_sum)/2;
Limit_Down_Count = (Abs_sum-N_sum)/2;

fprintf('The Number of  open limit up is : %d.\n',Limit_Up_Count(1));
fprintf('The Number of  open limit down is : %d.\n',Limit_Down_Count(1));
fprintf('The Number of  close limit up is : %d.\n',Limit_Up_Count(4));
fprintf('The Number of  close limit down is : %d.\n',Limit_Down_Count(4));

fprintf('The Number of  ever limit up is : %d.\n',Limit_Up_Count(2));
fprintf('The Number of  ever limit down is : %d.\n',Limit_Down_Count(3));

fprintf('The Number of  one line limit up is : %d.\n',Limit_Up_Count(3));
fprintf('The Number of  one line  limit down is : %d.\n',Limit_Down_Count(2));

fprintf('The Number of operable limit up is : %d.\n',Limit_Up_Count(4)-Limit_Up_Count(3));
fprintf('The Number of operable limit down is : %d.\n',Limit_Down_Count(4)-Limit_Down_Count(2));
fprintf('The Number of failed limit up is : %d.\n',Limit_Up_Count(2)-Limit_Up_Count(4));
fprintf('The Number of failed limit down is : %d.\n',Limit_Down_Count(3)-Limit_Down_Count(4));

