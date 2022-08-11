# %% Import libraries
import json
import functions_framework
from google.cloud import pubsub_v1

# %% main function
# Register a CloudEvent function with the Functions Framework
@functions_framework.cloud_event
def trigger_handler(cloud_event):
    # Your code here
    # Access the CloudEvent data payload via cloud_event.data
    
    project_id = "sandbox-egl1hjn"
    topic_id = "fantasy-premier-league-landing-object-finalised"

    publisher = pubsub_v1.PublisherClient()

    # The `topic_path` method creates a fully qualified identifier
    # in the form `projects/{project_id}/topics/{topic_id}`
    topic_path = publisher.topic_path(project_id, topic_id)

    # Publish message cloud event data
    pubsub_message = json.dumps(cloud_event.data, indent=2).encode('utf-8')

    # When you publish a message, the client returns a future.
    future = publisher.publish(topic_path, pubsub_message)
    print(future.result())

    return 'OK'
