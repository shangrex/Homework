all: main 
main: main.o Car.o
	g++ main.o	Car.o -o main
car.o: Car.cpp Car.h
	g++ -c Car.cpp 
main.o: main.cpp Car.h
	g++ -c main.cpp

clean:
	rm *.o
	rm main