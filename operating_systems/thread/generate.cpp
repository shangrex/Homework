#include <bits/stdc++.h>
#include <random>
#include <fstream>
#include <time.h>
using namespace std;
int main(){
    ofstream file("input.csv", ios::out);
    if(file){
        clock_t start, end;
        int line;
        cin >> line;
        srand(time(NULL)); 
        start = clock();
        uniform_int_distribution<int> distribution(-2147483648 ,2147483647);
        random_device rd;
        default_random_engine generator;
        generator.seed(rand());
        for(int j = 0; j < line; j++){
            string s = "";
            for(int i = 0 ; i < 20; i++){
                int dice_roll = distribution(generator);
                s += to_string(dice_roll); 
                if(i != 19)s += "|";
            }
            //cout << s << endl;
            if(j < line-1) file << s << '\n';
            else file << s;
        }
	    file.close();
        end = clock();
        cout << "total execution time " << ((double) (end - start)) / CLOCKS_PER_SEC  << " secs" << endl;

    }
    else {
        cout << "file open failed"  << endl;
    }
    return 0;
}
