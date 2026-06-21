# Windows Blue Team Toolkit

Zestaw narzędzi do **wykrywania, analizy i usuwania** zagrożeń na Windows —
process monitoring, memory forensics, threat hunting i incident response.

Wszystkie narzędzia łączy jedna filozofia: **uczę się myśleć jak atakujący,
żeby skuteczniej bronić.** Część z nich używa technik zapożyczonych z arsenału
ofensywnego (memory dumping, process suspension, kernel-level visibility) —
w służbie obrony i analizy. Purple team w praktyce.

> Narzędzia edukacyjne / do autoryzowanego użytku na własnych systemach.

---

## Narzędzia

### 🔍 SnitchHunter — real-time process monitor
Monitoruje pojawianie się nowych procesów na żywo. Loguje nazwę, PID, parent
PID i pełną ścieżkę. Prosty, szybki threat-hunting: wyłapuje podejrzaną lub
stealth'ową aktywność procesów. Detekcja, MITRE T1057.

### 🧹 Exorcist — persistence remover
Wykrywa i usuwa typowe mechanizmy persistence malware: podejrzane `dllhost.exe`,
backdoory WMI (event subscriptions), złośliwe scheduled tasks oraz wpisy
Run/RunOnce wskazujące na AppData/Temp. Remediacja po incydencie.

### 🐕 dllhost_watchdog — COM Surrogate monitor
Obserwuje aktywność `dllhost.exe` (COM Surrogate — częsty cel injection),
zamraża podejrzane instancje i zrzuca ich pamięć do analizy. Memory forensics
w reakcji na zdarzenie.

### 👻 GhostTrap — suspend & dump framework
Dwuczęściowy: natywny komponent C++ zamraża procesy spoza whitelisty, a dumper
PowerShell zrzuca ich pamięć przez procdump. Architektura kernel-adjacent do
łapania krótko żyjących, ukrywających się procesów.

### 🛡️ win-kernel-visibility-manager — studium anti-anti-analysis
Szkielet sterownika kernel-mode: studium technik, którymi malware wykrywa
obserwację, i jak (odwracając rootkit-technikę) analizować je w ukryciu.
Z pełną sekcją obronną (cross-view detection). Szczegóły w jego README.

### 🌐 audit_domowy — network audit
Skaner sieci LAN: discovery hostów, port/service scan, MAC vendor lookup,
heurystyczna klasyfikacja urządzeń i skan podatności (nmap NSE).

---

## Filozofia: purple team

Każde z tych narzędzi powstało w realnej sytuacji — najczęściej w walce z
konkretnym zagrożeniem na własnym systemie. Łączy je to, że sięgają po techniki
kojarzone z atakiem (memory dumping, process suspension, manipulacja
widocznością procesów) i obracają je w stronę **obrony, analizy i zrozumienia**.

---

## Status & roadmap

- [x] SnitchHunter — działa
- [x] Exorcist — działa (po refaktorze: lepsza detekcja, fix błędów)
- [x] dllhost_watchdog / GhostTrap — działają (memory forensics)
- [x] audit_domowy — działa
- [x] kernel-visibility-manager — szkielet edukacyjny + framing obronny
- [ ] Ujednolicenie logowania (wspólny format, ścieżki)
- [ ] Integracja z weryfikacją podpisu (jak w DEADWEIGHT) — redukcja FP
- [ ] Eksport znalezisk do formatu pod SIEM

---

## Autor

**Sentio** (`salmontts`) — Adrian Jędrocha
Cybersecurity & embedded · Windows internals · malware analysis

## Licencja

MIT
