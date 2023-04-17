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
