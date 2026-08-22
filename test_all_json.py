import urllib.request, re, json
req = urllib.request.Request('https://papajohns.ru/', headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36'})
html = urllib.request.urlopen(req).read().decode('utf-8')
for match in re.finditer(r'<script.*?>(\{.*?\})</script>', html):
    try:
        data = json.loads(match.group(1))
        print("Found JSON block:", list(data.keys())[:5])
    except:
        pass
for match in re.finditer(r'window\.[\w_]+\s*=\s*(\{.*?\});', html):
    try:
        data = json.loads(match.group(1))
        print("Found window var:", list(data.keys())[:5])
    except:
        pass