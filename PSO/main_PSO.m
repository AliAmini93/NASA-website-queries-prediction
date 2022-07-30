clc;
clear;
close all;

%% Problem Definition

global NFE;
load('Weights.mat')
load('trainset.mat')
load('testset.mat')



CostFunction=@(voroodi,trainset) cost_function(voroodi,trainset);        % Cost Function

nVar=71;             % Number of Decision Variables

VarSize=[1 nVar];   % Size of Decision Variables Matrix

VarMin=-5;         % Lower Bound of Variables
VarMax= 5;         % Upper Bound of Variables


%% PSO Parameters

MaxIt=100;      % Maximum Number of Iterations

nPop=50;        % Population Size (Swarm Size)

% w=1;            % Inertia Weight
% wdamp=0.99;     % Inertia Weight Damping Ratio
% c1=2;           % Personal Learning Coefficient
% c2=2;           % Global Learning Coefficient

% Constriction Coefficients
phi1=2.05;
phi2=2.05;
phi=phi1+phi2;
chi=2/(phi-2+sqrt(phi^2-4*phi));
w=chi;          % Inertia Weight
wdamp=0.99;        % Inertia Weight Damping Ratio
c1=chi*phi1;    % Personal Learning Coefficient
c2=chi*phi2;    % Global Learning Coefficient

% Velocity Limits
VelMax=0.1*(VarMax-VarMin);
VelMin=-VelMax;
%% Initialization

empty_particle.Position=[];
empty_particle.Cost=[];
empty_particle.Velocity=[];
empty_particle.Best.Position=[];
empty_particle.Best.Cost=[];
XX = weights(:,:);
particle=repmat(empty_particle,nPop,1);  
GlobalBest.Cost=inf;
Cost_Test= zeros(50,1);
for i=1:nPop
    
    % Initialize Position
    particle(i).Position= XX(i ,:);
    
    % Initialize Velocity
    particle(i).Velocity=zeros(VarSize);
    
    % Evaluation
    particle(i).Cost=CostFunction(particle(i).Position,trainset);
    Cost_Test(i)=CostFunction(particle(i).Position,testset);
    % Update Personal Best
    particle(i).Best.Position=particle(i).Position;
    particle(i).Best.Cost=particle(i).Cost;
    
    % Update Global Best
    if particle(i).Best.Cost<GlobalBest.Cost
        
        GlobalBest=particle(i).Best;
        
    end
    
end

BestCost_Train=zeros(MaxIt,1);
BestCost_Test=zeros(MaxIt,1);
[~, SortOrder]=sort(Cost_Test);
Cost_Test =Cost_Test(SortOrder);
nfe=zeros(MaxIt,1);
%% PSO Main Loop

for it=1:MaxIt
    
    for i=1:nPop
        
        % Update Velocity
        particle(i).Velocity = w*particle(i).Velocity ...
            +c1*rand(VarSize).*(particle(i).Best.Position-particle(i).Position) ...
            +c2*rand(VarSize).*(GlobalBest.Position-particle(i).Position);
        
        % Apply Velocity Limits
        particle(i).Velocity = max(particle(i).Velocity,VelMin);
        particle(i).Velocity = min(particle(i).Velocity,VelMax);
        
        % Update Position
        particle(i).Position = particle(i).Position + particle(i).Velocity;
        
        % Velocity Mirror Effect
        IsOutside=(particle(i).Position<VarMin | particle(i).Position>VarMax);
        particle(i).Velocity(IsOutside)=-particle(i).Velocity(IsOutside);
        
        % Apply Position Limits
        particle(i).Position = max(particle(i).Position,VarMin);
        particle(i).Position = min(particle(i).Position,VarMax);
        
        % Evaluation
        particle(i).Cost = CostFunction(particle(i).Position,trainset);
        for l= 1:nPop
          Cost_Test(l)=CostFunction(particle(l).Position,testset);
        end
        [~, SortOrder]=sort(Cost_Test);
        Cost_Test =Cost_Test(SortOrder);
        BestCost_Test(it) = Cost_Test(1);
        % Update Personal Best
        if particle(i).Cost<particle(i).Best.Cost
            
            particle(i).Best.Position=particle(i).Position;
            particle(i).Best.Cost=particle(i).Cost;
            
            % Update Global Best
            if particle(i).Best.Cost<GlobalBest.Cost
                
                GlobalBest=particle(i).Best;
                
            end
            
        end
        
    end
    
    BestCost_Train(it)=GlobalBest.Cost;
    
    nfe(it)=NFE;
    
    disp(['Iteration ' num2str(it) ': NFE = ' num2str(nfe(it)) ', Best Cost Train = ' num2str(BestCost_Train(it)) ', Best Cost Test = ' num2str(BestCost_Test(it))]);
    
    w=w*wdamp;
    
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