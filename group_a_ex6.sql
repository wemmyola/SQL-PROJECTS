--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--exercise 6

--creating the disaster table
CREATE TABLE disaster(
	Year INT,
	Disaster_Group VARCHAR(255),	
	Disaster_Subgroup VARCHAR(255),
	Disaster_Type VARCHAR(255),
	Disaster_Subtype VARCHAR(255),
	ISO VARCHAR(255),
	Region VARCHAR(255),
	Continent VARCHAR(255),
	Origin VARCHAR(255),
	Associated_Disaster VARCHAR(255),
	OFDA_Response VARCHAR(255),
	Disaster_Magnitude_Value INT,
	Latitude VARCHAR(255),
	Longitude VARCHAR(255),
	Start_Year VARCHAR(255),	
	End_Year VARCHAR(255),
	Total_Deaths	INT,
	No_Injured INT,
	No_Affected INT,
	No_Homeless INT,
	Total_Affected INT,
	Total_Damages_USD INT,
	Total_Damages_Adjusted_USD INT,
	Country VARCHAR(255),
	Location VARCHAR(255)
);


--Q1 what are the top 5 most common type of disaster?
SELECT disaster_type,
		COUNT(disaster_type) total_occurence
FROM disaster
GROUP BY disaster_type
ORDER BY total_occurence DESC
LIMIT 5;

--INSIGHT:::Flood is the most common type of disaster

--Q2 what are the top 5 types of disasters with the highest number of recorded deaths?
SELECT disaster_type,
		SUM(total_deaths) total_deaths
FROM disaster
GROUP BY disaster_type
ORDER BY total_deaths DESC
LIMIT 5;

--INSIGHT:::Earthquakes have the highest number of recorded deaths

--Q3 what country is affected by disasters the most?
WITH occurence AS(
	SELECT country,
		COUNT(disaster_type) total_occurence,
		SUM(total_deaths) total_deaths
	FROM disaster
	GROUP BY country, disaster_type
	ORDER BY total_occurence DESC
)
SELECT country,
		SUM(total_occurence) total_occurence,
		SUM(total_deaths) total_deaths
FROM occurence
GROUP BY country
ORDER BY total_deaths DESC
LIMIT 1;

--INSIGHT:::Indonesia is the country affected the most by disaster

--Q4 which year has the highest number of recorded disasters?
SELECT year,
		COUNT(*) total_occurence
FROM disaster
GROUP BY year
ORDER BY total_occurence DESC
LIMIT 1;
--INSIGHT:::2006 recorded the most amount of disasters

--Q5 which 5 disaster types cost more in total damages?
SELECT disaster_type,
		ROUND(AVG(total_damages_adjusted_usd),2) average_damages_amount
FROM disaster
WHERE total_damages_adjusted_usd IS NOT NULL
GROUP BY disaster_type
ORDER BY average_damages_amount DESC
LIMIT 5;
--INSIGHT:::Wildfire cost more in damages, I really thought it would be Earthquakes tho.

--Q6 what is the disaster type with the highest magnitude on average?
SELECT disaster_type,
		ROUND(AVG(disaster_magnitude_value),2) average_disaster_magnitude
FROM disaster
WHERE disaster_magnitude_value IS NOT NULL
GROUP BY disaster_type
ORDER BY average_disaster_magnitude DESC
LIMIT 5;
--INSIGHT:::Epidemic has the highest magnitude on average


--INSIGHTS
--Flood is the most common type of disaster
--Earthquakes have the highest number of recorded deaths
--Indonesia is the country affected the most by disaster
--2006 recorded the most amount of disasters
--Wildfire cost more in damages, I really thought it would be Earthquakes tho.
--Epidemic has the highest magnitude on average

--RECCOMENDATIONS
--Develop and implement disaster preparedness and response plans to reduce the impact of Earthquakes, Wildfires & Floods.
--Invest in infrastructures, medical facilities and technology that can help protect countries from Epidemics or other high magnitude disasters
--Increase financial and technical assistance to low-income countries like Indonesia to help them adapt to the impacts of disasters.