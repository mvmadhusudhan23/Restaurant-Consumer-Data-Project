--  CREATING DATABASE FOR PROJECT
CREATE DATABASE PROJECTDB;
-- MAKING IT DEFAULT SCHEMA
USE PROJECTDB;

-- CREATING TABLES
CREATE TABLE consumers (
    Consumer_ID VARCHAR(10) PRIMARY KEY,
    City VARCHAR(255),
    State VARCHAR(255),
    Country VARCHAR(255),
    Latitude DECIMAL(10,7),
    Longitude DECIMAL(10,7),
    Smoker VARCHAR(50),
    Drink_Level VARCHAR(50),
    Transportation_Method VARCHAR(100),
    Marital_Status VARCHAR(100),
    Children VARCHAR(100),
    Age INT,
    Occupation VARCHAR(50),
    Budget VARCHAR(50)
);


CREATE TABLE consumer_preferences (
    Consumer_ID VARCHAR(10),
    Preferred_Cuisine VARCHAR(255),
    PRIMARY KEY (Consumer_ID, Preferred_Cuisine),
    FOREIGN KEY (Consumer_ID) REFERENCES consumers(Consumer_ID)
);


CREATE TABLE RESTAURANTS
(
RESTAURANT_ID INT PRIMARY KEY,
NAME VARCHAR(255),
CITY VARCHAR(255),
STATE VARCHAR(255),
COUNTRY VARCHAR(255),
ZIP_CODE VARCHAR(10),
LATITUDE DECIMAL(12,8),
LONGITUDE DECIMAL(12,8),
ALCOHOL_SERVICE VARCHAR(50),
SMOKING_ALLOWED VARCHAR(100),
PRICE VARCHAR(10),
FRANCHISE VARCHAR(10),
AREA VARCHAR(10),
PARKING VARCHAR(50)
);


CREATE TABLE RESTAURANT_CUISINES(
RESTAURANT_ID INT,
CUISINE VARCHAR(255),
PRIMARY KEY(RESTAURANT_ID,CUISINE),
FOREIGN KEY(RESTAURANT_ID) REFERENCES RESTAURANTS(RESTAURANT_ID)
);

CREATE TABLE RATINGS
(
CONSUMER_ID VARCHAR(10),
RESTAURANT_ID INT,
OVERALL_RATING INT,
FOOD_RATING INT,
SERVICE_RATING INT,
FOREIGN KEY (CONSUMER_ID) REFERENCES CONSUMERS(CONSUMER_ID),
FOREIGN KEY (RESTAURANT_ID) REFERENCES RESTAURANTS(RESTAURANT_ID)
);

