import urllib.request, re, json
req = urllib.request.Request('https://papajohns.ru/', headers={'User-Agent': 'Mozilla/5.0'})
try:
    html = urllib.request.urlopen(req).read().decode('utf-8')
    match = re.search(r'window\.__APP_CONFIG__\s*=\s*(\{.*?\});', html)
    if match:
        data = json.loads(match.group(1))
        for k, v in data.items():
            if 'Url' in k:
                print(k, v)
    else:
        print("Not found")
except Exception as e:
    print(e)