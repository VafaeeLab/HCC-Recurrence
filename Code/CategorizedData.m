function y = CategorizedData(XX_ML)

% Binarization
    % No_Lensions >1, eGFR>=90, ALT > 50,
    % BMI >= 25, AFP > 100 (<=8),  Size >=5, albumin<35,
    % Age >= 65, bili>20,
    % PlateletCount<150, INR> 1.1,
    % Aus + European = 0, Asian = 1, African + other = 2
    % Sex (Male =1, Female =0)
    
    indxFinder = @(x)(strcmp(x,XX_ML.Properties.VariableNames));

    %=========== if AFP
    id_AFP = indxFinder('AFP');
    XX_ML = AFP_Binary(id_AFP,XX_ML,[],false);

    % ============== if Albumin
    % Train
    id_Alb = indxFinder('albumin');
    id_con_1 = XX_ML{:,id_Alb} < 35;
    XX_ML{id_con_1,id_Alb} = 1;
    XX_ML{~id_con_1,id_Alb} = 0;

    % ============== if PlateletCount
    id_pc = indxFinder('PlateletCount');
    id_con_1 = XX_ML{:,id_pc} < 150;
    XX_ML{id_con_1,id_pc} = 1;
    XX_ML{~id_con_1,id_pc} = 0;


    % ============== if eGFR
    id_gfr = indxFinder('eGFR');
    id_con_1 = XX_ML{:,id_gfr} < 90;
    XX_ML{id_con_1,id_gfr} = 1;
    XX_ML{~id_con_1,id_gfr} = 0;

    % ============== if No_Lesions
    id_nLen = indxFinder('numberOfLesions');
    id_con_1 = XX_ML{:,id_nLen} > 1;
    XX_ML{id_con_1,id_nLen} = 1;
    XX_ML{~id_con_1,id_nLen} = 0;

    % ============== if ALT
    id_alt = indxFinder('ALT'); % ALTLevelPriorToResection
    id_con_1 = XX_ML{:,id_alt} > 50;
    XX_ML{id_con_1,id_alt} = 1;
    XX_ML{~id_con_1,id_alt} = 0;

    % ============== if BMI
    id_bmi = indxFinder('BMI');
    id_con_1 = XX_ML{:,id_bmi} >= 25;
    XX_ML{id_con_1,id_bmi} = 1;
    XX_ML{~id_con_1,id_bmi} = 0;

    % ============== if Size
    id_size = indxFinder('sizeOfLargestLesion_cm_');
    id_con_1 = XX_ML{:,id_size} >= 5;
    XX_ML{id_con_1,id_size} = 1;
    XX_ML{~id_con_1,id_size} = 0;
    

    % ============== if Age
    id_age = indxFinder('AgeAtResection_years_');
    id_con_1 = XX_ML{:,id_age} >= 65;
    XX_ML{id_con_1,id_age} = 1;
    XX_ML{~id_con_1,id_age} = 0;

    
    % ============== if Bilirubin
    id_bili = indxFinder('bili');
    id_con_1 = XX_ML{:,id_bili} > 20;
    XX_ML{id_con_1,id_bili} = 1;
    XX_ML{~id_con_1,id_bili} = 0;

    % ============== if INR
    id_inr = indxFinder('INR');
    id_con_1 = XX_ML{:,id_inr} > 1.1;
    XX_ML{id_con_1,id_inr} = 1;
    XX_ML{~id_con_1,id_inr} = 0;

    % ============== if Sex Male 1 and Female 0
    id_sex = indxFinder('SexCodedM_0_F_1');
    id_con_1 = XX_ML{:,id_sex} == 0;
    XX_ML{id_con_1,id_sex} = 1;
    XX_ML{~id_con_1,id_sex} = 0;

    % ============== if Ethnicity
    id_ethn = indxFinder('Ethnicity_0Aus_1Asian_2African3European4Other_');
    id_con_1 = XX_ML{:,id_ethn} == 3; % European should be zero
    XX_ML{id_con_1,id_ethn} = 0;

    id_con_1 = XX_ML{:,id_ethn} == 4; % Other should be 2
    XX_ML{id_con_1,id_ethn} = 2;

    % ============== if Recurrence is NaN, it can be zero
    id_rec = indxFinder('Recurrence');
    XX_ML{isnan(XX_ML{:,id_rec}),id_rec} = 0;


    y = XX_ML;
    

end