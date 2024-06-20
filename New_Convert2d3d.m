%LOAD JSON FILES
global stereo;
stereo = jsondecode(fileread("Calibrations\UNDISTORT_STEREO.json"));
cam_rgb = cameraParameters(jsondecode(fileread("Calibrations\UNDISTORT_RGB_1280x1024.json")));
cam_thermal = cameraParameters(jsondecode(fileread("Calibrations\UNDISTORT_THERMAL_640x512.json")));

rgb.R = eye(3);
rgb.Translation = [0;0;0]; %x,y,z [0;695;0]
rgb.T = [[rgb.R,rgb.Translation];[zeros(1,3),1]];
rgb.K = cam_rgb.K;
thermal.Translation = rgb.Translation + stereo.TranslationOfCamera2;
thermal.T = [[stereo.RotationOfCamera2,thermal.Translation];[zeros(1,3),1]];
thermal.R = rgb.R*stereo.RotationOfCamera2;
thermal.K = cam_thermal.K;

%640 x 512
global z;
z = 15000; %2.5m
convA_B(150,150,rgb,rgb); %TEST TO RETURN 150,150
convA_B(0,0,thermal,rgb);
convA_B(640,0,thermal,rgb);
convA_B(640,512,thermal,rgb);
convA_B(0,512,thermal,rgb);

function World_3D = Cam2World(u,v,cam)
    global z
    Pixel_Coord = [u;v;1];
    %DEFINE (K)ALIBRATION, ROTATION, TRANSLATION AND TRANSFORMATION MATRIX
    K = cam.K;
    R = cam.R;
    T = cam.Translation;
    Transf = [[R,T];[0,0,0,1]];

    %Pixel Coordinate to 3D_Cam
    Cam_3D = z * inv(K) * Pixel_Coord;
    %3D_Cam to 3D_World
    World_3D = inv(R) * (Cam_3D - T);
    World_3D = World_3D;
end

function Pixel = World2Cam(Coord,cam)
    global z
    x = Coord(1);
    y = Coord(2);
    %[X';Y';Z'] = R * [X;Y;Z] + T  --> 3D world to 3D Cam
    %[u;v;1] = K * [X';Y';Z'] --> 3D Cam to Pixel Coordinate
    World_3D = [x;y;z];
    %DEFINE (K)ALIBRATION, ROTATION AND TRANSLATION MATRIX
    K = cam.K;
    R = cam.R;
    T = cam.Translation;
    %CALCULATING
    Cam_3D = R * World_3D + T; % --> 3D world to 3D Cam
    Pixel = K * [Cam_3D(1)/Cam_3D(3);Cam_3D(2)/Cam_3D(3);1]; %--> 3D Cam to Pixel Coordinate
    Pixel = Pixel(1:2);
end

function convA_B(u,v,cam_A,cam_B)
    global z
    world = Cam2World(u,v,cam_A);
    cam = World2Cam(world,cam_B);

    disp('==========================')
    msg = ['Pixel Cam A: (',num2str(u),',',num2str(v),')'];
    disp(msg)
    msg = ['Pixel Cam B: (',num2str(round(cam(1))),',',num2str(round(cam(2))),')'];
    disp(msg)
    msg = ['World 3D: x=',num2str(round(world(1))),' mm, y=',num2str(round(world(2))),' mm, z=',num2str(round(world(3))),' mm'];
    disp(msg)
    disp('==========================')
end