import urllib.request, re, json
req = urllib.request.Request('https://pabeppe.ru/', headers={'User-Agent': 'Mozilla/5.0'})
try:
    html = urllib.request.urlopen(req).read().decode('utf-8')
    print("Downloaded HTML. Length:", len(html))
    
    # Try to find API URLs in HTML
    apis = re.findall(r'https?://[a-zA-Z0-9.-]+/api/[a-zA-Z0-9./-]+', html)
    print("Found API routes:", list(set(apis)))
    
    # Look for ajax requests
    ajax = re.findall(r'url:\s*["\']([^"\']+)["\']', html)
    print("Found ajax routes:", list(set(ajax)))
    
    # Let's save it to inspect
    with open("c:/Projects/papajohns1000sber/beppe.html", "w", encoding="utf-8") as f:
        f.write(html)
except Exception as e:
    print(e)