--Table: public.hurricane_summary_db

DROP TABLE IF EXISTS public.hurricane_summary_db;

CREATE TABLE IF NOT EXISTS public.hurricane_summary_db
(
    year integer,
    storm character varying(100),
    dates character varying(100),
    max_winds_mph integer,
    min_pressure_mb integer,
    maximum_strength character varying(100)
);

