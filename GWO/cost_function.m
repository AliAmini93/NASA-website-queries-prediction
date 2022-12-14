function MAPE_train = cost_function(voroodi,trainset)
        global NFE;
        if isempty(NFE)
        NFE=0;
        end
        NFE=NFE+1;
        v = voroodi(1:50);
        v0 = voroodi(51:60);
        v = reshape(v,10,5);
        v0 = reshape(v0,10,1);
        w = voroodi(61:70);
        w0 = voroodi(71);
        target = trainset(:,6);
        output = zeros(size(trainset,1),1);
        for j=1:size(trainset,1)
            x = trainset(j,1:5);
            z_in = sum(x.*v,2)+v0;
            z = max(0,z_in);
            y = w*z + w0;
            output(j) = max(0,y);
        end
        MAPE_train = sum(abs((output-target))./target)/size(trainset,1);
    
end