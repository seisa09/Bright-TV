--USERS TABLE
--Collecting all users data
select * from `workspace`.`default`.`users`;

--Checking for Users based on their age, gender and race
SELECT UserID, age, gender, race
FROM `workspace`.`default`.`users`;

--Checking for users based on gender
SELECT gender, count(*) as user_count
FROM `workspace`.`default`.`users`
GROUP BY gender
ORDER BY user_count DESC;

--Checking for users based on race
SELECT race, count(*) as race
FROM `workspace`.`default`.`users`
GROUP BY race
ORDER BY race DESC;

--Grouping users based on age
SELECT CASE
    WHEN age between 0 and 12 then 'kids'
    WHEN age between 13 and 19 then 'teenagers'
    WHEN age between 20 and 39 then 'young adults'
    WHEN age between 40 and 59 then 'elderly'
    ELSE 'unknown'
    END as age_group,
    count(*) as total 
FROM `workspace`.`default`.`users`
GROUP BY age_group
ORDER BY total DESC;

--Users per province
SELECT province, count(*) as total
FROM `workspace`.`default`.`users`
GROUP BY province 
ORDER BY total DESC;

--Replacing the blank with unknown
SELECT CASE WHEN province = 'none' OR province = '' 
THEN 'unknown' 
ELSE province 
END as province, count(*) as total
FROM `workspace`.`default`.`users`
GROUP BY province 
ORDER BY total DESC;

--Checking for null values
SELECT userID, gender, age, race, province
FROM `workspace`.`default`.`users`
WHERE userID is null or gender is null or age is null or race is null or province is null;
--no null values

--Checking for duplicates
SELECT 
COUNT(*) as row_count,
COUNT(DISTINCT userid) as customer
FROM `workspace`.`default`.`users`
HAVING COUNT(*) >1;
--no duplicates

--Final query
SELECT 
    UserID,
    b.Gender,
    b.Race,
    b.Age,
    b.Province,
    a.`Duration 2`,
    RecordDate2,
    a.Channel2,

    -- Convert to Mzansi time (UTC+2)
    date_format(
        to_timestamp(a.RecordDate2, 'M/d/yyyy H:mm') + INTERVAL 2 HOURS,
        'HH:mm:ss'
    ) AS Mzansi_Time,

    -- Extract date
    to_date(to_timestamp(a.RecordDate2, 'M/d/yyyy H:mm')) AS View_date,

    -- Weekday vs Weekend
    CASE 
        WHEN dayofweek(to_timestamp(a.RecordDate2, 'M/d/yyyy H:mm')) IN (1,7) 
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS Weekday_or_weekend,

    -- Time of day buckets
    CASE 
        WHEN date_format(to_timestamp(a.RecordDate2, 'M/d/yyyy H:mm') + INTERVAL 2 HOURS, 'HH:mm:ss') BETWEEN '05:00:00' AND '09:59:59' THEN 'Morning'
        WHEN date_format(to_timestamp(a.RecordDate2, 'M/d/yyyy H:mm') + INTERVAL 2 HOURS, 'HH:mm:ss') BETWEEN '10:00:00' AND '16:59:59' THEN 'Day'
        WHEN date_format(to_timestamp(a.RecordDate2, 'M/d/yyyy H:mm') + INTERVAL 2 HOURS, 'HH:mm:ss') BETWEEN '17:00:00' AND '20:59:59' THEN 'Evening'
        WHEN date_format(to_timestamp(a.RecordDate2, 'M/d/yyyy H:mm') + INTERVAL 2 HOURS, 'HH:mm:ss') BETWEEN '21:00:00' AND '23:59:59' THEN 'Night'
        ELSE 'Midnight'
    END AS Time_of_day,

    -- Duration buckets
    CASE 
        WHEN date_format(a.`Duration 2`, 'HH:mm:ss') BETWEEN '00:00:00' AND '00:09:59' THEN 'Sneak_view'
        WHEN date_format(a.`Duration 2`, 'HH:mm:ss') BETWEEN '00:10:00' AND '00:19:59' THEN 'Standard_view'
        WHEN date_format(a.`Duration 2`, 'HH:mm:ss') BETWEEN '00:20:00' AND '00:59:59' THEN 'Long_view'
        ELSE 'Extra_long_view'
    END AS Duration_time,

    -- Age groups
    CASE
        WHEN b.Age BETWEEN 0 AND 12 THEN 'Kids'
        WHEN b.Age BETWEEN 13 AND 19 THEN 'Teenagers'
        WHEN b.Age BETWEEN 20 AND 39 THEN 'Young Adults'
        WHEN b.Age BETWEEN 40 AND 59 THEN 'Elderly'
        ELSE 'Unknown'
    END AS Age_group,

    -- Aggregations
    COUNT(UserID)/COUNT(DISTINCT UserID) AS Views_per_user,
    COUNT(UserID) - COUNT(DISTINCT UserID) AS Repeat_viewers,
    COUNT(UserID) AS Total_viewers,
    MAX(`Duration 2`) AS Max_Duration,
    MIN(`Duration 2`) AS Min_Duration