-- Using the WHERE clause to filter data based on specific criteria.

	-- List all details of consumers who live in the city of 'Cuernavaca'.
			
		SELECT * FROM CONSUMERS WHERE CITY='Cuernavaca';
        
	-- Find the Consumer_ID, Age, and Occupation of all consumers who are 'Students' AND are 'Smokers'.
		
        SELECT * FROM CONSUMERS WHERE OCCUPATION='STUDENT' AND SMOKER ='YES';
        
	-- List the Name, City, Alcohol_Service, and Price of all restaurants that serve 'Wine & Beer' and have a 'Medium' price level.
	
		SELECT NAME,CITY,ALCOHOL_SERVICE,PRICE
        FROM RESTAURANTS
        WHERE ALCOHOL_SERVICE = 'WINE & BEER'AND PRICE ='MEDIUM';
        
	-- Find the names and cities of all restaurants that are part of a 'Franchise'
        SELECT NAME,CITY
        FROM RESTAURANTS
        WHERE FRANCHISE = 'YES' ;
        
        
	-- Show the Consumer_ID, Restaurant_ID, and Overall_Rating for all ratings where the
	-- Overall_Rating was 'Highly Satisfactory' (which corresponds to a value of 2, according to the
	-- data dictionary).
		
		SELECT 
        CONSUMER_ID,
        RESTAURANT_ID,
        OVERALL_RATING
        FROM RATINGS
        WHERE OVERALL_RATING = 2;

	-- Questions JOINs with Subqueries
    -- List the names and cities of all restaurants that have an Overall_Rating of 2 (Highly
	-- Satisfactory) from at least one consumer.
    
		SELECT DISTINCT(R.NAME),R.CITY
        FROM RESTAURANTS R
        JOIN RATINGS RT
        ON R.RESTAURANT_ID = RT.RESTAURANT_ID
        WHERE RT.OVERALL_RATING = 2;

	-- Find the Consumer_ID and Age of consumers who have rated restaurants located in 'San Luis Potosi'.
		
        SELECT C.CONSUMER_ID,C.AGE
        FROM CONSUMERS C
        JOIN RATINGS RT
        ON C.CONSUMER_ID = RT.CONSUMER_ID
        JOIN RESTAURANTS R
		ON RT.RESTAURANT_ID = R.RESTAURANT_ID
		WHERE R.CITY= 'San Luis Potosi';

	-- List the names of restaurants that serve 'Mexican' cuisine and have been rated by consumer 'U1001'.
		
        SELECT R.NAME
        FROM RESTAURANTS R
        JOIN (
			SELECT *
			FROM restaurant_cuisines
			WHERE CUISINE ='MEXICAN'
            ) RC
		ON R.RESTAURANT_ID = RC.RESTAURANT_ID 
		JOIN RATINGS RT
		ON R.RESTAURANT_ID = RT.RESTAURANT_ID
		WHERE RT.CONSUMER_ID = 'U1001';

	-- Find all details of consumers who prefer 'American' cuisine AND have a 'Medium' budget.
		
        SELECT C.*
        FROM CONSUMERS C
        JOIN CONSUMER_PREFERENCES CP
        ON C.CONSUMER_ID = CP.CONSUMER_ID
        WHERE CP.Preferred_Cuisine='AMERICAN' AND C.BUDGET = 'MEDIUM';
	-- List restaurants (Name, City) that have received a Food_Rating lower than the average Food_Rating across all rated restaurants.
		
        SELECT DISTINCT R.NAME,R.CITY
        FROM RESTAURANTS R 
        JOIN RATINGS RT
        ON R.RESTAURANT_ID = RT.RESTAURANT_ID
        WHERE RT.FOOD_RATING < (
		SELECT AVG(FOOD_RATING)
        FROM RATINGS
        );
        
	-- Find consumers (Consumer_ID, Age, Occupation) who have rated at least one restaurant but have NOT rated any restaurant that serves 'Italian' cuisine.
    
        SELECT 
        CONSUMER_ID ,
        AGE,
        OCCUPATION
        FROM CONSUMERS 
        WHERE CONSUMER_ID NOT IN 
        (
				SELECT CONSUMER_ID
				FROM RATINGS  RT
				JOIN RESTAURANT_CUISINES RC
				ON RT.RESTAURANT_ID = RC.RESTAURANT_ID
				WHERE RC.CUISINE = 'ITALIAN'
		);
        
        -- List restaurants (Name) that have received ratings from consumers older than 30.
        
        SELECT 
			DISTINCT R.NAME
		FROM RESTAURANTS R
        JOIN RATINGS RT
        ON R.RESTAURANT_ID = RT.RESTAURANT_ID
        WHERE RT.CONSUMER_ID IN 
        (
        SELECT CONSUMER_ID 
        FROM CONSUMERS
        WHERE AGE > 30
        );

	-- Find the Consumer_ID and Occupation of consumers whose preferred cuisine is 'Mexican'
	-- and who have given an Overall_Rating of 0 to at least one restaurant (any restaurant).
    
		SELECT DISTINCT C.CONSUMER_ID,
        C.OCCUPATION
        FROM CONSUMERS C
        JOIN CONSUMER_PREFERENCES CP
        ON C.CONSUMER_ID = CP.CONSUMER_ID
        JOIN RATINGS RT
        ON RT.CONSUMER_ID = C.CONSUMER_ID
        WHERE CP.Preferred_Cuisine = 'MEXICAN' AND RT.OVERALL_RATING = 0
        ;
        
	-- List the names and cities of restaurants that serve 'Pizzeria' cuisine and are located in a city
	-- where at least one 'Student' consumer lives.
    
		SELECT R.NAME,R.CITY
        FROM RESTAURANTS R
        JOIN RESTAURANT_CUISINES RC
        ON R.RESTAURANT_ID = RC.RESTAURANT_ID
        WHERE CUISINE = 'PIZZERIA' AND CITY IN (SELECT DISTINCT CITY FROM CONSUMERS WHERE OCCUPATION = 'STUDENT');
        
	-- Find consumers (Consumer_ID, Age) who are 'Social Drinkers' and have rated a restaurant that has 'No' parking
		
        SELECT C.CONSUMER_ID,C.AGE
        FROM CONSUMERS C 
        JOIN 
        (
        SELECT * FROM RATINGS 
		WHERE RESTAURANT_ID IN (
        SELECT DISTINCT RESTAURANT_ID FROM RESTAURANTS
        WHERE PARKING = 'NONE'
        )) R
        ON C.CONSUMER_ID = R.CONSUMER_ID
        WHERE C.DRINK_LEVEL = 'SOCIAL DRINKER';
	

