#include <iostream>
#include <iomanip>
#include "random_point_generator.h"

#define ITERATION_COUNTER_END 100000
#define X_SIZE 4
#define Y_SIZE 4

const double INIT_ARRAY[X_SIZE][Y_SIZE] = { {0, 0, 0.1, 0.1}, {0.2, 0, 0, 0.2}, {0, 0, 0.3, 0},{0, 0.05, 0, 0.05} };

void Print(int random_sum[X_SIZE][Y_SIZE])
{
	std::cout << "X\\Y|";
	for (int i = 0; i < Y_SIZE; ++i)
		std::cout << "   " << i + 1 << "   |";
	std::cout << std::endl;
	std::cout << "-----------------------------------";
	std::cout << std::endl;

	for (int i = 0; i < X_SIZE; ++i)
	{
		std::cout << i + 1 << "  |";
		for (int j = 0; j < Y_SIZE; ++j)
			std::cout << std::setw(6) << random_sum[i][j] << " |";
		std::cout << std::endl;
	}

	std::cout << "press enter to continue";
	std::cin.ignore();
}

int main()
{
	int random_sum[X_SIZE][Y_SIZE] = { {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0} };
	RandomPointGenerator random_point_generator(*INIT_ARRAY, 4, 4);

	for(int iteration_counter = 0; iteration_counter < ITERATION_COUNTER_END; ++iteration_counter)
	{
		std::pair<int, int> point = random_point_generator.GetRandomPoint();
		++random_sum[point.first][point.second];
	}

	Print(random_sum);
}