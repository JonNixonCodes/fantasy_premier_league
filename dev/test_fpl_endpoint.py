# %% Import Python libraries
import requests, json
from pprint import pprint
import pandas as pd

# %% Test FPL API endpoint
base_url = 'https://fantasy.premierleague.com/api/'

# get data from bootstrap-static endpoint
r = requests.get(base_url+'bootstrap-static/').json()

# show the top level fields
pprint(r, indent=2, depth=1, compact=True)
# %% See player data
# get player data from 'elements' field
players = r['elements']

# show data for first player
pprint(players[0])

# %% Inspect with pandas
# create players dataframe
players = pd.json_normalize(r['elements'])

# show some information about first five players
players[['id', 'web_name', 'team', 'element_type']].head()

# %% Get teams
# create teams dataframe
teams = pd.json_normalize(r['teams'])

teams.head()

# %% Get positions
# get position information from 'element_types' field
positions = pd.json_normalize(r['element_types'])

positions.head()

# %% Combine dataframes
# join players to teams
df = pd.merge(
    left=players,
    right=teams,
    left_on='team',
    right_on='id'
)

# show joined result
df[['first_name', 'second_name', 'name']].head()
# %% Join positions
# join player positions
df = df.merge(
    positions,
    left_on='element_type',
    right_on='id'
)

# rename columns
df = df.rename(
    columns={'name':'team_name', 'singular_name':'position_name'}
)

# show result
df[
    ['first_name', 'second_name', 'team_name', 'position_name']
].head()
# %%
# get data from 'element-summary/{PID}/' endpoint for PID=4
r = requests.get(base_url + 'element-summary/4/').json()

# show top-level fields for player summary
pprint(r, depth=1)
# %%
def get_season_history(player_id):
    '''get all past season info for a given player_id'''
    
    # send GET request to
    # https://fantasy.premierleague.com/api/element-summary/{PID}/
    r = requests.get(
            base_url + 'element-summary/' + str(player_id) + '/'
    ).json()
    
    # extract 'history_past' data from response into dataframe
    df = pd.json_normalize(r['history_past'])
    
    return df


# show player #1's gameweek history
get_season_history(1)[
    [
        'season_name',
        'total_points',
        'minutes',
        'goals_scored',
        'assists'
    ]
].head(10)
# %%
def get_gameweek_history(player_id):
    '''get all gameweek info for a given player_id'''
    
    # send GET request to
    # https://fantasy.premierleague.com/api/element-summary/{PID}/
    r = requests.get(
            base_url + 'element-summary/' + str(player_id) + '/'
    ).json()
    
    # extract 'history' data from response into dataframe
    df = pd.json_normalize(r['history'])
    
    return df


# show player #4's gameweek history
get_gameweek_history(4)[
    [
        'round',
        'total_points',
        'minutes',
        'goals_scored',
        'assists'
    ]
].head()

# %% Output fpl endpoint data to file
base_url = 'https://fantasy.premierleague.com/api/'

# get data from bootstrap-static endpoint
r = requests.get(base_url+'bootstrap-static/').json()

with open("data/fpl_bootstrap_static.json", "w") as out_file:
    pprint(r, out_file)
# %%
