# CoinCat | Bildverarbeitung WS22/23 | Freiwilliges Abschlussprojekt
 
### Übersicht 
**CoinCat** ist eine in Matlab geschriebene Software, die dazu dient, kleinere Münzgeldmengen zusammenzuzählen und mit verschiedenen Kriterien zu filtern. Durch ein eigens trainiertes neurales Netzwerk werden Münzen erkannt und einem entsprechenden Wert zugewiesen.
Sie wurde im Zuge des Moduls **Bildverarbeitung** an der [FH Aachen](https://www.fh-aachen.de/) im Wintersemester 2022/2023 als freiwilliges Abschlussprojekt entwickelt.

### Features
- Unterstützung für das Einbinden von eigenen Modellen (```serializedNet.mat``` ersetzen)
- Klassifikation durch ein neurales Netzwerk
- Grafische Benutzerschnittstelle für Benutzer
- 4 anpassbare Filteroptionen

### Konfiguration
[Über Matlab die folgenden Toolboxen installieren](https://de.mathworks.com/help/matlab/matlab_env/get-add-ons.html):
- [Computer Vision Toolbox](https://de.mathworks.com/products/computer-vision.html)
- [Deep Learning Toolbox](https://www.mathworks.com/products/deep-learning.html)
- [Parallel Computing Toolbox](https://www.mathworks.com/products/parallel-computing.html)

*Weitere Information können der [Dokumentation](https://github.com/Tamagear/Bildverarbeitung-FreiwilligesProjekt/tree/main/Dokumentation) entnommen werden.*

### Startanleitung
1. Abarbeiten der **Konfiguration** (einmalig).
2. Öffnen der Datei ```GUI.mlapp```.
3. Starten über den Start-Knopf von Matlab.

### Autoren
- Tarik Glasmacher
- Tim Bering

### Wie es funktioniert
1. Ein Bild wird eingelesen. Der Nutzer zieht eine Linie über den Durchmesser einer beliebigen Münze. Je besser die Münze zu sehen ist, umso besser das zu erwartene Ergebnis.
2. Das gesamte Eingangsbild wird klassifiziert. Die Ergebnisse werden in der grafischen Benutzerschnittstelle angezeigt.

### Nutzen
Als für mobile Endgeräte kann **CoinCat** in Alltagssituationen helfen, so zum Beispiel, um genügend Geld für den Parkautomaten aus dem mitgeführten Kleingeld hervorzuheben.

### Beispieldaten
Beispiele für einlesbare Bilder finden sich im Ordner [Beispiele]().

### Projektpräsentation
Die Projektpräsentationen finden sich im Ordner [Präsentationen](https://github.com/Tamagear/Bildverarbeitung-FreiwilligesProjekt/tree/main/Pr%C3%A4sentationen).

### Lizenz
Lizensiert unter dem Lizenztypen [GNU GPL 3.0](https://www.gnu.org/licenses/gpl-3.0), jedoch ist kommerzieller Nutzen strengstens untersagt. Sämtliches Recht an den Namen, Projekten und Zugehörigkeiten der Autoren ist zu bewahren.

---
 
![Logo](https://cdn.discordapp.com/attachments/771767101164879892/1064668083324727407/CoinCatLogoHead.png)
