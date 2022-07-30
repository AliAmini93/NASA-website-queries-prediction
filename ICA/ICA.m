
clc;
clear;
close all;
load('weights.mat')
load('trainset.mat')
load('testset.mat')
global trainset;
%% Problem Definition
global NFE;    
CostFunction=@(voroodi,trainset) cost_function(voroodi,trainset);        % Cost Function
nVar=71;             % Number of Decision Variables
VarSize=[1 nVar];   % Decision Variables Matrix Size
VarMin=-5;         % Lower Bound of Variables
VarMax= 5;         % Upper Bound of Variables
%% ICA Parameters
MaxIt=2000;         % Maximum Number of Iterations
nPop=50;            % Population Size
nEmp=4;            % Number of Empires/Imperialists
nCol=nPop-nEmp;
alpha=1;            % Selection Pressure
beta=1.5;           % Assimilation Coefficient
pRevolution=0.05;   % Revolution Probability
mu=0.1;             % Revolution Rate
zeta=0.2;           % Colonies Mean Cost Coefficient
%% Globalization of Parameters and Settings
global ProblemSettings;
ProblemSettings.CostFunction=CostFunction;
ProblemSettings.nVar=nVar;
ProblemSettings.VarSize=VarSize;
ProblemSettings.VarMin=VarMin;
ProblemSettings.VarMax=VarMax;
global ICASettings;
ICASettings.MaxIt=MaxIt;
ICASettings.nPop=nPop;
ICASettings.nEmp=nEmp;
ICASettings.alpha=alpha;
ICASettings.beta=beta;
ICASettings.pRevolution=pRevolution;
ICASettings.mu=mu;
ICASettings.zeta=zeta;
%% Initialization
% Initialize Empires
XX = weights(:,:);
empty_country.Position=[];
empty_country.Cost=[];
Cost_Test= zeros(50,1);
country=repmat(empty_country,nPop,1);
for i=1:nPop
        country(i).Position=XX(i ,:);
        
        country(i).Cost=CostFunction(country(i).Position,trainset);
        Cost_Test(i)=CostFunction(country(i).Position,testset);
end
    
    costs=[country.Cost];
    [~, SortOrder]=sort(costs);  
    country=country(SortOrder);
    
    [~, SortOrder]=sort(Cost_Test);
    Cost_Test =Cost_Test(SortOrder);
    
    imp=country(1:nEmp);
    
    col=country(nEmp+1:end);
    
    
    empty_empire.Imp=[];
    empty_empire.Col=repmat(empty_country,0,1);
    empty_empire.nCol=0;
    empty_empire.TotalCost=[];
    
    emp=repmat(empty_empire,nEmp,1);
    
    % Assign Imperialists
    for k=1:nEmp
        emp(k).Imp=imp(k);
    end
    
    % Assign Colonies
    P=exp(-alpha*[imp.Cost]/max([imp.Cost]));
    P=P/sum(P);
    for j=1:nCol
        
        k=RouletteWheelSelection(P);
        
        emp(k).Col=[emp(k).Col
                    col(j)];
        
        emp(k).nCol=emp(k).nCol+1;
    end
    
    emp=UpdateTotalCost(emp);

% emp=CreateInitialEmpires();
% Array to Hold Best Cost Values
BestCost_Train=zeros(MaxIt,1);
BestCost_Test=zeros(MaxIt,1);
nfe=zeros(MaxIt,1);
%% ICA Main Loop
for it=1:MaxIt

    % Assimilation
    emp=AssimilateColonies(emp);
    
    % Revolution
    emp=DoRevolution(emp);
    
    % Intra-Empire Competition
    emp=IntraEmpireCompetition(emp);
    
    % Update Total Cost of Empires
    emp=UpdateTotalCost(emp);
    
    % Inter-Empire Competition
    emp=InterEmpireCompetition(emp);
    
    % Update Best Solution Ever Found
    imp=[emp.Imp];
    [~, BestImpIndex]=min([imp.Cost]);
    BestSol=imp(BestImpIndex);
    % Update Best Cost
    BestCost_Train(it)=BestSol.Cost;
    switch numel(emp)
        case 4
            M = [1,emp(1).nCol+1,1+emp(1).nCol+emp(2).nCol,1+emp(1).nCol+emp(2).nCol+emp(3).nCol];
            N=[emp(1).nCol,emp(1).nCol+emp(2).nCol,emp(1).nCol+emp(2).nCol+emp(3).nCol,emp(1).nCol+emp(2).nCol+emp(3).nCol+emp(4).nCol];
        case 3
            M = [1,emp(1).nCol+1,1+emp(1).nCol+emp(2).nCol];
            N=[emp(1).nCol,emp(1).nCol+emp(2).nCol,emp(1).nCol+emp(2).nCol+emp(3).nCol];
        case 2
            M = [1,emp(1).nCol+1];
            N=[emp(1).nCol,emp(1).nCol+emp(2).nCol];
        case 1
            M = 1;
            N=[emp(1).nCol];
    end
    o=1;
    for m=1 : numel(emp)
        for n = M(m) : N(m)
           Cost_Test(n)=CostFunction(emp(m).Col(o).Position,testset); 
           o=o+1;
        end
        o=1;
    end
    for l=1 :numel(emp)
        Cost_Test(l + N(end))=CostFunction(imp(l).Position,testset);
    end
    [~, SortOrder]=sort(Cost_Test);
    Cost_Test =Cost_Test(SortOrder);
    BestCost_Test(it) = Cost_Test(1);
    % Show Iteration Information
    nfe(it)=NFE;
    disp(['Iteration ' num2str(it) ': NFE = ' num2str(nfe(it)) ', Best Cost Train = ' num2str(BestCost_Train(it)) ', Best Cost Test = ' num2str(BestCost_Test(it))]);
    
end
%% Results
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
