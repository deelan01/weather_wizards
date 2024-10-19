select *
from weather_event

select *
from weather_event_cost_impact

select *
from weather_event_human_impact

select *
from weather_event_radar

select *
from weather_event_type

select * 
from hurricane_summary_staging;

select *
from region where region_id = -1

select * 
from hurricane_details_staging
	where hurricane_name = 'Marilyn'
	order by date desc


INSERT INTO public.weather_event_type (weather_event_type, weather_event_type_code)
SELECT 
    maximum_strength,
    REGEXP_REPLACE(maximum_strength, '(\w)\w*', '\1', 'g') -- Get first letter of each word
FROM public.hurricane_summary_staging
GROUP BY maximum_strength
ORDER BY maximum_strength;

WITH date_ranges AS (
    -- Extract start and end date from the date_range column
    SELECT 
        storm,
        max_winds_mph,
        min_pressure_mb,
        maximum_strength,
        -- Convert '5/25 - 5/31' to actual dates in the year
        to_date(year || '/' || split_part(dates, ' - ', 1), 'YYYY/MM/DD') AS start_date,
        to_date(year || '/' || split_part(dates, ' - ', 2), 'YYYY/MM/DD') AS end_date
    FROM public.hurricane_summary_staging
),
expanded_dates AS (
    -- Generate a series of dates for each record
    SELECT 
        storm,
        max_winds_mph,
        min_pressure_mb,
        maximum_strength,
        generate_series(start_date, end_date, '1 day'::interval) AS date
    FROM date_ranges
)
-- Select from the expanded series to see the new records
SELECT * FROM expanded_dates;

insert into weather_event(
	weather_event_name,
    weather_event_type_id,
    region_id,
    start_date,
    end_date
)
select wet.weather_event_type_code ||'_'|| replace (hds.hurricane_name, 'Hurricane-', '') as weather_event_name,
	wet.weather_event_type_id, 
	-1 region_id,
	min (hds.date) as start_date,
	max (hds.date) as end_date 
from hurricane_details_staging hds
join weather_event_type wet 
	on hds.storm_type = wet.weather_event_type 
group by hurricane_name, 
	weather_event_type_id


alter table weather_event
drop column radar_id

DROP TABLE IF EXISTS public.hurricane_details_staging;

CREATE TABLE IF NOT EXISTS public.hurricane_details_staging
(
    "hurricane_name" character varying(100),
    "date" date, 
    "time" time with time zone,
    "lat" numeric,
    "lon" numeric,
    "wind_mph" integer,
    "pressure_mb" double precision,
    "storm_type" character varying(100)
);

insert into region values (-1, 'NA', 'NA', '00000', 0, 0, 0)








