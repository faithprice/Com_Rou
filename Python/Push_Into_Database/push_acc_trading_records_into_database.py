# -*- coding: utf-8 -*-
import os
import cx_Oracle
import pandas as pd
os.environ["NLS_LANG"] = ".AL32UTF8"
os.putenv('ORACLE_HOME', '/usr/local/lib/share/oracle')
os.putenv('LD_LIBRARY_PATH', '/usr/local/lib/share/oracle')

trading_record = '融金添利交易20150301-20151031.xls'
df = pd.read_excel(trading_record, skiprows=1, skip_footer=1)
df.columns = ['Security_Code', 'Trading_Volume', 'Trading_Date', 'Average_Price', 'Trading_Direction', 'Security_Name']
df['Account_Name'] = trading_record[:4]
data_to_insert = df.replace('股票买入', '买入').replace('股票卖出', '卖出').replace('融券回购', '逆回购').to_dict()


conn = cx_Oracle.connect('wind', 'wind', '192.168.120.8:1521/jrgc')
cursor = conn.cursor()


Insert_String = "Insert Into FEDATA.Account_Trading (Trading_Date,Security_Code,Average_Price,Trading_Direction,Account_Name,Trading_Volume,Security_Name) Values("


n = len(data_to_insert['Trading_Date'])


for i in range(n):
    sqlquery = Insert_String + '\'' + str(data_to_insert['Trading_Date'][i]) + '\',\'' + str(data_to_insert['Security_Code'][i]).zfill(6) + '\',\'' + str(data_to_insert['Average_Price'][i]) + '\',\'' + str(data_to_insert['Trading_Direction'][i]) + '\',\'' + str(data_to_insert['Account_Name'][i]) + '\',\'' + str(data_to_insert['Trading_Volume'][i]) + '\',\'' + str(data_to_insert['Security_Name'][i])+ '\''+')'
    cursor.execute(sqlquery)

conn.commit()
conn.close()

