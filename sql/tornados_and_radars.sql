DROP TABLE IF EXISTS public.radar_locations;

DROP TABLE IF EXISTS public.swdiws_nx3tvs_geojson;

CREATE TABLE IF NOT EXISTS public.radar_locations
(
    radar_id character varying(10) COLLATE pg_catalog."default",
    city character varying(100) COLLATE pg_catalog."default",
    state character varying(50) COLLATE pg_catalog."default"
);

CREATE TABLE IF NOT EXISTS public.swdiws_nx3tvs_geojson
(
    cell_type character varying(10) COLLATE pg_catalog."default",
    max_shear integer,
    wsr_id character varying(10) COLLATE pg_catalog."default",
    mxdv integer,
    cell_id character varying(10) COLLATE pg_catalog."default",
    ztime timestamp with time zone,
    azimuth integer,
    range integer,
    type character varying(25) COLLATE pg_catalog."default",
    longitude double precision,
    latitude double precision
);