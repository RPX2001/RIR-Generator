% =========================================================================
% Project     : ReTM based quiet zone
% Date        : 29-09-2025
% Author      : Wageesha Manamperi
% Version     : V1
%
% Usage       : This is the code to generate the simulation setup using the
% image source method
% =========================================================================

clc;
%clear all;
% close all;

%% - S E T U P - ----------------------------------------------------------

% Define the room (in m width, length and height, respectively).
roomDimensions = [5.2 5.2 5.2];

% Receiver position.
% Mic group A.
r_Rx = [2.6,2.6,1]; %EM32 center w.r.t room cordinates
r_Mic = 0.042; %radius of EM32
angles_Mic = (180/pi)*[1.2043 0  % cordinates of em32 microphones
    1.5708    0.5585
    1.9373         0
    1.5708    5.7247
    0.5585         0
    0.9599    0.7854
    1.5708    1.2043
    2.1817    0.7854
    2.5831         0
    2.1817    5.4978
    1.5708    5.0789
    0.9599    5.4978
    0.3665    1.5882
    1.0123    1.5708
    2.1118    1.5708
    2.7751    1.5533
    1.2043    3.1416
    1.5708    3.7001
    1.9373    3.1416
    1.5708    2.5831
    0.5585    3.1416
    0.9599    3.9270
    1.5708    4.3459
    2.1817    3.9270
    2.5831    3.1416
    2.1817    2.3562
    1.5708    1.9373
    0.9599    2.3562
    0.3665    4.6949
    1.0123    4.7124
    2.1293    4.7124
    2.7751    4.7298];

%Converting EM32 microphone cordinate wrt EM2 to wrt room
Mic_pos_cart(:,1) = (r_Mic*sind(angles_Mic(:,1)).*cosd(angles_Mic(:,2)))+r_Rx(1);
Mic_pos_cart(:,2) = (r_Mic*sind(angles_Mic(:,1)).*sind(angles_Mic(:,2)))+r_Rx(2);
Mic_pos_cart(:,3) = (r_Mic*cosd(angles_Mic(:,1)))+r_Rx(3);