--               ==  Questions Emphasizing WHERE Clause and Order of Execution  ==

-- List Consumer_IDs and the count of restaurants they've rated, but only for consumers who
-- are 'Students'. Show only students who have rated more than 2 restaurants.
 
	select consumer_id,count(*) as No_of_students
    from  ratings 
    where  consumer_id in (
		select consumer_id 
		from consumers
		where occupation='student'
        ) 
    group by consumer_id
    having no_of_students > 2;
    
-- We want to categorize consumers by an 'Engagement_Score' which is their Age divided by
-- 10 (integer division). List the Consumer_ID, Age, and this calculated Engagement_Score, but
-- only for consumers whose Engagement_Score would be exactly 2 and who use 'Public'

    SELECT CONSUMER_ID,AGE, ROUND(AGE/10,2) AS ENGAGEMENT_SCORE
    FROM CONSUMERS
    WHERE CONSUMER_ID IN (
			SELECT CONSUMER_ID
			FROM CONSUMERS
			WHERE TRANSPORTATION_METHOD ='PUBLIC'
            )
	HAVING ENGAGEMENT_SCORE = 2;
	
-- For each restaurant, calculate its average Overall_Rating. Then, list the restaurant Name,
-- City, and its calculated average Overall_Rating, but only for restaurants located in
-- 'Cuernavaca' AND whose calculated average Overall_Rating is greater than 1.0.

	SELECT R.NAME,R.CITY,RT.AVG_RATING
    FROM RESTAURANTS R
    JOIN (
    SELECT RESTAURANT_ID,AVG(OVERALL_RATING) AS AVG_RATING
    FROM RATINGS
    WHERE RESTAURANT_ID IN (
    SELECT RESTAURANT_ID 
    FROM RESTAURANTS
    WHERE CITY = 'Cuernavaca')
    GROUP BY RESTAURANT_ID) RT
    ON R.RESTAURANT_ID = RT.RESTAURANT_ID
    HAVING AVG_RATING > 1;


-- Find consumers (Consumer_ID, Age) who are 'Married' and whose Food_Rating for any
-- restaurant is equal to their Service_Rating for that same restaurant, but only consider ratings
-- where the Overall_Rating was 2.

	SELECT C.CONSUMER_ID,C.AGE
    FROM CONSUMERS C
    JOIN 
    ( 
    SELECT *
    FROM RATINGS
    WHERE FOOD_RATING = SERVICE_RATING
    AND OVERALL_RATING = 2
    ) RT
    ON C.CONSUMER_ID = RT.CONSUMER_ID
    WHERE C.MARITAL_STATUS ='MARRIED';

	
-- List Consumer_ID, Age, and the Name of any restaurant they rated, but only for consumers
-- who are 'Employed' and have given a Food_Rating of 0 to at least one restaurant located in
-- 'Ciudad Victoria'.
	
    SELECT DISTINCT C.CONSUMER_ID,C.AGE,R.NAME
    FROM CONSUMERS C
    JOIN RATINGS RT
    ON C.CONSUMER_ID = RT.CONSUMER_ID
    JOIN RESTAURANTS R
    ON R.RESTAURANT_ID = RT.RESTAURANT_ID
    WHERE OCCUPATION ='EMPLOYED'
    AND R.CITY = 'Ciudad Victoria'
    AND FOOD_RATING = 0;
    

--           ==  Advanced SQL Concepts: Derived Tables, CTEs, Window Functions, Views, Stored Procedures == 

