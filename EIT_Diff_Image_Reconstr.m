% Compare 2D algorithms and Stimulation Patterns
% Based on $Id: tutorial120a.m 3273 2012-06-30 18:00:35Z aadler $
% http://eidors3d.sourceforge.net/tutorial/EIDORS_basics/tutorial120.shtml

stim_pattern_no = 14; % Select which stimulation pattern to show voltage for.
%Set plotting options
%Center of color scale
%CenterValue = 1.00;
CenterValue = 0.00;
calc_colours('ref_level',CenterValue);
%calc_colours('ref_level','auto');

%Range Plus-Minus from center value
Color_Range = 1.0;
%Color_Range = 2
calc_colours('clim',Color_Range);

% Choose the type of color scale, aka "cmap_type"
CMAP_TYPE_OPTIONS = ["blue_red","jet","jetair","blue_yellow","greyscale","greyscale-inverse","copper","blue_white_red","black_red","blue_black_red","polar_colours","draeger","draeger-2009","draeger-tidal","swisstom","timpel","flame","ice"];
Cmap_type_no = 2;
Cmap_type = CMAP_TYPE_OPTIONS(Cmap_type_no)
calc_colours('cmap_type',Cmap_type);

Nel= 32; %Number of elecs
%Zc = .0001; % Contact impedance
curr = 10; % applied current mA

electrode_radius = 1/24;
radius = 1.00;
mesh_size = 0.035;
fmdl = ng_mk_cyl_models([0,radius,mesh_size],[Nel,0],[electrode_radius,0,mesh_size]);

% Calculate a stimulation pattern
% Un-remark the desired pattern only.

%stim = mk_stim_patterns(Nel,1,'{ad}','{ad}',{'no_meas_current','rotate_meas'},curr); label = 'A-aanr'; % A
%stim = mk_stim_patterns(Nel,1,'{op}','{ad}',{'no_meas_current','rotate_meas'},curr); label = 'B-oanr'; % B
%stim = mk_stim_patterns(Nel,1,'{ad}','{op}',{'no_meas_current','rotate_meas'},curr); label = 'C-aonr'; % C
%stim = mk_stim_patterns(Nel,1,'{mono}','{ad}',{'meas_current','rotate_meas'},curr); label = 'D-momr'; % D 
%stim = mk_stim_patterns(Nel,1,'{mono}','{op}',{'meas_current','rotate_meas'},curr); label = 'E-momr'; % E
stim = mk_stim_patterns(Nel,1,'{ad}','{mono}',{'no_meas_current','rotate_meas'},curr); label = 'F-amnr'; % F
%stim = mk_stim_patterns(Nel,1,'{ad}','{mono}',{'no_meas_current_next3','rotate_meas'},curr); label = 'F-amn3r'; % F3
%stim = mk_stim_patterns(Nel,1,'{op}','{mono}',{'no_meas_current','rotate_meas'},curr); label = 'G-omnr'; % G
%stim = mk_stim_patterns(Nel,1,'{mono}','{mono}',{'meas_current'},curr); label = 'H-mmmn'; % H
%stim = mk_stim_patterns(Nel,1,'{mono}','{mono}',{'meas_current','rotate_meas'},curr); label = 'I-mmmr'; % I


% Solve all voltage patterns
fmdl.stimulation = stim;
fmdl.fwd_solve.get_all_meas = 1;

clf; show_fem(fmdl,[1,1.016]);
axis square; axis off
print_convert('Diff_Mesh.png', '-density 60')
%%
%imb=  mk_common_model('c2c',16);

bkgnd= 1;
img= mk_image(fmdl, bkgnd);
%vh = fwd_solve(img);
%img.calc_colours.cb_shrink_move = [.3,.8,-0.02];


%%
e= size(fmdl.elems,1);
% Un-remark the desired modification pattern only

% Conductivity Modification Linear 3
%scale_fcn = inline('(2-1.5*sqrt(x.^2+y.^2))','x','y','z');

% Conductivity Modification Inverse Linear 5
%scale_fcn = inline('(0.5+0.75*sqrt(x.^2+y.^2))','x','y','z');

