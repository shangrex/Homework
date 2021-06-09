int i;
for(i = 0; i < 10; i++){
	print(i);
}
print("\n");
i = 1 ;
while(i > 0)
{
	i--;
	int x[3];
	x[0] = 1 + 21;
	x[1] = x[0] - 1;
	x[2] = x[1] / 3;
	print(x[2]);
	print("\n");
	print(3 - 4 * (+5 + -8) - 10 / 7 > -4 % 3 || !true && !!false);
	print("\n");

	float yy[3];
	yy[0] = 1.1 + 2.1;
	print((int)yy[0]);
	print("\n");
}

int x;
x += 10;
while(x > 0){
	print(x);
	print("\t");
	x--;
	if(x != 0){
		float y = 3.14;
		print(((int)y)+x);
		/* print
		a string and 
		 */
	} else {
		float z = 6.6;
		print("If x == ");
		print(0);
		print(z);
	}
	int j = 1;
	while(j<=3){
		print("\t");
		print(x);
		print("*");
		print(j);
		print("=");
		print(x*j);
		print("\t");
		j++;		
	}
	print("\n");
}