DROP TABLE IF EXISTS public.swdiws_nx3tvs_geojson;

CREATE TABLE IF NOT EXISTS public.swdiws_nx3tvs_geojson
(
    cell_type character varying(10),
    max_shear integer,
    wsr_id character varying(10),
    mxdv integer,
    cell_id character varying(10),
    ztime timestamp with time zone,
    azimuth integer,
    range integer,
    type character varying(25),
    longitude double precision,
    latitude double precision
);