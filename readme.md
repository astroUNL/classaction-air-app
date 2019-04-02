
Extract classaction files (questions, animations, etc.) to files. This directory is not included in the git repo.

To compile main.swf:
cd src/astroUNL/classaction/browser
mxmlc -load-config compiler-config.xml -- Main.as

To test the app:
adl app.xml

To create the app:
adt -package -keystore <certificate> -storetype pkcs12 -target bundle ClassAction.app app.xml main.swf classaction