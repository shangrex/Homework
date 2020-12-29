import numpy as np
import cv2
import glob

# termination criteria
criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 30, 0.001)

# prepare object points, like (0,0,0), (1,0,0), (2,0,0) ....,(6,5,0)


# Arrays to store object points and image points from all the images.
objpoints = [] # 3d point in real world space
imgpoints = [] # 2d points in image plane.

images = glob.glob('*.jpg')


for i in range(5):
    x = cv2.imread("Datasets/Q3_Image/{}.bmp".format(i+1))
    x = cv2.resize(x, (1024, 1024), interpolation=cv2.INTER_AREA)
    images.append(x)

count = 0
check = True
x = 3
y = 3
cool = []
for img in images:
    for x in range(3, 13):
        for y in range(3, 13):
            if(check == False):
                break
            # print(x, y)
            objp = np.zeros((x*y,3), np.float32)
            objp[:,:2] = np.mgrid[0:x,0:y].T.reshape(-1,2)
            gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)

            # Find the chess board corners
            ret, corners = cv2.findChessboardCorners(gray,(x, y), None)

            # If found, add object points, image points (after refining them)
            if ret == True:
                count += 1
                print(count)
                print(x, y)
                # print(ret)
                # print(corners)
                objpoints.append(objp)

                corners2 = cv2.cornerSubPix(gray,corners,(11,11),(-1,-1),criteria)
                imgpoints.append(corners2)

                # Draw and display the corners
                img = cv2.drawChessboardCorners(img, (x, y), corners2,ret)
                # cv2.imshow('img{}'.format(count),img)
                ret, mtx, dist, rvecs, tvecs = cv2.calibrateCamera(objpoints, imgpoints, gray.shape[::-1],None,None)
                # print("ret", ret)
                # print("mtx", mtx)
                # print("dist", dist)
                # print("rvecs", rvecs)
                # print("tvecs", tvecs)

                objpoints = []
                imgpoints = []

                check = False
            else:
                # print(ret)
                pass
        # cv2.waitKey(5000)
    check = True


print(cool)



