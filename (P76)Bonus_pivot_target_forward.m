clc; clear all;
%%%%%%%%%  Contract Setting %%%%%%%%%%%%%%
P = 1000000;                %% Notional Amount
Upfront_Premium = 75000;   %% Upfront Premium 
L = 1;                      %% Leverage
SL = 1.31;                  %% Strike Low Price
SH = 1.425;                 %% Strike High Price 
T = 1;                      %% Time to Maturity  
n = 12;                     %% Number of Settlements
dt = T/n;                   %% Time Length of each period  
Target_count = 4;           %% Target
bonus_amount = 10000;        %% US 10000
%%%%%%%%%  Market Parameter %%%%%%%%%%%%%%
X=1.375;                  %% Spot Reference 
v=0.2;                    %% Volatility
rd=0.02;                  %% Domestic interest rate (US)
rf=0.01;                  %% Foreign Interest Rate (EUR)
%%%%%%%%%  Simulation  Parameter %%%%%%%%%%%%%%
N=1000;                    %%  Simulation Paths
randn('seed',100);         %%  Control random numbers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Payoff_Path=zeros(N,n);            %% Payoff for each settlement date of each Path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:N                %% Path 
    Xt = X;                %% Reset the Spot Exchange Rate
    TC = 0;                %% Target Acount
    for t=1:n              %% Settlement
        XT = Xt*exp((rd-rf-0.5*v^2)*dt+v*sqrt(dt)*normrnd(0,1,1,1));     
        if  SL <= XT & XT <= SH      %% profit
            Payoff_Path(i,t) = bonus_amount*exp(-rd*t*dt);  %% Profit
            TC = TC + 1;
            if TC >= 4
                break;
            end
        elseif XT > SH
            Payoff_Path(i,t) = -L*P*(XT - SH)*exp(-rd*t*dt); %% Loss 
        elseif XT < SH
             Payoff_Path(i,t) = -L*P*(SL - XT)*exp(-rd*t*dt); %% Loss
        end
        Xt=XT;    %% Reset inital exchnage rate         
    end
    Period_Path(i,1)=t;
end

Total_Payoff_Path = sum(Payoff_Path,2)+ Upfront_Premium;  
Price = mean(Total_Payoff_Path) 
se=std(Total_Payoff_Path)/sqrt(N)  
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%????????????
Win_Path = Total_Payoff_Path >=0;  %% Win=1, Loss=0
Win_Probability =  sum(Win_Path) / N   %??????????????????
Average_Profit_Win = mean( Total_Payoff_Path(Win_Path) )%????????????????????????
Average_Period_Win = mean( Period_Path(Win_Path) )  %???????????????????????????
SORT= sort(Total_Payoff_Path);  %????????????
BIG5 = SORT(ceil(0.95*N))       %???????????????5%?????????
Average_BIG5 = mean(SORT( ceil(0.95*N):N ))  %??????5%?????????
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%????????????
Loss_Path = Total_Payoff_Path <0;  %% Loss=1, Win=0
Loss_Probability =  sum(Loss_Path) / N   %??????????????????
Average_Loss_Loss = mean( Total_Payoff_Path(Loss_Path))%???????????????????????????
Average_Period_Loss = mean( Period_Path(Loss_Path) )  %???????????????????????????
SORT= sort(Total_Payoff_Path);  %????????????
SMALL5 = SORT(floor(0.05*N))       %???????????????5%?????????
Average_SMALL5 = mean(SORT( 1: floor(0.20*N)))  %??????5%?????????
