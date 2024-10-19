-- Table: public.hurricane_summary_staging

DROP TABLE IF EXISTS public.hurricane_summary_staging;

CREATE TABLE IF NOT EXISTS public.hurricane_summary_staging
(
    year integer,
    storm character varying(100),
    dates character varying(100),
    max_winds_mph integer,
    min_pressure_mb integer,
    maximum_strength character varying(100)
);
