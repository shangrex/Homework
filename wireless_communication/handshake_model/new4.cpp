#include <bits/stdc++.h>
using namespace std;


void initial(double bs[4][2], double lam[3], string all_policy[4], double speed[4][2]);
void exp(int total_time, double l, double bs[4][2], string policy, string exp_name, double speed[4][2]);
double sim_in();
char sim_way(char);
double distance(double x, double y, double bx, double by);
int time_scale = 1000; // 1 mili second
double get_random();
int get_tower(double , double , double[4][2]);
double get_strength(double , double, int, double[4][2]);

struct Car{
    double x;
    double y;
    char way;
    int bs;
    double power;
};

int main(int argc, char*argv[]){
    clock_t start, end; 
    //up down left right
    //0  1    2    3
    int total_time = stoi(argv[1]);
    string policy = argv[2];
    string exp_name = argv[3];
    //initial
    double bs[4][2];
    double lam[3];
    string all_policy[4];
    double speed[4][2];
    policy = "Best";
    initial(bs, lam, all_policy, speed);
    start = clock();
    for(int j = 0; j < 4; j++){
        for(int i = 0 ; i < 3; i++){
            exp(total_time, lam[i]/time_scale, bs, all_policy[j], exp_name, speed);
        }
    }
    double l = 0.5/time_scale;
    // exp(total_time ,l, bs, policy, exp_name, speed);
    end = clock();
    cout << "total execution time "<< (end-start)/CLOCKS_PER_SEC << " sec" << endl;

    return 0;
}



void initial(double bs[4][2], double lam[3], string all_policy[4], double speed[4][2]){
    //base station
    bs[0][0] = 360;//0
    bs[0][1] = 680;
    bs[1][0] = 330;//1
    bs[1][1] = 350;
    bs[2][0] = 660;//2
    bs[2][1] = 658;
    bs[3][0] = 640;//3
    bs[3][1] = 310;
    //lambda
    lam[0] = 0.5;
    lam[1] = 0.333333333;
    lam[2] = 0.2;

    //policy
    all_policy[0] = "Best";
    all_policy[1] = "Threshold";
    all_policy[2] = "Entropy";
    all_policy[3] = "my_policy";

    //speed
    speed[0][0] = 0;
    speed[0][1] = 10;
    speed[1][0] = 0;
    speed[1][1] = -10;
    speed[2][0] = -10;
    speed[2][1] = 0;
    speed[3][0] = 10;
    speed[3][1] = 0;
}

