import re
with open("c:/Projects/papajohns1000sber/beppe.html", "r", encoding="utf-8") as f:
    html = f.read()

# Let's find any large script tag
matches = re.findall(r'<script[^>]*>(.*?)</script>', html, re.DOTALL)
for i, m in enumerate(matches):
    if len(m) > 50000:
        print(f"Large script {i}: length {len(m)}")
        print(m[:200])
        print("...")
        print(m[-200:])
        print("-" * 50)