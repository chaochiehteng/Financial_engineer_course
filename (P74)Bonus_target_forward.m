clc; clear all;
%%%%%%%%%  Contract Setting %%%%%%%%%%%%%%
P = 1000000;                %% Notional Amount
Upfront_Premium = 100000;   %% Upfront Premium 
L = 2;                      %% Leverage
K = 1.415;                  %% Strike Price
B = 1.45;                   %% Barrier 
T = 1;                      %% Time to Maturity  
n = 12;                     %% Number of Settlements
dt = T/n;                   %% Time Length of each period  
Target_count = 4;           %% Target
pi = 0;                      %% P(i)
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
        if XT <= K      %% profit
            Payoff_Path(i,t) = bonus_amount*exp(-rd*t*dt);  %% Profit
            TC = TC + 1;
            if TC >= 4
                break;
            end
        elseif XT > K
            Payoff_Path(i,t) = -L*P*(XT - K)*exp(-rd*t*dt); %% Loss 
        end
        Xt=XT;    %% Reset inital exchnage rate         
    end
    Period_Path(i,1)=t;
end

Total_Payoff_Path = sum(Payoff_Path,2)+ Upfront_Premium;  
Price = mean(Total_Payoff_Path) 
se=std(Total_Payoff_Path)/sqrt(N)  
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%勝率分析
Win_Path = Total_Payoff_Path >=0;  %% Win=1, Loss=0
Win_Probability =  sum(Win_Path) / N   %出場獲利機率
Average_Profit_Win = mean( Total_Payoff_Path(Win_Path) )%出場獲利平均金額
Average_Period_Win = mean( Period_Path(Win_Path) )  %出場獲利的平均期數
SORT= sort(Total_Payoff_Path);  %小排至大
BIG5 = SORT(ceil(0.95*N))       %最大排在第5%的金額
Average_BIG5 = mean(SORT( ceil(0.95*N):N ))  %最大5%的平均
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%虧損分析
Loss_Path = Total_Payoff_Path <0;  %% Loss=1, Win=0
Loss_Probability =  sum(Loss_Path) / N   %出場虧損機率
Average_Loss_Loss = mean( Total_Payoff_Path(Loss_Path))%出場虧損的平均金額
Average_Period_Loss = mean( Period_Path(Loss_Path) )  %出場虧損的平均期數
SORT= sort(Total_Payoff_Path);  %小排至大
SMALL5 = SORT(floor(0.05*N))       %最小排在第5%的金額
Average_SMALL5 = mean(SORT( 1: floor(0.20*N)))  %最小5%的平均
