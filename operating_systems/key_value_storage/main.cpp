#include <bits/stdc++.h>
#include <time.h>
using namespace std;
int main(int argc, char *argv[]){
    fstream file_in(argv[1], ios::in);
    string s = argv[1];   
    string delimiter = ".";
    string out_file = s.substr(0, s.find(delimiter));
    // fstream file_out(out_file + ".output", ios::out);
    clock_t start, end;
    start = clock();
    // string cache[9999][9999][9999][9999];
    while(file_in >> s){
        string key, value;
        if(s == "PUT"){
            file_in >> key;
            file_in >> value;
            string c1 = "", c2 = "", c3 = "", c4 = "";
            // for(int i = 0; i < key.length(); i++){
            //     if(i < 4){
            //         c1 += key[i];
            //     }
            //     else if(i < 8){
            //         c2 += key[i];
            //     }
            //     else if(i < 12){
            //         c3 += key[i];
            //     }
            //     else if(i < 16){
            //         c4 += key[i];
            //     }
            // }
            // if(c1 == "")c1 = "0";
            // if(c2 == "")c2 = "0";
            // if(c3 == "")c3 = "0";
            // if(c4 == "")c4 = "0";
            // cache[stoi(c1)][stoi(c2)][stoi(c3)][stoi(c4)] = value;
        }
        else if(s == "GET"){
            file_in >> key;    
        }
        else if(s == "SCAN"){
            string l_sc, r_sc;
            file_in >> l_sc;
            cout << l_sc << endl;
            file_in >> r_sc;
            cout << r_sc << endl;
        }
    }
    end = clock();
    cout << "total execution time: " << ((double) (end - start)) / CLOCKS_PER_SEC  << " secs" << endl;
    cout << end - start << endl;
    return 0;
}