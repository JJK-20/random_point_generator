#include "random_point_generator.h"

RandomPointGenerator::RandomPointGenerator(const double *init_array, int size_x, int size_y)
{
	this->array_x_size = size_x;
	this->array_y_size = size_y;
	this->points_y_probability_ = new double*[size_y];
	for (int i = 0; i < size_x; ++i)
		this->points_y_probability_[i] = new double[size_x];

	for (int i = 0; i < size_y; ++i)
		for (int j = 0; j < size_x; ++j)
			this->points_y_probability_[i][j] = init_array[i*size_x + j];

	this->points_x_probability_ = new double[size_x];

	for (int i = 0; i < size_x; ++i)
	{
		this->points_x_probability_[i] = 0;
		for (int j = 0; j < size_y; ++j)
			this->points_x_probability_[i] += this->points_y_probability_[i][j];
	}

	for (int i = 0; i < size_x; ++i)
		for (int j = 0; j < size_y; ++j)
			this->points_y_probability_[i][j] /= this->points_x_probability_[i];

	this->seed_ = UnitGeneratorSeed();
	this->generator_ = CreateUnitGenerator();
}

RandomPointGenerator::~RandomPointGenerator()
{
	delete[] this->points_x_probability_;
	for (int i = 0; i < this->array_x_size; ++i)
		delete[] this->points_y_probability_[i];
	delete[] this->points_y_probability_;
}

std::pair<int, int> RandomPointGenerator::GetRandomPoint()
{
	std::pair<int, int>point;
	double random_x = generator_(seed_);

	int i = 0;
	while (random_x > points_x_probability_[i])
	{
		random_x -= points_x_probability_[i];
		++i;
	}	
	point.first = i;

	double random_y = generator_(seed_);

	int j = 0;
	while (random_y > points_y_probability_[i][j])
	{
		random_y -= points_y_probability_[i][j];
		++j;
	}
	point.second = j;

	return point;
}
