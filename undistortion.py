import os
import cv2
import json
import numpy as np

file = 'RGB_1280x1024.json'
folder = 'rgb'
#file = 'THERMAL_640x512.json'
#folder = 'thermal'


try:
    os.makedirs(folder+'_undistorted')
except:
    pass


# Carregar os parâmetros da câmera a partir do arquivo JSON
with open(file, 'r') as file:
    data = json.load(file)

K = np.array(data['K']) # Matriz de calibração

dist_coef = [data['RadialDistortion'][0],data['RadialDistortion'][1],data['TangentialDistortion'][0],data['TangentialDistortion'][1],data['RadialDistortion'][2]]
dist_coef = np.array(dist_coef) # Coeficientes de distorção

images = os.listdir(folder)

for image in images:
    print('Undistort',image)
    img = cv2.imread(os.path.join(folder,image))
    img = cv2.undistort(img, K, dist_coef)
    cv2.imwrite(os.path.join(folder+'_undistorted',image),img)