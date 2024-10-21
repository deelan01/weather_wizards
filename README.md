<h1>Weather Wizards: Storm Data ETL and Visualization</h1>

<h2>1. Project Overview</h2>
<p>This project provides an end-to-end solution for loading, transforming, and analyzing weather-related data in a PostgreSQL database, along with a web-based interface for visualizing storm impacts. The focus is on tornado and hurricane data, including staging, transformation, and visualization processes to enable detailed weather analysis. The website allows users to interact with the processed data and view visualizations of storm impacts across the United States.</p>

<h2>2. Tech Stack</h2>
<h3>Backend:</h3>
<ul>
  <li><strong>PostgreSQL</strong>: Local data storage and schema-based organization of weather events, human, and financial impacts.</li>
  <li><strong>Flask</strong>: Python web framework for serving APIs that interact with the database.</li>
  <li><strong>SQLAlchemy</strong>: ORM to interact with PostgreSQL databases in Python.</li>
  <li><strong>JavaScript</strong>: Interacts with the Flask backend to request and display data dynamically in the frontend.</li>
</ul>

<h3>Frontend:</h3>
<ul>
  <li><strong>HTML/CSS/JavaScript</strong>: For building the UI of the dashboard.</li>
  <li><strong>D3.js and Plotly.js</strong>: For generating interactive data visualizations like charts and graphs.</li>
  <li><strong>Leaflet.js</strong>: For mapping weather events with geographical data.</li>
</ul>

<h3>Data Processing:</h3>
<ul>
  <li><strong>Python</strong>: Used to handle the Extract, Transform, Load (ETL) process of preparing and cleaning weather datasets.</li>
  <li><strong>SQL</strong>: Schema design and querying in PostgreSQL for efficient storage and retrieval of data.</li>
</ul>

<h2>3. Folder Structure</h2>
<pre>
├── data/                    # Contains raw CSV data files for hurricanes, tornadoes, etc.
├── logos/                   # Contains logos and visual assets for the dashboard.
├── sql/                     # SQL scripts for creating and loading database schema and tables.
│   ├── hurricane_staging_schema.sql
│   ├── load_weather_tables.sql
│   ├── tornado_staging_schema.sql
│   └── weather_wizards_schema.sql  # Main schema with all required tables.
├── utils/                   # Utility scripts for ETL processes, data fetching, and data cleaning.
├── config_template.json      # Configuration template for API keys and DB connections.
├── .gitignore                # Files and directories to be ignored by Git.
├── hurricane.webp            # Visual asset for hurricane-related data.
├── index.html                # Main webpage for the interactive dashboard.
</pre>

<h2>4. Database Design</h2>
<h3>PostgreSQL Schema Overview</h3>
<p>The <strong>weather_wizards_schema</strong> consists of the following main tables:</p>
<ul>
  <li><strong>impact_type</strong>: Stores types of impacts (e.g., property damage, human casualties).</li>
  <li><strong>radar_station</strong>: Stores details of radar stations.</li>
  <li><strong>region</strong>: Geographical data for cities or ZIP codes affected by weather events.</li>
  <li><strong>weather_event_type</strong>: Types of weather events (e.g., hurricanes, tornadoes).</li>
  <li><strong>weather_event</strong>: Core table storing weather event metadata.</li>
  <li><strong>weather_event_cost_impact</strong>: Financial impacts of weather events.</li>
  <li><strong>weather_event_human_impact</strong>: Human impacts like casualties and recovery costs.</li>
  <li><strong>weather_event_radar</strong>: Stores radar readings associated with weather events.</li>
</ul>

<h3>Example: weather_event Table</h3>
<pre>
CREATE TABLE IF NOT EXISTS public.weather_event (
   event_id SERIAL PRIMARY KEY,
   weather_event_name VARCHAR(100) NOT NULL,
   weather_event_type_id INTEGER REFERENCES weather_event_type(weather_event_type_id) ON DELETE CASCADE,
   region_id INTEGER REFERENCES region(region_id) ON DELETE SET NULL,
   start_date DATE NOT NULL,
   end_date DATE NOT NULL,
   created_at TIMESTAMP DEFAULT NOW(),
   updated_at TIMESTAMP DEFAULT NOW(),
   CONSTRAINT weather_event_date_check CHECK (end_date >= start_date),
   CONSTRAINT weather_event_name_unq UNIQUE (weather_event_name, weather_event_type_id)
);
</pre>

<h2>5. Data Sources</h2>
<ul>
  <li><strong>Tornado Data</strong>: National Oceanic and Atmospheric Administration (NOAA).</li>
  <li><strong>Hurricane Data</strong>: National Hurricane Center (NHC).</li>
  <li><strong>Blizzard Data</strong>: National Weather Service (NWS).</li>
  <li><strong>Impact Data</strong>: FEMA, insurance agencies, public datasets.</li>
</ul>

<h2>6. ETL Pipeline</h2>
<ul>
  <li><strong>Extract:</strong> Data sourced from CSV, JSON, and APIs.</li>
  <li><strong>Transform:</strong> Cleaning and normalizing data using Python (Pandas) and SQLAlchemy.</li>
  <li><strong>Load:</strong> Store cleaned data in PostgreSQL for structured querying and analysis.</li>
</ul>

<h2>7. Frontend Design</h2>
<h3>Interactive Dashboard Layout:</h3>
<ul>
  <li><strong>Filters:</strong> Users can filter data by event type (e.g., hurricane), date range, and location.</li>
  <li><strong>Visualizations:</strong></li>
  <ul>
    <li><strong>Bar Charts:</strong> Display the number of events and impacts by year.</li>
    <li><strong>Line Graphs:</strong> Show trends in event frequency over time.</li>
    <li><strong>Geographic Maps (Leaflet.js):</strong> Visualize events on a map with markers for event severity and impact.</li>
  </ul>
</ul>

<h3>Example: Geographic Visualizations</h3>
<p><strong>Leaflet.js:</strong> Used for mapping weather events with custom layers (e.g., tornado paths, hurricane tracks).</p>

<h2>8. Backend API Design</h2>
<p>The backend provides RESTful API endpoints via Flask, allowing the frontend to retrieve and filter weather event data. Sample Flask route for weather event data:</p>
<pre>
@app.route('/api/weather-events')
def get_weather_events():
    # Query PostgreSQL and return data as JSON
    events = WeatherEvent.query.all()
    return jsonify([event.to_dict() for event in events])
</pre>

<h2>9. Version Control & Collaboration</h2>
<ul>
  <li><strong>GitHub:</strong> Used for version control, branching, and collaboration. The project is structured into different branches for backend and frontend development.</li>
  <li><strong>GitHub Actions:</strong> Integrated for continuous integration and testing.</li>
</ul>

<h2>10. Future Enhancements</h2>
<ul>
  <li><strong>Real-Time Data Integration:</strong> Add APIs for real-time weather data.</li>
  <li><strong>User-Uploaded Data:</strong> Allow users to upload weather data for analysis.</li>
  <li><strong>Machine Learning:</strong> Explore predictive modeling for weather event impacts.</li>
</ul>

<h2>11. Data Ethics</h2>
<p>This project establishes and upholds proper data handling to ensure the data is transparent up to date and protects user privacy. Our data sources such as NOAA, FEMA and many more are properly cited and comply to public data policies. Aforementioned in the beginning, this project ensures user privacy is not violated by masking sensitive information from Postgres and MongoDB in a config file. We also made sure to use a vast number of datasets to create a non biased and fair depiction of our story and environmental impacts. Our efforts  reflect a promise to uphold ethical data management, data handling and data accuracy. </p>