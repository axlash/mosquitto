; NSIS installer script for mosquitto

!include "MUI2.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"

; For environment variable code
!include "WinMessages.nsh"
!define env_hklm 'HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"'

Name "Eclipse Mosquitto"
!define VERSION 1.5.1
OutFile "mosquitto-${VERSION}-install-windows-x64.exe"

!include "x64.nsh"
InstallDir "$PROGRAMFILES64\mosquitto"

;--------------------------------
; Installer pages
!insertmacro MUI_PAGE_WELCOME

Page custom DependencyPage
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH


;--------------------------------
; Uninstaller pages
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;--------------------------------
; Languages
!insertmacro MUI_LANGUAGE "English"

;--------------------------------
; Installer sections

Section "Files" SecInstall
	SectionIn RO
	SetOutPath "$INSTDIR"
	File "..\build64\src\Release\mosquitto.exe"
	File "..\build64\src\Release\mosquitto_passwd.exe"
	File "..\build64\client\Release\mosquitto_pub.exe"
	File "..\build64\client\Release\mosquitto_sub.exe"
	File "..\build64\lib\Release\mosquitto.dll"
	File "..\build64\lib\cpp\Release\mosquittopp.dll"
	File "..\aclfile.example"
	File "..\ChangeLog.txt"
	File "..\mosquitto.conf"
	File "..\pwfile.example"
	File "..\readme.md"
	File "..\readme-windows.txt"
	;File "C:\pthreads\Pre-built.2\dll\x64\pthreadVC2.dll"
	;File "C:\OpenSSL-Win64\bin\libssl_1-1-x64.dll"
	;File "C:\OpenSSL-Win64\bin\libcrypto_1-1-x64.dll"
	File "..\edl-v10"
	File "..\epl-v10"

	SetOutPath "$INSTDIR\devel"
	File "..\lib\mosquitto.h"
	File "..\build64\lib\Release\mosquitto.lib"
	File "..\lib\cpp\mosquittopp.h"
	File "..\build64\lib\cpp\Release\mosquittopp.lib"
	File "..\src\mosquitto_plugin.h"

	WriteUninstaller "$INSTDIR\Uninstall.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Mosquitto64" "DisplayName" "Eclipse Mosquitto MQTT broker (64 bit)"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Mosquitto64" "UninstallString" "$\"$INSTDIR\Uninstall.exe$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Mosquitto64" "QuietUninstallString" "$\"$INSTDIR\Uninstall.exe$\" /S"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Mosquitto64" "HelpLink" "https://mosquitto.org/"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Mosquitto64" "URLInfoAbout" "https://mosquitto.org/"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Mosquitto64" "DisplayVersion" "${VERSION}"
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Mosquitto64" "NoModify" "1"
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Mosquitto64" "NoRepair" "1"

	WriteRegExpandStr ${env_hklm} MOSQUITTO_DIR $INSTDIR
	SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
SectionEnd

Section "Uninstall"
	ExecWait '"$INSTDIR\mosquitto.exe" uninstall'
	Delete "$INSTDIR\mosquitto.exe"
	Delete "$INSTDIR\mosquitto_passwd.exe"
	Delete "$INSTDIR\mosquitto_pub.exe"
	Delete "$INSTDIR\mosquitto_sub.exe"
	Delete "$INSTDIR\mosquitto.dll"
	Delete "$INSTDIR\mosquittopp.dll"
	Delete "$INSTDIR\aclfile.example"
	Delete "$INSTDIR\ChangeLog.txt"
	Delete "$INSTDIR\mosquitto.conf"
	Delete "$INSTDIR\pwfile.example"
	Delete "$INSTDIR\readme.txt"
	Delete "$INSTDIR\readme-windows.txt"
	;Delete "$INSTDIR\pthreadVC2.dll"
	;Delete "$INSTDIR\libssl_1-1-x64.dll"
	;Delete "$INSTDIR\libcrypto_1-1-x64.dll"
	Delete "$INSTDIR\edl-v10"
	Delete "$INSTDIR\epl-v10"

	Delete "$INSTDIR\devel\mosquitto.h"
	Delete "$INSTDIR\devel\mosquitto.lib"
	Delete "$INSTDIR\devel\mosquittopp.h"
	Delete "$INSTDIR\devel\mosquittopp.lib"
	Delete "$INSTDIR\devel\mosquitto_plugin.h"

	Delete "$INSTDIR\Uninstall.exe"
	RMDir "$INSTDIR"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Mosquitto64"

	DeleteRegValue ${env_hklm} MOSQUITTO_DIR
	SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
SectionEnd

LangString DESC_SecInstall ${LANG_ENGLISH} "The main installation."
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${SecInstall} $(DESC_SecInstall)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Var Dialog
Var OSSLLink
Var PTHLink

Function DependencyPage
	nsDialogs::Create 1018
	Pop $Dialog

	${If} $Dialog == error
		Abort
	${EndIf}

	${NSD_CreateLabel} 0 0 100% 12u "OpenSSL - install 'Win64 OpenSSL v1.1.0* Light' then copy libssl_1-1-x64.dll and libcrypto_1-1-x64.dll to the mosquitto directory"
	${NSD_CreateLink} 13u 13u 100% 12u "http://slproweb.com/products/Win32OpenSSL.html"
	Pop $OSSLLink
	${NSD_OnClick} $OSSLLink OnClick_OSSL

	!insertmacro MUI_HEADER_TEXT_PAGE "Dependencies" "This page lists packages that must be installed if not already present"
	nsDialogs::Show
FunctionEnd

Function OnClick_OSSL
	Pop $0
	ExecShell "open" "http://slproweb.com/products/Win32OpenSSL.html"
FunctionEnd
