import urllib.request, re, json
req = urllib.request.Request('https://papajohns.ru/', headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36'})
html = urllib.request.urlopen(req).read().decode('utf-8')
match = re.search(r'window\.__INITIAL_STATE__\s*=\s*(\{.*?\});', html)
if match:
    print("Found INITIAL_STATE")
    state = json.loads(match.group(1))
    print(list(state.keys()))
else:
    print("No INITIAL_STATE found")