#include <bits/stdc++.h>
#include "Car.h"
using namespace std;
int time_scale = 1000; // 1 mili second
// struct car{
//     double x;
//     double y;
//     int way;
//     int bs;
//     double power;
// }
void initial(vector<vector<int> >&bs, vector<vector<float> > &lam, vector<string>&all_policy){
    //base station
    bs.push_back(vector<int>());
    bs[0].push_back(360);
    bs[0].push_back(680);
    bs.push_back(vector<int>());
    bs[1].push_back(660);
    bs[1].push_back(658);
    bs.push_back(vector<int>());
    bs[2].push_back(330);
    bs[2].push_back(350);
    bs.push_back(vector<int>());
    bs[3].push_back(640);
    bs[3].push_back(310);
    //lambda
    lam.push_back(vector<float>());
    lam[0].push_back(0.5/time_scale);
    lam.push_back(vector<float>());
    lam[1].push_back(0.333333333/time_scale);
    lam.push_back(vector<float>());
    lam[2].push_back(0.2/time_scale);

    //policy
    all_policy.push_back("Best");
    all_policy.push_back("Threshold");
    all_policy.push_back("Entropy");
}

bool sim_in(float prob){
    float select = rand() % 100000;
    return prob*100000 > select;
}

int sim_way(int way){
    float pu, pd, pr, pl;
    if (way == 0){
        pu = 0.6;
        pd = 0;
        pl = 0.2;
        pr = 0.2;
    }
    else if (way == 1){
        pu = 0;
        pd = 0.6;
        pl = 0.2;
        pr = 0.2;
    }
    else if (way == 2){
        pu = 0.2;
        pd = 0.2;
        pl = 0.6;
        pr = 0;
    }
    else if (way == 3){
        pu = 0.2;
        pd = 0.2;
        pl = 0;
        pr = 0.6;
    }
    float select = rand() % 1000;
    float q1 = pu*1000;
    float q2 = q1+pd*1000;
    float q3 = q2+pl*1000;
    float q4 = q3+pr*1000;
    if(select <= q1){
        way = 0;
    }
    else if (select <= q2){
        way = 1;
    }
    else if (select <= q3){
        way = 2;
    }
    else {
        way = 3;
    }
    return way;
}
void test(){
    //test sim_in

    int count = 0 ;
    bool x = false;
    for(int i = 0; i < 1000; i++){
        x = sim_in(0.4);
        if(x){
            count += 1;
        }
        x = false;
    }
    cout << count << endl;

    //sim way


    // int x;    
    // int count = 0 ;
    // for(int i = 0; i < 1000; i++){
    //     x = sim_way(0);
    //     if(x == 2){
    //         count += 1;
    //     }
    // }
    // cout << count << endl;
}

