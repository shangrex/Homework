from PyQt5 import QtCore, QtGui, QtWidgets
from PyQt5.QtWidgets import QApplication, QWidget, QPushButton
import sys
import UI
import cv2
import numpy as np
import glob
import matplotlib.pyplot as plt
from resnet import resnet_train, resnet_show, resnet_test, resnet_resize_train
import math

class ExampleApp(QtWidgets.QMainWindow, UI.Ui_MainWindow):
    def __init__(self, parent=None):
        super(ExampleApp, self).__init__(parent)
        self.setupUi(self)
        self.find_contour_button.clicked.connect(self.click_contour_button)
        self.count_coins_buttons.clicked.connect(self.click_count_countours_button)
        self.ok1.clicked.connect(self.click_contour_button)
        self.ok1.clicked.connect(self.click_count_countours_button)
        self.find_corner_button.clicked.connect(self.click_find_corner)
        self.find_intrinstic_button.clicked.connect(self.click_find_intrinstic)
        self.find_extrinstic_button.clicked.connect(self.click_find_extrinstic)
        self.find_distortion_button.clicked.connect(self.click_find_distortion_button)
        choices = []
        for i in range(15):
            choices.append(str(i+1))
        
        self.extrinstic_pic_combobox.addItems(choices)
        self.extrinstic_pic_combobox.currentIndexChanged.connect(self.display)
        self.extrinstic_pic_index = 1

        
        self.calibration_image = []
        self.calibration_image_dis = []
        self.calibration_image_r = []
        self.calibration_image_t = []

        self.augmented_reality_button.clicked.connect(self.click_augmented_reality)
        self.stereo_disparity_map_button.clicked.connect(self.click_stereo_disparity_map)
        self.train_button.clicked.connect(self.click_train_button)
        self.tensorboard_button.clicked.connect(self.click_tensorboard_button)
        self.random_select_button.clicked.connect(self.click_random_select_button)
        self.resize_accuracy_button.clicked.connect(self.click_resize_accuracy_button)
        self.resize_train_button.clicked.connect(self.click_resize_train_button)
        # cv2.setMouseCallback("gray", self.click_stereo_disparity_map)
    
    def click_resize_train_button(self):
        print("click resize train button")
        #image resize
        # for i in tqdm(range(12500)):
        #     image = cv2.imread("Datasets/Q5_ASIRRA/train/cat.{}.jpg".format(i))
        #     image = cv2.resize(image, (128, 256)) 
        #     cv2.imwrite("Datasets/Q5_ASIRRA/trainresize/cat.{}.jpg".format(i), image)
        #     image = cv2.imread("Datasets/Q5_ASIRRA/train/dog.{}.jpg".format(i))
        #     image = cv2.resize(image, (128, 256)) 
        #     cv2.imwrite("Datasets/Q5_ASIRRA/trainresize/dog.{}.jpg".format(i), image)

        # for i in tqdm(range(12500)):
        #     image = cv2.imread("Datasets/Q5_ASIRRA/train/cat.{}.jpg".format(i))
        #     image = cv2.resize(image, (256, 128)) 
        #     cv2.imwrite("Datasets/Q5_ASIRRA/trainresize/cat.{}.jpg".format(i), image)
        #     image = cv2.imread("Datasets/Q5_ASIRRA/train/dog.{}.jpg".format(i))
        #     image = cv2.resize(image, (256, 128)) 
        #     cv2.imwrite("Datasets/Q5_ASIRRA/trainresize/dog.{}.jpg".format(i), image)
        resnet_resize_train(epoch=5)

    def click_resize_accuracy_button(self):
        print("click resize accuracy button")
        resnet_test()


    def click_random_select_button(self):
        print("click random select button")
        resnet_show()

    def click_tensorboard_button(self):
        print("click tensorboard button")

    def click_train_button(self):
        print("click train button")
        resnet_train(epoch=5)

    def draw(self, img, corners, imgpts):
        corner = tuple(corners[0].ravel())
        # print(len(corners))
        img = cv2.line(img, tuple(imgpts[0].ravel()), tuple(imgpts[1].ravel()), (255,0,0), 5)
        img = cv2.line(img, tuple(imgpts[0].ravel()), tuple(imgpts[2].ravel()), (255,0,0), 5)
        img = cv2.line(img, tuple(imgpts[0].ravel()), tuple(imgpts[3].ravel()), (255,0,0), 5)
        img = cv2.line(img, tuple(imgpts[1].ravel()), tuple(imgpts[2].ravel()), (0,255,0), 5)
        img = cv2.line(img, tuple(imgpts[1].ravel()), tuple(imgpts[3].ravel()), (0,255,0), 5)
        img = cv2.line(img, tuple(imgpts[2].ravel()), tuple(imgpts[3].ravel()), (0,0,255), 5)
        return img

    def click_augmented_reality(self):
        print("click_augmented_reality")
        arl = []
        # f_pattern = open("config2.txt", "r")
        # s = ""
        # cor = []
        axis = np.float32([[3,3,-3], [1,1,0], [3,5,0], [5, 1, 0]])
        # axis = np.float32([[3,0,0], [0,3,0], [0,0,-3]]).reshape(-1,3)

        for i in range(5):
            x = cv2.imread("Datasets/Q3_Image/{}.bmp".format(i+1))
            # x = cv2.resize(x, (1024, 1024), interpolation=cv2.INTER_AREA)
            arl.append(x)
            #read pattern
            # s = f_pattern.readline()
            # cor = s.split(" ")
            # x = int(cor[0])
            # y = int(cor[1])
            x = 8
            y = 11 
            print("{} bmp image".format(i+1))
            criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 30, 0.001)

            objpoints = []
            imgpoints = []

            objp = np.zeros((x*y,3), np.float32)
            objp[:,:2] = np.mgrid[0:y,0:x].T.reshape(-1,2)
            print("objp", objp)
            gray = cv2.cvtColor(arl[i],cv2.COLOR_BGR2GRAY)

            # Find the chess board corners
            ret, corners = cv2.findChessboardCorners(gray,(y, x), None)

            # If found, add object points, image points (after refining them)
            if ret == True:
                objpoints.append(objp)

                corners2 = cv2.cornerSubPix(gray,corners,(11,11),(-1,-1),criteria)
                imgpoints.append(corners2)
                print("imgpoints", imgpoints)
                # Draw and display the corners
                # img = cv2.drawChessboardCorners(arl[i], (x, y), corners2,ret)

                # cv2.imshow('img{}'.format(count),img)
                ret, mtx, dist, rvecs, tvecs = cv2.calibrateCamera(objpoints, imgpoints, gray.shape[::-1],None,None)

                # R, _ = cv2.Rodrigues(np.array(rvecs))
                mtx = np.array(mtx)
                dist = np.array(dist)
                rvecs = np.array(rvecs)
                tvecs = np.array(tvecs)

                imgpts, jac = cv2.projectPoints(axis, rvecs, tvecs, mtx, dist)
                print(imgpts)
                img = self.draw(arl[i],corners2,imgpts )
                img = cv2.resize(img, (1024, 1024), interpolation=cv2.INTER_AREA)
                cv2.imshow("img{}".format(i+1),img)

            else:
                print("Error pattern in corner")

            objpoints = []
            imgpoints = []
            imgpoints = []

    def draw_tag(self, event, x, y, flags, param):
        global x1, y1, drawing, radius, num, img2
        baseline = 178
        focal_length = 2826
        if event == cv2.EVENT_LBUTTONDOWN:
            print(x, y)
            # drawing = True
            x1, y1 = x, y
            self.disparity = abs(self.disparity)
            print(self.disparity[x1, y1])
            dis = self.disparity[x1, y1]
            # radius = int(math.hypot(x - x1, y - y1))
            # cv2.circle(self.disparity, (x1,y1), 100, (255, 0, 0), 1)
            dis = self.disparity[x1, y1]
            dis_max = self.disparity.max()
            dis_min = self.disparity.min()
            dis = (dis-dis_min)/(dis_max-dis_min)*255
            print(dis_max)
            print(dis_min)
            self.depth = baseline * focal_length / (abs(dis)+123)
            text = "Disparity: {} pixels".format(abs(dis))
            text2 = "Depth: {} mm".format(self.depth)            
            font = cv2.FONT_HERSHEY_SIMPLEX 
            org = (50, 50) 
            fontScale = 1
            color = (255, 255, 255) 
            thickness = 2
            cv2.putText(self.nor_disparity, text, org, font,  
                            fontScale, color, thickness, cv2.LINE_AA)
            org = (50, 100) 
            cv2.putText(self.nor_disparity, text2, org, font,  
                            fontScale, color, thickness, cv2.LINE_AA)  
            cv2.imshow("Dispairty", self.nor_disparity)
            self.nor_disparity = self.disparity
            self.nor_disparity = cv2.normalize(self.nor_disparity, None, alpha = 0, beta = 1, norm_type=cv2.NORM_MINMAX, dtype=cv2.CV_32F)


    def click_stereo_disparity_map(self):
        print("click_stereo_disparity_map")
        image_l = cv2.imread("Datasets/Q4_Image/imgL.png", 0)
        image_r = cv2.imread("Datasets/Q4_Image/imgR.png", 0)
        image_l = cv2.resize(image_l, (950, 950), interpolation=cv2.INTER_AREA)
        image_r = cv2.resize(image_r, (950, 950), interpolation=cv2.INTER_AREA)
        # stereo = cv2.StereoBM_create(numDisparities=80, blockSize=13)
        stereo = cv2.StereoBM_create(numDisparities=64, blockSize=5)
        self.disparity = stereo.compute(image_l, image_r)
        self.nor_disparity = cv2.normalize(self.disparity, None, alpha = 0, beta = 1, norm_type=cv2.NORM_MINMAX, dtype=cv2.CV_32F)
        # min = self.disparity.min()
        # max = self.disparity.max()
        # self.disparity = np.uint8(6400 * self.disparity)
        windowName = 'Dispairty'
        cv2.namedWindow(windowName)
        cv2.setMouseCallback(windowName, self.draw_tag)
        cv2.imshow(windowName, self.nor_disparity)

    def click_find_distortion_button(self):
        print("click find distortion button")
        for i in range(15):
            print("distortion matrix: {}.bmp".format(i+1),self.calibration_image_dis[i])
    

    def display(self):
        self.extrinstic_pic_index = self.extrinstic_pic_combobox.currentIndex()+1
        print("extrinstic index", self.extrinstic_pic_index)
    
    def click_find_extrinstic(self):
        print("click_find_extrinstic")
        # print(np.add(self.calibration_image_r[i], self.calibration_image_t[i]))
        print("{} bmp image".format(self.extrinstic_pic_index))
        # print(self.calibration_image_r[self.extrinstic_pic_index-1])
        R, _ = cv2.Rodrigues(np.array(self.calibration_image_r[self.extrinstic_pic_index-1]))
        T = np.array(self.calibration_image_t[self.extrinstic_pic_index-1])[0]
        print("extrinstic")
        # print(R.shape)
        # print(R)
        # print(T.shape)
        # print(T)
        print(np.concatenate((R, T), axis=1))

    def load_Q2_img(self):
        print("load Q2 img")
        self.calibration_image = [0 for i in range(15)]
        for i in range(15):
            x = cv2.imread("Datasets/Q2_Image/{}.bmp".format(i+1))
            # x = cv2.resize(x, (1024, 1024), interpolation=cv2.INTER_AREA)
            self.calibration_image[i] = x

    def click_find_intrinstic(self):
        print("click find intrinstic")
        self.load_Q2_img()

        criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 30, 0.001)

        # f_pattern = open("config2.txt", "r")
        # s = ""
        # cor = []

        for i in range(15):
            #read pattern
            # s = f_pattern.readline()
            # cor = s.split(" ")
            # x = int(cor[0])
            # y = int(cor[1])
            objpoints = []
            imgpoints = []
            x = 8
            y = 11
            
            print("{} bmp image".format(i+1))


            objp = np.zeros((x*y,3), np.float32)
            objp[:,:2] = np.mgrid[0:y,0:x].T.reshape(-1,2)
            gray = cv2.cvtColor(self.calibration_image[i],cv2.COLOR_BGR2GRAY)

            # Find the chess board corners
            ret, corners = cv2.findChessboardCorners(gray,(y, x), None)

            # If found, add object points, image points (after refining them)
            if ret == True:
                objpoints.append(objp)

                corners2 = cv2.cornerSubPix(gray,corners,(11,11),(-1,-1),criteria)
                imgpoints.append(corners2)

                # Draw and display the corners
                # img = cv2.drawChessboardCorners(self.calibration_image[i], (y, x), corners2,ret)
                # cv2.imshow('img{}'.format(count),img)
                ret, mtx, dist, rvecs, tvecs = cv2.calibrateCamera(objpoints, imgpoints, gray.shape[::-1],None,None)
                print("Intristic")
                print(mtx)
                self.calibration_image_dis.append(dist)
                self.calibration_image_r.append(rvecs)
                self.calibration_image_t.append(tvecs)
            else:
                print("Error pattern in corner")

      

    def click_find_corner(self):
        print("click_find_corner")
        self.calibration_image = [i for i in range(15)]
        criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 30, 0.001)

        print(len(self.calibration_image))
        for i in range(15):
            self.calibration_image[i] = cv2.imread("Datasets/Q2_Image/{}.bmp".format(i+1))
            gray = cv2.cvtColor(self.calibration_image[i], cv2.COLOR_BGR2GRAY)
            #method 1
            # gray = np.float32(gray)
            # dst = cv2.cornerHarris(gray,5,3,0.04)
            # dst = cv2.dilate(dst,None)

            
            # # Threshold for an optimal value, it may vary depending on the image.
            # self.calibration_image[i][dst>0.01*dst.max()]=[0,0,255]
            # self.calibration_image[i] = cv2.resize(self.calibration_image[i], (1024, 1024), interpolation=cv2.INTER_AREA)

            # cv2.imshow("find corner{}".format(i+1),self.calibration_image[i])
        
            #method 2
            # Find the chess board corners
            imgpoints = []

            x = 8
            y = 11
            ret, corners = cv2.findChessboardCorners(gray,(y, x), None)
            if ret == True:
                corners2 = cv2.cornerSubPix(gray,corners,(11,11),(-1,-1),criteria)
                imgpoints.append(corners2)

                # Draw and display the corners
                img = cv2.drawChessboardCorners(self.calibration_image[i], (y, x), corners2,ret)
                img = cv2.resize(img, (1024, 1024), interpolation=cv2.INTER_AREA)
                cv2.imshow('imgcorner{}'.format(i+1),img)
        
 
        

    def click_count_countours_button(self):
        print("click_count_countours_button")
        self.num_coin1_label.setText("There are {} coins in coin1.png".format(self.num_coin1_countours))
        self.num_coin2_label.setText("There are {} coins in coin2.png".format(self.num_coin2_countours))
    
    def click_contour_button(self):
        print("click_contour_button")


        image = cv2.imread("Datasets/Q1_Image/coin01.jpg")
        gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        blurred_image = cv2.GaussianBlur(gray_image, (11, 11), 0)
        canny_image = cv2.Canny(blurred_image, 30, 150)

        ret, thresh = cv2.threshold(canny_image, 127, 255, cv2.THRESH_BINARY)
        
        binary, contours, hierarchy = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        self.num_coin1_countours = len(contours)
        cv2.drawContours(image, contours, -1, (0, 0, 255), 1)
        # cv2.imshow("1", binary)
        cv2.imshow("coin1", image)
        

        image2 = cv2.imread("Datasets/Q1_Image/coin02.jpg")
        gray_image = cv2.cvtColor(image2, cv2.COLOR_BGR2GRAY)
        blurred_image = cv2.GaussianBlur(gray_image, (11, 11), 0)
        canny_image = cv2.Canny(blurred_image, 30, 150)

        ret, thresh = cv2.threshold(canny_image, 127, 255, cv2.THRESH_BINARY)

        binary, contours, hierarchy = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        cv2.drawContours(image2, contours, -1, (0, 0, 255), 1)
        # cv2.imshow("1", binary)
        cv2.imshow("coin2", image2)

        self.num_coin2_countours = len(contours)





    
def main():
    app = QApplication(sys.argv)
    form = ExampleApp()

    form.show()
    app.exec_()




if __name__ == '__main__':
    main()