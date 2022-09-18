use [google_data_analytics_1];

--modify type of data on lat and lgn

ALTER TABLE dbo.[2108LAT]
ALTER COLUMN start_lat decimal(12,9)
ALTER TABLE dbo.[2108LAT]
ALTER COLUMN start_lng decimal(12,9)
ALTER TABLE dbo.[2108LAT]
ALTER COLUMN end_lat decimal(12,9)
ALTER TABLE dbo.[2108LAT]
ALTER COLUMN end_lng decimal(12,9)

ALTER TABLE dbo.[2109LAT]
ALTER COLUMN start_lat decimal(12,9)
ALTER TABLE dbo.[2109LAT]
ALTER COLUMN start_lng decimal(12,9)
ALTER TABLE dbo.[2109LAT]
ALTER COLUMN end_lat decimal(12,9)
ALTER TABLE dbo.[2109LAT]
ALTER COLUMN end_lng decimal(12,9)

ALTER TABLE dbo.[2110LAT]
ALTER COLUMN start_lat decimal(12,9)
ALTER TABLE dbo.[2110LAT]
ALTER COLUMN start_lng decimal(12,9)
ALTER TABLE dbo.[2110LAT]
ALTER COLUMN end_lat decimal(12,9)
ALTER TABLE dbo.[2110LAT]
ALTER COLUMN end_lng decimal(12,9)

ALTER TABLE dbo.[2111LAT]
ALTER COLUMN start_lat decimal(12,9)
ALTER TABLE dbo.[2111LAT]
ALTER COLUMN start_lng decimal(12,9)
ALTER TABLE dbo.[2111LAT]
ALTER COLUMN end_lat decimal(12,9)
ALTER TABLE dbo.[2111LAT]
ALTER COLUMN end_lng decimal(12,9)

ALTER TABLE dbo.[2112LAT]
ALTER COLUMN start_lat decimal(12,9)
ALTER TABLE dbo.[2112LAT]
ALTER COLUMN start_lng decimal(12,9)
ALTER TABLE dbo.[2112LAT]
ALTER COLUMN end_lat decimal(12,9)
ALTER TABLE dbo.[2112LAT]
ALTER COLUMN end_lng decimal(12,9)

ALTER TABLE dbo.[2201LAT]
ALTER COLUMN start_lat decimal(12,9)
ALTER TABLE dbo.[2201LAT]
ALTER COLUMN start_lng decimal(12,9)
ALTER TABLE dbo.[2201LAT]
ALTER COLUMN end_lat decimal(12,9)
ALTER TABLE dbo.[2201LAT]
ALTER COLUMN end_lng decimal(12,9)

ALTER TABLE dbo.[2202LAT]
ALTER COLUMN start_lat decimal(12,9)
ALTER TABLE dbo.[2202LAT]
ALTER COLUMN start_lng decimal(12,9)
ALTER TABLE dbo.[2202LAT]
ALTER COLUMN end_lat decimal(12,9)
ALTER TABLE dbo.[2202LAT]
ALTER COLUMN end_lng decimal(12,9)

ALTER TABLE dbo.[2203LAT]
ALTER COLUMN start_lat decimal(12,9)
ALTER TABLE dbo.[2203LAT]
ALTER COLUMN start_lng decimal(12,9)
ALTER TABLE dbo.[2203LAT]
ALTER COLUMN end_lat decimal(12,9)
ALTER TABLE dbo.[2203LAT]
ALTER COLUMN end_lng decimal(12,9)

ALTER TABLE dbo.[2204LAT]
ALTER COLUMN start_lat decimal(12,9)
ALTER TABLE dbo.[2204LAT]
ALTER COLUMN start_lng decimal(12,9)
ALTER TABLE dbo.[2204LAT]
ALTER COLUMN end_lat decimal(12,9)
ALTER TABLE dbo.[2204LAT]
ALTER COLUMN end_lng decimal(12,9)

ALTER TABLE dbo.[2205LAT]
ALTER COLUMN start_lat decimal(12,9)
ALTER TABLE dbo.[2205LAT]
ALTER COLUMN start_lng decimal(12,9)
ALTER TABLE dbo.[2205LAT]
ALTER COLUMN end_lat decimal(12,9)
ALTER TABLE dbo.[2205LAT]
ALTER COLUMN end_lng decimal(12,9)

