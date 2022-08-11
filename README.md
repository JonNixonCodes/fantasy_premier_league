# fantasy_premier_league
Fantasy Premier League

## Usage
### Deploy cloud functions
```
# Gen1
gcloud functions deploy staging-fantasy-premier-league-api-bootstrapstatic \
--region=australia-southeast1 \
--entry-point=event_handler \
--runtime=python310 \
--source=. \
--trigger-topic=fantasy-premier-league-landing-object-finalised

# Gen2
gcloud functions deploy landing-fantasy-premierleague-api-elementsummary \
--region=australia-southeast1 \
--allow-unauthenticated \
--entry-point=request_handler \
--gen2 \
--runtime=python310 \
--source=. \
--trigger-http \
--timeout=1200
```
### Trigger cloud functions
```
curl https://australia-southeast1-sandbox-egl1hjn.cloudfunctions.net/landing-fantasy-premierleague-api-bootstrapstatic?bucket=fantasy-premier-league-landing
```
### Cloud scheduler to trigger function daily
```
gcloud scheduler jobs create http landing-fantasy-premierleague-api-bootstrapstatic-day \
--location=australia-southeast1 \
--schedule='0 1 * * *' \
--uri=https://australia-southeast1-sandbox-egl1hjn.cloudfunctions.net/landing-fantasy-premierleague-api-bootstrapstatic?bucket=fantasy-premier-league-landing
```

### Creating pubsub topic
```
gcloud pubsub topics create fantasy-premier-league-landing-object-finalised
```

### Create table definition file
```
bq mkdef \
--source_format=NEWLINE_DELIMITED_JSON \
--hive_partitioning_mode=CUSTOM \
--hive_partitioning_source_uri_prefix=gs://fantasy-premier-league-staging/fantasy_premierleague_api_bootstrapstatic_events/{source_date:DATE} \
--require_hive_partition_filter=false \
 gs://fantasy-premier-league-staging/fantasy_premierleague_api_bootstrapstatic_events/*.jsonl > fantasy_premierleague_api_bootstrapstatic_events_def
```

### Create BigQuery dataset
```
bq --location=australia-southeast1 mk \
    --dataset \
    sandbox-egl1hjn:fantasy_premier_league
```

### Create BigQuery external table
```
bq mk --external_table_definition=fantasy_premierleague_api_bootstrapstatic_events_def \
fantasy_premier_league.staging_fantasy_premierleague_api_bootstrapstatic_events
```