import re, json
with open("c:/Projects/papajohns1000sber/beppe.html", "r", encoding="utf-8") as f:
    html = f.read()

match = re.search(r'<script id="__NUXT_DATA__"[^>]*>(.*?)</script>', html, re.DOTALL)
if match:
    data = json.loads(match.group(1))
    print("NUXT data length:", len(match.group(1)))
    print("First few items:", str(data)[:200])
else:
    print("No NUXT_DATA")

match2 = re.search(r'<script id="__NEXT_DATA__"[^>]*>(.*?)</script>', html, re.DOTALL)
if match2:
    print("NEXT data length:", len(match2.group(1)))