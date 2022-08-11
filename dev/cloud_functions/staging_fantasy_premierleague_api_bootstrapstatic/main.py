# %% Import libraries
import base64,json,datetime,re
import functions_framework
from google.cloud import storage

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

def download_blob_as_bytes(bucket_name, blob_name):
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(blob_name)
    return blob.download_as_bytes()
      

# %% main function
# Register a CloudEvent function with the Functions Framework
@functions_framework.cloud_event
def event_handler(cloud_event):
    # Your code here
    # Access the CloudEvent data payload via cloud_event.data

    staging_bucket_name = "fantasy-premier-league-staging"

    # Get name of bucket/blob
    pubsub_message_data = json.loads(base64.b64decode(cloud_event.data["message"]["data"]).decode('utf-8'))
    bucket_name = pubsub_message_data["bucket"]
    blob_name = pubsub_message_data["name"]

    # Check if updated blob is in folder:fantasy_premierleague_api_bootstrapstatic
    if re.search("fantasy_premierleague_api_bootstrapstatic", blob_name)==None:
        return 'OK'

    # Load blob as dictionary
    blob_data = json.loads(download_blob_as_bytes(bucket_name,blob_name))

    # Extract metadata
    source_url = blob_data["source_url"]
    source_date = blob_data["source_date"]
    source_date_str = datetime.datetime.strftime(datetime.datetime.strptime(source_date, "%Y-%m-%d %H:%M:%S"),"%Y-%m-%d")

    # Export events data
    events_blob_name = f"fantasy_premierleague_api_bootstrapstatic_events/source_date={source_date_str}/data00.jsonl"
    events = blob_data["data"]["events"]
    events_str = "\n".join([json.dumps(event) for event in events])
    events_bytes = events_str.encode('utf-8')
    upload_blob(staging_bucket_name, events_bytes, events_blob_name)

    # Export teams
    teams_blob_name = f"fantasy_premierleague_api_bootstrapstatic_teams/source_date={source_date_str}/data00.jsonl"
    teams = blob_data["data"]["teams"]
    teams_str = "\n".join([json.dumps(team) for team in teams])
    teams_bytes = teams_str.encode('utf-8')
    upload_blob(staging_bucket_name, teams_bytes, teams_blob_name)

    # Export elements (players)
    elements_blob_name = f"fantasy_premierleague_api_bootstrapstatic_elements/source_date={source_date_str}/data00.jsonl"
    elements = blob_data["data"]["elements"]
    elements_str = "\n".join([json.dumps(element) for element in elements])
    elements_bytes = elements_str.encode('utf-8')
    upload_blob(staging_bucket_name, elements_bytes, elements_blob_name)

    return 'OK'
