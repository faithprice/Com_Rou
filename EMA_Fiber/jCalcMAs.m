function singleMAs = jCalcMAs( stock_prices, lookback_periods )
% 计算各周期MA的值。本函数特别处理停牌的问题。
% 返回格式为行向量，对应相应MA的值
singleMAs = [];
n = length( lookback_periods);
[sm, sn] = size(stock_prices);
for i = 1:n
    period = lookback_periods(i);
    c = 0;
    p = sm;
    sum = 0;
    while c < period && p > 0
        if strcmp( char(stock_prices(p,3)), '停牌' ) ~= 1
            sum = sum + cell2mat(stock_prices(p,4));
            c = c + 1;    
        end
        p = p - 1;
    end
    if c~=0
        ma = sum/c;
        singleMAs = [ singleMAs, ma ];
    else
        singleMAs = [ singleMAs, NaN ];
    end
end



end

