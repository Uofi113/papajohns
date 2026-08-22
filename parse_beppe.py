import json, re

with open("c:/Projects/papajohns1000sber/beppe.html", "r", encoding="utf-8") as f:
    html = f.read()

# Try to find json blobs
matches = re.findall(r'<script.*?>\s*({.*?})\s*</script>', html, re.DOTALL)
for m in matches:
    if len(m) > 1000:
        print("Found large JSON blob inside script tag, length:", len(m))

matches2 = re.findall(r'window\.[a-zA-Z0-9_]+\s*=\s*(\{.*?\});', html, re.DOTALL)
for m in matches2:
    if len(m) > 1000:
        print("Found large window variable JSON blob, length:", len(m))