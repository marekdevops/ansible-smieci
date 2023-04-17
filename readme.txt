import argparse
import json

parser = argparse.ArgumentParser()
parser.add_argument("exp_date", help="Expiration date to search for")
args = parser.parse_args()

with open("output.json") as f:
    data = json.load(f)

for item in data:
    if "exp_date" in item and item["exp_date"] == args.exp_date:
        print(item)


import argparse
from datetime import datetime, timedelta

parser = argparse.ArgumentParser()
parser.add_argument("start_date", help="Starting date")
args = parser.parse_args()

start_date = datetime.strptime(args.start_date, "%Y-%m-%d")
end_date = start_date + timedelta(days=360)

print("Starting date:", start_date.strftime("%Y-%m-%d"))
print("Ending date:", end_date.strftime("%Y-%m-%d"))
