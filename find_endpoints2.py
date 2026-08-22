import urllib.request, re, json
req = urllib.request.Request('https://papajohns.ru/', headers={'User-Agent': 'Mozilla/5.0'})
html = urllib.request.urlopen(req).read().decode('utf-8')

# Let's find any .js file and download it to find API paths
js_files = re.findall(r'src="(/_next/static/chunks/[^"]+\.js)"', html)
all_paths = []
for js in js_files:
    url = 'https://papajohns.ru' + js
    try:
        req2 = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        js_code = urllib.request.urlopen(req2).read().decode('utf-8')
        endpoints = re.findall(r'["\'](/api/[a-zA-Z0-9_/-]+)["\']', js_code)
        all_paths.extend(endpoints)
        endpoints2 = re.findall(r'["\'](/[a-zA-Z0-9_/-]+/menu)["\']', js_code)
        all_paths.extend(endpoints2)
    except:
        pass
print(list(set(all_paths)))