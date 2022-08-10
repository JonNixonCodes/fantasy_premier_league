# %% Import libraries
import base64,json
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
    # Get name of bucket/bucket
    pubsub_message_data = json.loads(base64.b64decode(cloud_event.data["message"]["data"]).decode())
    bucket_name = pubsub_message_data["bucket"]
    blob_name = pubsub_message_data["name"]
    
    # Load blob as dictionary
    blob_data = json.loads(download_blob_as_bytes(bucket_name,blob_name))

    # Extract metadata
    source_url = blob_data["source_url"]
    source_date = blob_data["source_date"]

    # Export events data
    events = blob_data["data"]["events"]

    # Export teams
    teams = blob_data["data"]["teams"]

    # Export elements (players)
    elements = blob_data["data"]["elements"]

    return 'OK'
