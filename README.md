CheckCAMP
====

CheckCAMP (Checking Compatibility Across Mobile Platforms) is a tool for detecting inconsistencies in the same native app implemented in iOS and Android platforms. Our technique (1) automatically instruments and traces the app on each platform for given execution scenarios, (2) infers abstract models from each platform execution trace through dynamic analysis, (3) formally compares the models using a set of code-based and GUI-based criteria to expose any discrepancies, and finally (4) produces a visualization of the models, highlighting any detected inconsistencies. 
CheckCAMP consists of an iOS dynamic analyser, an Android dynamic analyser, and a Mapping and Visualization engine. Our open-source multi-platform native mobile app-pairs together with their evaluation results are included.


Paper
-----

The technique behind CheckCAMP is published as a research paper at ISSRE 2015. It is titled <a href="http://salt.ece.ubc.ca/publications/docs/issre15.pdf">Detecting Inconsistencies in Multi-Platform Mobile Apps</a> and is available as a PDF. 



