
	Task: create an application that imports the provided YAML config file (which contains Control, Species and Habitat parameters) and then simulates the passage of time for each species in each habitat.
	At the end of each run, provide the following data:
		Species:
			Habitat:
				a) Average Population: x
				b) Max Population: x
				c) Mortality Rate: x%  #overall death percentage
				d) Causes of Death:
					x% starvation
					x% age
					x% cold_weather
					x% hot_weather
			
	Rules/Notes:
		Passage of Time:
			- The passage of time should be in months.  Animals only eat/drink/mate/die at 1 month intervals & habitats only refresh their food/water/temperature at 1 month intervals.
			- The Years value in the config should control how many years the simulation should run.
			- The Iterations value in the config should control how many times you run the full simulation from beginning to end.  When running multiple iterations, final stats should represent stats from all iterations combined.
		Species:
			- Each month individual animals should consume food & water, age, and survive temperature conditions
			- You only need to run one species at a time inside of a habitat (no need to run species side-by-side)
			- Assume animals are not monogamous
			- There is no need to keep track of parent/child relationships
			Death (causes):
				- Starvation: 3 consecutive full months without food 
				- Thirst: 1 full month without food
				- Old Age: age > life_span
				- Extreme Temperature:  1 full month above or below threshold for species
			Breeding:
				- When a species starts in a new habitat it should begin with exactly 1 male and 1 female
				- When a female gives birth, the sex of the offspring should be chosen 50:50
				- Breeding is controlled by
					- available females (not pregnant and within the breeding age range)
					- a supportive habitat
						- there should be more food and water currently available in habitat than is required to support the current population
						- HOWEVER, even when there is not enough food and water, allow breeding to occur at a 0.5% rate.
					- gestation period (# of months a female is pregnant before giving birth)
		Habitat:
			- The Habitat should refresh its food/water supply every month.
			- Seasons/Temperature
				- Use this Season/Month mapping  12,1,2=Winter  3,4,5=Spring  6,7,8=Summer  9,10,11=Fall
				- The temperature should be updated for every new month and should fluctuate above/below the average by up to 5 degrees, with a 0.5% chance of having up to a 15 degree fluctuation.
