# Standard library imports
import sys
import subprocess
from pathlib import Path

# Import Dependencies
import psycopg2
from pymongo import MongoClient
from pprint import pprint
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine
from sqlalchemy import func

# Local application imports
from utils import fetch_api_data, load_config, write_to_csv

# Load configuration from a JSON file
config = load_config('config.json')

# Retrieve the database credentials from the configuration
mongodb_user = config.get('mongodb_cluster', {}).get('user')
mongodb_pswd = config.get('mongodb_cluster', {}).get('password')
mongodb_srvr = config.get('mongodb_cluster', {}).get('server')

# Check if the API key was found in the configuration
if not mongodb_user or not mongodb_pswd:
    print("MongoDB credentials not found in the configuration file.")
    sys.exit()  # Exit the script if the key is missing


mongo_uri = f"mongodb+srv://{mongodb_user}:{mongodb_pswd}@{mongodb_srvr}/"

# Load data in MongoDB using the CSV file
def mongoImportFromCSV(mongo_uri, db_name, collection_name, csv_file_location ):
    # Build the mongoimport command
    """Function: mongoImportFromCSV"""

    command = [
        'mongoimport',
        '--uri', mongo_uri,
        '--db', db_name,
        '--collection', collection_name,
        '--type', 'csv',
        '--headerline',  # Assumes the first line of the CSV file contains column headers
        '--file', str(csv_file_location),
        '--drop'
    ]
    # Execute the command
    try:
        subprocess.run(command, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error importing {csv_file_location}: {e}")
    
    print(f"Imported {csv_file_location} into collection {collection_name}.")


def getDatabase(mongo, db_name):    
    """Function: getDatabase"""

    print(mongo.list_database_names())
    db = mongo[f'{db_name}']  
    return db

def checkCollectionNames(db):      
    """Function: checkCollectionNames"""

    return db.list_collection_names()

# Create a query that finds the all documents in the category collection
def getCollectionCount(db, collection_name):   
    """Function: getCollectionCount"""

    collection_data = db[collection_name]
    query = {}
    results = collection_data.find(query)
    # Print the number of results
    # print(f"Number of {collection_name} :", collection_data.count_documents({}))
    return collection_data.count_documents({})

def populateDatabase(db_name, mongo_uri, object_names):
    """Function: populateDatabase"""

    for each in object_names:
        file_name = f'Resources/{each}.csv'
        mongoImportFromCSV(mongo_uri,db_name,each,file_name)    


def createMongoDBCluster(db_name, object_names):   
    """Function: createMongoDBCluster"""

    populateDatabase(db_name, mongo_uri, object_names)
    

def validateMongoDBCluster(db_name):
    """Function: validateMongoDBCluster"""

    mongo = MongoClient(mongo_uri)
    db = getDatabase(mongo, db_name)
    collection_names = checkCollectionNames(db)
    print(collection_names)   
    for each in collection_names:        
        print(f'{each} {getCollectionCount(db,str(each))}')
    mongo.close()