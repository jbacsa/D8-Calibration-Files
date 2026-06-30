@ECHO OFF
ATTRIB *.* -r
IF NOT EXIST d8_ctrl.zip GOTO CONTINUE
unzip -o d8_ctrl.zip
del d8_ctrl.zip
:CONTINUE
d8_ctrl.exe
install.exe
