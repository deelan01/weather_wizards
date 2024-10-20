-- Create a default region record with ID -1 for cases where region is unknown or not applicable
INSERT INTO public.region VALUES (-1, 'NA', 'NA', '00000', 0, 0, 0);

-- Load weather event types from hurricane data
-- This complex query handles multiple sources of weather event types
WITH combined_data AS (
   -- Combine weather event types from both hurricane summary and details
   SELECT 
       maximum_strength AS weather_event_type, 
       -- Create short codes by taking first letter of each word
       REPLACE(REGEXP_REPLACE(maximum_strength, '(\w)\w*', '\1', 'g'), ' ', '') AS weather_event_type_code
   FROM public.hurricane_summary_staging
   UNION
   SELECT
       storm_type AS weather_event_type,
       REPLACE(REGEXP_REPLACE(storm_type, '(\w)\w*', '\1', 'g'), ' ', '') AS weather_event_type_code
   FROM public.hurricane_details_staging hds
),
ranked_data AS (
   -- Add row numbers to handle potential code conflicts
   SELECT 
       weather_event_type, 
       weather_event_type_code,
       ROW_NUMBER() OVER (PARTITION BY weather_event_type_code ORDER BY weather_event_type) AS rn
   FROM combined_data
)
-- Insert weather event types with unique codes
INSERT INTO public.weather_event_type (weather_event_type, weather_event_type_code)
SELECT 
   weather_event_type, 
   CASE 
       WHEN rn = 1 THEN weather_event_type_code
       ELSE CONCAT(weather_event_type_code, rn) -- Append number for duplicate codes
   END AS weather_event_type_code
FROM ranked_data;

-- Add tornado as a weather event type with code 'TVS' (Tornado Vortex Signature)
INSERT INTO public.weather_event_type (weather_event_type, weather_event_type_code) 
VALUES ('Tornado', 'TVS');

-- Load hurricane events into weather_event table
-- Combines data points into single events based on hurricane name
INSERT INTO weather_event(
   weather_event_name,
   weather_event_type_id,
   region_id,
   start_date,
   end_date
)
SELECT 
   REPlACE(hds.hurricane_name, 'Hurricane-', '') AS weather_event_name,
   wet.weather_event_type_id, 
   -1 region_id,  -- Use default region
   MIN(hds.date) AS start_date,  -- First date of hurricane
   MAX(hds.date) AS end_date     -- Last date of hurricane
FROM public.hurricane_details_staging hds
JOIN public.weather_event_type wet 
   ON hds.storm_type = wet.weather_event_type 
GROUP BY
   hds.hurricane_name, 
   wet.weather_event_type_id;

-- Load tornado events into weather_event table
-- Creates unique event names by combining cell_id and radar station ID
INSERT INTO weather_event(
   weather_event_name,
   weather_event_type_id,
   region_id,
   start_date,
   end_date
)
SELECT 
   tds.cell_id ||'_'|| tds.wsr_id AS weather_event_name,
   wet.weather_event_type_id,
   -1 region_id,  -- Use default region
   MIN(tds.ztime) AS start_date,  -- First observation time
   MAX(tds.ztime) AS end_date     -- Last observation time
FROM public.tornado_details_staging tds
JOIN public.weather_event_type wet 
   ON tds.cell_type = wet.weather_event_type_code
GROUP BY 
   tds.cell_id,
   tds.wsr_id,
   wet.weather_event_type_id;

-- Create a default radar station record for unknown/NA cases
INSERT INTO public.radar_station VALUES (-1, 'NA', 'NA', 'NA');

-- Load hurricane radar observations
INSERT INTO weather_event_radar(
   weather_event_id, 
   radar_id,
   radar_date, 
   latitude, 
   longitude,
   wind_speed_mph,
   atmospheric_pressure_mb
)
SELECT DISTINCT
   we.event_id,
   -1 AS radar_id,  -- Use default radar station
   -- Convert separate date and time fields into timestamp with timezone
   MAKE_TIMESTAMPTZ(
       EXTRACT(YEAR FROM hds.date)::INTEGER, 
       EXTRACT(MONTH FROM hds.date)::INTEGER,
       EXTRACT(DAY FROM hds.date)::INTEGER,
       EXTRACT(HOUR FROM hds.time)::INTEGER,
       EXTRACT(MINUTE FROM hds.time)::INTEGER,
       EXTRACT(SECOND FROM hds.time)::DOUBLE PRECISION
   ) AS radar_date,
   hds.lat AS latitude,
   hds.lon AS longitude,
   hds.wind_mph AS wind_speed_mph,
   hds.pressure_mb AS atmospheric_pressure_mb
FROM public.hurricane_details_staging hds
JOIN weather_event we 
   ON REPLACE(hds.hurricane_name, 'Hurricane-', '') = we.weather_event_name
JOIN public.weather_event_type wet 
   ON hds.storm_type = wet.weather_event_type
   AND we.weather_event_type_id = wet.weather_event_type_id;

-- Load tornado radar observations
-- Aggregates multiple readings per timestamp using MAX for some measurements
INSERT INTO weather_event_radar(
   weather_event_id, 
   radar_id,
   radar_date, 
   latitude, 
   longitude,
   max_shear,
   max_doppler_velocity_knots,
   azimuth_degrees,
   nautical_miles_from_radar
)
SELECT
   we.event_id,
   rs.radar_id,
   tds.ztime AS radar_date,
   tds.latitude,
   tds.longitude,
   MAX(tds.max_shear) AS max_shear,  -- Maximum shear reading
   MAX(tds.mxdv) AS max_doppler_velocity_knots,  -- Maximum velocity
   tds.azimuth AS azimuth_degrees,
   tds.range AS nautical_miles_from_radar
FROM tornado_details_staging tds
JOIN radar_station rs 
   ON tds.wsr_id = rs.radar_name
JOIN public.weather_event_type wet 
   ON tds.cell_type = wet.weather_event_type_code
JOIN weather_event we 
   ON tds.cell_id ||'_'|| tds.wsr_id = we.weather_event_name
GROUP BY 
   we.event_id,
   rs.radar_id,
   tds.ztime,
   tds.latitude,
   tds.longitude,
   tds.azimuth,
   tds.range;