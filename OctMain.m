%% Script desgined for data pre-processing for later use on deep learning

%% Versions modified by Lin
%  v0.1 (First version working for virtual population with pulse and signal input)
%  v0.2 (** Removed code for calculating variables that are not considered in our study
%           Wave intensity calculation from Pxs.
%           automatic detection of last cardiac cycle from input of virtual population
%  v0.3  Separated WI calculation into the function WIA. added results
%  export to excel
%  v0.4 added batch analysis to all the txt files in Spata folder.
%  v0.5 optimised single pressure waveform detection --> imporved results
%       especially for the younger popoulations
%  v0.6 Added wave separation using true wavespeed/estimated wavespeed from
%  1ms-1 assumption. Added Diastolic Excess pressure zeroing function.
%  Added number of zero crossing on the dP as parameter.

%%%%%%%%%%%%%%%
%% m files required to be in directory
% fitres_v6.m
% kreservoir_v14.m
%%%%%%%%%%%%%%%%
% 66-193 = length(di)
%% Constants
clear all; clc;

close all;

sampling_rate = 128;  %

kres_v=14;          % Version tracking for reservoir fitting
headernumber=1;       % headers for columns of results (see end)
mmHgPa = 133;          % P conversion for WIA
uconst=1;              % empirical constant to convert normalized
% velocity to m/s based on Hughes et al.
% Front. Physiol. DOI: 10.3389/fphys.2020.00550
Npoly=2;               % Order of polynomial fit for sgolay
Frame=11;               % Window length for sgolay
version='0.6';         % Version of Main

PngLibrary_zero = '0\';  % Name of the subfolder in code to save results
PngLibrary_one = '1\';  % Name of the subfolder in code to save results
dim  = 200;             % Dimension of CNN input
aaf_size = 2;           % Anti-alising filter size (2 x aaf_size x max(p,q))
% Load Excel containing labels
T = readtable('newdf.csv');
tcv = T.tcv;
patid = T.patid;
notfound = 0;
repeat = {};

% atx = zeros (1500,201);
atx = zeros (594,201);
%%%%%%%%%%%%%%%%
%% Select files
% default folder as per manual
folder_name ='C:\Spdata\Real\Test\';
% check that C:\Spdata exists and if not allows new folder to be chosen
if ~exist('C:\Spdata\Real\Test\', 'dir')
    answer = questdlg('C:\Spdata\Real doesnt exist. Would you like to choose another folder?', ...
        'Sphygmocor Data Folder','Yes', 'No [end]','Yes');
    % Handle response
    switch answer
        case 'Yes'
            folder_name = uigetdir;
        case 'No [end]'             % end if no folder identified
            return
    end
end
% read files
file_lists=dir(fullfile(folder_name, '*.txt'));
no_of_files=length(file_lists);
% add an error trap here if no files in folder
if no_of_files==0
    f = errordlg('No data files to analyse in folder','File error');
    return
end
% set record number to 1 and extract filename
    record_no=0;
% preallocate cell array
proc_var=cell(no_of_files,headernumber);



%% Reservoir analysis for each filename
for file_number=1:no_of_files
    % refresh filename
    record_no = file_number;        %for multiple file input
    filename=file_lists(record_no).name;

    
    fid = fopen([folder_name filename]);
%     data = textscan(fid,'%f%f%f%f%f','headerlines',5);
    data = dlmread([folder_name filename],'\t',4,0);
    fclose(fid);

    pressure=data(:,3);
    index = find(pressure == 0, 1, 'first');
    pressure = pressure(1 : index-1);   % Remove all the zero paddings in real patient txt files.

    single_pulse=pressure;
    
    % call function for reservoir fitting
    [P_av, Pr_av,Pinf_av,Pn_av,Tn_av,Sn_av, fita_av, fitb_av,rsq_av,dp,nn]=fitres_v6(single_pulse,sampling_rate,kres_v);
    
    Pxs=P_av-Pr_av; % Excess Pressure

    
    %% Wave intensity analysis (WI Using pressure-only method)
    cpwia = zeros(1,length(P_av));
%     cpwia(1:11)=P_av(end-10:end);
%     cpwia(12:end)=P_av(1:end-11);

    cpwia = P_av;
    
    cpwia=(cpwia*mmHgPa);
    cuxwia = zeros(1,length(Pxs));
%     cuxwia(1:11)=Pxs(end-10:end);
%     cuxwia(12:end)=Pxs(1:end-11);
    cuxwia = Pxs;    
    % convert xwia to flow velocity and assume peak velocity = 1m/s
    % based on Lindroos, M., et al. J Am Coll Cardiol 1993; 21: 1220-1225.
    % cuxwia=uconst*(cuxwia-min(cuxwia))/(max(cuxwia)-min(cuxwia));
    
%     uconst = max(velocity); % Using actual max(U) for better estimation
    cuxwia=uconst*(cuxwia/max(cuxwia));   % Peak Velocity calibrated to 1m/s assumption/max(U) depend on uconst
    % Estimate c (wavespeed) as k*dP/du where k is empirical constant
    % currently k = 1!
    rhocxs=max(Pxs)*mmHgPa./1060./uconst; % fixed units (kg) 
    [di,wri,diplocs,dippks,dimlocs,dimpks,dipt,dimt,diparea,dimarea] = WIA(Npoly,Frame,cpwia,cuxwia,sampling_rate);
   
    ID = append('50004-',filename(1:5));
    idx = all(ismember(patid,ID),2);
    lidx=find(idx);

    x = resample(di,dim,length(di),aaf_size);
    Idx = find(x < 0, 1);
    Idx2 = find(x(Idx:end) > 0, 1);
    
    if Idx<10
        x(Idx:Idx2+Idx-2) = 0;
    end
    
%     if min(x) < 0 ;
%     x = x + abs(min(x));
%     end

    wave = x;


%     image = zeros(dim,dim);
%     
%     for i = 1:dim
%         image(round(wave(i)),i) = 1 ;
%     end
    
    
    
    if ~isempty(lidx)
        
        label = tcv(lidx(1));
        if label == 1 
            dict = PngLibrary_one;
        elseif label ==0
            dict = PngLibrary_zero;
        end        
        
        outputname = append(dict,'50004-',filename(1:5));
        if length(filename)<34
            outputname = append(dict,'50004-',filename(23:29)); 
        else
            outputname = append(dict,'50004-',filename(23:30)); 
        end
        
%          cnn_pre(di,dim,outputname);
%          outputname_left = append(outputname,'_left');
%          outputname_right = append(outputname,'_right');
%          cnn_pre(di*0.9,dim,outputname_left);
%          cnn_pre(di*1.1,dim,outputname_right);
    else
        notfound = notfound + 1;
    end
    

    
%     proc_var{record_no,1}= label; 
%     for i = 1:dim
%         proc_var{record_no,i+1}= wave(i);
%     end

    atx(3*record_no-2,1) = label;
    atx(3*record_no-1,1) = label;
    atx(3*record_no,1) = label;
    
    atx(3*record_no-2,2:end) = wave;
    atx(3*record_no-1,2:end) = 1.1*wave;
    atx(3*record_no,2:end) = 0.9*wave;
    fprintf('Processing............... %f%% \n', file_number/no_of_files.*100)
end
%% 
xlsfile='Test.csv'; % Or use .xls for compatibility
% Results_table=cell2mat(proc_var);
% writematrix(Results_table, xlsfile);

writematrix(atx, xlsfile);

clc;
fprintf('Analysis Complete')
