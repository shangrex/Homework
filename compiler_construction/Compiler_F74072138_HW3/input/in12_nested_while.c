int j;
int i = 1;
while(i<=9){
	j = 1; 
	while(j<=9){
		print(i);
		print("*");
		print(j);
		print("=");
		print(i*j);
		print("\t");
		j++;
	}
	print("\n");
	i++;
}