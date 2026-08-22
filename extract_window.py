import re
with open("c:/Projects/papajohns1000sber/beppe.html", "r", encoding="utf-8") as f:
    html = f.read()

matches = re.findall(r'window\.[A-Za-z0-9_]+\s*=\s*(.*?});', html, re.DOTALL)
for m in matches:
    if len(m) > 1000:
        print("Found window var length:", len(m))
        print("Prefix:", m[:100])
        with open("c:/Projects/papajohns1000sber/beppe_window.js", "w", encoding="utf-8") as out:
            out.write(m)