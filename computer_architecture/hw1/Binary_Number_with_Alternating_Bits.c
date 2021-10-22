# include <stdio.h>
# include <stdlib.h>
# include <stdbool.h>

int main(void){
    int input = 10;
    bool t = input & 1;
    char *str1 = "The answer is True.";
    char *str2 = "The answer is False.";
    char *rst = str1;
    while(input != 0){
        input = input >> 1;
        if(t == (input&1))rst = str2;
        t = input & 1;
    }    
    printf("The answer is %s\n", rst);
    return 0;
}