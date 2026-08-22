import urllib.request, json
urls = [
    'https://api.papajohns.ru/catalog/menu',
    'https://api.papajohns.ru/menu',
    'https://api-facade.papajohns.ru/api/v1/catalog',
    'https://api-facade.papajohns.ru/api/v1/menu',
]
for u in urls:
    req = urllib.request.Request(u, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        resp = urllib.request.urlopen(req)
        print(f"SUCCESS {u}")
        print(resp.read().decode('utf-8')[:200])
    except Exception as e:
        print(f"FAIL {u}: {e}")