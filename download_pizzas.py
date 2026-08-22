import urllib.request
urls = {
    'pep.jpg': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Pepperoni_pizza.jpg/320px-Pepperoni_pizza.jpg',
    'meat.jpg': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Supreme_pizza.jpg/320px-Supreme_pizza.jpg',
    'marg.jpg': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Eq_it-na_pizza-margherita_sep2005_sml.jpg/320px-Eq_it-na_pizza-margherita_sep2005_sml.jpg'
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