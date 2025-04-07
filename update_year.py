import datetime
import re

with open("mkdocs.yml", "r") as f:
    content = f.read()

current_year = str(datetime.datetime.now().year)
content = re.sub(r'\{\{CURRENT_YEAR\}\}', current_year, content)

with open("mkdocs.yml", "w") as f:
    f.write(content)
