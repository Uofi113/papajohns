import urllib.request
urls = {
    'pep.jpg': 'https://upload.wikimedia.org/wikipedia/commons/d/d1/Pepperoni_pizza.jpg',
    'meat.jpg': 'https://upload.wikimedia.org/wikipedia/commons/d/d3/Supreme_pizza.jpg',
    'marg.jpg': 'https://upload.wikimedia.org/wikipedia/commons/a/a3/Eq_it-na_pizza-margherita_sep2005_sml.jpg'
}
for name, url in urls.items():
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as resp:
            with open('c:/Projects/papajohns1000sber/Resources/' + name, 'wb') as f:
                f.write(resp.read())
        print('Downloaded', name)
    except Exception as e:
        print('Failed', name, e)