-- Using a CTE, find all consumers who live in 'San Luis Potosi'. Then, list their Consumer_ID,
-- Age, and the Name of any Mexican restaurant they have rated with an Overall_Rating of 2.

WITH SAN_CONSUMERS AS (
SELECT *
FROM CONSUMERS
WHERE CITY = 'San Luis Potosi'
)

SELECT 
SC.CONSUMER_ID,
SC.AGE,
R.NAME
FROM SAN_CONSUMERS SC
JOIN RATINGS RT
ON SC.CONSUMER_ID = RT.CONSUMER_ID
JOIN RESTAURANTS R 
ON RT.RESTAURANT_ID = R.RESTAURANT_ID
JOIN RESTAURANT_CUISINES RC
ON RT.RESTAURANT_ID = RC.RESTAURANT_ID 
WHERE RC.CUISINE = 'MEXICAN' 
AND RT.OVERALL_RATING = 2
ORDER BY SC.CONSUMER_ID;


-- For each Occupation, find the average age of consumers. Only consider consumers who
-- have made at least one rating. (Use a derived table to get consumers who have rated).
    
    WITH CONSUMER_CTE AS (
    SELECT DISTINCT CONSUMER_ID
    FROM RATINGS
    WHERE OVERALL_RATING IS NOT NULL AND 
    FOOD_RATING IS NOT NULL AND
    SERVICE_RATING IS NOT NULL
    )


	SELECT C.OCCUPATION,ROUND(AVG(C.AGE),2) AS AVG_AGE
    FROM CONSUMERS C
    JOIN CONSUMER_CTE CC 
    ON C.CONSUMER_ID = CC.CONSUMER_ID
    WHERE C.OCCUPATION !=""
    GROUP BY C.OCCUPATION;
  

-- Using a CTE to get all ratings for restaurants in 'Cuernavaca', rank these ratings within each
-- restaurant based on Overall_Rating (highest first). Display Restaurant_ID, Consumer_ID,
-- Overall_Rating, and the RatingRank.

	WITH CTE_OVERALL_RATING AS 
    (
	SELECT RT.CONSUMER_ID,RT.RESTAURANT_ID,RT.OVERALL_RATING
    FROM RATINGS RT
    JOIN RESTAURANTS R
    ON RT.RESTAURANT_ID = R.RESTAURANT_ID
    WHERE R.CITY = 'Cuernavaca'
    )
    
    SELECT *,
		DENSE_RANK() OVER(PARTITION BY RESTAURANT_ID ORDER BY OVERALL_RATING DESC) AS RATINGRANK
	FROM CTE_OVERALL_RATING;

-- For each rating, show the Consumer_ID, Restaurant_ID, Overall_Rating, and also display the
-- average Overall_Rating given by that specific consumer across all their ratings.

SELECT 
DISTINCT CONSUMER_ID ,
RESTAURANT_ID , 
OVERALL_RATING , 
AVG(OVERALL_RATING) OVER(PARTITION BY CONSUMER_ID) AS AVG_RATING  
FROM RATINGS
;

-- Using a CTE, identify students who have a 'Low' budget. Then, for each of these students,
-- list their top 3 most preferred cuisines based on the order they appear in the
-- Consumer_Preferences table (assuming no explicit preference order, use Consumer_ID,
-- Preferred_Cuisine to define order for ROW_NUMBER).

WITH BUDGET_CTE AS (
	SELECT CONSUMER_ID
    FROM CONSUMERS
    WHERE BUDGET='LOW'
    )
SELECT *
FROM 
(
	SELECT CP.CONSUMER_ID,CP.PREFERRED_CUISINE,
	ROW_NUMBER() OVER(PARTITION BY CONSUMER_ID ORDER BY  CONSUMER_ID,PREFERRED_CUISINE) AS RN
	FROM BUDGET_CTE BC
	JOIN CONSUMER_PREFERENCES CP
	ON BC.CONSUMER_ID = CP.CONSUMER_ID
) AS RT
WHERE RN<=3
ORDER BY CONSUMER_ID ,RN ;