% Conductivity Modification Quadratic Smoother 3b
scale_fcn = inline('(1.5-1*(x.^2+y.^2))','x','y','z');

% Conductivity Modification Inverse Quadratic 5b
%scale_fcn = inline('(0.625+0.75*(x.^2+y.^2))','x','y','z');

% Un-remark the desired voltage map name only
%voltage_map_name = "Voltage_uniform"
%voltage_map_name = "Voltage_modified_Lin3"
voltage_map_name = "Voltage_modified_3b"
%voltage_map_name = "Voltage_modified_5b"

%Here is where the modification to the baseline conductivity distribution takes place.
img.elem_data = elem_select(img.fwd_model, scale_fcn);

% Solve Homogeneous model
% img= mk_image(imb.fwd_model, bkgnd);
img.fwd_solve.get_all_meas = 1;
vh= fwd_solve( img );
CenterValue = 1.00;
calc_colours('ref_level',CenterValue);
clf; show_fem(img,[1,1.016]);
axis square; axis off
print_convert('Background.png', '-density 60')

% Show voltage pattern for img1
h1= subplot(221);
img_v = rmfield(img, 'elem_data');
img_v.node_data = vh.volt(:,stim_pattern_no);
CenterValue = 0.00;
calc_colours('ref_level',CenterValue);
Color_Range = 1.0;
calc_colours('clim',Color_Range);
show_fem(img_v);
img_v1 = img_v;

% Add a small object with 95% conductivity, slightly above the center.
local_rel_cond_red = 0.05; %Here, set local relative reduction in conductivity.
select_fcn = inline('(x-0.18).^2+(y-0.32).^2<0.1628^2','x','y','z');
img.elem_data_object = elem_select(img.fwd_model, select_fcn);
img.elem_data = img.elem_data - img.elem_data .* img.elem_data_object * local_rel_cond_red;

% Add a second small object to the left of the center.
%local_rel_cond_red = 0.05;
select_fcn = inline('(x+0.35).^2+(y-0.05).^2<0.1628^2','x','y','z');
img.elem_data_object = elem_select(img.fwd_model, select_fcn);
img.elem_data = img.elem_data - img.elem_data .* img.elem_data_object * local_rel_cond_red;

% Add a third small object near the lower edge.
%local_rel_cond_red = 0.05;
select_fcn = inline('(x-0.15).^2+(y+0.7).^2<0.1628^2','x','y','z');
img.elem_data_object = elem_select(img.fwd_model, select_fcn);
img.elem_data = img.elem_data - img.elem_data .* img.elem_data_object * local_rel_cond_red;


%img.fwd_solve.get_all_meas = 1;
vi= fwd_solve( img );

% Show a stim pattern for img2
h2= subplot(222);
img_v = rmfield(img, 'elem_data');
img_v.node_data = vi.volt(:,stim_pattern_no);

CenterValue = 0.00;
calc_colours('ref_level',CenterValue);
Color_Range = 1.0;
calc_colours('clim',Color_Range);

show_fem(img_v);

img_v2 = img_v;

img_v.calc_colours.cb_shrink_move = [0.3,0.8,-0.02];
common_colourbar([h1,h2],img_v);

print_convert(voltage_map_name + ".png")

% Show voltage patterns with contours
clf;
h1= subplot(221);
img_v1.show_slices.contour_levels = [-.75, -.5, -.25 ,0 , 0.25, 0.5, 0.75]; %=> Put contours at these locations
img_v1.show_slices.contour_properties = {'Color',[0,0,0],'LineWidth',1.5};
img_v1.calc_colours.cb_shrink_move = [0.3,0.8,-0.04];
show_slices(img_v1, [0.5]);

h2= subplot(222);
img_v2.show_slices.contour_levels = [-.75, -.5, -.25 ,0 , 0.25, 0.5, 0.75]; %=> Put contours at these locations
img_v2.show_slices.contour_properties = {'Color',[0,0,0],'LineWidth',1.5};
img_v2.calc_colours.cb_shrink_move = [0.3,0.8,0.04];
show_slices(img_v2, [0.5]);

common_colourbar([h1,h2],img_v1);
print_convert(voltage_map_name + "_con.png")

