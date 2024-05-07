clear all
%% 
addpath '/SCRATCH/software/toolboxes/conn21a';

% Parameters 
NSUBJECTS=21;
nsessions=7;
TR=1; % Repetition time

% Files
cd '/DATAPOOL/ERRORMONITORING/CONN_data/';
conn_dir('s7.5_wrarun1_biasfield_topup_4D.nii');
% Functional files
func_files_run1=cellstr(conn_dir('s7.5_wrarun1_biasfield_topup_4D.nii'));
func_files_run2=cellstr(conn_dir('s7.5_wrarun2_biasfield_topup_4D.nii'));
func_files_run3=cellstr(conn_dir('s7.5_wrarun3_biasfield_topup_4D.nii'));
func_files_run4=cellstr(conn_dir('s7.5_wrarun4_biasfield_topup_4D.nii'));
func_files_run5=cellstr(conn_dir('s7.5_wrarun5_biasfield_topup_4D.nii'));
func_files_run6=cellstr(conn_dir('s7.5_wrarun6_biasfield_topup_4D.nii'));
func_files_run7=cellstr(conn_dir('s7.5_wrarun7_biasfield_topup_4D.nii'));
FUNCTIONAL_FILE = [func_files_run1 func_files_run2 func_files_run3 ...
    func_files_run4 func_files_run5 func_files_run6 func_files_run7];
% Structural files
STRUCTURAL_FILE=cellstr(conn_dir('wSEM_t1_mprage_sag_p2_iso.nii'));
STRUCTURAL_FILE={STRUCTURAL_FILE{1:NSUBJECTS}};
% Structural files (from segmentation)
greymatter_file = cellstr(conn_dir('wc1SEM_t1_mprage_sag_p2_iso.nii'));
whitematter_file = cellstr(conn_dir('wc2SEM_t1_mprage_sag_p2_iso.nii'));
csf_file = cellstr(conn_dir('wc3SEM_t1_mprage_sag_p2_iso.nii'));
ROI_file = [greymatter_file whitematter_file csf_file];
% Covariates files
cov_files_run1 = cellstr(conn_dir('run1_multiple_regressors.txt'));
cov_files_run2 = cellstr(conn_dir('run2_multiple_regressors.txt'));
cov_files_run3 = cellstr(conn_dir('run3_multiple_regressors.txt'));
cov_files_run4 = cellstr(conn_dir('run4_multiple_regressors.txt'));
cov_files_run5 = cellstr(conn_dir('run5_multiple_regressors.txt'));
cov_files_run6 = cellstr(conn_dir('run6_multiple_regressors.txt'));
cov_files_run7 = cellstr(conn_dir('run7_multiple_regressors.txt'));
COV_FILE = [cov_files_run1 cov_files_run2 cov_files_run3 cov_files_run4 ...
    cov_files_run5 cov_files_run6 cov_files_run7];

disp([num2str(size(FUNCTIONAL_FILE,1)),' subjects']);
disp([num2str(size(FUNCTIONAL_FILE,2)),' sessions']);

%% CONN-SPECIFIC SECTION: RUNS PREPROCESSING/SETUP/DENOISING/ANALYSIS STEPS
%% Prepares batch structure
clear batch;
batch.filename='/DATAPOOL/ERRORMONITORING/CONN_data/SEM_conn.mat';            % New conn_*.mat experiment name

%% SETUP & PREPROCESSING step (using default values for most parameters, see help conn_batch to define non-default values)
% CONN Setup                                            % Default options (uses all ROIs in conn/rois/ directory)
batch.Setup.isnew=1;
batch.Setup.nsubjects=NSUBJECTS;
batch.Setup.RT=TR;                                        % TR (seconds)

batch.Setup.functionals=repmat({{}},[NSUBJECTS,1]);       % Point to functional volumes for each subject/session
for nsub=[1:21]
    for nses=1:nsessions
        batch.Setup.functionals{nsub}{nses}{1}=FUNCTIONAL_FILE{nsub,nses}; 
    end
end 
batch.Setup.structurals=STRUCTURAL_FILE;                  % Point to anatomical volumes for each subject

batch.Setup.conditions.importfile = '/DATAPOOL/ERRORMONITORING/CONN_data/conditions_conn.txt'; 
batch.Setup.conditions.missingdata = 1;

batch.Setup.covariates.names = {'multiple_regressors'};
for nsub=[1:21]
    for nses=1:nsessions
        batch.Setup.covariates.files{1}{nsub}{nses}=COV_FILE{nsub,nses}; 
    end
end

