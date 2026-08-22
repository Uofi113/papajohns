import json, re

with open("c:/Projects/papajohns1000sber/beppe.html", "r", encoding="utf-8") as f:
    html = f.read()

matches = re.findall(r'<script.*?>\s*({.*?})\s*</script>', html, re.DOTALL)
for m in matches:
    if len(m) > 100000:
        with open("c:/Projects/papajohns1000sber/beppe_data.json", "w", encoding="utf-8") as out:
            out.write(m)
        print("Saved beppe_data.json")