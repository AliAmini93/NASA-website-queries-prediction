
function emp=CreateInitialEmpires()
    global ProblemSettings;
    global ICASettings;
    global XX;
    CostFunction=ProblemSettings.CostFunction;
    
    nPop=ICASettings.nPop;
    nEmp=ICASettings.nEmp;
    nCol=nPop-nEmp;
    alpha=ICASettings.alpha;
    
    empty_country.Position=[];
    empty_country.Cost=[];
    
    country=repmat(empty_country,nPop,1);
    
    for i=1:nPop
        country(i).Position=XX(i ,:);
        
        country(i).Cost=CostFunction(country(i).Position);
        
    end
    
    costs=[country.Cost];
    [~, SortOrder]=sort(costs);
    
    country=country(SortOrder);
    
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
    
end