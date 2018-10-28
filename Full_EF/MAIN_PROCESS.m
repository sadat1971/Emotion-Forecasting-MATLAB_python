% This code Runs the main part for  processing the data 
% Inputs::

% st: numerical input (1,2 or 3)
% FW: Forecasting Window ('UF' or 'TF')
% history: is it history added or history less  ('his' or 'cur')

% Created By: 
%           Sadat Shahriar
%           last modefied: 10-27-2018

function MAIN_PROCESS(st, FW, history)
tic
f_window();  %process the data window-wise
if strcmp(FW,'UF')
    if strcmp(history,'cur')
        sprintf('The dataset preparation and processing for UF-%s %d has started',history,st)
        UF_preparing_cur(st);
        saving(st, FW, history);
        
    elseif strcmp(history, 'his')
        sprintf('The dataset preparation and processing for UF-%s %d has started',history,st)
        UF_preparing_his(st);
        saving(st, FW, history);
        
    else
        sprint('please write his or cur in the argument line');
    end

elseif strcmp(FW, 'TF')

%as TF is just the subsets of UF, we need to have the UF data first.

    UF_preparing_cur(1);
    UF_preparing_cur(2);
    UF_preparing_cur(3);
    create_TF_subsets_from_UF();
    if strcmp(history,'cur')
        sprintf('The dataset preparation and processing for TF-%s %d has started',history,st)
        TF_preparing_cur(st);
        saving(st, FW, history);
        
    elseif strcmp(history, 'his')
        sprintf('The dataset preparation and processing for TF-%s %d has started',history,st)
        TF_preparing_his(st);
        saving(st, FW, history);
        
    else
        sprint('please write his or cur in the argument line');
    end
    

end
else
sprintf('please write UF or TF in the FW field')
toc
end
