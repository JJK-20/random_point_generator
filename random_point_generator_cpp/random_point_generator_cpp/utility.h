#pragma once
#include<random>

#define NUM_OF_ELEMENTS(array_pointer, data_type) sizeof(array_pointer) / sizeof(data_type)

inline std::mt19937 UnitGeneratorSeed()
{
	std::random_device random_device;			//Will be used to obtain a seed for the random number engine
	return std::mt19937(random_device());		//Standard mersenne_twister_engine seeded with rd()
}

inline std::uniform_real_distribution<double> CreateUnitGenerator()
{
	return std::uniform_real_distribution<double>(0.0, 1.0);
}