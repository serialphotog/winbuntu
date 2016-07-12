;--------------------------------
; Defines

!define VERSION "Beta-1.0"

;--------------------------------
; General

; Name/File
Name "Winbuntu ${VERSION}"
OutFile "Winbutnu_${VERSION}_setup.exe"

SetCompressor /SOLID LZMA

; Default install Dir
InstallDir "C:\Winbuntu"

; Fetch install dir from registry, if available
InstallDirRegKey HKLM "Software\Winbuntu" ""

; We need amin rights
RequestExecutionLevel admin

;--------------------------------
; Modern UI

!include "MUI2.nsh"

;--------------------------------
; Pages

!insertmacro MUI_PAGE_LICENSE "..\COPYING"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

;--------------------------------
; Installer

Section "install"
	
	SetOutPath "$INSTDIR"
	SetRegView 64

	;; Install xming
	DetailPrint "Installing Xming..."
	StrCpy $2 "$INSTDIR\tmp"
	CreateDirectory $2
	StrCpy $0 "$2\xming-install.exe"
	NSISdl::download "http://downloads.sourceforge.net/project/xming/Xming/6.9.0.31/Xming-6-9-0-31-setup.exe?use_mirror=autoselect" $0
	Pop $1
	StrCmp $1 success success
		SetDetailsView show
		DetailPrint "Xming download failed"
		Abort
	success:
		ExecWait '"$0" /silent /dir="xming\"'

		;; Clean up tmp files
		DetailPrint "Cleaning temporary files..."
		RMDir /r "$INSTDIR\tmp\*.*"
		RMDir /r "$INSTDIR\tmp"

		;; Winbuntu components
    	DetailPrint "Installing base system..."
		File "..\linux.bat"
		File "..\environment.sh"

		;; Registry
		WriteRegStr HKLM "Software\Winbuntu" "" $INSTDIR
		WriteRegStr HKLM "Software\Winbuntu" "InstallPath" "$INSTDIR"
		WriteRegStr HKLM "Software\Winbuntu" "Version" "${VERSION}"

		;; Registry
		WriteRegStr HKLM "Software\Winbuntu" "" $INSTDIR
		WriteRegStr HKLM "Software\Winbuntu" "Version" "${VERSION}"

		;; Uninstaller
		DetailPrint "Creating Uninstaller..."
		WriteUninstaller "$INSTDIR\uninstall.exe"

		;; Uninstaller Registry
		WriteRegExpandStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Winbuntu" "UninstallString" "$INSTDIR\uninstall.exe"
		WriteRegExpandStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Winbuntu" "InstallLocation" "$INSTDIR"
		WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Winbuntu" "DisplayName" "Winbuntu ${VERSION}"
		WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Winbuntu" "DisplayVersion" "${VERSION}"
		WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Winbuntu" "NoModify" "1"
		WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Winbuntu" "NoRepair" "1"

SectionEnd

;--------------------------------
; Uninstaller

Section "Uninstall"

	;; Run the Xming uninstaller
	ExecWait '"$INSTDIR\xming\unins000.exe" /S_?=$INSTDIR'
	
	;; Delete the Files
	RMDir /r "$INSTDIR\*.*"
	RMDir "$INSTDIR"

	;; Remove Uninstaller
	DeleteRegKey HKLM "SOFTWARE\Winbuntu"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Winbuntu"

SectionEnd
