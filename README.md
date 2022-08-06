# fantasy_premier_league
Fantasy Premier League

## Usage
### Deploy cloud functions
```
gcloud functions deploy fantasy_premierleague_api_fixtures_day --runtime=python310 --trigger-http
```
### Trigger cloud functions
```
curl https://us-central1-sandbox-egl1hjn.cloudfunctions.net/fantasy_premierleague_api_fixtures_day?bucket=fantasy-premier-league
```
### Cloud scheduler to trigger function daily
```
gcloud scheduler jobs create http fantasy_premierleague_api_fixtures_day --location=us-central1 --schedule='0 6 * * *' --uri=https://us-central1-sandbox-egl1hjn.cloudfunctions.net/fantasy_premierleague_api_fixtures_day?bucket=fantasy-premier-league
```