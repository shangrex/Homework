from PyQt5 import QtCore, QtGui, QtWidgets
from PyQt5.QtWidgets import QApplication, QWidget, QPushButton
import sys
import UI
import cv2
import matplotlib.pyplot as plt
import numpy as np
from PIL import Image
import math
from numpy.fft import fft2, ifft2



class ExampleApp(QtWidgets.QMainWindow, UI.Ui_MainWindow):
    def __init__(self, parent=None):
        super(ExampleApp, self).__init__(parent)
        self.setupUi(self)
        self.load_button.clicked.connect(self.click_load_Button)
        self.seperate_button.clicked.connect(self.click_seperate_Button)
        self.flip_buuton.clicked.connect(self.click_flip_Button)
        self.blend_button.clicked.connect(self.click_blend_Button)
        #filter
        self.median_Button.clicked.connect(self.click_median_Button)
        self.gaussian_Button.clicked.connect(self.click_gaussian_Button)
        self.bilateral_Button.clicked.connect(self.click_bilateral_Button)
        #edge detection
        self.guassian_gray_Button.clicked.connect(self.click_guassian_gray_Button)
        self.sobelx_Button.clicked.connect(self.click_sobelx_Button)
        self.sobely_Button.clicked.connect(self.click_sobely_Button)
        self.magnitude_Button.clicked.connect(self.click_sobel_Button)
        self.ok_Button.clicked.connect(self.click_ok_Button)
        self.cancel_Button.clicked.connect(self.click_cancel_Button)
        #transformation
        self.transformation_Button.clicked.connect(self.click_transformation_Button)
        #define default image
        self.array = np.zeros(10)

    def click_transformation_Button(self):
        print("click_transformation_Button")
        self.img_parrot = cv2.imread('Dataset_opencvdl/Q4_Image/Parrot.png')
        # cv2.imshow("cool", self.img_parrot)
        width = self.img_parrot.shape[1]
        height = self.img_parrot.shape[0]
        print(self.img_parrot.shape)
        rotate = float(self.rotation_text.toPlainText())
        tx = float(self.tx_text.toPlainText())
        ty = float(self.ty_text.toPlainText())
        scale = float(self.scaling_text.toPlainText()) 
        square = np.float32([[1, 0, tx], [0, 1,  ty]])
        rot_mat = cv2.getRotationMatrix2D(tuple([width/2, height/2]), rotate, 1.0)
        move_parrot = cv2.warpAffine(self.img_parrot,square,(width,height))
        move_parrot = cv2.warpAffine(move_parrot,rot_mat,(width,height))
        move_parrot = cv2.resize(move_parrot,(int(scale*width),int(scale*height)),interpolation=cv2.INTER_CUBIC)
        cv2.imshow("Parrot image", move_parrot)

    def click_load_Button(self):
        print("click_load_Button")
        self.img_uncle = cv2.imread('Dataset_opencvdl/Q1_Image/Uncle_Roger.jpg')
        print("height", self.img_uncle.shape[0])
        print("width", self.img_uncle.shape[1])
        cv2.imshow("Uncle_Roger" , self.img_uncle)

    def click_seperate_Button(self):
        print("click_seperate_Button")
        self.img_flower = cv2.imread('Dataset_opencvdl/Q1_Image/Flower.jpg')
        print("height", self.img_flower.shape[0])
        print("width", self.img_flower.shape[1])
        print(self.img_flower.shape)
        cv2.imshow("original image", self.img_flower)
        b = self.img_flower.copy()
        # set green and red channels to 0
        b[:, :, 1] = 0
        b[:, :, 2] = 0
        cv2.imshow("blue image", b)
        g = self.img_flower.copy()
        # set blue and red channels to 0
        g[:, :, 0] = 0
        g[:, :, 2] = 0
        cv2.imshow("green image", g)

        r = self.img_flower.copy()
        # set blue and green channels to 0
        r[:, :, 0] = 0
        r[:, :, 1] = 0
        cv2.imshow("red image", r)

    def click_flip_Button(self):
        print("click_flip_Button")
        # img_uncle = cv2.imread('Dataset_opencvdl/Q1_Image/Uncle_Roger.jpg')
        # cv2.imshow("Uncle_Roger", self.img_uncle)
        self.img_uncle = cv2.imread('Dataset_opencvdl/Q1_Image/Uncle_Roger.jpg')
        self.img_uncle_flip = cv2.flip(self.img_uncle, 1)
        cv2.imshow("flipping image", self.img_uncle_flip)


    def Change_blend(self, x):
        # get current positions of four trackbars
        ra = x/255
        self.img_uncle_blend = cv2.addWeighted(self.img_uncle_flip, ra, self.img_uncle, 1-ra, 0.0)

        cv2.imshow('blending_image',self.img_uncle_blend)




    def click_blend_Button(self):
        print("click_blend_Button")
        self.img_uncle = cv2.imread('Dataset_opencvdl/Q1_Image/Uncle_Roger.jpg')
        self.img_uncle_flip = cv2.flip(self.img_uncle, 1)
        # self.img_uncle_blend = cv2.addWeighted(self.img_uncle_flip, 0.5, self.img_uncle, 0.5, 0.0)
        # cv2.imshow("blending image", self.img_uncle_blend)

        width = self.img_uncle.shape[0]
        height = self.img_uncle.shape[1]
        cv2.namedWindow("blending_image",  cv2.WINDOW_NORMAL)
        cv2.resizeWindow("blending_image", int(width+500), int(height+500));

        cv2.createTrackbar('trackbar_number','blending_image',0,255,self.Change_blend)


 
    def click_median_Button(self):
        print("click_median_Button")
        self.img_cat = cv2.imread('Dataset_opencvdl/Q2_Image/Cat.png')
        self.img_mblur_cat = cv2.medianBlur(self.img_cat, 7)
        cv2.imshow("median blur image", self.img_mblur_cat)
 
    def click_gaussian_Button(self):
        print("click_gaussian_Button")
        self.img_cat = cv2.imread('Dataset_opencvdl/Q2_Image/Cat.png')
        self.img_gblur_cat = cv2.GaussianBlur(self.img_cat,(3, 3), 1)
        cv2.imshow("gaussian blur image", self.img_gblur_cat)


    def click_bilateral_Button(self):
        print("click_bilateral_Button")
        self.img_cat = cv2.imread('Dataset_opencvdl/Q2_Image/Cat.png')
        self.img_bblur_cat = cv2.bilateralFilter(self.img_cat,9,90,90)
        cv2.imshow("bilateral blur image ", self.img_bblur_cat)

    def guassian_keranl(self):
        #3*3 Gassian filter
        x, y = np.mgrid[-1:2, -1:2]
        gk = np.exp(-(x**2+y**2))

        #Normalization
        gk = gk / gk.sum()

        return gk

    def click_guassian_gray_Button(self):
        print("click_guassian_gray_Button")
        self.img_chihiro = cv2.imread('Dataset_opencvdl/Q3_Image/Chihiro.jpg')
        self.img_chihiro = cv2.cvtColor(self.img_chihiro,cv2.COLOR_RGB2GRAY)
        gk = self.guassian_keranl()
        self.grad = self.convolution2d(self.img_chihiro, gk)
        self.array = self.grad

    def convolution2d(self, image, kernel):
        m, n = kernel.shape
        if (m == n):
            y, x = image.shape
            y = y - m + 1
            x = x - m + 1
            new_image = np.zeros((y,x))
            for i in range(y):
                for j in range(x):
                    new_image[i][j] = np.sum(image[i:i+m, j:j+m]*kernel)
        else:
            new_image = np.zeros((y, x))
        return new_image

    def click_sobelx_Button(self):
        self.click_guassian_gray_Button()
        self.fsx = np.array([[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]])
        self.sobelx = self.convolution2d(self.grad, self.fsx)
        self.solidx = cv2.normalize(self.sobelx, 0, 255, cv2.NORM_MINMAX)        
        self.array = np.array(self.solidx, np.uint8)

    def click_sobely_Button(self):
        self.click_guassian_gray_Button()
        self.fsy = np.array([[1, 2, 1], [0, 0, 0], [-1, -2, -1]])
        self.sobely = self.convolution2d(self.grad, self.fsy)
        self.solidy = cv2.normalize(self.sobely, 0, 255, cv2.NORM_MINMAX) 
        self.array = np.array(self.solidy, np.uint8)
    
    def click_sobel_Button(self):
        print("click_sobel_Button")
        self.click_sobely_Button()
        self.click_sobelx_Button()
        self.sobel = np.sqrt(np.fabs(np.add(np.square(self.sobelx),np.square(self.sobely))))
        # self.sobel = cv2.normalize(self.sobel, 0, 255, cv2.NORM_MINMAX) 
        self.array = np.array(self.sobel, np.uint8)
        
    def click_ok_Button(self):
        print("click_ok_Button")
        self.img = Image.fromarray(self.array)
        self.img.show()

    def click_cancel_Button(self):
        print("click_cancel_Button")
        self.img.close()

        
def main():
    app = QApplication(sys.argv)
    form = ExampleApp()

    form.show()
    app.exec_()




if __name__ == '__main__':
    main()