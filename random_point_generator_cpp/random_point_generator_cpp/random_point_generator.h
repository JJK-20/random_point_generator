#pragma once
#include<utility>
#include"utility.h"

class RandomPointGenerator
{
public:
	RandomPointGenerator(const double *init_array, int size_x, int size_y);
	~RandomPointGenerator();
	std::pair<int, int> GetRandomPoint();
private:
	std::mt19937 seed_;
	std::uniform_real_distribution<double> generator_;
	double *points_x_probability_;
	double **points_y_probability_;
	int array_x_size_, array_y_size_;
};
