import torch.utils.data as data
from torchvision import models
from torch.utils.data import DataLoader
import torch.nn as nn
import numpy as np
import torch
from torch.autograd import Variable
import os
from torch.utils.tensorboard import SummaryWriter

class Data(data.Dataset):
    def __init__(self, feature, label):
        self.feature = feature
        self.label = label
    def __len__(self):
        return len(self.feature)
    def __getitem__(self, idx):
        return self.feature[idx], self.label[idx]


class vgg(nn.Module):
    def __init__(self):
        super(VGG, self).__init__()
        self.feature = models.vgg16()
        # self.features = self.nn.Sequential(
        #     nn.Conv2d(2, 32, 3, padding=1)
        #     ,nn.Relu(True)
        #     ,nn.Conv2d(32, 32, 3, padding=1)
        #     ,nn.Relu(True)
        #     ,nn.MaxPool2d(2, 2)
        #     ,nn.Conv2d(32, 64, 3, padding=1)
        #     ,nn.ReLU(True)
        #     ,nn.Conv2d(64, 64, 3, padding=1)
        #     ,nn.ReLU(True)
        #     ,nn.MaxPool2d(2, 2)
        #     ,nn.Conv2d(64, 128, 3, padding=1)
        #     ,nn.ReLU(True)
        #     ,nn.Conv2d(128, 128, 3, padding=1)
        #     ,nn.ReLU(True)
        #     ,nn.Conv2d(128, 128, 3, padding=1)
        #     ,nn.ReLU(True)
        #     ,nn.MaxPool2d(2, 2)
        #     ,nn.Conv2d(128, 256, 3, padding=1)
        #     ,nn.ReLU(True)
        #     ,nn.Conv2d(256, 256, 3, padding=1)
        #     ,nn.ReLU(True)
        #     ,nn.Conv2d(256, 256, 3, padding=1)
        #     ,nn.ReLU(True)
        #     ,nn.MaxPool2d(2, 2)
        #     ,nn.Conv2d(256, 256, 3, padding=1)
        #     ,nn.ReLU(True)
        #     ,nn.Conv2d(256, 256, 3, padding=1)
        #     ,nn.ReLU(True)
        #     ,nn.Conv2d(256, 256, 3, padding=1)
        #     ,nn.ReLU(True)
        # )

        self.classifier = nn.Sequential(
            nn.Linear(2 * 2 * 256, 512)
            ,nn.ReLU(True)
            ,nn.Dropout()
            ,nn.Linear(512, 512)
            ,nn.ReLU(True)
            ,nn.Dropout()
            ,nn.Linear(512, 10)
        )
        
    def foward(self, x):
        x = self.features(x)
        x = x.view(x.size(0), -1)
        x = self.classifier(x)
        return x



def train(trainloader, batch_size, lr, optimizer, epoch):
    writer = SummaryWriter('runs/cifar_experiment_30')

    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    print("device", device)
    model = models.vgg16()
    model.classifier._modules['6'] = nn.Linear(in_features=4096, out_features=10, bias=True)


    model.to(device)
    print(model)
    if optimizer == "SGD":
        optimizer = torch.optim.SGD(model.parameters(), lr=lr)
    elif optimizer == "Adam":
        optimizer = torch.optim.Adam(model.parameters(), lr=lr)
    critierion = nn.CrossEntropyLoss()

    loss_p = np.array([])
    total_images = 0

    #can delete
    correct_images = 0
    running_loss = 0
    count = 0


    for e in range(epoch):
        print("epoch", e)
        for i, data in enumerate(trainloader, 0):
            images, labels = data
            count += 1
            images = Variable(images.to(device))
            labels = Variable(labels.to(device))
            
            optimizer.zero_grad()
            outputs = model(images)
            _, predicts = torch.max(outputs.data, 1)

            loss = critierion(outputs, labels)

            loss.backward()


            optimizer.step()

            total_images += labels.size(0)
            correct_images += (predicts == labels).sum().item()
            loss_data = loss.data.item()
            running_loss += loss_data
            
        # if i % 2000 == 1999:
        print('Epoch,  %5d loss: %.6f, Training accuracy: %.5f' %
                (e + 1, running_loss / count, 100 * correct_images / total_images))
        print("count", count)
        acc = 100 * correct_images / total_images

        writer.add_scalar('accuracy',
                100 * correct_images / total_images,
                e+1)
        writer.add_scalar('training loss',
                running_loss/count,
                (e+1))
        loss_p = np.append(loss_p, running_loss/count)
        total_images = 0
        correct_images = 0
        count = 0
        running_loss = 0

    print("load save to ", os.path.join(os.path.dirname(os.path.abspath(__file__)),'data/vgg16.pth'))
    torch.save(model.state_dict(), os.path.join(os.path.dirname(os.path.abspath(__file__)),'data/vgg16.pth'))
    writer.flush()
    writer.close()
    print("average loss", loss_p.mean())
    return acc

def test(testloader, classes, choose_index):
    model = models.vgg16()
    print("load model to ", os.path.join(os.path.dirname(os.path.abspath(__file__)),'data/vgg16.pth'))
    model.load_state_dict(torch.load(os.path.join(os.path.dirname(os.path.abspath(__file__)),'data/vgg16.pth')))

    