ALTER TABLE dbo.[2206LAT]
ALTER COLUMN start_lat decimal(12,9)
ALTER TABLE dbo.[2206LAT]
ALTER COLUMN start_lng decimal(12,9)
ALTER TABLE dbo.[2206LAT]
ALTER COLUMN end_lat decimal(12,9)
ALTER TABLE dbo.[2206LAT]
ALTER COLUMN end_lng decimal(12,9)

ALTER TABLE dbo.[2207LAT]
ALTER COLUMN start_lat decimal(12,9)
ALTER TABLE dbo.[2207LAT]
ALTER COLUMN start_lng decimal(12,9)
ALTER TABLE dbo.[2207LAT]
ALTER COLUMN end_lat decimal(12,9)
ALTER TABLE dbo.[2207LAT]
ALTER COLUMN end_lng decimal(12,9)




SELECT * INTO yearly_Datas

FROM

(
SELECT * from dbo.[2108LAT] 
union all
select * from dbo.[2109LAT]
UNION ALL
select * from dbo.[2110LAT]
union all
select * from dbo.[2111LAT]
union all
select * from dbo.[2112LAT]
union all
select * from dbo.[2201LAT]
UNION ALL
SELECT * from dbo.[2202LAT]
union all 
select * from dbo.[2203LAT]
union all
select * from dbo.[2204LAT]
union all
select * from dbo.[2205LAT]
union all 
select * from dbo.[2206LAT]
union all
select * from dbo.[2207LAT]) A

select * from yearly_Datas

--cleaning null values--

SELECT *INTO null_clean 
from 
(
SELECT * FROM yearly_Datas
	where start_station_name NOT LIKE '%NULL%'
					AND end_station_name NOT LIKE '%NULL%'
						AND start_lat NOT LIKE '%NULL%'
							AND start_lng NOT LIKE '%NULL%'
								AND end_lat NOT LIKE '%NULL%'
									AND end_lng NOT LIKE '%NULL%'
					 				) B

SELECT * FROM  null_clean

--Trim station name from possible extra spaces and replace TEMP rows --

SELECT * INTO station_clean_finaal
from
(
SELECT DISTINCT rideable_type as bike_type, started_at, ended_at,
	TRIM(REPLACE(REPLACE(start_station_name,'(*)',''),'TEMP','')) as  start_station_name_clean,
		TRIM(REPLACE(REPLACE(end_station_name,'(*)',''),'TEMP','')) as  end_station_name_clean,
			start_lat,start_lng,end_lat,end_lng,member_casual,start_date,start_hour,end_date,end_hour,[ride_length(minutes)],weekday
from null_clean
) C

select * from station_clean_finaal

--final table, filtering ride_length > 1 minutes--

SELECT * INTO final
from(
	SELECT bike_type, started_at, ended_at,start_station_name_clean,end_station_name_clean,start_lat,start_lng,end_lat,end_lng,member_casual,CAST(start_date AS date) AS Date_ofYear,start_hour,end_date,end_hour,[ride_length(minutes)],weekday
	FROM station_clean_finaal
	where [ride_length(minutes)] > 1
) D




SELECT * from final

--ANALYSIS-

--FIND TOTAL NUMBER OF MEMBERS AND CASUAL RIDERS LEAVING A STATION and join them

SELECT * INTO casual_start_station
FROM
(
	SELECT COUNT(member_casual) AS casual, start_station_name_clean
	FROM final
	WHERE member_casual = 'casual'
	GROUP BY start_station_name_clean
) D

SELECT * INTO member_start_station
FROM
(
	SELECT COUNT(member_casual) AS member, start_station_name_clean
	FROM final
	WHERE member_casual = 'member'
	GROUP BY start_station_name_clean
) E

SELECT * INTO start_station
from (
SELECT casual, member, casual_start_station.start_station_name_clean
FROM casual_start_station
	INNER JOIN member_start_station on casual_start_station.start_station_name_clean=member_start_station.start_station_name_clean		
) F

SELECT * from start_station

--group start station name with lat and lng--

SELECT * INTO start_coord
from(
SELECT DISTINCT start_station_name_clean, 
										ROUND(AVG(start_lat),4) AS start_station_lat, 
											ROUND(AVG(start_lng),4) AS start_station_lng 
from final
group by start_station_name_clean
) G

