#include <bits/stdc++.h>
#include <random>
#include <fstream>
using namespace std;
int main(){
    //FILE* file = fopen("input.txt", "w");
    ofstream file("input.txt");
    if(file){
        int line;
        cin >> line;
        for(int j = 0; j < line; j++){
            string s = "";
            for(int i = 0 ; i < 20; i++){
                default_random_engine generator;
                uniform_int_distribution<int> distribution(-2147483648 ,2147483647);
                int dice_roll = distribution(generator);
                s += to_string(dice_roll); 
                if(i != 19)s += "|";
                else s += "\n";
            }
            cout << s << endl;
            //fprintf(file, "%s", s);
	    file << s;
        }
        //fclose(file);
	file.close();
    }
    else {
        cout << "file open failed"  << endl;
    }
    return 0;
}
