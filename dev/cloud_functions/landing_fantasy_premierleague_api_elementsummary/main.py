# %% Import libraries
import functions_framework,requests,json
import datetime
from google.cloud import storage

# %% Fantasy Premier League API endpoint
bootstrap_url = 'https://fantasy.premierleague.com/api/bootstrap-static/'
base_url = 'https://fantasy.premierleague.com/api/element-summary/'
source_date = datetime.date.today()

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

# %% main function
@functions_framework.http
def request_handler(request):
    """HTTP Cloud Function.
    Args:
        request (flask.Request): The request object.
        <https://flask.palletsprojects.com/en/1.1.x/api/#incoming-request-data>
    Returns:
        The response text, or any set of values that can be turned into a
        Response object using `make_response`
        <https://flask.palletsprojects.com/en/1.1.x/api/#flask.make_response>.
    """
    # Flask request object
    request_json = request.get_json(silent=True)
    request_args = request.args
    # Check Flask request object for input parameter
    if request_json and 'bucket' in request_json:
        bucket_name = request_json['bucket']
    elif request_args and 'bucket' in request_args:
        bucket_name = request_args['bucket']
    else:
        return {'error':'missing input parameter:bucket'}
    # Request data from fantasy premier league bootstrap-static endpoint
    r = requests.get(bootstrap_url)
    elements = r.json()['elements']
    element_ids = [e['id'] for e in elements]
    # Loop through each element
    for element_id in element_ids:
        # Append metadata
        url = base_url+str(element_id)+"/"
        r = requests.get(url)
        data = {"source_url":url, "source_date":source_date.strftime("%Y-%m-%d %H:%M:%S"), "element_id":element_id, "data":r.json()}
        # Load data to GCS
        destination_blob_name = "fantasy_premierleague_api_elementsummary/{}_{}.json".format(str(element_id),source_date.strftime("%Y%m%d"))
        source_object = json.dumps(data)
        upload_blob(bucket_name, source_object, destination_blob_name)
    return 'OK'
