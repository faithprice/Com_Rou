%This script update db table : EMA_Percents.
%the difference between generate all new data and updating is:
%check the latest date between EMA_Percents and AShareEMAs.
%We use function to do it.
xEMA_Percents_all_update
xEMA_Percents_update('000300.SH');
xEMA_Percents_update('000905.SH');
xEMA_Percents_update('000001.SH');
xEMA_Percents_update('399106.SZ');
xEMA_Percents_update('399101.SZ');
xEMA_Percents_update('399102.SZ');