FROM `workspace`.`default`.`viewers` AS a
LEFT JOIN `workspace`.`default`.`users` AS b
    ON a.userID0 = b.userID

GROUP BY 
    UserID, b.Gender, b.Race, b.Age, b.Province,
    a.`Duration 2`, a.RecordDate2, a.Channel2

ORDER BY Views_per_user DESC;



--VIEWERS TABLE
select * from `workspace`.`default`.`viewers`;

--Converting time to South African time and sepataring date
SELECT 
date_format(to_timestamp(RecordDate2, 'M/d/yyyy H:mm') + INTERVAL '2' HOUR, 'HH:mm:ss') as Mzansi_Time,
to_date(to_timestamp(RecordDate2, 'M/d/yyyy H:mm')) as View_date 
FROM `workspace`.`default`.`viewers`;

--checking for total viewers
SELECT 
COUNT(UserID0) AS Total_viewers
FROM `workspace`.`default`.`viewers`;

--Identifying channels 
SELECT DISTINCT Channel2, COUNT(DISTINCT UserID0) as number_of_users
FROM `workspace`.`default`.`viewers`
GROUP BY channel2
ORDER BY number_of_users DESC;

--Checking for null values
SELECT 'RecordDte2', 'channel2', 'duration2'
FROM `workspace`.`default`.`viewers`
WHERE RecordDate2 IS NULL OR Channel2 IS NULL OR 'Duration 2' IS NULL
OR RecordDate2 = '' OR Channel2 = '' OR 'Duration 2' = '';
--no null values

--checking for duplicates
SELECT UserID0, COUNT(*) as row_count
FROM `workspace`.`default`.`viewers`
GROUP BY UserID0
HAVING COUNT(*) > 1
ORDER BY row_count DESC;
--duplicates found

--Checking duration times
SELECT date_format(`Duration 2`, 'HH:mm:ss') as Duration_time
FROM `workspace`.`default`.`viewers`;

--Weekday or weekend
SELECT 
to_date(to_timestamp(RecordDate2, 'M/d/yyyy H:mm')) as View_date,
CASE WHEN dayofweek(to_timestamp(RecordDate2, 'M/d/yyyy H:mm')) in (1,7) THEN 'Weekend'
ELSE 'Weekday'
END AS Weekday_or_weekend
FROM `workspace`.`default`.`viewers`;

--Buckets
--Time of day
SELECT
CASE 
        WHEN date_format(to_timestamp(RecordDate2, 'M/d/yyyy H:mm') + INTERVAL 2 HOURS, 'HH:mm:ss') BETWEEN '05:00' AND '09:59' THEN 'Morning'
        WHEN date_format(to_timestamp(RecordDate2, 'M/d/yyyy H:mm') + INTERVAL 2 HOURS, 'HH:mm:ss') BETWEEN '10:00' AND '16:59' THEN 'Day'
        WHEN date_format(to_timestamp(RecordDate2, 'M/d/yyyy H:mm') + INTERVAL 2 HOURS, 'HH:mm:ss') BETWEEN '17:00' AND '20:59' THEN 'Evening'
        WHEN date_format(to_timestamp(RecordDate2, 'M/d/yyyy H:mm') + INTERVAL 2 HOURS, 'HH:mm:ss') BETWEEN '21:00' AND '23:59' THEN 'Night'
        ELSE 'Midnight'
    END AS Time_of_day
    FROM `workspace`.`default`.`viewers`;

--Duration time
select case 
when date_format(`duration 2`, 'HH:mm:ss') between'00:00:00' and '00:09:59' then 'Sneak_view'
when date_format(`duration 2`, 'HH:mm:ss') between'00:10:00' and '00:19:59' then 'standard_view'
when date_format(`duration 2`, 'HH:mm:ss') between'00:20:00' and '00:59:59' then 'long_view'
else 'extra_long_view'
end as duration_time
from `workspace`.`default`.`viewers`;

