clc;
clear;
%Transform Matrix and Camera Matrix
CameraLidarCalibration = 'Calibrations\Lidar-RGB\LIDAR_to_RGB_CROP.mat';
FileCameraParams = 'Calibrations\RGB_CROP_640x512.json';

% Caminho para os arquivos de PointCloud e imagens
input_image = 'C:\Users\GreenBotics\Desktop\NewDataset\[04292024][104558]\rgb_und_crop'; % Substitua pelo caminho correto
input_pcd = 'C:\Users\GreenBotics\Desktop\NewDataset\[04292024][104558]\pcd'; % Substitua pelo caminho correto
output_folder = 'C:\Users\GreenBotics\Desktop\NewDataset\[04292024][104558]\projections';

%File Extensions
pcd_ext = '.ply'; %Point Cloud File Extension
img_ext = '.png'; %Image File Extension

%Load Camera Lidar Calibration
load(CameraLidarCalibration);
% Carregue os parâmetros da câmera (você deve ter calibrado a câmera previamente)
%load(FileCameraParams);
cameraParams = cameraParameters(jsondecode(fileread(FileCameraParams)));

% Cria pasta se não existir
if ~exist(output_folder,'dir')
    mkdir(output_folder);
end

pcd_files = dir(fullfile(input_pcd, strcat('*',pcd_ext))); % ou a extensão correta das PCD

tform = cam;
% Loop através das 500 imagens e pcds correspondentes
for i = 1:numel(pcd_files)
    disp(['Processing ',num2str(i),'/',num2str(numel(pcd_files))]);

    % Criar o caminho completo para o arquivo .pcd atual
    pcd_file = fullfile(input_pcd, pcd_files(i).name);
    ptCloud = pcread(pcd_file);
    [projectedPoints, index_pcd] = projectLidarPointsOnImage(ptCloud.Location, cameraParams.Intrinsics, tform);

    distances = [];
    for v = index_pcd
        radial_distance = sqrt(ptCloud.Location(v,1).^2 + ptCloud.Location(v,2).^2);
        distances = [distances,radial_distance];
    end

    colormap = parula; % Você pode escolher um colormap diferente se desejar

    % Normalizar as distâncias para o intervalo [0, 1] para mapear as cores do colormap
    %normalized_distances = (distances - min(distances)) / (max(distances) - min(distances));
    normalized_distances = (distances - min(distances)) / (30 - min(distances));
    
    % Mapear as distâncias normalizadas para cores usando o colormap
    colors = interp1(linspace(0, 1, size(colormap, 1)), colormap, normalized_distances);

    % Visualizar a imagem com os pontos projetados (opcional, apenas para visualização)
    [~ , filename , ~] = fileparts(pcd_file);
    image_file = fullfile(input_image, strcat(filename,img_ext));
    image = imread(image_file);
    figure;
    imshow(image);
    hold on;
    scatter(projectedPoints(:, 1), projectedPoints(:, 2), 3, colors, 'filled'); % Plot dos pontos padrao = 5
    hold off;

    % Salvar a imagem projetada
    outputImageFile = fullfile(output_folder, strcat(filename,'.png')); % Adicione a extensão .png ao nome do arquivo de saída
    imwrite(getframe(gcf()).cdata, outputImageFile); % Use getframe() para capturar a imagem da figura atual

    % Feche a figura para evitar acumulação de janelas abertas
    close(gcf);
end
