import cv2
import os

rgb_path = "rgb_und_crop"
thermal_path = "thermal_undistorted"
output_path = "fusion"

try:
    #CREATE FOLDER TO RGBT (RGB + THERMAL)FILES
    os.mkdir(output_path)
except:
    pass

rgb = os.listdir(rgb_path)
thermal = os.listdir(thermal_path)

len = len(rgb)
j=1
for i in rgb:
    if i in thermal:
        print(j,"/",len)
        rgb_pic = cv2.imread(os.path.join(rgb_path,i))
        thermal_pic = cv2.imread(os.path.join(thermal_path,i))
        alpha = cv2.cvtColor(thermal_pic, cv2.COLOR_BGR2GRAY)
        #rgb_pic = cv2.resize(rgb_pic,(thermal_pic.shape[1],thermal_pic.shape[0]),interpolation=cv2.INTER_AREA)
        B,G,R = cv2.split(rgb_pic)
        rgbt = cv2.merge([B,G,R,alpha])
        cv2.imwrite(os.path.join(output_path,i)+".png",rgbt)
        j=j+1
    else:
        print("ERROR ==============")
        j=j+1