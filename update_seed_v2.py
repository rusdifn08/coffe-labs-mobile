import re

file_path = 'E:/APPS From Agent/Mobile-Flutter/Coffee Hub/coffee_hub_mobile/lib/services/seed_data.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

def replacer(match):
    author = match.group(1)
    clean_name = re.sub(r'\s*\(.*?\)', '', author)
    url_name = clean_name.replace(' ', '+') + '+coffee+brewer+WBrC'
    new_url = f'https://tse1.mm.bing.net/th?q={url_name}&w=150&h=150&c=7&rs=1&p=0'
    return f'"author": "{author}",\n        "authorImageUrl": "{new_url}",'

content = re.sub(r'"author":\s*"(.*?)",\n\s*"authorImageUrl":\s*".*?",', replacer, content)

def add_grind(match):
    coffee_weight = match.group(1)
    grind_size = 'Medium to Coarse'
    return f'"grindSize": "{grind_size}",\n        "coffeeWeightGrams": {coffee_weight},'

content = re.sub(r'"coffeeWeightGrams":\s*(\d+(\.\d+)?),', add_grind, content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