%% 
CenterValue = 1.00;
calc_colours('ref_level',CenterValue);
clf; show_fem(img,[1,1.016]);
axis square; axis off
print_convert('Object.png', '-density 60')

%mean(img.elem_data)


% Add noise
vi_n= vi; 

% nampl= 10 * std(vi.meas - vh.meas)*10^(-18/20); % Different noise level.
avg_vi = mean(vi.meas);
nampl= 0.004 * avg_vi; % Noise level is fraction of the average measurement level.
SNR = (avg_vi^2)/(nampl^2);
SNRdB = 10*log10(SNR)
rng('shuffle'); % Different noise every time
%rng('default'); % Same noise for each Matlab session.
vi_n.meas = vi.meas + nampl *randn(size(vi.meas));

%%
% Compare 2D algorithms
% Based on tutorial120b.m published 2017-06-07 12:03:37Z aadler $
clf;clear imgr imgn

% Create Inverse Model
inv2d= eidors_obj('inv_model', 'EIT inverse');
inv2d.reconst_type= 'difference';
inv2d.jacobian_bkgnd.value= 1;

inv2d.fwd_model= fmdl;

% Guass-Newton solvers
inv2d.solve=       @inv_solve_diff_GN_one_step;

% Tikhonov prior
inv2d.hyperparameter.value = .03;
inv2d.RtR_prior=   @prior_tikhonov;
imgr(1)= inv_solve( inv2d, vh, vi);
imgn(1)= inv_solve( inv2d, vh, vi_n);

% NOSER prior
inv2d.hyperparameter.value = .1;
inv2d.RtR_prior=   @prior_noser;
imgr(2)= inv_solve( inv2d, vh, vi);
imgn(2)= inv_solve( inv2d, vh, vi_n);

% Laplace image prior
inv2d.hyperparameter.value = .1;
inv2d.RtR_prior=   @prior_laplace;
imgr(3)= inv_solve( inv2d, vh, vi);
imgn(3)= inv_solve( inv2d, vh, vi_n);

% Automatic hyperparameter selection
inv2d.hyperparameter = rmfield(inv2d.hyperparameter,'value');
inv2d.hyperparameter.func = @choose_noise_figure;
inv2d.hyperparameter.noise_figure= 0.5;
inv2d.hyperparameter.tgt_elems= 1:4;
inv2d.RtR_prior=   @prior_gaussian_HPF;
inv2d.solve=       @inv_solve_diff_GN_one_step;
imgr(4)= inv_solve( inv2d, vh, vi);
imgn(4)= inv_solve( inv2d, vh, vi_n);
inv2d.hyperparameter = rmfield(inv2d.hyperparameter,'func');

% Total variation using PDIPM
inv2d.hyperparameter.value = 1e-5;
inv2d.solve=       @inv_solve_TV_pdipm;
inv2d.R_prior=     @prior_TV;
inv2d.parameters.max_iterations= 10;
inv2d.parameters.term_tolerance= 1e-3;

%Vector of structs, all structs must have exact same (a) fields (b) ordering
imgr5= inv_solve( inv2d, vh, vi);
imgr5=rmfield(imgr5,'type'); imgr5.type='image';
imgr(5)=imgr5;
imgn5= inv_solve( inv2d, vh, vi_n);
imgn5=rmfield(imgn5,'type'); imgn5.type='image';
imgn(5)=imgn5;
%%
% Output image
imgn(1).calc_colours.npoints= 128;
imgr(1).calc_colours.npoints= 128;

%Set plotting options
%Center of color scale
CenterValue = 0.00;
%CenterValue = 1.00;
calc_colours('ref_level',CenterValue);
%calc_colours('ref_level','auto');

%Range Plus-Minus from center value
Color_Range = 0.10;
%Color_Range = 1.00;
calc_colours('clim',Color_Range);

show_slices(imgr, [inf,inf,0,1,1]);
eidors_colourbar( imgr(5) )
filename = "Without_Noise_" + label + ".png"
print_convert(filename)

show_slices(imgn, [inf,inf,0,1,1]);
eidors_colourbar( imgn(5) )
filename = "With_Noise_" + label + ".png"
print_convert(filename)

