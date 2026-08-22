import urllib.request, re
req = urllib.request.Request('https://papajohns.ru/', headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'})
html = urllib.request.urlopen(req).read().decode('utf-8')
js_files = re.findall(r'src="(/_next/static/chunks/[^"]+\.js)"', html)
for js in js_files[:3]:
    url = 'https://papajohns.ru' + js
    try:
        req2 = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        js_code = urllib.request.urlopen(req2).read().decode('utf-8')
        endpoints = re.findall(r'["\'](/api/v\d+/[a-zA-Z0-9_/-]+)["\']', js_code)
        for e in set(endpoints):
            print("Found endpoint:", e)
    except:
        pass