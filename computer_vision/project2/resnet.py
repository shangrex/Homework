import os
import time
import torch.nn as nn
import torch
import torch.utils.data
import torchvision.transforms as transforms
from PIL import Image
from matplotlib import pyplot as plt
import torchvision.models as models
import torchvision
import pandas as pd 
from sklearn.model_selection import train_test_split
from include import CatDogDataset
from torch.utils.data import Dataset, DataLoader, ConcatDataset
import numpy as np
from tqdm import tqdm
from torch.utils.tensorboard import SummaryWriter
import cv2



def resnet_train(epoch = 10):

    #load model
    model = torch.hub.load('pytorch/vision:v0.6.0', 'resnet50')
    model.fc = nn.Linear(2048, 2)
    # print(model)

    #load training data in PetImages
    #cat is 0, dog is 1
    # label = []
    # path = "Datasets/Q5_ASIRRA/PetImages/Cat/"
    # file_name = os.listdir(path)
    # file_name_tmp = []
    # for i in file_name:
    #     i = path + i
    #     if 'jpg' not in i:
    #         continue
    #     file_name_tmp.append(i)
    #     label.append(0)
    # file_name = file_name_tmp
    # path = "Datasets/Q5_ASIRRA/PetImages/Dog/"
    # file_name_tmp = os.listdir(path)
    # for i in file_name_tmp:
    #     i = path + i
    #     if 'jpg' not in i:
    #         continue
    #     file_name.append(i)
    #     label.append(1)
    # print(len(file_name))
    # print(len(label))
    # data_frame = pd.DataFrame() 
    # data_frame['file_name'] = file_name
    # data_frame['label'] = label
    # print(data_frame.head())
    # print(data_frame.tail())

    #load data set in train
    path = "Datasets/Q5_ASIRRA/train"
    file_name = os.listdir(path)
    print("kaggle", len(file_name))

    #transforms
    data_transform = transforms.Compose([
        transforms.Resize(256),
        transforms.ColorJitter(),
        transforms.RandomCrop(224),
        transforms.RandomHorizontalFlip(),
        transforms.Resize(128),
        transforms.ToTensor()
    ])
    train_file_name , test_file_name = train_test_split(file_name, test_size=0.2, random_state=42)
    train_file_name , valid_file_name = train_test_split(train_file_name, test_size=0.2, random_state=42)
    print("train ", len(train_file_name))
    print("test ", len(test_file_name))
    print("valid ", len(valid_file_name))
    cat_files = [tf for tf in file_name if 'cat' in tf]
    dog_files = [tf for tf in file_name if 'dog' in tf]

    train_cat_files = [tf for tf in train_file_name if 'cat' in tf]
    train_dog_files = [tf for tf in train_file_name if 'dog' in tf]
    test_cat_files = [tf for tf in test_file_name if 'cat' in tf]
    test_dog_files = [tf for tf in test_file_name if 'dog' in tf]
    valid_cat_files = [tf for tf in valid_file_name if 'cat' in tf]
    valid_dog_files = [tf for tf in valid_file_name if 'dog' in tf]

    cats = CatDogDataset(cat_files, path, transform = data_transform)
    dogs = CatDogDataset(dog_files, path, transform = data_transform)
    catdogs = ConcatDataset([cats, dogs])

    train_cats = CatDogDataset(train_cat_files, path, transform = data_transform)
    train_dogs = CatDogDataset(train_dog_files, path, transform = data_transform)
    train_catdogs = ConcatDataset([train_cats, train_dogs])

    test_cats = CatDogDataset(test_cat_files, path, transform = data_transform)
    test_dogs = CatDogDataset(test_dog_files, path, transform = data_transform)
    test_catdogs = ConcatDataset([test_cats, test_dogs])

    valid_cats = CatDogDataset(valid_cat_files, path, transform = data_transform)
    valid_dogs = CatDogDataset(valid_dog_files, path, transform = data_transform)
    valid_catdogs = ConcatDataset([valid_cats, valid_dogs])

    dataloader = DataLoader(catdogs, batch_size = 32, shuffle=True, num_workers=4)
    train_dataloader = DataLoader(train_catdogs, batch_size = 32, shuffle=True, num_workers=4)
    test_dataloader = DataLoader(test_catdogs, batch_size = 32, shuffle=True, num_workers=4)
    valid_dataloader = DataLoader(valid_catdogs, batch_size = 32, shuffle=True, num_workers=4)

    # test
    # samples, labels = iter(dataloader).next()
    # plt.figure(figsize=(16,24))
    # grid_imgs = torchvision.utils.make_grid(samples[:24])
    # np_grid_imgs = grid_imgs.numpy()
    # # in tensor, image is (batch, width, height), so you have to transpose it to (width, height, batch) in numpy to show it.
    # plt.imshow(np.transpose(np_grid_imgs, (1,2,0)))
    # plt.show()


    #data preprocess
    # for i in file_name:
    #     try:
    #         input_image = Image.open(i)
    #         input_tensor = preprocess(input_image)
    #         input_batch = input_tensor.unsqueeze(0)
    #         train_data.append(input_batch)
    #     except Exception:
    #         print("cannot identify image file", i)

    # train
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    model = model.to(device)

    optimizer = torch.optim.Adam(model.parameters(), lr=0.002, amsgrad=True)
    criterion = nn.CrossEntropyLoss()


    writer = SummaryWriter('runs/resnet50_exp2')

    count_dataloader = 0
    sum_correct_images = 0
    for e in tqdm(range(epoch)):
        total_loss = 0
        total_images = 0
        total_correct_images = 0   
        total_loss_count = 0 
        valid_correct_images = 0
        total_valid_images = 0
        for train_data, train_target in train_dataloader:
            model.train()
            correct_images = 0
            count_dataloader += 1
            total_loss_count += 1
            train_data = train_data.to(device)
            train_target = train_target.to(device)
            optimizer.zero_grad()

            output = model(train_data)
            loss = criterion(output, train_target)
            loss.backward()
            optimizer.step()
            total_loss += loss.item()
            predict = torch.argmax(output.data, dim=1)
            correct_images = (predict == train_target).sum().item()
            total_correct_images += correct_images
            total_images += 32
            # print(loss.item())
            # writer.add_scalar('accuracy',
            #         100 * correct_images / 32,
            #         count_dataloader+1)
            # writer.add_scalar('training loss',
            #         loss.item(),
            #         (count_dataloader+1))
        #valid eval
        model.eval()
        for valid_data, valid_target in valid_dataloader:
            valid_data = valid_data.to(device)
            valid_target = valid_target.to(device)
            predict = model(valid_data)
            predict = torch.argmax(output.data, dim=1)
            valid_correct_images += (predict == train_target).sum().item()
            total_valid_images += 32

        writer.add_scalar('accuracy',
                100 * total_correct_images / total_images,
                (e+1))
        writer.add_scalar('training loss',
                total_loss/total_loss_count,
                (e+1))
        
        print("epoch ", e)
        print("epoch train loss ", total_loss/total_loss_count)
        print("training accuracy {} %".format(100 * total_correct_images / total_images))
        print("valid accuracy {} %".format(100 * valid_correct_images / total_valid_images))
    torch.save(model.state_dict(), os.path.join(os.path.dirname(os.path.abspath(__file__)),'Datasets/Q5_ASIRRA/PetImages/resnet50.pth'))
    writer.flush()
    writer.close()


