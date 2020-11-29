#include "Car.h"
#include <bits/stdc++.h>
using namespace std;
Car::Car(int x, int y, int way, int bs, float power){
    this->x = x;
    this->y = y;
    this->way = way;
    this->bs = bs;
    this->power = power;
    //speed
    this->speed[0][0] = 0;
    this->speed[0][1] = 10;
    this->speed[1][0] = 0;
    this->speed[1][1] = -10;
    this->speed[2][0] = -10;
    this->speed[2][1] = 0;
    this->speed[3][0] = 10;
    this->speed[2][1] = 0;
}
void Car::move(){
    switch(this->way){
        case 0:
            this->x += this->speed[0][0];
            this->y += this->speed[0][1];
            break;
        case 1:
            this->x += this->speed[1][0];
            this->y += this->speed[1][1];
            break;
        case 2:
            this->x += this->speed[2][0];
            this->y += this->speed[2][1];
            break;
        case 3:
            this->x += this->speed[3][0];
            this->y += this->speed[3][1];
            break;
        default:
            cout << "move wrong way" << endl;

        cout << this->x << " " <<  this->y << endl;

    }
}