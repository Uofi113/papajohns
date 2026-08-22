<p align="center">
  <img src="https://img.shields.io/badge/platform-iOS%206.0-red?style=flat-square&logo=apple" />
  <img src="https://img.shields.io/badge/built%20with-Theos-orange?style=flat-square" />
  <img src="https://img.shields.io/badge/language-Objective--C-blue?style=flat-square" />
  <img src="https://img.shields.io/github/actions/workflow/status/uofi113/papajohns/build.yml?style=flat-square&label=build" />
</p>

<h1 align="center">🍕 Papa Johns iOS 6</h1>
<p align="center">Нативный клиент Papa John's для iPhone на iOS 6, собранный через Theos без Xcode и сторибордов.<br/>Чистый Objective-C. Максимальный скевоморфизм.</p>

---

## Фичи

| | |
|---|---|
| 📋 **Каталог** | `UITableViewController` с текстурой дерева через `colorWithPatternImage:` |
| 🃏 **Карточки** | Белая подложка ячейки, `UIBezierPath` shadowPath — скролл без лагов |
| ✨ **Глянец** | Кнопка «В корзину» на `CAGradientLayer` + полупрозрачный блик + вдавленный текст |
| 🌐 **Сеть** | `NSURLConnection` с блоками, async GET/POST, `NSJSONSerialization` |
| 📦 **Сборка** | Theos → `.deb`, устанавливается в `/Applications` |

---

## Сборка

### GitHub Actions (автоматически)

При каждом пуше в `main`/`master` Actions собирает проект на Ubuntu и кладёт `.deb` в **Artifacts**.

### Вручную (Ubuntu / WSL)

```bash
export THEOS=/opt/theos
git clone --recursive https://github.com/theos/theos.git $THEOS

make package FINALPACKAGE=1
```

`.deb` появится в папке `packages/`.

---

## Установка на устройство

```bash
scp packages/*.deb root@<ip>:/tmp/
ssh root@<ip> "dpkg -i /tmp/*.deb && uicache"
```

Или скинуть `.deb` вручную через Filza.

---

## Структура

```
.
├── .github/workflows/build.yml   # CI: сборка и публикация .deb
├── Makefile                       # Theos: цели, архитектуры, фреймворки
├── control                        # dpkg: метаданные пакета
└── src/
    ├── main.m
    ├── AppDelegate.h / .m
    ├── PJNetworkManager.h / .m    # NSURLConnection, GET/POST, JSON
    ├── PJMenuItem.h / .m          # Модель позиции меню
    ├── PJGlossButton.h / .m       # Глянцевая кнопка (CAGradientLayer)
    ├── PJMenuCell.h / .m          # UITableViewCell с карточкой и тенью
    └── PJMenuViewController.h/.m  # Каталог, текстура дерева
```

---

## Требования

- iOS 6.0+, armv7 / armv7s
- Jailbreak (Cydia / Sileo)
- Theos (сборка на Ubuntu/macOS)

---

<p align="center">
  Сделано с ❤️ и ностальгией &nbsp;·&nbsp;
  <a href="https://t.me/uofist">@uofist</a> &nbsp;·&nbsp;
  <a href="https://github.com/uofi113">uofi113</a>
</p>