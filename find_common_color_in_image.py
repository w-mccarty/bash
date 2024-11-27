import os
import numpy as np
import cv2
from sklearn.cluster import KMeans
from PIL import Image, ImageOps

imgloc = "/DIR/HOLDING/IMAGE/"
i_name = imgloc + "IMAGE.webp"

#FIND X MOST COMMON BGR VALUES
def preprocess_image(image):
    pixels = image.reshape((-1, 3))
    pixels = np.float32(pixels)
    return pixels
def get_dominant_colors(pixels, k=3):
    kmeans = KMeans(n_clusters=k)
    kmeans.fit(pixels)
    colors = kmeans.cluster_centers_
    return colors.astype(int)
num_colors = 20 #15
image = cv2.imread(i_name)
preprocessed_image = preprocess_image(image)
dcv = get_dominant_colors(preprocessed_image, k=num_colors)

#CONVERT TO CMYK AND TAKE PERCENTAGES OF VALUES
cmyk1 = []
rgb_scale = 255
cmyk_scale = 100
def rgb_to_cmyk(r,g,b):
    if (r == 0) and (g == 0) and (b == 0): #black
        return 0, 0, 0, cmyk_scale
    # rgb [0,255] -> cmy [0,1]
    c = 1 - r / rgb_scale
    m = 1 - g / rgb_scale
    y = 1 - b / rgb_scale
    # extract out k [0,1]
    min_cmy = min(c, m, y)
    c = (c - min_cmy) / (1 - min_cmy)
    m = (m - min_cmy) / (1 - min_cmy)
    y = (y - min_cmy) / (1 - min_cmy)
    k = min_cmy
    # get cmy values and get sum of values
    cmykmax = max(round(c*cmyk_scale), round(m*cmyk_scale), round(y*cmyk_scale)) #prevent single high value (ie:0,7,0) from outweighing others (ie: 0,3,5)
    cmyksum = (round(c*cmyk_scale) + round(m*cmyk_scale) + round(y*cmyk_scale) + cmykmax)
    cmyk1.append([round(c*cmyk_scale), round(m*cmyk_scale), round(y*cmyk_scale), cmyksum])
for i in range(len(dcv)):
    rgb_to_cmyk((dcv[i][2]),(dcv[i][1]),(dcv[i][0]))

#REMOVE COLORS TOO SIMILAR (MINIMUM DIFFERENCE REQUIRED FOR ANY OF CMY VALUES)
difval = 15 #10 #minimum difference allowed (all 3 colors must not meet to skip color)
totval = 4 #5 #total colors required
dcx = []
dcfin = []
dcx.append(cmyk1[0])
for i in range(len(cmyk1)):
        td = 0
        dcxlen = len(dcx)
        for j in range(len(dcx)):
                if ((((abs(cmyk1[i][0]-dcx[j][0]))-difval)>0) or (((abs(cmyk1[i][1]-dcx[j][1]))-difval)>0) or (((abs(cmyk1[i][2]-dcx[j][2]))-difval)>0)):
                        td = td + 1
        if (td ==  dcxlen):
                dcx.append(cmyk1[i])
for k in (range(len(cmyk1))):
        if (len(dcx) < totval):
                if cmyk1[k] not in dcx:
                        dcx.append(cmyk1[k])
if (len(dcx) >= totval):
	for m in range(totval):
		dcfin.append(dcx[m])

#SORT BY CMY SUM (least color > more) and then get 10% K Values
sort_kval = 10
cmyk2 = []
dcfin = sorted(dcfin, key=lambda x: x[3])
for z in range(len(dcfin)):
    #for i in (10, 20, 30, 40, 50, 60, 70, 80, 90):
    cmyk2.append([dcfin[z][0], dcfin[z][1], dcfin[z][2], sort_kval])  #sort_kval replaces i

#CONVERT TO RGB
rgb1 = []
def cmyk_to_rgb(c,m,y,k):
    r = rgb_scale * (1.0 - c / float(cmyk_scale)) * (1.0 - k / float(cmyk_scale))
    g = rgb_scale * (1.0 - m / float(cmyk_scale)) * (1.0 - k / float(cmyk_scale))
    b = rgb_scale * (1.0 - y / float(cmyk_scale)) * (1.0 - k / float(cmyk_scale))
    rgb1.append([round(r), round(g), round(b)])
for i in range(len(cmyk2)):
    cmyk_to_rgb(cmyk2[i][0],cmyk2[i][1],cmyk2[i][2],cmyk2[i][3])

#CONVERT TO HEX VALUES
hex1 = []
def clamp(x):
    return max(0, min(x, 255))
for i in range(len(rgb1)):
    hex = "#{0:02x}{1:02x}{2:02x}".format(clamp(rgb1[i][0]), clamp(rgb1[i][1]), clamp(rgb1[i][2]))
    hex1.append(hex)

print(hex1)
