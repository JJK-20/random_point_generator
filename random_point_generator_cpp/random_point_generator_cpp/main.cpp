#include <iostream>
#include "random_point_generator.h"

#define ITERATION_COUNTER_END 100000

const double arr[4][4] = { {0, 0, 0.1, 0.1}, {0.2, 0, 0, 0.2}, {0, 0, 0.3, 0},{0, 0.05, 0, 0.05} };
int random_sum[4][4] = { {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0} };

int main()
{
	RandomPointGenerator rpg(*arr, 4, 4);
	for(int iteration_counter = 0; iteration_counter < ITERATION_COUNTER_END; ++iteration_counter)
	{
		std::pair<int, int> point = rpg.GetRandomPoint();
		random_sum[point.first][point.second]++;
	}

	for (int i = 0; i < 4; ++i)
	{
		for (int j = 0; j < 4; ++j)
			std::cout << random_sum[i][j] << "     ";
		std::cout << std::endl;
	}

	std::cout << "press enter to continue";
	std::cin.ignore();

}