select * from start_coord

--join coords with riders count and export table--

SELECT * INTO startriders_coord_viz
from(
	select start_coord.start_station_name_clean,casual,member, start_coord.start_station_lat,start_coord.start_station_lng
	from start_station
	INNER JOIN start_coord on start_station.start_station_name_clean=start_coord.start_station_name_clean
)H

SELECT * FROM startriders_coord_viz

--members and casual riders arriving--

SELECT * INTO casual_arrive_station
FROM
(
	SELECT COUNT(member_casual) AS casual, end_station_name_clean
	FROM final
	WHERE member_casual = 'casual'
	GROUP BY end_station_name_clean
) I

SELECT * INTO member_arrive_station
FROM
(
	SELECT COUNT(member_casual) AS member, end_station_name_clean
	FROM final
	WHERE member_casual = 'member'
	GROUP BY end_station_name_clean
) J

SELECT * INTO arrive_station
from (
SELECT casual, member, casual_arrive_station.end_station_name_clean
FROM casual_arrive_station
	INNER JOIN member_arrive_station on casual_arrive_station.end_station_name_clean=member_arrive_station.end_station_name_clean		
) K

SELECT * from arrive_station

--group arrive station name with lat and lng--

SELECT * INTO arrive_coord
from(
SELECT DISTINCT end_station_name_clean, 
										ROUND(AVG(end_lat),4) AS end_station_lat, 
											ROUND(AVG(end_lng),4) AS end_station_lng 
from final
group by end_station_name_clean
) L

select * from arrive_coord

--join coords with riders data and export--

SELECT * INTO arriveriders_coord_viz
from(
	select arrive_coord.end_station_name_clean,casual,member, arrive_coord.end_station_lat,arrive_coord.end_station_lng
	from arrive_station
	INNER JOIN arrive_coord on arrive_station.end_station_name_clean=arrive_coord.end_station_name_clean
)H

SELECT * FROM arririders_coord_viz

--trips taken by casual and members grouped by days--

SELECT * INTO casual_day_trips
from(

	SELECT count(member_casual) AS casual, Date_ofYear
	FROM final
	WHERE member_casual = 'casual'
	GROUP BY Date_ofYear
)I

select * from casual_day_trips

SELECT * INTO member_day_trips
from(

	SELECT count(member_casual) AS member,Date_ofYear
	FROM final
	WHERE member_casual = 'member'
	GROUP BY Date_ofYear
)J

SELECT * FROM member_day_trips

SELECT * INTO day_trips_yearVIZ
from
(
	SELECT casual,member,member_day_trips.Date_ofYear 
	FROM casual_day_trips
	  INNER JOIN member_day_trips
	  ON casual_day_trips.Date_ofYear = member_day_trips.Date_ofYear
)K

SELECT * from day_trips_yearVIZ

--trips taken by both cutomers by day of the week

SELECT * INTO WeekDay_casual_trips
FROM
(
	SELECT COUNT(member_casual) AS casual, weekday
	from final
	WHERE member_casual = 'casual'
	GROUP BY weekday
) L

SELECT * INTO WeekDay_member_trips
FROM
(
	SELECT COUNT(member_casual) AS member, weekday
	from final
	WHERE member_casual = 'member'
	GROUP BY weekday
) M

SELECT * INTO weekday_tripsVIZ
from(
	SELECT WeekDay_casual_trips.weekday, casual,member
	from WeekDay_casual_trips
		INNER JOIN WeekDay_member_trips
		ON WeekDay_casual_trips.weekday=WeekDay_member_trips.weekday
)N

--AVG ride time--

select * from final

SELECT * INTO casual_totalMin
FROM(
	SELECT AVG(totalMinutes) as casual_AVG_ride
	FROM final
	WHERE member_casual = 'casual'
)O

SELECT * INTO member_totalMin
FROM(
	SELECT AVG(totalMinutes) as member_AVG_ride
	FROM final
	WHERE member_casual = 'member'
)P

--Overall Rider Count for both riders

SELECT * INTO casual_totalRides
FROM(
	SELECT count(member_casual) AS casual_riders
	FROM final
	WHERE member_casual='casual'
)Q

SELECT * INTO member_totalRides
FROM(
	SELECT count(member_casual) AS member_riders
	FROM final
	WHERE member_casual='member'
)R