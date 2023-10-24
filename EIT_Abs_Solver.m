% Based on RPI tank model $Id: rpi_data01.m 3790 2013-04-04 15:41:27Z aadler $

Nel= 32; %Number of elecs
Zc = .0001; % Contact impedance
curr = 20; % applied current mA


elec_sz = 1/12;
fmdl= ng_mk_cyl_models([0,1,0.05],[Nel,0],[elec_sz,0,0.01]);

for i=1:Nel
   fmdl.electrode(i).z_contact= Zc;
end

% Trig stim patterns
th= linspace(0,2*pi,Nel+1)';th(1)=[];
for i=1:Nel-1;
   if i<=Nel/2;
      stim(i).stim_pattern = curr*cos(th*i);
   else;
      stim(i).stim_pattern = curr*sin(th*( i - Nel/2 ));
   end
   stim(i).meas_pattern= eye(Nel)-ones(Nel)/Nel;
   stim(i).stimulation = 'Amp';
end

fmdl.stimulation = stim;

clf; show_fem(fmdl,[0,1.016])
axis square; axis off;

print_convert('rpi_data01a.png','-density 60')
%%
bkgnd= 1;
%Set plotting options
%Center of color scale
CenterValue = 1.1;
calc_colours('ref_level',CenterValue);
%calc_colours('ref_level','auto');

%Range Plus-Minus from center value
Color_Range = 1.1;
calc_colours('clim',Color_Range);

% Choose the type of color scale, aka "cmap_type"
CMAP_TYPE_OPTIONS = ["blue_red","jet","jetair","blue_yellow","greyscale","greyscale-inverse","copper","blue_white_red","black_red","blue_black_red","polar_colours","draeger","draeger-2009","draeger-tidal","swisstom","timpel","flame","ice"];
Cmap_type_no = 2;
Cmap_type = CMAP_TYPE_OPTIONS(Cmap_type_no)
calc_colours('cmap_type',Cmap_type);

img_h= mk_image(fmdl, bkgnd);

% Conductivity Modification Linear 3
scale_fcn = inline('(2-1.5*sqrt(x.^2+y.^2))','x','y','z');
img_h.elem_data = elem_select(img_h.fwd_model, scale_fcn);

% Conductivity Modification Smoother 3b
%scale_fcn = inline('(1.5-1*(x.^2+y.^2))','x','y','z');
%img_h.elem_data = elem_select(img_h.fwd_model, scale_fcn);

% Conductivity Modification Inverse Linear 5
%scale_fcn = inline('(0.5+0.75*sqrt(x.^2+y.^2))','x','y','z');
%img_h.elem_data = elem_select(img_h.fwd_model, scale_fcn);

mean(img_h.elem_data)
img_h.calc_colours.cb_shrink_move = [0.5,0.8,-0.02];
clf; show_fem(img_h,[1,1.016]);
axis square; axis off;
print_convert('rpi_background.png','-density 60')
vh = fwd_solve(img_h);
img_i = img_h;

% Add a small object with 50% of conductivity, slightly above the center.
%local_rel_cond_red = 0.50;
%select_fcn = inline('(x-0.18).^2+(y-0.32).^2<0.168^2','x','y','z');
%img_i.elem_data_object = elem_select(img_i.fwd_model, select_fcn);
%img_i.elem_data = img_i.elem_data - img_i.elem_data .* img_i.elem_data_object * local_rel_cond_red;

% Add a second small object with 50% of conductivity to the left of the center.
%local_rel_cond_red = 0.50;
%select_fcn = inline('(x+0.35).^2+(y-0.05).^2<0.1628^2','x','y','z');
%img_i.elem_data_object = elem_select(img_i.fwd_model, select_fcn);
%img_i.elem_data = img_i.elem_data - img_i.elem_data .* img_i.elem_data_object * local_rel_cond_red;

% Add a third small object with 50% of conductivity near the lower edge.
local_rel_cond_red = 0.50;
select_fcn = inline('(x-0.15).^2+(y+0.7).^2<0.1628^2','x','y','z');
img_i.elem_data_object = elem_select(img_i.fwd_model, select_fcn);
img_i.elem_data = img_i.elem_data - img_i.elem_data .* img_i.elem_data_object * local_rel_cond_red;


clf; show_fem(img_i,[1,1.016]);
axis square; axis off;
print_convert('rpi_object.png','-density 60')

vi = fwd_solve(img_i);
vd.meas = vi.meas-vh.meas;

%%
% Absolute reconstructions $Id: rpi_data06.m 5537 2017-06-14 12:49:20Z aadler $

%imdl = mk_common_model('b2c2',Nel);
imdl = mk_common_model('d2c2',Nel);
imdl.fwd_model = fmdl;
imdl.reconst_type = 'absolute';
imdl.hyperparameter.value = 2.0;
imdl.solve = @inv_solve_abs_GN;

for iter = [1,2,3, 5];
   imdl.inv_solve_gn.max_iterations = iter;
   img = inv_solve(imdl , vi);
   img.calc_colours.cb_shrink_move = [0.5,0.8,-0.02];
   img.calc_colours.ref_level = CenterValue;
   clf; show_fem(img,[1,1.016]); %axis off; axis image
   axis square; axis off;
   
   print_convert(sprintf('rpi_data06%c.png', 'a'-1+iter),'-density 60');
end
%%
% Show change relative to a case without any objects.

% Choose the type of color scale, aka "cmap_type"
CMAP_TYPE_OPTIONS = ["blue_red","jet","jetair","blue_yellow","greyscale","greyscale-inverse","copper","blue_white_red","black_red","blue_black_red","polar_colours","draeger","draeger-2009","draeger-tidal","swisstom","timpel","flame","ice"];
Cmap_type_no = 3;
Cmap_type = CMAP_TYPE_OPTIONS(Cmap_type_no)
calc_colours('cmap_type',Cmap_type);

%Center of color scale
CenterValue = 3;
calc_colours('ref_level',CenterValue);
%calc_colours('ref_level','auto');

%Range Plus-Minus from center value
Color_Range = 0.6;
calc_colours('clim',Color_Range);

img_frac = img;
img_frac.elem_data = img_i.elem_data ./ img_h.elem_data;

clf; show_fem(img_frac,[1,1.016]); %axis off; axis image
axis square; axis off;
print_convert('fraction_actual.png','-density 60');

img_frac.elem_data = img.elem_data ./ img_h.elem_data;

clf; show_fem(img_frac,[1,1.016]); %axis off; axis image
axis square; axis off;
print_convert('fraction_reconstructed.png','-density 60');