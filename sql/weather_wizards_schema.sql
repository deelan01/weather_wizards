-- First, clean up existing tables to ensure a fresh start
-- Tables are dropped in reverse order of their dependencies
-- CASCADE is used to automatically drop dependent objects (like foreign keys)
DROP TABLE IF EXISTS public.weather_event_radar CASCADE;
DROP TABLE IF EXISTS public.weather_event_human_impact CASCADE;
DROP TABLE IF EXISTS public.weather_event_cost_impact CASCADE;
DROP TABLE IF EXISTS public.weather_event CASCADE;
DROP TABLE IF EXISTS public.weather_event_type CASCADE;
DROP TABLE IF EXISTS public.region CASCADE;
DROP TABLE IF EXISTS public.radar_station CASCADE;
DROP TABLE IF EXISTS public.impact_type CASCADE;

-- Reference table for different types of weather impacts (e.g., property damage, crop damage)
CREATE TABLE IF NOT EXISTS public.impact_type (
   impact_type_id SERIAL PRIMARY KEY,
   impact_type VARCHAR(50) UNIQUE NOT NULL,  -- Unique impact type names
   created_at TIMESTAMP DEFAULT NOW(),       -- Audit timestamps
   updated_at TIMESTAMP DEFAULT NOW()
);

-- Stores information about weather radar stations
CREATE TABLE IF NOT EXISTS public.radar_station (
   radar_id SERIAL PRIMARY KEY,
   radar_name VARCHAR(100) UNIQUE NOT NULL,  -- Unique radar station names
   city VARCHAR(100) NOT NULL,
   state VARCHAR(2) NOT NULL CHECK (LENGTH(state) = 2),  -- Enforces 2-character state codes
   created_at TIMESTAMP DEFAULT NOW(),
   updated_at TIMESTAMP DEFAULT NOW(),
   CONSTRAINT radar_station_name_city_state UNIQUE (radar_name, city, state)  -- Prevents duplicate stations
);

-- Stores geographical regions (cities/ZIP codes) affected by weather events
CREATE TABLE IF NOT EXISTS public.region (
   region_id SERIAL PRIMARY KEY,
   city VARCHAR(100) NOT NULL,
   state VARCHAR(2) NOT NULL CHECK (LENGTH(state) = 2),  -- Enforces 2-character state codes
   zip VARCHAR(10) CHECK (LENGTH(zip) BETWEEN 5 AND 10), -- Allows both ZIP and ZIP+4 formats
   population_size INTEGER CHECK (population_size >= 0),  -- Ensures valid population counts
   latitude DOUBLE PRECISION NOT NULL,
   longitude DOUBLE PRECISION NOT NULL,
   created_at TIMESTAMP DEFAULT NOW(),
   updated_at TIMESTAMP DEFAULT NOW(),
   CONSTRAINT region_unique_city_state_zip UNIQUE (city, state, zip)  -- Prevents duplicate regions
);

-- Reference table for types of weather events (e.g., hurricane, tornado)
CREATE TABLE IF NOT EXISTS public.weather_event_type (
   weather_event_type_id serial NOT NULL PRIMARY KEY,
   weather_event_type VARCHAR(50) UNIQUE NOT NULL,      -- Unique event type names
   weather_event_type_code VARCHAR(5) UNIQUE NOT NULL,  -- Short codes for event types
   created_at TIMESTAMP DEFAULT NOW(),
   updated_at TIMESTAMP DEFAULT NOW()
);

-- Main table for weather events (storms, hurricanes, etc.)
CREATE TABLE IF NOT EXISTS public.weather_event (
   event_id SERIAL PRIMARY KEY,
   weather_event_name VARCHAR(100) NOT NULL,           -- Name of the event (e.g., Hurricane Katrina)
   weather_event_type_id INTEGER REFERENCES weather_event_type(weather_event_type_id) ON DELETE CASCADE,
   region_id INTEGER REFERENCES region(region_id) ON DELETE SET NULL,  -- Main affected region
   start_date DATE NOT NULL,
   end_date DATE NOT NULL,
   created_at TIMESTAMP DEFAULT NOW(),
   updated_at TIMESTAMP DEFAULT NOW(),
   CONSTRAINT weather_event_date_check CHECK (end_date >= start_date),  -- Ensures valid date range
   CONSTRAINT weather_event_name_unq UNIQUE (weather_event_name, weather_event_type_id)  -- Prevents duplicate events
);

-- Tracks financial impacts of weather events
CREATE TABLE IF NOT EXISTS public.weather_event_cost_impact (
   event_cost_id SERIAL PRIMARY KEY,
   weather_event_id INTEGER REFERENCES weather_event(event_id) ON DELETE CASCADE,
   impact_type_id INTEGER REFERENCES impact_type(impact_type_id) ON DELETE CASCADE,
   region_id INTEGER REFERENCES region(region_id) ON DELETE SET NULL,
   cost_amount NUMERIC(12, 2) CHECK (cost_amount >= 0),  -- Monetary impact with 2 decimal places
   created_at TIMESTAMP DEFAULT NOW(),
   updated_at TIMESTAMP DEFAULT NOW()
);

-- Tracks human impacts of weather events (casualties, injuries)
CREATE TABLE IF NOT EXISTS public.weather_event_human_impact (
   human_impact_id SERIAL PRIMARY KEY,
   weather_event_id INTEGER REFERENCES weather_event(event_id) ON DELETE CASCADE,
   impact_type_id INTEGER REFERENCES impact_type(impact_type_id) ON DELETE CASCADE,
   region_id INTEGER REFERENCES region(region_id) ON DELETE SET NULL,
   recovery_cost NUMERIC(12, 2) CHECK (recovery_cost >= 0),  -- Cost of human recovery efforts
   casualties INTEGER CHECK (casualties >= 0),               -- Number of casualties
   created_at TIMESTAMP DEFAULT NOW(),
   updated_at TIMESTAMP DEFAULT NOW()
);

-- Stores radar measurements and readings for weather events
CREATE TABLE IF NOT EXISTS public.weather_event_radar (
   radar_event_id SERIAL PRIMARY KEY,
   weather_event_id INTEGER REFERENCES weather_event(event_id) ON DELETE CASCADE,
   radar_id INTEGER REFERENCES radar_station(radar_id) ON DELETE CASCADE,
   radar_date TIMESTAMP WITH TIME ZONE NOT NULL,        -- Timestamp of radar reading
   latitude DOUBLE PRECISION NOT NULL,                  -- Location of reading
   longitude DOUBLE PRECISION NOT NULL,
   wind_speed_mph INTEGER,                             -- Various radar measurements
   atmospheric_pressure_mb INTEGER,
   max_shear INTEGER,
   max_doppler_velocity_knots INTEGER,
   azimuth_degrees INTEGER,
   nautical_miles_from_radar INTEGER,
   created_at TIMESTAMP DEFAULT NOW(),
   updated_at TIMESTAMP DEFAULT NOW(),
   CONSTRAINT weather_event_radar_unique UNIQUE (weather_event_id, radar_id, radar_date, latitude, longitude)  -- Prevents duplicate readings
);