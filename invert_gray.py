import os
import cv2

input_folder = 'rgb'
output_folder = input_folder+'_mod'

try:
    os.makedirs(output_folder)
except:
    pass

files = os.listdir(input_folder)

for file in files:
    print('Preparing',file)
    img = cv2.imread(os.path.join(input_folder,file))
    img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    img = cv2.bitwise_not(img)
    cv2.imwrite(os.path.join(output_folder,file),img)