def resnet_show():
    path = "Datasets/Q5_ASIRRA/train"
    file_name = os.listdir(path)
    #transforms
    data_transform = transforms.Compose([
        transforms.Resize(256),
        transforms.ColorJitter(),
        transforms.RandomCrop(224),
        transforms.RandomHorizontalFlip(),
        transforms.Resize(128),
        transforms.ToTensor()
    ])
    cat_files = [tf for tf in file_name if 'cat' in tf]
    dog_files = [tf for tf in file_name if 'dog' in tf]
    cats = CatDogDataset(cat_files, path, transform = data_transform)
    dogs = CatDogDataset(dog_files, path, transform = data_transform)
    catdogs = ConcatDataset([cats, dogs])
    dataloader = DataLoader(catdogs, batch_size = 32, shuffle=True, num_workers=4)

    model = torch.hub.load('pytorch/vision:v0.6.0', 'resnet50')
    model.fc = nn.Linear(2048, 2)
    model.load_state_dict(torch.load(os.path.join(os.path.dirname(os.path.abspath(__file__)),'Datasets/Q5_ASIRRA/PetImages/resnet50.pth')))

    # get some random training images
    dataiter = iter(dataloader)
    images, labels = dataiter.next()
    # plt.axis("off")
    plt.imshow(np.transpose(images[0], (1, 2, 0)))
    # plt.imshow(cv2.cvtColor(images[0], cv2.COLOR_BGR2RGB))
    predict = model(images)
    predict = torch.argmax(predict.data, dim=1)

    if predict[0] == 0:
        plt.title("Cat")
    else:
        plt.title("Dog")
    plt.show()


