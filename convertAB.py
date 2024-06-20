import os
import cv2
import json
import numpy as np

Cam_A = 'rgb.json'
Cam_B = 'thermal.json'
Stereo = 'stereo2.json'

# Carregar os parâmetros da câmera a partir do arquivo JSON
with open(Cam_A, 'r') as file:
    Cam_A = json.load(file)

# Carregar os parâmetros da câmera a partir do arquivo JSON
with open(Cam_B, 'r') as file:
    Cam_B = json.load(file)

# Carregar os parâmetros da câmera a partir do arquivo JSON
with open(Stereo, 'r') as file:
    Stereo = json.load(file)
    
K1 = np.array(Cam_A['K'])
K2 = np.array(Cam_B['K'])
E = np.array(Stereo['EssentialMatrix'])
R = np.array(Stereo['PoseCamera2']['R'])

def B_to_A(x,y):
    pB = np.array([x,y,1])
    E_inv = np.linalg.inv(E)
    World_3d = np.dot(E_inv,pB)
    print('World 3D:',World_3d)
    pA_homogeneous = np.dot(np.linalg.inv(K1),World_3d)
    pA = [pA_homogeneous[0]/pA_homogeneous[2],pA_homogeneous[1]/pA_homogeneous[2]]
    print(pA)
    return pA

P = B_to_A(640,512)

    
    
