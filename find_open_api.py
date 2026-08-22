import urllib.request, re, json
urls = [
    'https://foodband.ru/',
    'https://farfor.ru/',
    'https://pizzasushiwok.ru/'
]
for u in urls:
    try:
        req = urllib.request.Request(u, headers={'User-Agent': 'Mozilla/5.0'})
        html = urllib.request.urlopen(req, timeout=5).read().decode('utf-8')
        print(f"--- {u} ---")
        apis = re.findall(r'https?://[a-zA-Z0-9.-]+/api/[a-zA-Z0-9./-]+', html)
        print("APIs:", set(apis))
        ajax = re.findall(r'url:\s*["\']([^"\']+)["\']', html)
        print("Ajax:", set(ajax))
    except Exception as e:
        print(u, e)