def resnet_test():
    origin_accuracy  = 78.7625
    resize_accuracy = 79.13333333333334
    plt.ylim(75, 80)
    y = [origin_accuracy, resize_accuracy]
    x = ['before resize', 'after resize']
    plt.bar(x, y)
    plt.show()



def resnet_resize_train(epoch = 10):
  #load model
    model = torch.hub.load('pytorch/vision:v0.6.0', 'resnet50')
    model.fc = nn.Linear(2048, 2)
    # print(model)

    #load training data in PetImages
    #cat is 0, dog is 1
    # label = []
    # path = "Datasets/Q5_ASIRRA/PetImages/Cat/"
    # file_name = os.listdir(path)
    # file_name_tmp = []
    # for i in file_name:
    #     i = path + i
    #     if 'jpg' not in i:
    #         continue
    #     file_name_tmp.append(i)
    #     label.append(0)
    # file_name = file_name_tmp
    # path = "Datasets/Q5_ASIRRA/PetImages/Dog/"
    # file_name_tmp = os.listdir(path)
    # for i in file_name_tmp:
    #     i = path + i
    #     if 'jpg' not in i:
    #         continue
    #     file_name.append(i)
    #     label.append(1)
    # print(len(file_name))
    # print(len(label))
    # data_frame = pd.DataFrame() 
    # data_frame['file_name'] = file_name
    # data_frame['label'] = label
    # print(data_frame.head())
    # print(data_frame.tail())

    #load data set in train
    path = "Datasets/Q5_ASIRRA/trainresize"
    file_name = os.listdir(path)
    print("kaggle", len(file_name))

    #transforms
    data_transform = transforms.Compose([
        transforms.Resize(256),
        transforms.ColorJitter(),
        transforms.RandomCrop(224),
        transforms.RandomHorizontalFlip(),
        transforms.Resize(128),
        transforms.ToTensor()
    ])
    train_file_name , test_file_name = train_test_split(file_name, test_size=0.2, random_state=42)
    train_file_name , valid_file_name = train_test_split(train_file_name, test_size=0.2, random_state=42)
    print("train ", len(train_file_name))
    print("test ", len(test_file_name))
    print("valid ", len(valid_file_name))

    cat_files = [tf for tf in file_name if 'cat' in tf]
    dog_files = [tf for tf in file_name if 'dog' in tf]


    train_cat_files = [tf for tf in train_file_name if 'cat' in tf]
    train_dog_files = [tf for tf in train_file_name if 'dog' in tf]
    test_cat_files = [tf for tf in test_file_name if 'cat' in tf]
    test_dog_files = [tf for tf in test_file_name if 'dog' in tf]
    valid_cat_files = [tf for tf in valid_file_name if 'cat' in tf]
    valid_dog_files = [tf for tf in valid_file_name if 'dog' in tf]

    cats = CatDogDataset(cat_files, path, transform = data_transform)
    dogs = CatDogDataset(dog_files, path, transform = data_transform)
    catdogs = ConcatDataset([cats, dogs])

    train_cats = CatDogDataset(train_cat_files, path, transform = data_transform)
    train_dogs = CatDogDataset(train_dog_files, path, transform = data_transform)
    train_catdogs = ConcatDataset([train_cats, train_dogs])

    test_cats = CatDogDataset(test_cat_files, path, transform = data_transform)
    test_dogs = CatDogDataset(test_dog_files, path, transform = data_transform)
    test_catdogs = ConcatDataset([test_cats, test_dogs])

    valid_cats = CatDogDataset(valid_cat_files, path, transform = data_transform)
    valid_dogs = CatDogDataset(valid_dog_files, path, transform = data_transform)
    valid_catdogs = ConcatDataset([valid_cats, valid_dogs])

    dataloader = DataLoader(catdogs, batch_size = 32, shuffle=True, num_workers=4)
    train_dataloader = DataLoader(train_catdogs, batch_size = 32, shuffle=True, num_workers=4)
    test_dataloader = DataLoader(test_catdogs, batch_size = 32, shuffle=True, num_workers=4)
    valid_dataloader = DataLoader(valid_catdogs, batch_size = 32, shuffle=True, num_workers=4)

    # test
    # samples, labels = iter(dataloader).next()
    # plt.figure(figsize=(16,24))
    # grid_imgs = torchvision.utils.make_grid(samples[:24])
    # np_grid_imgs = grid_imgs.numpy()
    # # in tensor, image is (batch, width, height), so you have to transpose it to (width, height, batch) in numpy to show it.
    # plt.imshow(np.transpose(np_grid_imgs, (1,2,0)))
    # plt.show()


    #data preprocess
    # for i in file_name:
    #     try:
    #         input_image = Image.open(i)
    #         input_tensor = preprocess(input_image)
    #         input_batch = input_tensor.unsqueeze(0)
    #         train_data.append(input_batch)
    #     except Exception:
    #         print("cannot identify image file", i)

    # train
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    model = model.to(device)

    optimizer = torch.optim.Adam(model.parameters(), lr=0.002, amsgrad=True)
    criterion = nn.CrossEntropyLoss()


    writer = SummaryWriter('runs/resnet50_expresize')

    count_dataloader = 0
    sum_correct_images = 0
    for e in tqdm(range(epoch)):
        total_loss = 0
        total_images = 0
        total_correct_images = 0   
        total_loss_count = 0 
        valid_correct_images = 0
        total_valid_images = 0
        for train_data, train_target in train_dataloader:
            model.train()
            correct_images = 0
            count_dataloader += 1
            total_loss_count += 1
            train_data = train_data.to(device)
            train_target = train_target.to(device)
            optimizer.zero_grad()

            output = model(train_data)
            loss = criterion(output, train_target)
            loss.backward()
            optimizer.step()
            total_loss += loss.item()
            predict = torch.argmax(output.data, dim=1)
            correct_images = (predict == train_target).sum().item()
            total_correct_images += correct_images
            total_images += 32
            # print(loss.item())
            # writer.add_scalar('accuracy',
            #         100 * correct_images / 32,
            #         count_dataloader+1)
            # writer.add_scalar('training loss',
            #         loss.item(),
            #         (count_dataloader+1))
        #valid eval
        model.eval()
        for valid_data, valid_target in valid_dataloader:
            valid_data = valid_data.to(device)
            valid_target = valid_target.to(device)
            predict = model(valid_data)
            predict = torch.argmax(output.data, dim=1)
            valid_correct_images += (predict == train_target).sum().item()
            total_valid_images += 32

        writer.add_scalar('accuracy',
                100 * total_correct_images / total_images,
                (e+1))
        writer.add_scalar('training loss',
                total_loss/total_loss_count,
                (e+1))
        
        print("epoch ", e)
        print("epoch train loss ", total_loss/total_loss_count)
        print("training accuracy {} %".format(100 * total_correct_images / total_images))
        print("valid accuracy {} %".format(100 * valid_correct_images / total_valid_images))
    torch.save(model.state_dict(), os.path.join(os.path.dirname(os.path.abspath(__file__)),'Datasets/Q5_ASIRRA/PetImages/resnet50resize.pth'))
    writer.flush()
    writer.close()