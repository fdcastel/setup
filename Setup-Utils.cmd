@ECHO OFF

CALL cinst 7zip GoogleChrome TeamViewer sublimetext3 utorrent

IF /I [%1] EQU [FULL] (
	CALL cinst PdfXchangeViewer PdfCreator Skype
)