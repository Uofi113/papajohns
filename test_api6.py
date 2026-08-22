import urllib.request, re, json
req = urllib.request.Request('https://papajohns.ru/', headers={'User-Agent': 'Mozilla/5.0'})
try:
    html = urllib.request.urlopen(req).read().decode('utf-8')
    data = re.search(r'id="__NEXT_DATA__".*?>(.*?)</script>', html)
    if data:
        parsed = json.loads(data.group(1))
        print("Got NEXT_DATA keys:", parsed.keys())
    else:
        print("No NEXT_DATA found again.")
        # Try to find api routes
        api_routes = re.findall(r'https?://[a-zA-Z0-9.-]+/api/[a-zA-Z0-9./-]+', html)
        print("Found API routes:", list(set(api_routes)))
except Exception as e:
    print(e)