% Mic group B.
h = 2.60; 
nrefmic = 12;
ref_offset = 0.40; % below motor height
theta = linspace(0, 2*pi, nrefmic+1); theta(end) = [];
ref_radius = 0.25;
ref_Rx=[2.6,2.6,2.2];
Ref_pos_cart(:,1)=(ref_radius*cos(theta).')+ref_Rx(1);
Ref_pos_cart(:,2)=(ref_radius*sin(theta).')+ref_Rx(2);
Ref_pos_cart(:,3)=ones(nrefmic,1)*ref_Rx(3);
% ref_pos = [ref_radius*cos(theta).' ref_radius*sin(theta).' (h-ref_offset)*ones(nrefmic,1)];

% Primary noise sources.
src1 = [2.3 2.3 h];
src2 = [2.3 2.9 h];
src3 = [2.9 2.3 h];
src4 = [2.9 2.9 h];

% Create point sources
hsspk = 2;
ssrc1 = [2.4 2.6 hsspk];
ssrc2 = [2.6 2.4 hsspk];
ssrc3 = [2.6 2.8 hsspk];
ssrc4 = [2.8 2.6 hsspk];


% h = figure;
% for ind = 1:32
%     plotRoom(roomDimensions,Mic_pos_cart(ind,:),src1,h)
%     hold on;
% end
% for ind2 = 1:nrefmic
%     plotRoom(roomDimensions,Ref_pos_cart(ind2,:),src2,h)
%     hold on;
% end
% plotRoom(roomDimensions,Ref_pos_cart(1,:),src3,h)
% hold on;
% plotRoom(roomDimensions,Ref_pos_cart(1,:),src4,h)
% hold on;
% plotRoom(roomDimensions,Ref_pos_cart(1,:),ssrc1,h)
% hold on;
% plotRoom(roomDimensions,Ref_pos_cart(1,:),ssrc2,h)
% hold on;
% plotRoom(roomDimensions,Ref_pos_cart(1,:),ssrc3,h)
% hold on;
% plotRoom(roomDimensions,Ref_pos_cart(1,:),ssrc4,h)
% hold on;

% Parameters
T_start=24.1;
T_end=23.1;
temperature=mean([T_start,T_end],'all');
c = 331.4+0.6*temperature;  % Sound velocity (m/s)
Fs = 16000;                 % Sample frequency (samples/s)
n = 8192;                   % Number of samples

%[beta_x1 beta_x2 beta_y1 beta_y2 beta_z1 beta_z2]
% beta = [0.75, 0.9,0.8, 0.7, 0.6, 0.65]; % Reflection coefficient
beta = [0, 0,0, 0, 0.6, 0]; % Reflection coefficient

%RIR generation using  ISM
h_emic2psrc1 = rir_generator(c, Fs, Mic_pos_cart, src1, roomDimensions, beta, n);
h_emic2psrc2 = rir_generator(c, Fs, Mic_pos_cart, src2, roomDimensions, beta, n);
h_emic2psrc3 = rir_generator(c, Fs, Mic_pos_cart, src3, roomDimensions, beta, n);
h_emic2psrc4 = rir_generator(c, Fs, Mic_pos_cart, src4, roomDimensions, beta, n);

h_emic2ssrc1 = rir_generator(c, Fs, Mic_pos_cart, ssrc1, roomDimensions, beta, n);
h_emic2ssrc2 = rir_generator(c, Fs, Mic_pos_cart, ssrc2, roomDimensions, beta, n);
h_emic2ssrc3 = rir_generator(c, Fs, Mic_pos_cart, ssrc3, roomDimensions, beta, n);
h_emic2ssrc4 = rir_generator(c, Fs, Mic_pos_cart, ssrc4, roomDimensions, beta, n);

h_rmic2psrc1 = rir_generator(c, Fs, Ref_pos_cart, src1, roomDimensions, beta, n);
h_rmic2psrc2 = rir_generator(c, Fs, Ref_pos_cart, src2, roomDimensions, beta, n);
h_rmic2psrc3 = rir_generator(c, Fs, Ref_pos_cart, src3, roomDimensions, beta, n);
h_rmic2psrc4 = rir_generator(c, Fs, Ref_pos_cart, src4, roomDimensions, beta, n);

h_rmic2ssrc1 = rir_generator(c, Fs, Ref_pos_cart, ssrc1, roomDimensions, beta, n);
h_rmic2ssrc2 = rir_generator(c, Fs, Ref_pos_cart, ssrc2, roomDimensions, beta, n);
h_rmic2ssrc3 = rir_generator(c, Fs, Ref_pos_cart, ssrc3, roomDimensions, beta, n);
h_rmic2ssrc4 = rir_generator(c, Fs, Ref_pos_cart, ssrc4, roomDimensions, beta, n);

%% Save to .mat files

mkdir('Datafiles');

save(fullfile('Datafiles', 'IRs_emics2Psrc1.mat'), 'h_emic2psrc1');
save(fullfile('Datafiles', 'IRs_emics2Psrc2.mat'), 'h_emic2psrc2');
save(fullfile('Datafiles', 'IRs_emics2Psrc3.mat'), 'h_emic2psrc3');
save(fullfile('Datafiles', 'IRs_emics2Psrc4.mat'), 'h_emic2psrc4');

save(fullfile('Datafiles', 'IRs_emics2Ssrc1.mat'), 'h_emic2ssrc1');
save(fullfile('Datafiles', 'IRs_emics2Ssrc2.mat'), 'h_emic2ssrc2');
save(fullfile('Datafiles', 'IRs_emics2Ssrc3.mat'), 'h_emic2ssrc3');
save(fullfile('Datafiles', 'IRs_emics2Ssrc4.mat'), 'h_emic2ssrc4');

save(fullfile('Datafiles', 'IRs_rmics2Psrc1.mat'), 'h_rmic2psrc1');
save(fullfile('Datafiles', 'IRs_rmics2Psrc2.mat'), 'h_rmic2psrc2');
save(fullfile('Datafiles', 'IRs_rmics2Psrc3.mat'), 'h_rmic2psrc3');
save(fullfile('Datafiles', 'IRs_rmics2Psrc4.mat'), 'h_rmic2psrc4');

save(fullfile('Datafiles', 'IRs_rmics2Ssrc1.mat'), 'h_rmic2ssrc1');
save(fullfile('Datafiles', 'IRs_rmics2Ssrc2.mat'), 'h_rmic2ssrc2');
save(fullfile('Datafiles', 'IRs_rmics2Ssrc3.mat'), 'h_rmic2ssrc3');
save(fullfile('Datafiles', 'IRs_rmics2Ssrc4.mat'), 'h_rmic2ssrc4');