#include <bits/stdc++.h>
using namespace std;


void initial(double bs[4][2], double lam[3], string all_policy[4], double speed[4][2]);
void exp(int total_time, double l, double bs[4][2], string policy, string exp_name, double speed[4][2]);
double sim_in();
int sim_way(int);
double distance(double x, double y, double bx, double by);
int time_scale = 1000; // 1 mili second
double get_random();

struct Car{
    double x;
    double y;
    int way;
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
    for(int i = 0 ; i < 4; i++){
        //exp(total_time, lam[i]/time_scale, bs, policy, exp_name, speed);
    }
    double l = 0.5/time_scale;
    start = clock();
    exp(total_time ,l, bs, policy, exp_name, speed);
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
                    c.way = 1;
                    c.bs = 1;
                    c.power = 0.0;
                    car.push_back(c);
                    x++;
                }
                if(sim_in() <= l){
                    Car c;
                    c.x = double(i*100);
                    c.y = 1000;
                    c.way = 0;
                    c.bs = 1;
                    c.power = 0.0;
                    car.push_back(c);
                    x++;
                } 
                if(sim_in() <= l){
                    Car c;
                    c.x = 1000;
                    c.y = double(i*100);
                    c.way = 2;
                    c.bs = 1;
                    c.power = 0.0;
                    car.push_back(c);
                    x++;
                }
                if(sim_in() <= l){
                    Car c;
                    c.x = 0;
                    c.y = double(i*100);
                    c.way = 3;
                    c.bs = 0;
                    c.power = 0.0;
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
                for(int j = 0; j < 4; j++){
                    double d = distance(car[i].x, car[i].y, bs[j][0], bs[j][1]);
                    double p = 100-33-20*log10(d);
                    if(car[i].power < p){
                        car[i].power = p;
                        car[i].bs = j;
                    }
                }
                if(car[i].bs != old_bs){
                    handoff ++;
                }
            }
        }
        else if(policy == "Worst"){
            float threshold = 10.0;
            for(int i = 0; i < car.size(); i++){
                int old_bs = car[i].bs;
                for(int j = 0; j < 4; j++){
                    double d = distance(car[i].x, car[i].y, bs[j][0], bs[j][1]);
                    double p = 67 - 20*log10(d);
                    if(p > car[i].power && car[i].power < threshold){
                        car[i].power = p;
                        car[i].bs = j;
                    }
                }
                if(car[i].bs != old_bs){
                    handoff ++;
                }
            }
        }
        else if (policy == "Entropy"){
            double entropy = 5;
            for(int i = 0; i < car.size(); i++){
                int old_bs = car[i].bs;
                for(int j = 0; j < 4; j++){
                    double d = distance(car[i].x, car[i].y, bs[j][0], bs[j][1]);
                    double p = 67 - 20*log10(d);
                    if(p - car[i].power > entropy){
                        car[i].power = p;
                        car[i].bs = j;
                    }
                }
                if(car[i].bs != old_bs){
                    handoff ++;
                }
            }
        }
        else {
            //my policy
            double entropy = 5;
            double threshold = 15;
            for(int i = 0; i < car.size(); i++){
                int old_bs = car[i].bs;
                for(int j = 0; j < 4; j++){
                    double d = distance(car[i].x, car[i].y, bs[j][0], bs[j][1]);
                    double p = 67 - 20*log10(d);
                    if(p - car[i].power > entropy && car[i].power < threshold){
                        car[i].power = p;
                        car[i].bs = j;
                    }
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
                // if(fmod(car[i].x, 100) == 0 && fmod(car[i].y, 100) == 0){
                //     // cout << "turn " << car[i].x << " " << car[i].y << endl; 
                //     car[i].way = sim_way(car[i].way);
                // }
                if((int)car[i].x % 100 == 0 && (int)car[i].y % 100 == 0){
                    // cout << "turn " << car[i].x << " " << car[i].y << " " << car[i].way << endl; 
                    car[i].way = sim_way(car[i].way);
                }
                if(car[i].way == 0){
                    //up
                    car[i].x += (double)0.0;
                    car[i].y += (double)10.0;
                }
                else if(car[i].way == 1){
                    //down
                    car[i].x += (double)0.0;
                    car[i].y -= (double)10.0;
                }
                else if(car[i].way == 2){
                    //left
                    car[i].x -= (double)10.0;
                    car[i].y += (double)0.0;
                }
                else if(car[i].way == 3){
                    //right
                    car[i].x += (double)0;
                    car[i].y += (double)10.0;
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
// int sim_way(int way){
//     double select = (double)rand()/RAND_MAX;
//     if(way == 0){
//         if(get_random() <= 0.6){
//             return 0;
//         }
//         else if(get_random() <= 0.8 && get_random() >= 0.6){
//             return 2;
//         }
//         else{
//             return 3;
//         }
//     }
//     else if(way == 1){
//         if(get_random() <= 0.6){
//             return 1;
//         }
//         else if(get_random() <= 0.8 && get_random() >= 0.6){
//             return 2;
//         }
//         else {
//             return 3;
//         }

//     }
//     else if(way == 2){
//         if(get_random() <= 0.6){
//             return 2;
//         }
//         else if(get_random() <= 0.8 && get_random() >= 0.6){
//             return 0;
//         }
//         else {
//             return 1;
//         }
//     }
//     else{
//         if(get_random() <= 0.6){
//             return 3;
//         }
//         else if(get_random() <= 0.8 && get_random() >= 0.6){
//             return 0;
//         }
//         else {
//             return 1;
//         }
//     }
// }

int sim_way(int way){
    double select = (double)rand()/RAND_MAX;
    if(way == 0){
        if(select <= 0.6){
            return 0;
        }
        else if(select <= 0.8){
            return 2;
        }
        else{
            return 3;
        }
    }
    else if(way == 1){
        if(select <= 0.6){
            return 1;
        }
        else if(select <= 0.8){
            return 2;
        }
        else {
            return 3;
        }

    }
    else if(way == 2){
        if(select <= 0.6){
            return 2;
        }
        else if(select <= 0.8){
            return 0;
        }
        else {
            return 1;
        }
    }
    else{
        if(select <= 0.6){
            return 3;
        }
        else if(select <= 0.8){
            return 0;
        }
        else {
            return 1;
        }
    }
}


double distance(double x, double y, double bx, double by){
    return (double)sqrt((double)(x-bx)*(double)(x-bx) + (double)(y-by)*(double)(y-by));
}