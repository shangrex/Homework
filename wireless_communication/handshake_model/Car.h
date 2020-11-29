using namespace std;
class Car{
    public:
    int x;
    int y;
    int way;
    int bs;
    float power;
    int speed[4][2];
    Car(int , int , int , int , float);
    void move();
};