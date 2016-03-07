# -*- coding: utf-8 -*-
import os
import cx_Oracle
import pandas as pd
os.environ["NLS_LANG"] = ".AL32UTF8"
conn = cx_Oracle.connect('wind', 'wind', '192.168.120.8:1521/jrgc')
cursor = conn.cursor()

# 本程序第一版，先计算汇聚金的净利润
# 我们需要的数据包括：2016年1月1日的净值、本金，2016年1月1日之后的理财进出资金情况(数额、日期)，
# 资金成本用4% 和 5% 分别计算一次。

# Part 1.
sqlquery = "select DT,KMBM,KMMC from FEDATA.BZH_GZB where zh_ID=3 and KMBM='今日单位净值：'  order by DT desc"
cursor.execute(sqlquery)
a = cursor.fetchone()
print(a)
print(type(a))