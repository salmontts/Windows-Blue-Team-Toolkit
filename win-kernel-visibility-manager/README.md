# Kernel Process Visibility — studium anti-anti-analysis

> **TL;DR:** Szkielet sterownika kernel-mode powstały podczas walki z malware,
> które wykrywało, że jest obserwowane, i wstrzymywało działanie. Pomysł:
> ukryć narzędzie analityczne przed badanym malware, żeby obserwować jego
> prawdziwe zachowanie. To studium techniki **podwójnego zastosowania** —
> ofensywna mechanika (process hiding) w służbie **defensywnej analizy**.

> ⚠️ **Status: niedziałający szkielet edukacyjny.** Logika ukrywania procesów
> (`FilterProcessInformation`) jest celowo niezaimplementowana — to studium
> mechaniki i architektury, nie gotowe narzędzie. Patrz sekcja "Granice".

---

## Geneza: malware, które wiedziało, że patrzę

Analizując pewną próbkę natknąłem się na klasyczny problem malware analysis:
**próbka wykrywała obserwację i przestawała działać.** Gdy uruchamiałem
monitoring procesów / debugger / narzędzia analityczne, malware "zasypiało" —
nie pokazywało swojego prawdziwego zachowania.

To jest znana rodzina technik: **anti-analysis / evasion**.
- Malware sprawdza, czy w liście procesów są narzędzia analityczne
  (debuggery, monitory, sandboxy) — MITRE **T1057** (Process Discovery) w
  służbie **T1622** (Debugger Evasion).
- Jeśli wykryje obserwatora → zmienia zachowanie albo się usypia.

Nasunął mi się pomysł rodem z myślenia ofensywnego, zastosowany defensywnie:
**skoro malware patrzy na listę procesów, żeby mnie znaleźć — co, jeśli ukryję
obserwatora przed tą listą?** Wtedy malware "nie wie", że jest badane, i działa
normalnie. To jest dokładnie podejście, które stosują profesjonalne, stealth'owe
środowiska do analizy malware.

---

## Mechanika (czego to studium dotyczy)

Lista procesów w Windows pochodzi m.in. z `NtQuerySystemInformation`
(`SystemProcessInformation`). Technika polega na przechwyceniu wyników tego
wywołania i odfiltrowaniu wybranego PID, zanim trafią do procesu pytającego.

```
Proces pyta o listę procesów
        │
        ▼
NtQuerySystemInformation  ──►  [hook]  ──►  usuń wpis obserwatora  ──►  zwróć resztę
        │
        ▼
Malware widzi listę BEZ narzędzia analitycznego → działa "naturalnie"
```

To jest ta sama mechanika, której używają **rootkity** do ukrywania się
(MITRE **T1014** — Rootkit). Różnica jest w *intencji i kontekście*: rootkit
ukrywa malware przed obrońcą; tutaj ukrywamy obrońcę przed malware. Mechanika
identyczna, wektor odwrócony.

---

## Co jest w tym repo

| Plik | Stan | Opis |
|------|------|------|
| `driver/Driver.c` | **Działa** | Szkielet WDM: device, symbolic link, IOCTL dispatch — realna infrastruktura kernel↔user |
| `driver/VisibilityManager.c` | **Pusty (celowo)** | `FilterProcessInformation` zwraca `STATUS_SUCCESS` bez logiki. Tu *byłaby* część ukrywająca — nie ma jej. |
| `user_app/main.c` | Szkielet | Klient user-mode komunikujący się ze sterownikiem przez IOCTL |

Czyli: **jest infrastruktura komunikacji kernel-user, nie ma zaimplementowanej
części ukrywającej.** To studium architektury i mechanizmu, nie działający
hider.

---

## Strona obrońcy: jak wykryć, że ktoś używa TEJ techniki

Tu domyka się cykl atak↔obrona. Skoro znam mechanikę ukrywania procesu, wiem
też, **jak je wykryć** — i to jest realna wartość obronna:

**Cross-view detection.** Process hiding przez hook na jednym API zostawia
ślad: różne źródła listy procesów przestają się zgadzać. Porównujesz np.:
- `NtQuerySystemInformation` (to, co hook modyfikuje)
- enumerację po `PID brute-force` (`OpenProcess` po kolejnych PID)
- listę z `CSRSS` / handle table / `EPROCESS` walk w kernelu

Proces widoczny w jednym źródle, a nieobecny w drugim = **ukryty proces**.
To jest klasyczna technika wykrywania rootkitów (tak działa np. GMER).

**Inne sygnały:** nieoczekiwane hooki w SSDT, modyfikacje w pamięci jądra,
sterowniki bez podpisu (powiązanie z modułem weryfikacji podpisu z DEADWEIGHT).

---

## Granice (świadome)

- **To nie jest działający rootkit ani działający stealth-monitor.** Część
  ukrywająca nie istnieje w kodzie. Repo pokazuje *zrozumienie mechaniki*, nie
  dostarcza narzędzia.
- Nowoczesny Windows (PatchGuard / KPP) blokuje klasyczne hookowanie SSDT na
  x64 — naiwna implementacja tej techniki i tak by nie przeszła na współczesnym
  systemie. To kolejny powód, dla którego wartość tu jest *edukacyjna*.
- Sterowniki kernel-mode wymagają podpisu (driver signing enforcement) — to
  studium buduje się i ładuje tylko w trybie testowym / na maszynie testowej.

---

## Czego to studium uczy

Rozumienia, że **granica między atakiem a obroną jest często kwestią kontekstu,
nie techniki.** Ta sama mechanika (manipulacja widocznością procesów) jest
bronią w rękach rootkita i narzędziem w rękach analityka malware. Zrozumienie
jednej strony jest warunkiem skutecznego działania po drugiej.

To jest sedno podejścia, które prowadzi cały ten toolkit: **uczę się technik
ofensywnych, żeby budować i rozumieć obronę.**

---

## Build (tryb testowy)

Wymaga Windows Driver Kit (WDK). Ładowanie wymaga włączonego test-signing
(`bcdedit /set testsigning on`) i maszyny testowej — nigdy produkcyjnej.

```
cd driver && nmake        # sterownik (WDK)
cd user_app && nmake      # klient user-mode
```

## Disclaimer

Materiał edukacyjny do nauki Windows internals i mechaniki anti-analysis.
Część ukrywająca jest celowo niezaimplementowana. Uruchamiać wyłącznie na
własnej maszynie testowej.
