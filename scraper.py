import requests, json, re, sys

headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
    "Accept-Language": "ru-RU,ru;q=0.9",
}

resp = requests.get("https://pabeppe.ru/", headers=headers, timeout=30)
html = resp.text

items = []

nuxt_match = re.search(r'<script[^>]+id="__NUXT_DATA__"[^>]*>(.*?)</script>', html, re.DOTALL)
if nuxt_match:
    print("Found __NUXT_DATA__ block")
    try:
        flat = json.loads(nuxt_match.group(1).strip())
        if not isinstance(flat, list):
            flat = []
        seen_names = set()
        id_counter = 1
        i = 0
        while i < len(flat):
            val = flat[i]
            if isinstance(val, str) and 5 < len(val) < 80 and re.search(r"[А-Яа-яёЁ]", val):
                for j in range(i + 1, min(i + 25, len(flat))):
                    cand = flat[j]
                    if isinstance(cand, (int, float)) and 300 <= cand <= 3000:
                        name = val.strip()
                        if name not in seen_names and not any(c in name for c in ["/", "<", "@", "http", "www", "{"]):
                            seen_names.add(name)
                            img_url = ""
                            for k in range(max(0, i - 15), min(len(flat), i + 35)):
                                if isinstance(flat[k], str) and re.search(r"\.(jpg|png|webp)", flat[k], re.I) and "http" in flat[k]:
                                    img_url = flat[k]
                                    break
                            desc = ""
                            for k in range(i + 1, min(len(flat), i + 20)):
                                if isinstance(flat[k], str) and 20 < len(flat[k]) < 300 and flat[k] != name:
                                    desc = flat[k].strip()
                                    break
                            items.append({
                                "id": str(id_counter),
                                "name": name,
                                "description": desc or "Свежая пицца из Калининграда",
                                "price": int(cand),
                                "image_url": img_url or "local://pep.jpg"
                            })
                            id_counter += 1
                        break
            i += 1
    except Exception as e:
        print(f"Parse error: {e}")
else:
    print("No __NUXT_DATA__ block found")
    print("HTML snippet:", html[:3000])

if items:
    seen = set()
    unique = []
    for item in items:
        if item["name"] not in seen and len(item["name"]) > 3:
            seen.add(item["name"])
            unique.append(item)
    menu = {"items": unique[:40]}
    with open("menu.json", "w", encoding="utf-8") as f:
        json.dump(menu, f, ensure_ascii=False, indent=4)
    print(f"SUCCESS: Saved {len(unique)} items to menu.json")
else:
    print("ERROR: No items parsed.")
    sys.exit(1)