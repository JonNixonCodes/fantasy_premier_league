# fantasy_premier_league
Fantasy Premier League

## Usage
### Deploy cloud functions
```
# Gen1
gcloud functions deploy fantasy_premierleague_api_fixtures_day --runtime=python310 --trigger-http --allow-unauthenticated
# Gen2
gcloud functions deploy fantasy-premierleague-api-elementsummary-day\
--gen2\
--runtime=python310\
--source=.\
--entry-point=fantasy_premierleague_api_elementsummary_day\
--trigger-http\
--allow-unauthenticated\
--timeout=1200
```
### Trigger cloud functions
```
curl https://us-central1-sandbox-egl1hjn.cloudfunctions.net/fantasy_premierleague_api_fixtures_day?bucket=fantasy-premier-league
```
### Cloud scheduler to trigger function daily
```
gcloud scheduler jobs create http fantasy_premierleague_api_fixtures_day --location=us-central1 --schedule='0 6 * * *' --uri=https://us-central1-sandbox-egl1hjn.cloudfunctions.net/fantasy_premierleague_api_fixtures_day?bucket=fantasy-premier-league
```

### Creating pubsub topic
```
gcloud pubsub topics create gcs_landing_object_finalised
```