void exp(int total_time, double l, double bs[4][2], string policy, string exp_name, double speed[4][2]){
    fstream file_out(policy+to_string(l)+".csv", ios::out);
    vector<Car>car;
    // srand(time(NULL));
    cout << "lam " << l << endl;
    // l*=2;
    long long int total_handoff = 0;
    long long int handoff = 0;
    long double total_power = 0;
    long long int total_car = 0;
    int x = 0;
    for(int t = 0; t < total_time/time_scale; t++){
        // cout << car.size() << endl;
        for(int j = 0 ; j < time_scale; j++){
            for(int i = 1; i < 10; i++){
                //car
                //x_pos , y_pos, way, bs, power
                if(sim_in() <= l){
                    Car c;
                    c.x = double(i*100);
                    c.y = 0;
                    c.way = 'd';
                    c.bs = get_tower(c.x, c.y, bs);
                    c.power = get_strength(c.x, c.y, c.bs, bs);
                    car.push_back(c);
                    x++;
                }
                if(sim_in() <= l){
                    Car c;
                    c.x = double(i*100);
                    c.y = 1000;
                    c.way = 'u';
                    c.bs = get_tower(c.x, c.y, bs);
                    c.power = get_strength(c.x, c.y, c.bs, bs);
                    car.push_back(c);
                    x++;
                } 
                if(sim_in() <= l){
                    Car c;
                    c.x = 1000;
                    c.y = double(i*100);
                    c.way = 'l';
                    c.bs = get_tower(c.x, c.y, bs);
                    c.power = get_strength(c.x, c.y, c.bs, bs);
                    car.push_back(c);
                    x++;
                }
                if(sim_in() <= l){
                    Car c;
                    c.x = 0;
                    c.y = double(i*100);
                    c.way = 'r';
                    c.bs = get_tower(c.x, c.y, bs);
                    c.power = get_strength(c.x, c.y, c.bs, bs);
                    car.push_back(c);
                    x++;
                }
            }
        }
        // cout << x / (t+1) << endl;
        if(policy == "Best"){
            // cout << "Best policy" << endl;
            for(int i = 0; i < car.size(); i++){
                int old_bs = car[i].bs;
                double max_p = 0;
                int max_bs = 0;
                for(int j = 0; j < 4; j++){
                    double d = distance(car[i].x, car[i].y, bs[j][0], bs[j][1]);
                    double p = 67-20*log10(d);
                    if(max_p <= p){
                        max_p = p;
                        max_bs = j;
                    }
                }
                car[i].bs = max_bs;
                car[i].power = max_p;
                if(car[i].bs != old_bs){
                    handoff ++;
                }
                // cout << car[i].x << " " << car[i].y <<  " " << car[i].bs << " "<< car[i].power << " " <<car[i].power << endl;

            }
        }
        else if(policy == "Threshold"){
            double threshold = 15;
            for(int i = 0; i < car.size(); i++){
                int old_bs = car[i].bs;
                double max_p = 0;
                int max_bs = 0;
                bool check = false;
                for(int j = 0; j < 4; j++){
                    double d = distance(car[i].x, car[i].y, bs[j][0], bs[j][1]);
                    double p = 67 - 20*log10(d);
                    if(p >= max_p && car[i].power <= threshold){
                        max_p = p;
                        max_bs = j;
                        check = true;
                    }
                }
                if(check){
                    car[i].bs = max_bs;
                    car[i].power = max_p;
                }
                else{
                    car[i].power = get_strength(car[i].x, car[i].y, car[i].bs, bs);
                }
                if(car[i].bs != old_bs){
                    handoff ++;
                }
            }
        }
        else if (policy == "Entropy"){
            double entropy = 11;
            for(int i = 0; i < car.size(); i++){
                int old_bs = car[i].bs;
                double max_p = 0;
                int max_bs = 0;
                bool check = false;
                for(int j = 0; j < 4; j++){
                    double d = distance(car[i].x, car[i].y, bs[j][0], bs[j][1]);
                    double p = 67 - 20*log10(d);
                    if(p - car[i].power > entropy && p >= max_p){
                        max_p = p;
                        max_bs = j;
                        check = true;
                    }
                }
                if(check){
                    car[i].bs = max_bs;
                    car[i].power = max_p;
                }
                else{
                    car[i].power = get_strength(car[i].x, car[i].y, car[i].bs, bs);
                }
                if(car[i].bs != old_bs){
                    handoff ++;
                }
            }
        }
        else {
            //my policy
            double entropy = 12;
            double threshold = 19.7;
            for(int i = 0; i < car.size(); i++){
                int old_bs = car[i].bs;
                double max_p = 0;
                int max_bs = 0;
                bool check = false;
                for(int j = 0; j < 4; j++){
                    double d = distance(car[i].x, car[i].y, bs[j][0], bs[j][1]);
                    double p = 67 - 20*log10(d);
                    if(p - car[i].power > entropy && p >= max_p && car[i].power < threshold){
                        max_p = p;
                        max_bs = j;
                        check = true;
                    }
                }
                if(check){
                    car[i].bs = max_bs;
                    car[i].power = max_p;
                }
                else{
                    car[i].power = get_strength(car[i].x, car[i].y, car[i].bs, bs);
                }
                if(car[i].bs != old_bs){
                    handoff ++;
                }
            }
        
        }
        
        for(int i = car.size()-1; i >= 0; i--){
            //car move
            // cout << "before " << car[i].x << " " << car[i].y << endl; 
            if(car[i].x <= 1005 && car[i].x >= -5 && car[i].y <= 1005 && car[i].y >= -5){
                //select way
                if(fmod(car[i].x, 100) == 0 && fmod(car[i].y, 100) == 0){
                    // cout << "turn " << car[i].x << " " << car[i].y << endl; 
                    car[i].way = sim_way(car[i].way);
                }
                // if((int)car[i].x % 100 == 0 && (int)car[i].y % 100 == 0 
                //     && car[i].x - (int)car[i].x == 0 && car[i].y - (int)car[i].y == 0){
                //     // cout << "turn " << car[i].x << " " << car[i].y << " " << car[i].way << endl; 
                //     car[i].way = sim_way(car[i].way);
                // }
                if(car[i].way == 'u'){
                    //up
                    car[i].x += (double)0.0;
                    car[i].y -= (double)10.0;
                }
                else if(car[i].way == 'd'){
                    //down
                    car[i].x += (double)0.0;
                    car[i].y += (double)10.0;
                }
                else if(car[i].way == 'l'){
                    //left
                    car[i].x -= (double)10.0;
                    car[i].y += (double)0.0;
                }
                else if(car[i].way == 'r'){
                    //right
                    car[i].x += (double)10;
                    car[i].y += (double)0.0;
                }
            }
            else {
                car.erase(car.begin()+i);                
            }
        }

        //add
        total_car += car.size();
        for(int i = 0 ; i < car.size(); i++){
            total_power += car[i].power;
        } 
        file_out << handoff << '\n';
        // cout << "handoff" << handoff << endl;
        total_handoff += handoff;
        handoff = 0;
        // cout << "Avg power " << total_power / (double) total_car << endl;
    
        
    }
    cout << policy << endl;
    cout  << total_time/time_scale << endl;
    cout << "total handoff " << total_handoff << endl;
    cout << "Avg handoff " << total_handoff / (total_time/time_scale) << endl;
    cout << "Avg power " << total_power / (double) total_car << endl;
}

