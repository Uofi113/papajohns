import urllib.request, re, json
req = urllib.request.Request('https://papajohns.ru/', headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36'})
html = urllib.request.urlopen(req).read().decode('utf-8')
match = re.search(r'id="__NEXT_DATA__" type="application/json">(\{.*?\})</script>', html)
if match:
    print("Found NEXT_DATA")
    state = json.loads(match.group(1))
    print(list(state.keys()))
else:
    print("No NEXT_DATA found")