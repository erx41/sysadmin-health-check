# Windows 11 System Health & Security Check

Algajasõbralik PowerShelli skript süsteemiadministraatorile, mis teeb kiire ülevaate Windows 11 arvuti seisukorrast ja põhilisest turvalisusest.

## Mida skript kontrollib?
- **Windows Defender tulemüür:** Kontrollib, kas tulemüür on kõigis võrguprofiilides sisse lülitatud.
- **Kettaruum:** Kuvab C: ketta vaba ja kasutatud mahu.
- **Mälukasutus (RAM):** Leiab 5 kõige rohkem mälu tarbivat protsessi.
- **Tööaeg (Uptime):** Näitab, millal süsteem viimati taaskäivitati.

## Kuidas kasutada?
1. Laadi alla fail `SystemHealthCheck.ps1`.
2. Ava Windows PowerShell.
3. Käivita skript:
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   .\SystemHealthCheck.ps1
   ```
4. Tulemus kuvatakse ekraanile ja salvestatakse automaatselt töölauale tekstifailina.


