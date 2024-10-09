
BEGIN;

ALTER TABLE IF EXISTS public.weather_event
    DROP CONSTRAINT weather_event_weather_event_type_id_fkey;


ALTER TABLE IF EXISTS public.weather_event_cost_impact
    DROP CONSTRAINT weather_event_cost_fkey;
   


ALTER TABLE IF EXISTS public.weather_event_cost_impact
    DROP CONSTRAINT weather_event_cost_impact_type_fkey;
   


ALTER TABLE IF EXISTS public.weather_event_cost_impact
    DROP CONSTRAINT weather_event_cost_region_fkey;
 


ALTER TABLE IF EXISTS public.weather_event_human_impact
    DROP CONSTRAINT weather_event_human_fkey;



ALTER TABLE IF EXISTS public.weather_event_human_impact
    DROP CONSTRAINT weather_event_human_impact_type_fkey;


ALTER TABLE IF EXISTS public.weather_event_human_impact
    DROP CONSTRAINT weather_event_human_region_fkey;
   


ALTER TABLE IF EXISTS public.weather_event_radar
    DROP CONSTRAINT weather_event_id;



ALTER TABLE IF EXISTS public.weather_event_radar
    DROP CONSTRAINT weather_event_radar_id_fkey;




CREATE TABLE IF NOT EXISTS public.impact_type
(
    impact_type_id serial NOT NULL,
    impact_type character varying(50) COLLATE pg_catalog."default",
    CONSTRAINT impact_type_pkey PRIMARY KEY (impact_type_id),
    CONSTRAINT impact_type_impact_type_key UNIQUE (impact_type)
);

CREATE TABLE IF NOT EXISTS public.radar_station
(
    radar_id serial NOT NULL,
    radar_name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    station_number character varying(50) COLLATE pg_catalog."default" NOT NULL,
    city character varying(100) COLLATE pg_catalog."default" NOT NULL,
    state character varying(50) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT radar_station_pkey PRIMARY KEY (radar_id),
    CONSTRAINT radar_station_radar_name_key UNIQUE (radar_name)
);

CREATE TABLE IF NOT EXISTS public.region
(
    region_id serial NOT NULL,
    city character varying(100) COLLATE pg_catalog."default",
    state character varying(50) COLLATE pg_catalog."default",
    zip character varying(50) COLLATE pg_catalog."default",
    population_size integer,
    CONSTRAINT region_pkey PRIMARY KEY (region_id)
);

CREATE TABLE IF NOT EXISTS public.weather_event
(
    weather_event_id serial NOT NULL,
    weather_event_type_id integer,
    weather_event_name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    weather_event_description character varying(100) COLLATE pg_catalog."default",
    flood_levels character varying(50) COLLATE pg_catalog."default",
    air_pressure character varying(50) COLLATE pg_catalog."default",
    humidity character varying(50) COLLATE pg_catalog."default",
    tempeture character varying(50) COLLATE pg_catalog."default",
    water_levels character varying(50) COLLATE pg_catalog."default",
    CONSTRAINT weather_event_pkey PRIMARY KEY (weather_event_id),
    CONSTRAINT weather_event_weather_event_name_key UNIQUE (weather_event_name)
);

CREATE TABLE IF NOT EXISTS public.weather_event_cost_impact
(
    weather_event_cost_impact_id serial NOT NULL,
    weather_event_id integer,
    impact_type_id integer,
    region_id integer,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    recovery_cost bigint,
    CONSTRAINT weather_event_cost_impact_pkey PRIMARY KEY (weather_event_cost_impact_id)
);

CREATE TABLE IF NOT EXISTS public.weather_event_human_impact
(
    weather_event_human_impact_id serial NOT NULL,
    weather_event_id integer NOT NULL,
    impact_type_id integer NOT NULL,
    region_id integer NOT NULL,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    recovery_cost bigint,
    casualties character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT weather_event_human_impact_pkey PRIMARY KEY (weather_event_human_impact_id)
);

CREATE TABLE IF NOT EXISTS public.weather_event_radar
(
    weather_event_id serial NOT NULL,
    start_date timestamp without time zone NOT NULL,
    longitude integer NOT NULL,
    latitude integer NOT NULL,
    radar_id integer,
    CONSTRAINT weather_event_id_ckey PRIMARY KEY (weather_event_id)
);

CREATE TABLE IF NOT EXISTS public.weather_event_type
(
    weather_event_type_id serial NOT NULL,
    weather_event_type character varying(50) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT weather_event_type_pkey PRIMARY KEY (weather_event_type_id)
);

ALTER TABLE IF EXISTS public.weather_event
    ADD CONSTRAINT weather_event_weather_event_type_id_fkey FOREIGN KEY (weather_event_type_id)
    REFERENCES public.weather_event_type (weather_event_type_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.weather_event_cost_impact
    ADD CONSTRAINT weather_event_cost_fkey FOREIGN KEY (weather_event_id)
    REFERENCES public.weather_event (weather_event_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.weather_event_cost_impact
    ADD CONSTRAINT weather_event_cost_impact_type_fkey FOREIGN KEY (impact_type_id)
    REFERENCES public.impact_type (impact_type_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.weather_event_cost_impact
    ADD CONSTRAINT weather_event_cost_region_fkey FOREIGN KEY (region_id)
    REFERENCES public.region (region_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.weather_event_human_impact
    ADD CONSTRAINT weather_event_human_fkey FOREIGN KEY (weather_event_id)
    REFERENCES public.weather_event (weather_event_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.weather_event_human_impact
    ADD CONSTRAINT weather_event_human_impact_type_fkey FOREIGN KEY (impact_type_id)
    REFERENCES public.impact_type (impact_type_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.weather_event_human_impact
    ADD CONSTRAINT weather_event_human_region_fkey FOREIGN KEY (region_id)
    REFERENCES public.region (region_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.weather_event_radar
    ADD CONSTRAINT weather_event_id FOREIGN KEY (weather_event_id)
    REFERENCES public.weather_event (weather_event_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
CREATE INDEX IF NOT EXISTS weather_event_id_ckey
    ON public.weather_event_radar(weather_event_id);


ALTER TABLE IF EXISTS public.weather_event_radar
    ADD CONSTRAINT weather_event_radar_id_fkey FOREIGN KEY (radar_id)
    REFERENCES public.radar_station (radar_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

END;