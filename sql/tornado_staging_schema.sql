DROP TABLE IF EXISTS public.tornado_details_staging;

CREATE TABLE IF NOT EXISTS public.tornado_details_staging
(
    cell_type VARCHAR(10),
    max_shear INTEGER,
    wsr_id VARCHAR(10),
    mxdv INTEGER,
    cell_id VARCHAR(10),
    ztime TIMESTAMP WITH TIME ZONE,
    azimuth INTEGER,
    range INTEGER,
    type VARCHAR(25),
    longitude DOUBLE PRECISION,
    latitude DOUBLE PRECISION
);