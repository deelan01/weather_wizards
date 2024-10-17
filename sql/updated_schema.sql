-- Drop existing tables and constraints if they exist
DROP TABLE IF EXISTS public.weather_event_radar CASCADE;
DROP TABLE IF EXISTS public.weather_event_human_impact CASCADE;
DROP TABLE IF EXISTS public.weather_event_cost_impact CASCADE;
DROP TABLE IF EXISTS public.weather_event CASCADE;
DROP TABLE IF EXISTS public.weather_event_type CASCADE;
DROP TABLE IF EXISTS public.region CASCADE;
DROP TABLE IF EXISTS public.radar_station CASCADE;
DROP TABLE IF EXISTS public.impact_type CASCADE;


-- Table: impact_type
CREATE TABLE IF NOT EXISTS public.impact_type (
    impact_type_id SERIAL PRIMARY KEY,
    impact_type VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Table: radar_station
CREATE TABLE IF NOT EXISTS public.radar_station (
    radar_id SERIAL PRIMARY KEY,
    radar_name VARCHAR(100) UNIQUE NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(2) NOT NULL CHECK (LENGTH(state) = 2),  -- Standard US State Code Length
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT radar_station_name_city_state UNIQUE (radar_name, city, state) -- Prevents duplication of station per city/state
);

-- Table: region
CREATE TABLE IF NOT EXISTS public.region (
    region_id SERIAL PRIMARY KEY,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(2) NOT NULL CHECK (LENGTH(state) = 2),  -- Standard US State Code Length
    zip VARCHAR(10) CHECK (LENGTH(zip) BETWEEN 5 AND 10), -- ZIP or ZIP+4 formats
    population_size INTEGER CHECK (population_size >= 0), -- Ensures population size is non-negative
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT region_unique_city_state_zip UNIQUE (city, state, zip) -- Ensures no duplicate city/state/zip combinations
);

-- Table: weather_event_type
CREATE TABLE IF NOT EXISTS public.weather_event_type
(
    weather_event_type_id serial NOT NULL PRIMARY KEY,
    weather_event_type VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Table: weather_event
CREATE TABLE IF NOT EXISTS public.weather_event (
    event_id SERIAL PRIMARY KEY,
    weather_event_name VARCHAR(100) NOT NULL,
    weather_event_type_id INTEGER REFERENCES weather_event_type(weather_event_type_id) ON DELETE CASCADE,
    radar_id INTEGER REFERENCES radar_station(radar_id) ON DELETE SET NULL,
    region_id INTEGER REFERENCES region(region_id) ON DELETE SET NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT weather_event_date_check CHECK (end_date >= start_date), -- Ensures end date is after start date
    CONSTRAINT weather_event_name_unq UNIQUE (weather_event_name) -- Ensures no unique weather event (storm) name
);

-- Table: weather_event_cost_impact
CREATE TABLE IF NOT EXISTS public.weather_event_cost_impact (
    event_cost_id SERIAL PRIMARY KEY,
    weather_event_id INTEGER REFERENCES weather_event(event_id) ON DELETE CASCADE,
    impact_type_id INTEGER REFERENCES impact_type(impact_type_id) ON DELETE CASCADE,
    region_id INTEGER REFERENCES region(region_id) ON DELETE SET NULL,
    cost_amount NUMERIC(12, 2) CHECK (cost_amount >= 0), -- Ensures cost is non-negative
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Table: weather_event_human_impact
CREATE TABLE IF NOT EXISTS public.weather_event_human_impact (
    human_impact_id SERIAL PRIMARY KEY,
    weather_event_id INTEGER REFERENCES weather_event(event_id) ON DELETE CASCADE,
    impact_type_id INTEGER REFERENCES impact_type(impact_type_id) ON DELETE CASCADE,
    region_id INTEGER REFERENCES region(region_id) ON DELETE SET NULL,
    recovery_cost NUMERIC(12, 2) CHECK (recovery_cost >= 0), -- Ensures cost is non-negative
    casualties INTEGER CHECK (casualties >= 0),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Table: weather_event_radar
CREATE TABLE IF NOT EXISTS public.weather_event_radar (
    radar_event_id SERIAL PRIMARY KEY,
    weather_event_id INTEGER REFERENCES weather_event(event_id) ON DELETE CASCADE,
    radar_id INTEGER REFERENCES radar_station(radar_id) ON DELETE CASCADE,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT weather_event_radar_unique UNIQUE (weather_event_id, radar_id, latitude, longitude)
);