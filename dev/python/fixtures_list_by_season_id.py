import requests

url = "https://football-xg-statistics.p.rapidapi.com/seasons/12310/fixtures/"

headers = {
	"X-RapidAPI-Key": "b0793e2edemsha20e8ebc3877a90p130d6bjsn8341e5462d51",
	"X-RapidAPI-Host": "football-xg-statistics.p.rapidapi.com"
}

response = requests.request("GET", url, headers=headers)

print(response.text)