import json
import os

# We will generate seeds_part_12.dart to seeds_part_21.dart
# 15 recipes per file, 10 files = 150 recipes (IDs 301 to 450).

output_dir = r"c:\Rusdi\Coffe Labs\coffe-labs-mobile\lib\data\seeds"

def format_recipe(r):
    steps_dart = ",\n".join([
        f'          {{"stepOrder": {s["stepOrder"]}, "title": "{s["title"]}", "durationSeconds": {s["durationSeconds"]}, "waterAddedGrams": {s["waterAddedGrams"]}}}'
        for s in r["steps"]
    ])
    
    return f'''  {{
    "id": {r["id"]},
    "title": "{r["title"]}",
    "author": "{r["author"]}",
    "coverImageUrl": "{r["coverImageUrl"]}",
    "authorAvatarUrl": "{r["authorAvatarUrl"]}",
    "authorImageUrl": "{r["authorImageUrl"]}",
    "beanName": "{r["beanName"]}",
    "variety": "{r["variety"]}",
    "process": "{r["process"]}",
    "method": "{r["method"]}",
    "category": "{r["category"]}",
    "waterTempCelsius": {r["waterTempCelsius"]},
    "grindSize": "{r["grindSize"]}",
    "coffeeWeightGrams": {r["coffeeWeightGrams"]},
    "totalWaterWeightGrams": {r["totalWaterWeightGrams"]},
    "totalTimeSeconds": {r["totalTimeSeconds"]},
    "description": "{r["description"]}",
    "isCustom": false,
    "createdAt": now,
    "steps": [
{steps_dart}
    ]
  }}'''

print("Helper ready")