void exp(int total_time, float l, vector<vector<int> >bs, string policy, string exp_name){
    fstream file_out(policy+".csv", ios::out);
    long long int handoff = 0;
    long long int total_handoff = 0;
    long double total_pow = 0;
    long long int total_car = 0;
    //inut car
    vector<Car> car;
    for (int t = 0; t < total_time; t++){
        //car
        //x_pos , y_pos, way, bs, power

        for(int i = 1; i < 10; i++){
            if(sim_in(l)){
                Car c = Car(i*100, 0, 1, 0, 0.0);
                car.push_back(c);
            }
        }
        
        for(int i = 1; i < 10; i++){
            if(sim_in(l)){
                Car c = Car(0, i*100, 0, 0, 0.0);
                car.push_back(c);
            }
        }
        
        for(int i = 1; i < 10; i++){
            if(sim_in(l)){
                Car c = Car(1000, i*100, 2, 0, 0.0);
                car.push_back(c);
            }
        }

        for(int i = 1; i < 10; i++){
            if(sim_in(l)){
                Car c = Car(i*100, 0, 3, 0, 0.0);
                car.push_back(c);
            }
        }
        // cout << "car size" << car.size() << endl;
        if(policy == "Best"){
            // cout << "Best policy" << endl;
            for(int i = 0; i < car.size(); i++){
                for(int j = 0; j < bs.size(); j++){
                    // cout << "car position" << car[i][0] << " " << car[i][1] << endl;
                    // cout << "bs position" << bs[j][0] << " " << bs[j][1] << endl;
                    float d = sqrt((car[i].x-bs[j][0])*(car[i].x-bs[j][0]) + (car[i].y-bs[j][1])*(car[i].y-bs[j][1]));
                    float p = 67 - 20*log10(d);
                    if(car[i].power < p){
                        handoff ++;
                        car[i].power = p;
                        car[i].bs = j;
                    }
                }
            }


        }
        else if(policy == "Threshold"){
            float threshold = 20.0;
            for(int i = 0; i < car.size(); i++){
                for(int j = 0; j < bs.size(); j++){
                    // cout << "car position" << car[i][0] << " " << car[i][1] << endl;
                    // cout << "bs position" << bs[j][0] << " " << bs[j][1] << endl;
                    float d = sqrt((car[i].x-bs[j][0])*(car[i].x-bs[j][0]) + (car[i].y-bs[j][1])*(car[i].y-bs[j][1]));
                    float p = 67 - 20*log10(d);
                    if(p > car[i].power && car[i].power < threshold){
                        handoff ++;
                        car[i].power = p;
                        car[i].bs = j;
                    }
                }
            }
        }
        else if (policy == "Entropy"){
            float entropy = 10.0;
            for(int i = 0; i < car.size(); i++){
                int select_bs = 0;
                float min_d = 1000;
                for(int j = 0; j < bs.size(); j++){
                    // cout << "car position" << car[i][0] << " " << car[i][1] << endl;
                    // cout << "bs position" << bs[j][0] << " " << bs[j][1] << endl;
                    float d = sqrt((car[i].x-bs[j][0])*(car[i].x-bs[j][0]) + (car[i].y-bs[j][1])*(car[i].y-bs[j][1]));
                    float p = 67 - 20*log10(d);
                    if(p - car[i].power > entropy){
                        handoff++;
                        car[i].power = p;
                        car[i].bs = j;
                    }
                }
            }
        }
        else if(policy == "Worst"){
            float threshold = 10.0;
            for(int i = 0; i < car.size(); i++){
                for(int j = 0; j < bs.size(); j++){
                    // cout << "car position" << car[i][0] << " " << car[i][1] << endl;
                    // cout << "bs position" << bs[j][0] << " " << bs[j][1] << endl;
                    float d = sqrt((car[i].x-bs[j][0])*(car[i].x-bs[j][0]) + (car[i].y-bs[j][1])*(car[i].y-bs[j][1]));
                    float p = 67 - 20*log10(d);
                    if(p > car[i].power && car[i].power < threshold){
                        handoff ++;
                        car[i].power = p;
                        car[i].bs = j;
                    }
                }
            }
        }
        else{

        }

        //movement
        if(t % time_scale == 0){
            for(int i = 0; i < car.size(); i++){
                //car move
                if (car[i].x > 1000 || car[i].x < 0 || car[i].y > 1000 || car[i].y < 0){
                    car.erase(car.begin()+i);
                }
                else {
                    //select way
                    if(car[i].x % 100 == 0 && car[i].y % 100 == 0){
                        // cout << "choose way " << car[i].x << " " << car[i].y << endl; 
                        car[i].way = sim_way(car[i].way);
                    }
                    car[i].move();
                }
            }
            //file_out << handoff <<'\n';
            total_handoff += handoff;
            handoff = 0;

        }
        //add car  
        total_car += car.size();
        // add power
        for(int i = 0; i < car.size(); i++){
            total_pow += car[i].power;
        }
        if(total_car > 0)
            cout << "Average Power: " << total_pow / (long double)total_car << endl;


    }
    cout << "toatal handoff " << total_handoff << endl;
    if(total_car > 0)
        cout << "Average Power: " << total_pow / (long double)total_car << endl;

}
int main(int argc, char*argv[]){
    clock_t start, end; 

    //up down left right
    //0  1    2    3
    int total_time = stoi(argv[1]);
    string policy = argv[2];
    string exp_name = argv[3];
    vector<vector<int> >bs;
    vector<vector<float> >lam;
    vector<string> all_policy;
    initial(bs, lam, all_policy);
    float l = 0.5/time_scale;
    policy = "Best";
    for(int i = 0; i < lam.size(); i++){
    }
    start = clock();
    exp(total_time ,l, bs, policy, exp_name);
    end = clock();
    cout << "total execution time "<< (end-start)/CLOCKS_PER_SEC << " sec" << endl;

    return 0;
}