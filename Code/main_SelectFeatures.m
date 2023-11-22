clc;
clear;
%%
file_name = 'imputed_data_train.xlsx';
opts = detectImportOptions(file_name);
Data = readtable(file_name,opts,'Sheet',1);

%% Test Data
for j = 1:1
    %%
    DaysToRec = Data.DaysToRecurrence;

    %% censor cut-off
    Censor = 90;
    
    censor = Censor(1);
    disp(censor)
    %%
    idx = DaysToRec <= censor;
    id_censor = idx;

    data = Data(~id_censor,:);
    
    %%
    XX_ML = data;
    
    %%
    X_raw_train = XX_ML{:,6:end}';
    Y_train = XX_ML{:,4};
    
    %%
    for i = 1:100
        
        r_sample = randperm(size(X_raw_train,2));
        SampleSize = size(X_raw_train,2);
        Y_model = Y_train(r_sample);
        X_train = X_raw_train(:,r_sample);   
        r_features = randperm(size(X_raw_train,1));
        X_train = X_train(r_features,:);
        %
        %% ML model
        x_train_test = X_train;
        Y_train_test = cellstr(num2str(Y_model));
    
        
        Y_train_test(strcmp(Y_train_test,'1'))= {'Yes'};
        Y_train_test(strcmp(Y_train_test,'0'))= {'No'};
        
        cv = cvpartition(size(x_train_test,2),'HoldOut',0.2);
        idx = cv.test;
        
        
        [count,label] = hist(categorical(Y_train_test),unique(Y_train_test));
        %%
        XTrain = x_train_test(:,~idx);
        YTrain = Y_train_test(~idx);

        XTest = x_train_test(:,idx);
        YTest = Y_train_test(idx);

        %%
        % n = 1: RF, 2: KNN, 3: SVM
        
        % RF
        n = 1;
        
        disp(i);
        
        pred_test = [];

        [err,acc_train,acc,sen,spe,ppv,auc,order,cm,model,pred_train]= ...
            F_classifier_CV(XTrain',YTrain,n,true,{'Yes'});

        
        f1 = 2*(ppv*sen)/(ppv+sen);
        
        if ~isempty(auc)
            x_auc = auc.X_auc;
            y_auc = auc.Y_auc;
        else
            x_auc = [];
            y_auc = [];
        end


        %%
        words_row = XX_ML.Properties.VariableNames;
        
        Features = words_row(2:end);
        Features_order = Features(r_features);
        
        % If the model is Random Forest thereby the important predictor
        % factor can be calculated. 
        
        if n == 1
            
            imp = predictorImportance(model{1});
        
            [imp_sorted,index_imp]=sort(imp,'descend');
            
            Result(i,j).rankFeatures = imp_sorted;
            Result(i,j).FeaturesSorted = Features(index_imp);
            Result(i,j).indxe_imp = index_imp;
            
        end
%         
        
        Result(i,j).err = err;
        Result(i,j).acc = acc;
        Result(i,j).acc_train = acc_train;
        Result(i,j).sen = sen;
        Result(i,j).spe = spe;
        Result(i,j).f1 = f1;
        Result(i,j).auc = auc;
        Result(i,j).cm = cm;
        Result(i,j).model = model{1};
        Result(i,j).sampleOrder = r_sample;

        Result(i,j).ypred_train = pred_train;
        Result(i,j).ypred_test = pred_test;
        Result(i,j).ytest = YTest;
        Result(i,j).xtest = XTest;
        Result(i,j).ytrain = YTrain;
        Result(i,j).xtrain = XTrain;
        Result(i,j).xraw = X_raw_train;
  
        Result(i,j).Features = Features;
        Result(i,j).order = order;
        Result(i,j).idx = idx;
        Result(i,j).r_features = r_features;

        Result(i,j).Features_order = Features_order;

    end
    
end

%% Find the most important Features

imp = [];
Features_Imp = [];
fprintf('Please wait ... \n')
for j = 1:50
    for i = 1:length(Result)
        try
            Mdl = Result(i).model;
            Imp = oobPermutedPredictorImportance(Mdl);
            imp = [imp;Imp];
            Features_Imp = [Features_Imp;Result(i).Features_order];
            fprintf('=')
        catch
            continue
        end
        
    end
    disp(['# Evaluation: ' num2str(j)])
    if j == 50
        fprintf('\n Feature Importancy is done!\n')
    end

end
%% Make the order consistent for features
save('imp','imp');
save('Features_Imp','Features_Imp');
ref_order = sort(Features_Imp(1,:));
%     ref_order = {'INR'      , ...   
%     'LiverDisease', ...
%     'No_Lesions', ...  
%     'Ethnicity' , ...  
%     'Cirrhosis' , ...  
%     'DM'        , ...  
%     'Hypertension', ...  
%     'ALT'         , ...  
%     'eGFR'        , ...  
%     'Albumin'     , ...  
%     'AFP'         , ...  
%     'BMI'         , ...  
%     'Satellite'   , ...  
%     'LVI'         , ...  
%     'Sex'         , ...  
%     'Bilirubin'   , ...  
%     'Age'         , ...  
%     'IHD'         , ...  
%     'Size'        , ...  
%     'PriorTACE'   };

for i = 1:size(imp,1) %
    [~,id_f] = sort(Features_Imp(i,:));
    imp_sorted_features(i,:) = imp(i,id_f);
end


%% Plot the feature importancy
meanIMP = mean(imp_sorted_features);

[ccc,bb] = sort(abs(meanIMP),'ascend');

MIN = min(imp_sorted_features);
MIN = MIN(bb);

MAX = max(imp_sorted_features);
MAX = MAX(bb);


Err = std(imp_sorted_features);
Err = Err(bb);
mod_features = strrep(ref_order,'_','.');

X = categorical(strrep(mod_features(bb),'_','.'));
X = reordercats(X,mod_features(bb));

for i = 1:length(X)
    
    if ccc(i)>0
        clr = 'r';
    else
        clr = 'b';
    end
    barh(X(i),ccc(i),clr)
    hold on
end

er = errorbar(ccc,X,Err/2,'.','horizontal');
er.LineWidth = 1.5;
er.Color = 'k';
er.MarkerSize = 1;

set(gca,'fontname','times')
xlabel('Importance Factor')
saveas(gcf,'ImportanceFigure.fig')
saveas(gcf,'ImportanceFigure.pdf')
%%
save('Final_100Runs_RF_SelecFeature','Result')



