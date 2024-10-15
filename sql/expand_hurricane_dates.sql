select *
from public.weather_event_type;

insert into public.weather_event_type (weather_event_type)
select maximum_strength
from public.hurricane_summary_staging
group by maximum_strength
order by maximum_strength;

commit;

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

select *
from public.swdiws_nx3tvs_geojson;

select *
from radar_station;
