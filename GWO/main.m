clc;
clear;
close all;
%% Problem Definition
global NFE;
load('weights.mat')
load('trainset.mat')
load('testset.mat')

CostFunction=@(voroodi,trainset) cost_function(voroodi,trainset);        % Cost Function

nVar=71;             % Number of Decision Variables

VarSize=[1 nVar];   % Size of Decision Variables Matrix

VarMin=-5;         % Lower Bound of Variables
VarMax= 5;         % Upper Bound of Variables
%% GWO Parameters

MaxIt=6600;      % Maximum Number of Iterations

nPop=50;        % Population Size (Swarm Size)


empty_wolf.Position=[];
empty_wolf.Cost=[];

XX = weights(:,:);
wolf=repmat(empty_wolf,nPop,1);
Cost_Test= zeros(50,1);
for i=1:nPop
    
    % Initialize Position
    wolf(i).Position= XX(i ,:); 
    % Evaluation
    wolf(i).Cost=CostFunction(wolf(i).Position,trainset);
    Cost_Test(i)=CostFunction(wolf(i).Position,testset);
end

BestCost_Train=zeros(MaxIt,1);
BestCost_Test=zeros(MaxIt,1);
costs=[wolf.Cost];
[~, SortOrder]=sort(costs);
wolf=wolf(SortOrder);

[~, SortOrder]=sort(Cost_Test);
Cost_Test =Cost_Test(SortOrder);

nfe=zeros(MaxIt,1);

%% GWO Main Loop
for it=1:MaxIt
    alfa = wolf(1);
    beta = wolf(2);
    delta = wolf(3);
    omegas = wolf(4:end);

    a = 2-(2*it/MaxIt);
    for j=1 :47
    A1 = 2*a*rand(1,71)-a;
    A2 = 2*a*rand(1,71)-a;
    A3 = 2*a*rand(1,71)-a;
    
    c1 = 2*rand(1,71);
    c2 = 2*rand(1,71);
    c3 = 2*rand(1,71);
    d_alfa = abs(c1.*(alfa.Position) - omegas(j).Position);
    d_beta = abs(c2.*(beta.Position) - omegas(j).Position);
    d_delta = abs(c3.*(delta.Position) - omegas(j).Position);
    
    new_omegas_1 = alfa.Position - A1.*d_alfa;
    new_omegas_2 = beta.Position - A2.*d_beta;
    new_omegas_3 = delta.Position - A3.*d_delta;
    omegas(j).Position = (new_omegas_1+new_omegas_2+new_omegas_3)/3;
    omegas(j).Cost = CostFunction(omegas(j).Position,trainset);
    end
    
      wolf(1)=alfa;
      wolf(2) = beta;
      wolf(3)= delta;
      wolf(4:end) = omegas;
      for l= 1:nPop
          Cost_Test(l)=CostFunction(wolf(l).Position,testset);
      end
      [~, SortOrder]=sort(Cost_Test);
      Cost_Test =Cost_Test(SortOrder);
      BestCost_Test(it) = Cost_Test(1);
      
      costs=[wolf.Cost];
      [~, SortOrder]=sort(costs);
      wolf=wolf(SortOrder); 
      BestCost_Train(it) = wolf(1).Cost;
      
      nfe(it)=NFE;
      disp(['Iteration ' num2str(it) ': NFE = ' num2str(nfe(it)) ', Best Cost Train = ' num2str(BestCost_Train(it)) ', Best Cost Test = ' num2str(BestCost_Test(it))]);

end

%%  Results
figure;
semilogx(BestCost_Train,'LineWidth',2);
xlabel('Iteration');
ylabel('Best Cost Train');
grid on;

figure;
semilogx(BestCost_Test,'LineWidth',2);
xlabel('Iteration');
ylabel('Best Cost Test');
grid on;





