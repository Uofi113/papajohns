import urllib.request
urls = [
    'https://api-facade.papajohns.ru/api/v1/catalog',
    'https://api.papajohns.ru/catalog',
    'https://api.papajohns.ru/v1/catalog',
    'https://api.papajohns.ru/v2/catalog',
    'https://api.papajohns.ru/api/v1/catalog'
]
for u in urls:
    try:
        req = urllib.request.Request(u, headers={'User-Agent': 'Mozilla/5.0', 'x-city-id': '1'})
        resp = urllib.request.urlopen(req)
        print("SUCCESS", u, resp.read().decode('utf-8')[:100])
    except Exception as e:
        print("FAIL", u, e)