-- Insert default region record
INSERT INTO public.region VALUES (-1, 'NA', 'NA', '00000', 0, 0, 0);

-- Load hurricane data to weather_event_type table
WITH combined_data AS (
    SELECT 
        maximum_strength AS weather_event_type, 
        REPLACE(REGEXP_REPLACE(maximum_strength, '(\w)\w*', '\1', 'g'), ' ', '') AS weather_event_type_code
    FROM public.hurricane_summary_staging
    UNION
    SELECT
        storm_type AS weather_event_type,
        REPLACE(REGEXP_REPLACE(storm_type, '(\w)\w*', '\1', 'g'), ' ', '') AS weather_event_type_code
    FROM public.hurricane_details_staging hds
),
ranked_data AS (
    SELECT 
        weather_event_type, 
        weather_event_type_code,
        ROW_NUMBER() OVER (PARTITION BY weather_event_type_code ORDER BY weather_event_type) AS rn
    FROM combined_data
)
INSERT INTO public.weather_event_type (weather_event_type, weather_event_type_code)
SELECT 
    weather_event_type, 
    CASE 
        WHEN rn = 1 THEN weather_event_type_code
        ELSE CONCAT(weather_event_type_code, rn) -- Append row number if there's a conflict
    END AS weather_event_type_code
FROM ranked_data;

-- Load tornado data to weather_event_type table
INSERT INTO public.weather_event_type (weather_event_type, weather_event_type_code) VALUES ('Tornado', 'TVS');

-- Load hurricane data to weather_event
INSERT INTO weather_event(
	weather_event_name,
    weather_event_type_id,
    region_id,
    start_date,
    end_date
)
SELECT REPlACE(hds.hurricane_name, 'Hurricane-', '') ||'_'|| wet.weather_event_type_code AS weather_event_name,
	wet.weather_event_type_id, 
	-1 region_id,
	MIN(hds.date) AS start_date,
	MAX(hds.date) AS end_date 
FROM public.hurricane_details_staging hds
JOIN public.weather_event_type wet 
	ON hds.storm_type = wet.weather_event_type 
GROUP BY
	hds.hurricane_name, 
	wet.weather_event_type_id;

-- Load tornado data to weather_event
INSERT INTO weather_event(
	weather_event_name,
    weather_event_type_id,
    region_id,
    start_date,
    end_date
)
SELECT tds.cell_id ||'_'|| tds.wsr_id ||'_'|| wet.weather_event_type_code AS weather_event_name,
       wet.weather_event_type_id,
	   -1 region_id,
	   MIN(tds.ztime) AS start_date,
	   MAX(tds.ztime) AS end_date 
FROM public.tornado_details_staging tds
JOIN public.weather_event_type wet 
	ON tds.cell_type = wet.weather_event_type_code
GROUP BY tds.cell_id,
         tds.wsr_id,
         wet.weather_event_type_id;