batch.Setup.rois.names{1} = 'Grey Matter';
batch.Setup.rois.names{2} = 'White Matter';
batch.Setup.rois.names{3} = 'CSF';
batch.Setup.rois.names{4} = 'atlas';
batch.Setup.rois.names{5} = 'networks';
batch.Setup.rois.names{6} = 'dACC';
batch.Setup.rois.names{7} = 'pre-SMA';
batch.Setup.rois.names{8} = 'SFG_A9m';
batch.Setup.rois.names{9} = 'SFG_A6dl';
batch.Setup.rois.names{10} = 'rPut';
batch.Setup.rois.names{11} = 'lPut';
batch.Setup.rois.names{12} = 'lAI';
batch.Setup.rois.names{13} = 'rAI';
batch.Setup.rois.names{14} = 'IFG_A44v_L';
batch.Setup.rois.names{15} = 'IFG_A44v_R';
batch.Setup.rois.names{16} = 'IFG_A44op_L';
batch.Setup.rois.names{17} = 'IFG_A44op_R';
batch.Setup.rois.names{18} = 'OrG_A1247l_L';
batch.Setup.rois.names{19} = 'OrG_A1247l_R';

for nsub=1:NSUBJECTS
    batch.Setup.rois.files{1}{nsub} = ROI_file{nsub,1};
    batch.Setup.rois.files{2}{nsub} = ROI_file{nsub,2};
    batch.Setup.rois.files{3}{nsub} = ROI_file{nsub,3};
end
batch.Setup.rois.files{4}='/SCRATCH/software/toolboxes/conn21a/rois/atlas.nii';
batch.Setup.rois.multiplelabels(4) = 1;
batch.Setup.rois.files{5}='/SCRATCH/software/toolboxes/conn21a/rois/networks.nii';
batch.Setup.rois.multiplelabels(5) = 1;

vois_dir = '/DATAPOOL/ERRORMONITORING/group_level_analysis/ROIs/Atlas/AAL3 and Brainnetome/';

batch.Setup.rois.files{6} = [vois_dir, 'ACC/dACC/A32p_BN.nii'];
batch.Setup.rois.multiplelabels(6) = 0;
batch.Setup.rois.files{7} = [vois_dir, 'pre-SMA/A8m_BN.nii'];
batch.Setup.rois.multiplelabels(7) = 0;
batch.Setup.rois.files{8} = [vois_dir, 'SFG/SFG_A9m.nii'];
batch.Setup.rois.multiplelabels(8) = 0;
batch.Setup.rois.files{9} = [vois_dir, 'SFG/SFG_A6dl.nii'];
batch.Setup.rois.multiplelabels(9) = 0;
batch.Setup.rois.files{10} = [vois_dir, 'putamen/ventromedial_right_putamen_BN.nii'];
batch.Setup.rois.multiplelabels(10) = 0;
batch.Setup.rois.files{11} = [vois_dir, 'putamen/ventromedial_left_putamen_BN.nii'];
batch.Setup.rois.multiplelabels(11) = 0;
batch.Setup.rois.files{12} = [vois_dir, 'lAI/ROI_lAI_BN.nii'];
batch.Setup.rois.multiplelabels(12) = 0;
batch.Setup.rois.files{13} = [vois_dir, 'rAI/ROI_rAI_BN.nii'];
batch.Setup.rois.multiplelabels(13) = 0;
batch.Setup.rois.files{14} = [vois_dir, 'IFG/A44v_L.nii'];
batch.Setup.rois.multiplelabels(14) = 0;
batch.Setup.rois.files{15} = [vois_dir, 'IFG/A44v_R.nii'];
batch.Setup.rois.multiplelabels(15) = 0;
batch.Setup.rois.files{16} = [vois_dir, 'IFG/A44op_L.nii'];
batch.Setup.rois.multiplelabels(16) = 0;
batch.Setup.rois.files{17} = [vois_dir, 'IFG/A44op_R.nii'];
batch.Setup.rois.multiplelabels(17) = 0;
batch.Setup.rois.files{18} = [vois_dir, 'OrG/A12-47l_L.nii'];
batch.Setup.rois.multiplelabels(18) = 0;
batch.Setup.rois.files{19} = [vois_dir, 'OrG/A12-47l_R.nii'];
batch.Setup.rois.multiplelabels(19) = 0;

batch.Setup.done=1;
batch.Setup.overwrite='Yes';

%% DENOISING step
% CONN Denoising                                    % Default options (uses White Matter+CSF+multiple regressors+conditions as confound regressors); 
batch.Denoising.filter=[0.01, inf];                 % frequency filter (band-pass values, in Hz)
batch.Denoising.done=1;
batch.Denoising.overwrite='Yes';

% %% FIRST-LEVEL ANALYSIS step
% % CONN Analysis                                     % Default options (uses all ROIs in conn/rois/ as connectivity sources); see conn_batch for additional options
% batch.Analysis.modulation=1;                        % gPPI
% batch.Analysis.measure=3;                           % Regression (bivariate)
% batch.Analysis.done=1;
% batch.Analysis.overwrite='Yes';

conn_batch(batch);
