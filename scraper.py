import urllib.request, json, re, sys

raw = urllib.request.urlopen(urllib.request.Request(
    "https://pabeppe.ru/",
    headers={"User-Agent":"Mozilla/5.0","Accept-Language":"ru-RU,ru;q=0.9"}
)).read()

m = re.search(rb'<script[^>]+id="__NUXT_DATA__"[^>]*>(.*?)</script>', raw, re.DOTALL)
flat = json.loads(m.group(1).decode("utf-8"))
CDN = "https://cdn.arora.pro/m"

def rv(idx, depth=0):
    if depth > 10 or not isinstance(idx, int) or idx < 0 or idx >= len(flat): return idx
    v = flat[idx]
    if isinstance(v, dict): return {k: rv(vi, depth+1) for k, vi in v.items()}
    if isinstance(v, list):
        if len(v) >= 2 and isinstance(v[0], str) and v[0] in ("ShallowReactive","ShallowReadonly","Reactive","Ref"):
            return rv(v[1], depth+1)
        return [rv(vi, depth+1) for vi in v]
    return v

def get_img(obj):
    if not isinstance(obj, dict): return ""
    p = obj.get("Path","") or ""
    d = obj.get("Domain", CDN)
    if p and p not in ("//","",None):
        return (d+p) if not p.startswith("http") else p
    return ""

# --- Extract menu categories ---
categories = []
seen_pids = set()

for i, v in enumerate(flat):
    if not isinstance(v, dict): continue
    keys = set(v.keys())
    if not keys >= {"Items","Title","Id","Link","Groups","ProductsCountTotal"}: continue
    try:
        title_idx = v.get("Title")
        title = flat[title_idx] if isinstance(title_idx, int) else title_idx
        if not isinstance(title, str) or not title.strip(): continue
        items_list = flat[v["Items"]] if isinstance(v["Items"], int) else v["Items"]
        if not isinstance(items_list, list) or not items_list: continue
        gid_raw = v.get("Id")
        gid = flat[gid_raw] if isinstance(gid_raw, int) else gid_raw
        products = []
        for item_idx in items_list:
            ir = flat[item_idx] if isinstance(item_idx, int) else item_idx
            if not isinstance(ir, dict): continue
            api_t_idx = ir.get("ApiGroupItemType")
            if (flat[api_t_idx] if isinstance(api_t_idx, int) else api_t_idx) != "ApiGroupItemProduct": continue
            sl_idx = ir.get("StopList")
            if flat[sl_idx] if isinstance(sl_idx, int) else sl_idx: continue
            pid_raw = ir.get("Id")
            pid = flat[pid_raw] if isinstance(pid_raw, int) else pid_raw
            if pid in seen_pids: continue
            seen_pids.add(pid)
            name_raw = ir.get("Title")
            name = flat[name_raw] if isinstance(name_raw, int) else name_raw
            price_raw = ir.get("Price")
            price = flat[price_raw] if isinstance(price_raw, int) else price_raw
            desc_raw = ir.get("Description")
            desc = flat[desc_raw] if isinstance(desc_raw, int) else desc_raw
            img_raw = ir.get("Image")
            img_obj = rv(img_raw) if isinstance(img_raw, int) else img_raw
            img_url = get_img(img_obj)
            if not isinstance(name, str) or not name: continue
            if not isinstance(price, (int,float)) or price <= 0: continue
            products.append({"id":str(pid),"name":name.strip(),"description":(desc.strip() if isinstance(desc,str) else ""),"price":int(price),"image_url":img_url})
        if products:
            categories.append({"id":str(gid),"title":title.strip(),"items":products})
    except: pass

# --- Extract promotions/actions ---
promos = []
seen_promo_ids = set()

for i, v in enumerate(flat):
    if not isinstance(v, dict): continue
    keys = set(v.keys())
    if not keys >= {"Title","Description","DateBegin","Active","Link","Teaser"}: continue
    try:
        r = rv(i)
        title = r.get("Title","")
        if not isinstance(title, str) or not title.strip(): continue
        promo_id = str(r.get("ID", i))
        if promo_id in seen_promo_ids: continue
        seen_promo_ids.add(promo_id)
        teaser = r.get("Teaser","") or ""
        desc = r.get("Description","") or ""
        # Strip HTML tags from description
        desc_clean = re.sub(r'<[^>]+>', '', desc).replace('\n','').strip()
        teaser_clean = re.sub(r'<[^>]+>', '', teaser).replace('\n','').strip()
        img_url = ""
        for key in ["ImageHorizontalSmallInfo","ImageBigBannerInfo","ImageSmallEventInfo"]:
            obj = r.get(key)
            if isinstance(obj, dict):
                img_url = get_img(obj)
                if img_url: break
        if not img_url:
            for key in ["ImageSmallEvent","ImageHorizontalSmall"]:
                obj = r.get(key)
                if isinstance(obj, dict):
                    img_url = get_img(obj)
                    if img_url: break
        promos.append({
            "id": promo_id,
            "title": title.strip(),
            "teaser": teaser_clean[:200],
            "description": desc_clean[:500],
            "image_url": img_url
        })
    except: pass

# Write combined menu.json
menu = {"categories": categories, "promotions": promos}
with open("menu.json","w",encoding="utf-8") as f:
    json.dump(menu, f, ensure_ascii=False, indent=4)

sys.stderr.write(f"SUCCESS: {len(categories)} categories, {sum(len(c['items']) for c in categories)} products, {len(promos)} promos\n")