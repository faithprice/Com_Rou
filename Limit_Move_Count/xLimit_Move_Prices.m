function [PLMP] = xLimit_Move_Prices( pre_Close )
%Compute probable limit move price. normally 10%, for ST 5%.
%   input:preClose. computation rule: round at 0.01 yuan.
%   PLM means probable limit move prices.
normal_limit_move_size = 0.1;
ST_limit_move_size = 0.05;

PLMP = [ round(pre_Close*(1+normal_limit_move_size),2),...
    round(pre_Close*(1-normal_limit_move_size),2),...
    round(pre_Close*(1+ST_limit_move_size),2),...
    round(pre_Close*(1-ST_limit_move_size),2) ];
end

