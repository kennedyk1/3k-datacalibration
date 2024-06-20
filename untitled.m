clc;
clear;

%LOAD JSON FILES
global stereo;
stereo = jsondecode(fileread("stereo.json"));
rgb = jsondecode(fileread("rgb.json"));
rgb.Translation = [0;695;0]; %define x,y,z
thermal = jsondecode(fileread("thermal.json"));
thermal.Translation = rgb.Translation + stereo.PoseCamera2.Translation;

rgb.R = eye(3);
rgb.T = [[rgb.R,rgb.Translation];[zeros(1,3),1]];
thermal.T = [[stereo.PoseCamera2.R,thermal.Translation];[zeros(1,3),1]];
thermal.R = rgb.R*stereo.PoseCamera2.R;

%640 x 512
u=640;
v=512;
cam = rgb;

%[X';Y';Z'] = inv(K) * [u;v;1] --> Pixel Coordinate to 3D_Cam
%[X;Y;Z;1] = inv([R|T]) * [X';Y';Z';1] --> 3D_Cam to 3D_World
Pixel_Coord = [u;v;1];
%DEFINE (K)ALIBRATION, ROTATION, TRANSLATION AND TRANSFORMATION MATRIX
K = cam.K;
R = cam.R;
T = cam.Translation;
Transf = [[R,T];[0,0,0,1]];

%Pixel Coordinate to 3D_Cam
Cam_3D = inv(K) * Pixel_Coord;
Cam_3D = [Cam_3D;1];
%3D_Cam to 3D_World
World_3D = inv(Transf) * Cam_3D;




function Pixel = World2Cam(x,y,z,cam)
    %[X';Y';Z'] = R * [X;Y;Z] + T  --> 3D world to 3D Cam
    %[u;v;1] = K * [X';Y';Z'] --> 3D Cam to Pixel Coordinate
    World_3D = [x;y;z];
    %DEFINE (K)ALIBRATION AND TRANSLATION MATRIX
    K = cam.K;
    T = cam.Translation;
    %CALCULATING
    Cam_3D = R * World_3D + T; % --> 3D world to 3D Cam
    Pixel = K * Cam_3D; %--> 3D Cam to Pixel Coordinate
end