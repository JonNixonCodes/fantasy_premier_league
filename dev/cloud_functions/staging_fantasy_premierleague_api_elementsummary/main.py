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
    if re.search("fantasy_premierleague_api_elementsummary", blob_name)==None:
        return 'OK'

    # Load blob as dictionary
    blob_data = json.loads(download_blob_as_bytes(bucket_name,blob_name))

    # Extract metadata
    source_url = blob_data["source_url"]
    source_date = blob_data["source_date"]
    element_id = blob_data["element_id"]
    source_date_str = datetime.datetime.strftime(datetime.datetime.strptime(source_date, "%Y-%m-%d %H:%M:%S"),"%Y-%m-%d")

    # Export fixtures
    fixtures_blob_name = f"fantasy_premierleague_api_elementsummary_fixtures/source_date={source_date_str}/element_id={str(element_id)}/data00.jsonl"
    fixtures = blob_data["data"]["fixtures"]
    fixtures_str = "\n".join([json.dumps(fixture) for fixture in fixtures])
    fixtures_bytes = fixtures_str.encode('utf-8')
    upload_blob(staging_bucket_name, fixtures_bytes, fixtures_blob_name)

    # Export history
    history_blob_name = f"fantasy_premierleague_api_elementsummary_history/source_date={source_date_str}/element_id={str(element_id)}/data00.jsonl"
    history = blob_data["data"]["history"]
    history_str = "\n".join([json.dumps(h) for h in history])
    history_bytes = history_str.encode('utf-8')
    upload_blob(staging_bucket_name, history_bytes, history_blob_name)

    # Export history_past
    history_past_blob_name = f"fantasy_premierleague_api_elementsummary_historypast/source_date={source_date_str}/element_id={str(element_id)}/data00.jsonl"
    history_past = blob_data["data"]["history_past"]
    history_past_str = "\n".join([json.dumps(h) for h in history_past])
    history_past_bytes = history_past_str.encode('utf-8')
    upload_blob(staging_bucket_name, history_past_bytes, history_past_blob_name)

    return 'OK'
