import urllib.request, re, json
with open("c:/Projects/papajohns1000sber/beppe.html", "r", encoding="utf-8") as f:
    html = f.read()

# Find JS files
js_files = re.findall(r'src="([^"]+\.js[^"]*)"', html)
for js in js_files:
    if not js.startswith('http'):
        js = 'https://pabeppe.ru' + js
    try:
        req = urllib.request.Request(js, headers={'User-Agent': 'Mozilla/5.0'})
        code = urllib.request.urlopen(req).read().decode('utf-8')
        apis = re.findall(r'["\'](https?://[^"\']+/api/[^"\']+)["\']', code)
        apis2 = re.findall(r'["\'](/api/[^"\']+)["\']', code)
        if apis or apis2:
            print("Found in", js, ":", set(apis + apis2))
    except Exception as e:
        print("Failed to load", js)