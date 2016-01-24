function [ current_EMAs ] = jCalcEMAs( adj_Current_Close, Last_EMAs,Periods )
% 计算单只股票所提供时间序列上每个时间点的EMAs。本函数针对日线，对停牌做了特殊处理。
% 本函数的输入：最新交易日后复权收盘价，上一个交易日的EMA数值，EMA的参数。
% 本函数的输出：最新交易日的EMAs
n = length( Periods);
adj_Last_Closes = ones(1,n)*adj_Current_Close;
current_EMAs = (adj_Last_Closes+(Periods-1).*Last_EMAs)./Periods;
end

