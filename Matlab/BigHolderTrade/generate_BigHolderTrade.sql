SELECT S_info_windcode,transact_startdate,transact_enddate,HOLDER_TYPE,TRANSACT_TYPE,nvl(TRANSACT_QUANTITY,0),nvl(AVG_PRICE,0)
FROM WIND.AShareMjrHolderTrade
WHERE whether_agreed_repur_trans = 0
ORDER BY transact_enddate