# %% Import libraries
import requests, json
import datetime
from google.cloud import storage

# %% Request data from fantasy premier league API endpoint
url = 'https://fantasy.premierleague.com/api/bootstrap-static/'

# get data from bootstrap-static endpoint
data = requests.get(url).text

# %% Upload object
def upload_blob(bucket_name, source_object, destination_blob_name):
    """Uploads a file to the bucket."""
    # The ID of your GCS bucket
    # bucket_name = "your-bucket-name"
    # The path to your file to upload
    # source_file_name = "local/path/to/file"
    # The ID of your GCS object
    # destination_blob_name = "storage-object-name"

    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)

    blob.upload_from_string(source_object)

    print(
        f"Data uploaded to {destination_blob_name}."
    )

bucket_name = "fantasy-premier-league"
destination_blob_name = "fantasy_premier_league_api_bootstrap_static/"+datetime.date.today().strftime("%Y%m%d")+".json"
source_object = data

upload_blob(bucket_name, source_object, destination_blob_name)
