# Papa Johns iOS 6 Client

Нативный клиент Papa Johns для iOS 6, написанный на Objective-C.  
Собирается через [Theos](https://github.com/theos/theos) в GitHub Actions → выдаёт `.deb`.

**Автор:** uofist | tg: [@uofist](https://t.me/uofist)

## Сборка

Автоматическая — при пуше в `main`/`master`.  
`.deb` появится во вкладке **Actions → Build .deb → Artifacts**.

## Ручная сборка (Ubuntu)

```bash
export THEOS=/opt/theos
make package FINALPACKAGE=1
```

## Установка

Скинуть `.deb` на устройство, поставить через `dpkg -i` или Filza.