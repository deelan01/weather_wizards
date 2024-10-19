DROP TABLE IF EXISTS public.hurricane_summary_staging;
DROP TABLE IF EXISTS public.hurricane_details_staging;
DROP TABLE IF EXISTS public.hurricane_archive_summary_staging;

-- Table: public.hurricane_summary_staging
CREATE TABLE IF NOT EXISTS public.hurricane_summary_staging
(
    year INTEGER,
    storm VARCHAR(100),
    dates VARCHAR(100),
    max_winds_mph INTEGER,
    min_pressure_mb INTEGER,
    maximum_strength VARCHAR(100)
);

-- Table: public.hurricane_details_staging
CREATE TABLE IF NOT EXISTS public.hurricane_details_staging
(
    hurricane_name VARCHAR(100),
    date DATE, 
    time TIME WITH TIME ZONE,
    lat DOUBLE PRECISION,
    lon DOUBLE PRECISION,
    wind_mph INTEGER,
    pressure_mb INTEGER,
    storm_type VARCHAR(100)
);

-- Table: public.hurricane_archive_summary_staging
CREATE TABLE IF NOT EXISTS public.hurricane_archive_summary_staging
(
    year INTEGER,
    storms INTEGER,
    hurricanes INTEGER,
    deaths VARCHAR(25),
    damage_millions_usd VARCHAR(25),
    retired_names VARCHAR(100) 
);