-- Consider all ratings made by 'Consumer_ID' = 'U1008'. For each rating, show the Restaurant_ID, Overall_Rating, and the Overall_Rating of the next restaurant they rated 
-- (if any), ordered by Restaurant_ID (as a proxy for time if rating time isn't available). Use aderived table to filter for the consumer's ratings first.

SELECT RESTAURANT_ID,OVERALL_RATING,
LEAD(OVERALL_RATING) OVER(ORDER BY RESTAURANT_ID) AS NEXT_RATED_RESTAURANT
FROM RATINGS
WHERE CONSUMER_ID ='U1008'
ORDER BY RESTAURANT_ID;


-- Create a VIEW named HighlyRatedMexicanRestaurants that shows the Restaurant_ID, Name, 
-- and City of all Mexican restaurants that have an average Overall_Rating greater than 1.5.

CREATE VIEW HIGHLYRATEDMEXICANRESTAURANTS AS
SELECT DISTINCT R.RESTAURANT_ID,R.NAME,R.CITY
FROM RESTAURANTS R
JOIN RATINGS RT
ON R.RESTAURANT_ID = RT.RESTAURANT_ID
WHERE R.RESTAURANT_ID IN 
(
SELECT DISTINCT RESTAURANT_ID FROM RESTAURANT_CUISINES
WHERE CUISINE = 'MEXICAN'
)
GROUP BY
R.RESTAURANT_ID,
R.NAME
HAVING AVG(RT.OVERALL_RATING ) > 1.5 ;

SELECT * 
FROM HighlyRatedMexicanRestaurants;

-- . First, ensure the HighlyRatedMexicanRestaurants view from Q7 exists. Then, using a CTE to
-- find consumers who prefer 'Mexican' cuisine, list those consumers (Consumer_ID) who have
-- not rated any restaurant listed in the HighlyRatedMexicanRestaurants view

WITH MEXICANCONSUMERS AS
(
SELECT DISTINCT CONSUMER_ID
FROM CONSUMER_PREFERENCES 
WHERE PREFERRED_CUISINE = 'MEXICAN'
)
SELECT M.CONSUMER_ID
FROM MEXICANCONSUMERS M
LEFT JOIN RATINGS RT
ON M.CONSUMER_ID = RT.CONSUMER_ID
AND RT.RESTAURANT_ID IN
			(
            SELECT RESTAURANT_ID 
            FROM HighlyRatedMexicanRestaurants
            )
WHERE RT.RESTAURANT_ID IS NULL;

-- Create a stored procedure GetRestaurantRatingsAboveThreshold that accepts a
-- Restaurant_ID and a minimum Overall_Rating as input. It should return the Consumer_ID,
-- Overall_Rating, Food_Rating, and Service_Rating for that restaurant where the Overall_Rating
-- meets or exceeds the threshold.

DELIMITER //
CREATE PROCEDURE GetRestaurantRatingsAboveThreshold(IN REST_ID INT ,
													IN MIN_OVERALL_RATING DECIMAL(10,2))
BEGIN 
SELECT CONSUMER_ID,OVERALL_RATING,FOOD_RATING,SERVICE_RATING
FROM RATINGS
WHERE RESTAURANT_ID = REST_ID AND
OVERALL_RATING >= MIN_OVERALL_RATING ;
END //
DELIMITER ;

CALL GetRestaurantRatingsAboveThreshold(135104,1);


-- Identify the top 2 highest-rated (by Overall_Rating) restaurants for each cuisine type. If there
-- are ties in rating, include all tied restaurants. Display Cuisine, Restaurant_Name, City, and
-- Overall_Rating.
WITH RESTAURANTCUISINE AS (
SELECT R.RESTAURANT_ID,
	   R.NAME AS RESTAURANT_NAME,
       R.CITY,
       RC.CUISINE,
       AVG(OVERALL_RATING) AS AVG_RATING
FROM RESTAURANT_CUISINES RC
JOIN RESTAURANTS R 
ON RC.RESTAURANT_ID = R.RESTAURANT_ID
JOIN RATINGS RT
ON R.RESTAURANT_ID = RT.RESTAURANT_ID
GROUP BY  RC.CUISINE,R.RESTAURANT_ID,R.NAME,R.CITY
),
TOP2 AS (
SELECT *,
DENSE_RANK() OVER(PARTITION BY CUISINE ORDER BY AVG_RATING DESC ) AS RATING_RANK
FROM RESTAURANTCUISINE
)
SELECT 
	CUISINE,RESTAURANT_NAME,CITY,AVG_RATING AS OVERALL_RATING
FROM TOP2
WHERE RATING_RANK <=2
ORDER BY CUISINE,AVG_RATING DESC;


-- First, create a VIEW named ConsumerAverageRatings that lists Consumer_ID and their
-- average Overall_Rating. Then, using this view and a CTE, find the top 5 consumers by their
-- average overall rating. For these top 5 consumers, list their Consumer_ID, their average
-- rating, and the number of 'Mexican' restaurants they have rated.

 CREATE VIEW ConsumerAverageRatings AS
 SELECT CONSUMER_ID,AVG(OVERALL_RATING) AS AVG_RATING
 FROM RATINGS
 GROUP BY CONSUMER_ID;
 
 WITH TOP5 AS
 (
 SELECT *
 FROM ConsumerAverageRatings
 ORDER BY AVG_RATING DESC
 LIMIT 5
)

SELECT T.CONSUMER_ID,T.AVG_RATING,COUNT(DISTINCT RC.RESTAURANT_ID) AS MEXICAN_REST_COUNT 
FROM TOP5 T
LEFT JOIN RATINGS RT 
ON T.CONSUMER_ID = RT.CONSUMER_ID
LEFT JOIN RESTAURANT_CUISINES RC
ON RT.RESTAURANT_ID = RC.RESTAURANT_ID
AND CUISINE = 'MEXICAN'
GROUP BY T.CONSUMER_ID,T.AVG_RATING
ORDER BY MEXICAN_REST_COUNT DESC;


-- Create a stored procedure named GetConsumerSegmentAndRestaurantPerformance that accepts a Consumer_ID as input.
 
  -- 1. Determine the consumer's "Spending Segment" based on their Budget:
		-- ○ 'Low' -> 'Budget Conscious'
		-- ○ 'Medium' -> 'Moderate Spender'
		-- ○ 'High' -> 'Premium Spender'
		-- ○ NULL or other -> 'Unknown Budget'
DELIMITER //
CREATE PROCEDURE GetConsumerSegmentAndRestaurantPerformance(IN P_CONSUMERID VARCHAR(20))

BEGIN
-- 1.CONSUMER SPENDING SEGMENT 
	SELECT CONSUMER_ID,
	CASE BUDGET
		WHEN 'LOW' THEN 'Budget Conscious'
		WHEN 'MEDIUM' THEN 'Moderate Spender'
		WHEN 'HIGH' THEN 'Premium Spender'
		ELSE 'UNKNOWN BUDGET' 
		END AS SPENDING_SEGMENT
	FROM CONSUMERS
	WHERE CONSUMER_ID = P_CONSUMERID;
    
WITH RESTAVG AS (
SELECT RESTAURANT_ID,AVG(OVERALL_RATING) AS AVG_RATING 
FROM RATINGS
GROUP BY RESTAURANT_ID
)
-- 2- SHOW RESTAURANT PERFORMANCE 

	SELECT
		R.NAME AS RESTAURANT_NAME,
        RT.OVERALL_RATING,
        RA.AVG_RATING AS RESTAURANT_AVG_RATING,
        CASE 
			WHEN RT.OVERALL_RATING >  RA.AVG_RATING THEN 'ABOVE RATING'
            WHEN RT.OVERALL_RATING =  RA.AVG_RATING THEN 'AT AVERAGE'
            ELSE 'BELOW AVERAGE'
		END AS PERFORMANCE_FLAG,
        DENSE_RANK() OVER(ORDER BY RT.OVERALL_RATING DESC) AS RATING_RANK
	
    FROM RATINGS RT
    JOIN RESTAURANTS R
	ON RT.RESTAURANT_ID = R.RESTAURANT_ID 
    JOIN RESTAVG RA
    ON RA.RESTAURANT_ID = R.RESTAURANT_ID
    WHERE RT.CONSUMER_ID = P_CONSUMERID
	ORDER BY 
    RT.OVERALL_RATING DESC;
END //
DELIMITER ;

CALL  GetConsumerSegmentAndRestaurantPerformance('U1001');

	
    