double sim_in(){
    return  (double)rand()/RAND_MAX;
}
double get_random(){
    return (double)rand()/RAND_MAX;
}

char sim_way(char way){
    double select = (double)rand()/RAND_MAX;
    if(way == 'u'){
        if(select <= 0.6){
            return 'u';
        }
        else if(select <= 0.8){
            return 'l';
        }
        else{
            return 'r';
        }
    }
    else if(way == 'd'){
        if(select <= 0.6){
            return 'd';
        }
        else if(select <= 0.8){
            return 'l';
        }
        else {
            return 'r';
        }

    }
    else if(way == 'l'){
        if(select <= 0.6){
            return 'l';
        }
        else if(select <= 0.8){
            return 'u';
        }
        else {
            return 'd';
        }
    }
    else{
        if(select <= 0.6){
            return 'r';
        }
        else if(select <= 0.8){
            return 'u';
        }
        else {
            return 'd';
        }
    }
}


double distance(double x, double y, double bx, double by){
    return (double)sqrt((double)(x-bx)*(double)(x-bx) + (double)(y-by)*(double)(y-by));
}


int get_tower(double x, double y, double bs[4][2]){
    // cout << x << " " << y << " ";
    int min_m = 0;
    double d_c = 1000;
    for(int i = 0; i < 4; i++){
        double d = distance(x, y ,bs[i][0], bs[i][1]);
        if(d_c > d){
            d_c = d;
            min_m = i;
        }
    }
    // cout << min_m << endl;
    return min_m;
}

double get_strength(double x, double y , int i_bs, double bs[4][2]){
    double d = distance(x, y, bs[i_bs][0], bs[i_bs][1]);
    return 67-20*log10(d);
}