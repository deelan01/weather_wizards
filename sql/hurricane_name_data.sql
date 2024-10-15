-- Table: public.hurricane_name_data_staging

DROP TABLE IF EXISTS public.hurricane_name_data_staging;

CREATE TABLE IF NOT EXISTS public.hurricane_name_data_staging
(
    "hurricane_name" character varying(100),
    "date" character varying(100), 
    "time" time with time zone,
    "lat" numeric,
    "lon" numeric,
    "wind_mph" integer,
    "pressure_mb" double precision,
    "storm_type" character varying(100)
);
