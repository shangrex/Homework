from torch.utils.data import DataLoader
import torch.utils.data as data
from torchvision import models
from torch.utils.data import DataLoader

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



def train():
    

