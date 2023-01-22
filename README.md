# CoinCat - Bilderverarbeitung, Projekt WS2022/2023
> Tim Bering, Tarik Glasmacher
> Link zum [Github-Repository](https://github.com/Tamagear/Bildverarbeitung-FreiwilligesProjekt) (Original)
>> Die Verlinkungen zu Teilen des Projektes führen zum [Github-Repository](https://github.com/Tamagear/Bildverarbeitung-FreiwilligesProjekt), können aber auch in diesem Repository gefunden werden.
------

## Motivation

**CoinCat** ist eine in Matlab geschriebene Software, die dazu dient, kleinere Münzgeldmengen zusammenzuzählen und mit verschiedenen Kriterien zu filtern. Durch ein eigens trainiertes neurales Netzwerk werden Münzen erkannt und einem entsprechenden Wert zugewiesen.
Sie wurde im Zuge des Moduls **Bildverarbeitung** an der [FH Aachen](https://www.fh-aachen.de/) im Wintersemester 2022/2023 als freiwilliges Abschlussprojekt entwickelt.

------


![Bild aus der Software](https://cdn.discordapp.com/attachments/923610318893121606/1065598644885135370/image.png)
*Ein Bild dass das Endergebnis demontiert; Die gewünschten Münzen sind hervorgehoben.*

| Features                    									|
| ----------------------------------------------------------------------------------------------|
| Unterstützung für das Einbinden von eigenen Modellen (```serializedNet.mat``` ersetzen)   	|
| Klassifikation durch ein neurales Netzwerk          						|
| Grafische Benutzerschnittstelle für Benutzer 							|
| Anpassbare Filteroptionen          								|

### Datenbasis - Eigenschaften eines Bildes, die genutzt werden sollen

Die Münzen auf dem Bild werden durch die Hough-Transformation als Kreise erkannt und genutzt.

## Pipeline - Übersicht von Funktionen und Zwischenergebnissen

**Kurzübersicht der Funktionen**:

| Funktion                               | Input 							| Output 					| Kurzbeschreibung                                            						|
| -------------------------------------- | ------------------------------------------------------------ | --------------------------------------------- | ------------------------------------------------------------------------------------------------------|
| Kreise auf dem Originalbild erkennen   | Originalbild      						| Hough-Kreisdaten       			| Die Münzen sollen im Originalbild erkannt werden. 							|
| Teilbilder erstellen			 | Originalbild, Hough-Kreisdaten 				| Zellen mit Teilbildpfad, Position, Radius 	| Die Münzen werden in Teilbilder zerschnitten und der Hintergrund ausgeschwärzt. 			|
| Klassifikation               		 | Teilbildpfade      						| Zellen mit klassifiziertem Wert       	| Die Teilbilder werden in das neurale Netzwerk eingespeist, um einen klassifizierten Wert zu erhalten. |
| Bild filtern 				 | Filter, Zellen mit Teilbildpfad, Position, Radius, Wert      | Gefiltertes Bild       			| Je nach Filtereinstellungen werden die gewünschten Münzen hervorgehoben. 				|
| Netzwerk trainieren\*			 | Trainings- und Validierungsdaten				| SGDM-NN					| Das Training eines neuralen Netzwerkes anhand von vorgegebenen Daten.					|

\**Gehört nicht zum eigentlichen Userflow, wird deshalb als letztes aufgeführt.*

### Kreise auf dem Originalbild erkennen

**Wichtig**:
- Die Münzen müssen möglichst vollständig auf dem Bild zu sehen sein.

**Anmerkungen**:
- Reflektionen können dazu führen, dass einige Münzen nicht erkannt werden. Am besten die Münzen bei mäßiger Beleuchtung auf einem möglichst dunklem Hintergrund abfotografieren. Bei Ergebnissen aus ca. 20cm Höhe und der möglichst direkt auf die Münzen gerichteten Kamera
ist die Wahrscheinlichkeit, dass das neurale Netzwerk später die Münzen richtig erkennt, höher.

**Quellen**:
- [Hough-Transformation](https://de.mathworks.com/help/images/ref/hough.html)
- [imfindcircles / Circular Hough Transform](https://de.mathworks.com/help/images/ref/imfindcircles.html)

------

Es wird ein Durchmesser vom Nutzer zur Referenz gezeichnet (`diameter`), dann werden anhand dieses Durchmessers die Münzen auf dem Bild gefunden.
Die Parameter `EdgeThreshold` und `Sensitivity` können jeweils angepasst werden, um auf verschiedene Bilder zu reagieren. Die von uns gewählten Werte haben wir durch das systematische Ausprobieren gefunden.


> Die Theorie hierzu wurde in Kapitel 7 - Segmentierung behandelt.

------



![Bild: Vorher-Nachher](https://cdn.discordapp.com/attachments/923610318893121606/1065621703893471232/image.png)
*Ablauf*



```matlab
[centers, radii] = imfindcircles(IOrig, [round(diameter * 0.25), diameter], ...
        "EdgeThreshold", 0.25, "Sensitivity", 0.97);
```


### Teilbilder erstellen

**Wichtig**:
- Kreisförmige Objekte oder Teilobjekte im Bild sollten möglichst vermieden werden

**Anmerkungen**:
- Fälschlicherweise als Münzen erkannte Objekte erhöhen das Risiko einer Falschbeurteilung seitens des verwendeten Neuralen Netzwerks. Die Münzen sollten vor einem einfarbigen Hintergrund fotografiert werden.

**Quellen**:
- [ndgrid](https://de.mathworks.com/help/matlab/ref/ndgrid.html)
- [uint8](https://de.mathworks.com/help/matlab/ref/uint8.html)

------

Die erkannten Münzen werden anhand der Koordinaten ihrer Mittelpunkte und ihrer Radien separiert und für die Weiterverarbeitung in Einzelbildern gespeichert.
Die Dateien erhalten hierbei eine ID, mit welcher sie eindeutig den erkannten Münzen zugewiesen werden können.


> Die Theorie hierzu wurde in Kapitel 7 - Segmentierung behandelt.

------


![Bild: Vorher-Nachher](https://cdn.discordapp.com/attachments/923610318893121606/1065621939391041536/image.png)
*Ablauf*



```matlab
for i = 1:coinCount
        x = round(centers(i, 1));
        y = round(centers(i, 2));
        r = round(radii(i)) + radiusPadding;

        [xx, yy ] = ndgrid((1:imagesize(1))-y,(1:imagesize(2))-x);

        mask = uint8((xx.^2 + yy.^2)<(r^2));
        IMasked(:,:,:) = IOrig(:,:,:).*mask;

        ICoin = imcrop(IMasked, [x - r, y - r, 2 * r , 2* r ]);
        ICoin = imresize(ICoin, [256, 256]);
    
        str = sprintf("readCoins/img_%02d.jpg",i);
        imwrite(ICoin, str);
%[...]
end
```

### Klassifikation

**Wichtig**:
- Da es sich beim zweiten Parameter `imdsTest` um  einen ImageDatastore handelt, dürfen die Inhalte des referenzierten Verzeichnisses beim Durchlaufen der Software nicht verändert werden!

**Anmerkungen**:
- Das neurale Netzwerk kann ausgetauscht werden, indem die Datei `serializedNet.mat` im Verzeichnis ersetzt wird. Die classify-Methode (s.u.) ist in diesem Bezug sehr flexibel.

**Quellen**:
- [Mathworks Neural Networks](https://de.mathworks.com/discovery/neural-network.html)
- [Simple Image Classification Network](https://de.mathworks.com/help/deeplearning/gs/create-simple-deep-learning-classification-network.html)

------

Die Teilbilder werden in das neurale Netzwerk eingespeist. Ihnen werden Wertigkeiten zugewiesen, anhand deren klassifiziert wird, um welche Münzklasse es sich am wahrscheinlichsten handelt. Nicht als Münzen erkannte Bilder werden als solche gekennzeichnet.


> Die Theorie hierzu wurde in Kapitel 9 - Mustererkennung behandelt.

------


![Bild: Klassifikation](https://cdn.discordapp.com/attachments/923610318893121606/1065613406343802972/image.png)
*Den einzelnen Teilbildern werden Wertigkeiten zugewiesen, anhand deren klassifiziert wird, um welche Münzklasse es sich am wahrscheinlichsten handelt. Nicht als Münzen erkannte Bilder werden als solche gekennzeichnet.*



![Bild: Vorher](https://cdn.discordapp.com/attachments/923610318893121606/1065613219571449876/image.png)
*Zellen vorher (Beispielhaft)*



![Bild: Nachher](https://cdn.discordapp.com/attachments/923610318893121606/1065612982060580884/image.png)
*Zellen nachher (Beispielhaft)*



```matlab
[YTest, scores] = classify(net, imdsTest);
```


### Bild filtern

**Wichtig**:
- Filterungsoperationen können fehlschlagen. Der Filter "Cheat" liefert ausschließlich bei festgelegten Testbildern ein präzises Ergebnis und ist nicht für den Einsatz in Realsituationen vorgesehen.

**Anmerkungen**:
- mit Ausnahme der Filter "Kein Filter" und "Cheat" können Filterunsversuche Fehlschlagen, sollte eine Filterung aufgrund fehlender Voraussetzungen nicht möglich sein. Gründe hierfür sind etwa ein zu geringer Gesamtbetrag um einen gewünschten Betrag darzustellen.

**Quellen**:
- [gcolorize](https://de.mathworks.com/matlabcentral/fileexchange/53786-image-manipulation-toolbox)
- [imblend](https://de.mathworks.com/matlabcentral/fileexchange/53786-image-manipulation-toolbox)
- [replacepixels](https://de.mathworks.com/matlabcentral/fileexchange/53786-image-manipulation-toolbox)
- [cell2mat](https://de.mathworks.com/help/matlab/ref/cell2mat.html)
- [size](https://de.mathworks.com/help/matlab/ref/size.html)
- [ismember](https://de.mathworks.com/help/matlab/ref/double.ismember.html)
- [ndgrid](https://de.mathworks.com/help/matlab/ref/ndgrid.html)
- [uint8](https://de.mathworks.com/help/matlab/ref/uint8.html)
- [fix](https://de.mathworks.com/help/matlab/ref/fix.html)
- [mod](https://de.mathworks.com/help/matlab/ref/mod.html)

------

Der Nutzer kann aus verschiedenen Filterungsoptionen auswählen, welche Münzen im Ausgangsbild farbig hinterlegen.
Dem Nutzer stehen folgende Filterungsoptionen zur Verfügung:
- "Kein Filter": Es wird kein Filter angewandt, alle Münzen werden basierend auf ihrem Wert eingefärbt.
- "Wenige Münzen": Der Nutzer kann einen gewünschten Betrag angeben. Das Programm ermittelt nun die kleinstmögliche Kombination an gegebenen Münzen um diesen Betrag zu erhalten und hinterlegt diese basierend auf ihrem Wert farbig.
- "Mindestens": Der Nutzer kann einen Mindestwert angeben. Es werden die Münzen farblich hinterlegt, welche mindestens diesen Wert besitzen.
- "Maximal": Der Nutzer kann einen Maximalwert angeben. Es werden die Münzen farblich hinterlegt, welche maximal diesen Wert besitzen.
- "Cheat": Dieser Filter bestückt interne Variablen zwecks Tests während der Entwicklungsphase mit Idealwerten für ein gegebenes Testbild


> Die Theorie hierzu wurde in Kapitel 7 - Segmentierung behandelt.

------



![Bild: Vorher](https://cdn.discordapp.com/attachments/923610318893121606/1065620539013607495/image.png)
*Eingabebild (Vorher)*



![Bild: Nachher](https://cdn.discordapp.com/attachments/923610318893121606/1065620570416369674/image.png)
*Ausgabebild (Nachher)*



```matlab
mask = uint8((xx.^2 + yy.^2)<(r^2)) * 255;
IAdjusted = gcolorize(I, valueColor(values(i)));
IAdjusted = imblend(I, IAdjusted, 1, 'linearburn');
I = replacepixels(IAdjusted, I, mask);
```



### Netzwerk trainieren

**Wichtig**:
- Die Trainingsdauer steigt exponentiell mit der Menge an Trainings- und Validierungsdaten.
- Die Eingabedaten für das neurale Netzwerk müssen mit denen der Trainings- und Validierungsdaten übereinstimmen, also 256x256px (Farbbilder) groß sein. Dies wird im vorigen Schritt erledigt.

**Anmerkungen**:
- Durch das Parallel Pooling wäre es theoretisch möglich, das Cluster der FH Aachen zu nutzen, um den Algorithmus verteilt das neurale Netzwerk trainieren zu lassen. Bei der hier verwendeten, geringen Trainingsmenge, ergibt das jedoch wenig Sinn.
- Wir nutzen ein Verhältnis von 75%-25% zwischen Trainings- und Validierungsdaten. Dies kann aber im Code mit der Variable `numTrainFiles` abgeändert werden.
- Die Trainingsoptionen können in der Variable `trainingOptions`angepasst werden, um beispielsweise die Trainingszeit und -intensität anzupassen.
- Es war uns leider nicht möglich, genügend gute Testdaten für das Trainieren des Netzwerkes zu sammeln. Deshalb ist die Genauigkeit bei eigens eingegebenen Bildern gering. *(Siehe Abschlusspräsentation: Lessons Learned)*

**Quellen**:
- [Mathworks Neural Networks](https://de.mathworks.com/discovery/neural-network.html)
- [Simple Image Classification Network](https://de.mathworks.com/help/deeplearning/gs/create-simple-deep-learning-classification-network.html)
- [Parallel Computing](https://de.mathworks.com/help/deeplearning/ug/neural-networks-with-parallel-and-gpu-computing.html)

------

Die Netzwerkarchitektur wird mit den verschienenen Layern und einer Eingabegröße von 256x256px (Farbbilder) initialisiert. Dabei wird für jede Münzklasse eine Klasse im `fullyConnectedLayer` angelegt.
Daraufhin wird das Netz trainiert und der Datei `serializedNet.mat` abgelegt.


> Die Theorie hierzu wurde in Kapitel 9 - Mustererkennung behandelt.

------



[Trainingsverlauf](https://cdn.discordapp.com/attachments/923610318893121606/1065617444200267927/image.png)
*Fortschritt des letzten ausgeführten Trainings*



```matlab
% Unterteilen in Trainings- und Validierungsdaten
numTrainFiles = 750;
[imdsTrain, imdsValidation] = splitEachLabel(imds, numTrainFiles, 'randomized');

%%

% Netzwerkarchitektur definieren
inputSize = [256 256 3];
numClasses = 8;

layers = [
    imageInputLayer(inputSize)
    convolution2dLayer(5,20)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

%%

% Netzwerk trainieren
options = trainingOptions('sgdm', 'MaxEpochs', 4,'ValidationData', imdsValidation, ...
    'ValidationFrequency', 30, 'Verbose', false, 'Plots', 'training-progress', ...
    'ExecutionEnvironment', 'parallel');

net = trainNetwork(imdsTrain, layers, options);
serializedNet = net;
save serializedNet;
```


------


## Konfiguration
[Über Matlab die folgenden Toolboxen installieren](https://de.mathworks.com/help/matlab/matlab_env/get-add-ons.html):
- [Computer Vision Toolbox](https://de.mathworks.com/products/computer-vision.html)
- [Image Processing Toolbox](https://de.mathworks.com/products/image.html)
- [Image Manipulation Toolbox](https://de.mathworks.com/matlabcentral/fileexchange/53786-image-manipulation-toolbox)
- [Deep Learning Toolbox](https://www.mathworks.com/products/deep-learning.html)
- [Parallel Computing Toolbox](https://www.mathworks.com/products/parallel-computing.html)

*Weitere Information können der [Dokumentation](https://github.com/Tamagear/Bildverarbeitung-FreiwilligesProjekt/tree/main/Dokumentation) entnommen werden.*


## Startanleitung
1. Abarbeiten der [**Konfiguration**](## Konfiguration) (einmalig).
2. Öffnen der Datei `GUI.mlapp`.
3. Starten über den Start-Knopf von Matlab.


## Wie es funktioniert
1. Ein Bild wird eingelesen. Der Nutzer zieht eine Linie über den Durchmesser einer beliebigen Münze. Je besser die Münze zu sehen ist, umso besser das zu erwartene Ergebnis.
2. Das gesamte Eingangsbild wird klassifiziert. Die Ergebnisse werden in der grafischen Benutzerschnittstelle angezeigt.


## Nutzen
Als für mobile Endgeräte kann **CoinCat** in Alltagssituationen helfen, so zum Beispiel, um genügend Geld für den Parkautomaten aus dem mitgeführten Kleingeld hervorzuheben.


## Beispieldaten
Beispiele für einlesbare Bilder finden sich im Ordner [Beispiele](https://github.com/Tamagear/Bildverarbeitung-FreiwilligesProjekt/tree/main/Beispiele).


## Projektpräsentation
Die Projektpräsentationen finden sich im Ordner [Präsentationen](https://github.com/Tamagear/Bildverarbeitung-FreiwilligesProjekt/tree/main/Pr%C3%A4sentationen).


## Lizenz
Lizensiert unter dem Lizenztypen [GNU GPL 3.0](https://www.gnu.org/licenses/gpl-3.0), jedoch ist kommerzieller Nutzen strengstens untersagt. Sämtliches Recht an den Namen, Projekten und Zugehörigkeiten der Autoren ist zu bewahren.


------

## Erklärung der Repo-Struktur

- Der Ordner `resource` enthält die Bilder die verwendet werden sollen.
- Der Ordner `prototyping` enthält obsolete oder irrelevante Funktionen und Dateien.
- Die Ordner `src` und `include` können dabei helfen Features und Funktionen strukturell voneinander zu trennen.
  - Der Ordner `include` beinhaltet Funktionsdefinitionen in `.m`-Dateien.
  - Der Ordner `src` beinhaltet Liveskripe und Apps. Ggfs. kann man es Skripte mit bspw. verschiedenen Visualisierungen oder mehr oder weniger Zwischenschritten geben.
- Weitere Informationen zu den einzelnen Ordnern können der `Dokumentation` oder der `readme-alt.md` entnommen werden.
- Die Präsentationen befinden sich alle in `Präsentationen`.

------

![Logo](https://cdn.discordapp.com/attachments/771767101164879892/1064668083324727407/CoinCatLogoHead.png)
