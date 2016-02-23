#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Imgs\Icon.ico
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_Res_Fileversion=2.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=R.S.S.
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_Add_Constants=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <TreeViewConstants.au3>
#include <WindowsConstants.au3>
#include <GDIPlus.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <StaticConstants.au3>
#include <Timers.au3>
#include <TrayConstants.au3>
#include <ButtonConstants.au3>



#include ".\Skins\Cosmo.au3"
#include "_UskinLibrary.au3"

_Uskin_LoadDLL()
_USkin_Init(_Cosmo(True))

Opt("GUIOnEventMode", 1)
Opt("TrayMenuMode", 3)
Opt("TrayOnEventMode", 1)

Global $CurrentGui, $AZTreeView, $InputMovieDescription = 0, $InputMovieGenre = 0, $InputMovieTitle = 0, $Stop = 0, $CheckMovieAddition = 0
Global $MainGui, $CurrentListSelection, $OldListSelection, $Msg, $StartTimer, $DefaultButton, $CurrentMovieDescription, $CurrentMovieGenre, $CurrentMovieWatchCount
Global $CurrentMovieTitle, $MovieDataGui, $GenericPicture, $MoviePicture, $CheckPicture, $CurrentMoviePictureCheck, $DisplayMovieTitle, $CheckFavorite
Global $FavoritesList, $CurrentMovieFavoriteCheck, $NumberList, $CurrentMovieGenreDisplay, $CurrentMovieTitleDisplay, $CurrentMovieDescriptionDisplay
Global $CurrentMovieFavoriteDisplay, $CurrentMoviePictureDisplay, $EditButton, $SaveButton, $TrimTitleForSelection, $MovieButton
Global $MoviePictureYesRadio, $MoviePictureNoRadio, $MovieFavoriteYesRadio, $MovieFavoriteNoRadio, $EditMoviePicture = "0", $EditMovieFavorite = "0"

Dim $Alphabet[27] = [26, "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
Dim $AZList[27]

$CheckFirstRun = IniRead(@ScriptDir & "/Data/Settings.ini", "Settings", "FirstRun", "NA")
If $CheckFirstRun = 0 Then
    MsgBox(48, "Warning", "Please be aware, to get the images for movies to work properly you will need to save them as .jpg and will also need to name them the same as you did the movie title!")
    MsgBox(0, "Note", "If you wish to see this message again you may go into the Settings.ini file in the Data folder and change the 1 to a 0")
    IniWrite(@ScriptDir & "/Data/Settings.ini", "Settings", "FirstRun", "1")
EndIf

TrayCreateItem("Exit...")
TrayItemSetOnEvent(-1, "_CloseProgram")
TrayCreateItem("Refresh Database...")
TrayItemSetOnEvent(-1, "_UpdateDatabase")

_ReCreateMainGui()
_UpdateDatabase()

Func _ReCreateMainGui()
    $CurrentGui = "Main"

    $MainGui = GUICreate("Movie Database - RSSoftware", 800, 600)
    GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")

    GUICtrlCreateLabel("© RS Software", 730, 575, 200)
    GUICtrlSetFont(-1, 8)
    GUICtrlCreateLabel("Version 2.0", 738, 585, 200)
    GUICtrlSetFont(-1, 8)



    $AZTreeView = GUICtrlCreateTreeView(5, 80, 200, 515, BitOR($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS), $WS_EX_CLIENTEDGE)

    $FavoritesList = GUICtrlCreateTreeViewItem("Favorites", $AZTreeView)

    $NumberList = GUICtrlCreateTreeViewItem("#", $AZTreeView)

    For $i = 1 To $Alphabet[0]
        $AZList[$i] = GUICtrlCreateTreeViewItem($Alphabet[$i], $AZTreeView)
    Next



    $AddMovieButton = GUICtrlCreateButton("Add Movie", 20, 10, 200, 50)
    GUICtrlSetOnEvent(-1, "_AddMovie")
    GUICtrlSetFont(-1, 16)
    $OptionsButton = GUICtrlCreateButton("Refresh Database", 580, 10, 200, 50)
    GUICtrlSetOnEvent(-1, "_UpdateDatabase")
    GUICtrlSetFont(-1, 16)

    $RemoveMovieButton = GUICtrlCreateButton("Remove Movie", 300, 10, 200, 50)
    GUICtrlSetOnEvent(-1, "_RemoveMovie")
    GUICtrlSetFont(-1, 16)

    $GenericPicture = GUICtrlCreatePic(@ScriptDir & "/Imgs/DefaultImg.jpg", 385, 160, 250, 300)
    $MoviePicture = GUICtrlCreatePic(@ScriptDir & "/Imgs/DefaultImg.jpg", 385, 160, 250, 300)

    $DefaultButton = GUICtrlCreateButton("Movie Information", 360, 500, 300, 80)
    GUICtrlSetOnEvent(-1, "_DefaultButton")
    GUICtrlSetFont(-1, 22)

    GUICtrlSetState($AZList[1], $GUI_FOCUS)


    $DisplayMovieTitle = GUICtrlCreateInput("", 220, 95, 570, 40, BitOR($ES_ReadOnly, $ES_Center))
    GUICtrlSetFont(-1, 22)
    GUICtrlSetColor(-1, 0x00CCFF)

    GUISetState(@SW_SHOW)



EndFunc   ;==>_ReCreateMainGui


Func _DefaultButton()
    MsgBox(0, "Hello!", "Please select a movie to see the movie information! Or add a movie if you haven't yet!")
EndFunc   ;==>_DefaultButton

Func _GetMovieData()
    $GetTitleLength = StringLen($CurrentListSelection)
    $TrimTitleForSelection = StringTrimRight($CurrentListSelection, $GetTitleLength - 1)
    If StringIsDigit($TrimTitleForSelection) Then
        $MovieData = IniReadSection(@ScriptDir & "/Data/# List/" & $CurrentListSelection & ".ini", $CurrentListSelection)
        MsgBox(0, "Test", "Test")
    EndIf
    If StringIsAlpha($TrimTitleForSelection) Then
        $MovieData = IniReadSection(@ScriptDir & "/Data/AZList/" & $TrimTitleForSelection & "/" & $CurrentListSelection & ".ini", $CurrentListSelection)
    EndIf
    $CurrentMovieTitle = $CurrentListSelection
    $CurrentMovieGenre = $MovieData[1][1]
    $CurrentMovieDescription = $MovieData[2][1]
    $CurrentMoviePictureCheck = $MovieData[3][1]
    $CurrentMovieFavoriteCheck = $MovieData[4][1]
    If $MovieData[3][1] = 1 Then
        GUICtrlSetState($GenericPicture, $GUI_HIDE)
        GUICtrlDelete($MoviePicture)
        $MoviePicture = GUICtrlCreatePic(@ScriptDir & "/Imgs/" & $CurrentListSelection & ".jpg", 385, 160, 250, 300)
    Else
        GUICtrlSetState($MoviePicture, $GUI_HIDE)
        GUICtrlSetState($GenericPicture, $GUI_SHOW)
    EndIf
    GUICtrlDelete($DefaultButton)
    GUICtrlDelete($MovieButton)

    $MovieButton = GUICtrlCreateButton("Movie Information", 360, 500, 300, 80)
    GUICtrlSetOnEvent(-1, "_ReadMovieData")
    GUICtrlSetFont(-1, 22)

    GUICtrlSetData($DisplayMovieTitle, $CurrentMovieTitle)
EndFunc   ;==>_GetMovieData

Func _ReadMovieData()
    GUISetState(@SW_DISABLE, $MainGui)
    $CurrentGui = "MovieDataGui"
    $MovieDataGui = GUICreate($CurrentMovieTitle, 400, 520)
    GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")

    GUICtrlCreateLabel("Movie Title", 150, 10, 200)
    GUICtrlSetFont(-1, 16)
    GUICtrlSetColor(-1, 0xFFFFFF)
    $CurrentMovieTitleDisplay = GUICtrlCreateInput($CurrentMovieTitle, 10, 40, 380, 30, BitOR($ES_Center, $ES_ReadOnly))
    GUICtrlSetFont(-1, 12)
    GUICtrlSetColor(-1, 0x00CCFF)

    GUICtrlCreateLabel("Movie Genre", 140, 90, 200)
    GUICtrlSetFont(-1, 16)
    GUICtrlSetColor(-1, 0xFFFFFF)
    $CurrentMovieGenreDisplay = GUICtrlCreateInput($CurrentMovieGenre, 10, 120, 380, 30, BitOR($ES_Center, $ES_ReadOnly))
    GUICtrlSetFont(-1, 12)
    GUICtrlSetColor(-1, 0x00CCFF)



    GUICtrlCreateLabel("Movie Picture", 140, 170, 200)
    GUICtrlSetFont(-1, 16)
    GUICtrlSetColor(-1, 0xFFFFFF)
    GUIStartGroup()
    $MoviePictureYesRadio = GUICtrlCreateRadio("Yes", 145, 210, 60, 20, $BS_Center)
    GUICtrlSetFont(-1, 14)
    GUICtrlSetState($MoviePictureYesRadio, $GUI_HIDE)
    GUICtrlSetOnEvent(-1, "_YesPicture")
    $MoviePictureNoRadio = GUICtrlCreateRadio("No", 215, 210, 60, 20, $BS_Center)
    GUICtrlSetFont(-1, 14)
    GUICtrlSetState($MoviePictureNoRadio, $GUI_HIDE)
    GUICtrlSetOnEvent(-1, "_NoPicture")
    If $CurrentMoviePictureCheck = 1 Then
        $DisplayPicture = "Yes"
        $EditMoviePicture = "1"
        GUICtrlSetState($MoviePictureYesRadio, $GUI_CHECKED)
    Else
        $DisplayPicture = "No"
        $EditMoviePicture = "0"
        GUICtrlSetState($MoviePictureNoRadio, $GUI_CHECKED)
    EndIf
    $CurrentMoviePictureDisplay = GUICtrlCreateInput($DisplayPicture, 10, 200, 380, 30, BitOR($ES_Center, $ES_ReadOnly))
    GUICtrlSetFont(-1, 12)
    GUICtrlSetColor(-1, 0x00CCFF)

    GUICtrlCreateLabel("Movie Favorited", 125, 250, 200)
    GUICtrlSetFont(-1, 16)
    GUICtrlSetColor(-1, 0xFFFFFF)
    GUIStartGroup()
    $MovieFavoriteYesRadio = GUICtrlCreateRadio("Yes", 145, 290, 60, 20, $BS_Center)
    GUICtrlSetFont(-1, 14)
    GUICtrlSetState($MovieFavoriteYesRadio, $GUI_HIDE)
    GUICtrlSetOnEvent(-1, "_YesFavorite")
    $MovieFavoriteNoRadio = GUICtrlCreateRadio("No", 215, 290, 60, 20, $BS_Center)
    GUICtrlSetFont(-1, 14)
    GUICtrlSetState($MovieFavoriteNoRadio, $GUI_HIDE)
    GUICtrlSetOnEvent(-1, "_NoFavorite")
    If $CurrentMovieFavoriteCheck = 1 Then
        $EditMovieFavorite = "1"
        $DisplayFavorite = "Yes"
        GUICtrlSetState($MovieFavoriteYesRadio, $GUI_CHECKED)
    Else
        $DisplayFavorite = "No"
        $EditMovieFavorite = "0"
        GUICtrlSetState($MovieFavoriteNoRadio, $GUI_CHECKED)
    EndIf
    $CurrentMovieFavoriteDisplay = GUICtrlCreateInput($DisplayFavorite, 10, 280, 380, 30, BitOR($ES_Center, $ES_ReadOnly))
    GUICtrlSetFont(-1, 12)
    GUICtrlSetColor(-1, 0x00CCFF)

    GUICtrlCreateLabel("Movie Description", 120, 330, 200)
    GUICtrlSetFont(-1, 16)
    GUICtrlSetColor(-1, 0xFFFFFF)
    $CurrentMovieDescriptionDisplay = GUICtrlCreateEdit($CurrentMovieDescription, 10, 360, 380, 100, BitOR($ES_Center, $ES_ReadOnly))
    GUICtrlSetFont(-1, 12)
    GUICtrlSetColor(-1, 0x00CCFF)

    $EditButton = GUICtrlCreateButton("Edit Movie", 10, 470, 180, 50)
    GUICtrlSetOnEvent(-1, "_EditMovie")
    GUICtrlSetFont(-1, 16)

    $SaveButton = GUICtrlCreateButton("Save Movie", 10, 470, 180, 50)
    GUICtrlSetOnEvent(-1, "_SaveMovie")
    GUICtrlSetFont(-1, 16)

    GUICtrlSetState(-1, $GUI_HIDE)

    $CloseButton = GUICtrlCreateButton("Close", 210, 470, 180, 50)
    GUICtrlSetOnEvent(-1, "_Exit")
    GUICtrlSetFont(-1, 16)
    GUISetState()
EndFunc   ;==>_ReadMovieData

Func _YesPicture()
    $EditMoviePicture = "1"
EndFunc   ;==>_YesPicture

Func _NoPicture()
    $EditMoviePicture = "0"
EndFunc   ;==>_NoPicture

Func _YesFavorite()
    $EditMovieFavorite = "1"
EndFunc   ;==>_YesFavorite

Func _NoFavorite()
    $EditMovieFavorite = "0"
EndFunc   ;==>_NoFavorite

Func _EditMovie()
    GUICtrlSetState($EditButton, $GUI_HIDE)
    GUICtrlSetState($SaveButton, $GUI_SHOW)
    GUICtrlSetStyle($CurrentMovieGenreDisplay, $GUI_SS_DEFAULT_INPUT)
    GUICtrlSetStyle($CurrentMovieGenreDisplay, $ES_CENTER)
    GUICtrlSetColor($CurrentMovieGenreDisplay, 0xfb0000)
    GUICtrlSetStyle($CurrentMovieDescriptionDisplay, $GUI_SS_DEFAULT_INPUT)
    GUICtrlSetStyle($CurrentMovieDescriptionDisplay, $ES_CENTER)
    GUICtrlSetColor($CurrentMovieDescriptionDisplay, 0xfb0000)
    GUICtrlSetState($CurrentMoviePictureDisplay, $GUI_HIDE)
    GUICtrlSetState($CurrentMovieFavoriteDisplay, $GUI_HIDE)
    GUICtrlSetState($MoviePictureYesRadio, $GUI_SHOW)
    GUICtrlSetState($MoviePictureNoRadio, $GUI_SHOW)
    GUICtrlSetState($MovieFavoriteYesRadio, $GUI_SHOW)
    GUICtrlSetState($MovieFavoriteNoRadio, $GUI_SHOW)
EndFunc   ;==>_EditMovie

Func _SaveMovie()
    $EditMovieGenre = GUICtrlRead($CurrentMovieGenreDisplay)
    $EditMovieDescription = GUICtrlRead($CurrentMovieDescriptionDisplay)
    If StringIsDigit($TrimTitleForSelection) Then
        IniWrite(@ScriptDir & "/Data/# List/" & $CurrentMovieTitle & ".ini", $CurrentMovieTitle, "Genre", $EditMovieGenre)
        IniWrite(@ScriptDir & "/Data/# List/" & $CurrentMovieTitle & ".ini", $CurrentMovieTitle, "Description", $EditMovieDescription)
        IniWrite(@ScriptDir & "/Data/# List/" & $CurrentMovieTitle & ".ini", $CurrentMovieTitle, "Picture", $EditMoviePicture)
        IniWrite(@ScriptDir & "/Data/# List/" & $CurrentMovieTitle & ".ini", $CurrentMovieTitle, "Favorite", $EditMovieFavorite)
    EndIf
    If StringIsAlpha($TrimTitleForSelection) Then
        IniWrite(@ScriptDir & "/Data/AZList/" & $TrimTitleForSelection & "/" & $CurrentMovieTitle & ".ini", $CurrentMovieTitle, "Genre", $EditMovieGenre)
        IniWrite(@ScriptDir & "/Data/AZList/" & $TrimTitleForSelection & "/" & $CurrentMovieTitle & ".ini", $CurrentMovieTitle, "Description", $EditMovieDescription)
        IniWrite(@ScriptDir & "/Data/AZList/" & $TrimTitleForSelection & "/" & $CurrentMovieTitle & ".ini", $CurrentMovieTitle, "Picture", $EditMoviePicture)
        IniWrite(@ScriptDir & "/Data/AZList/" & $TrimTitleForSelection & "/" & $CurrentMovieTitle & ".ini", $CurrentMovieTitle, "Favorite", $EditMovieFavorite)
    EndIf

    If $EditMovieFavorite = 1 Then

        If StringIsDigit($TrimTitleForSelection) Then
            FileCopy(@ScriptDir & "/Data/# List/" & $CurrentMovieTitle & ".ini", @ScriptDir & "/Data/Favorites/" & $CurrentMovieTitle & ".ini", 1)
        Else

            FileCopy(@ScriptDir & "/Data/AZList/" & $TrimTitleForSelection & "/" & $CurrentMovieTitle & ".ini", @ScriptDir & "/Data/Favorites/" & $CurrentMovieTitle & ".ini", 1)
        EndIf

    Else

        FileDelete(@ScriptDir & "/Data/Favorites/" & $CurrentMovieTitle & ".ini")
    EndIf

    GUIDelete($MovieDataGui)
    GUISetState(@SW_ENABLE, $MainGui)
    _UpdateDatabase()

EndFunc   ;==>_SaveMovie


Func _AddMovie()
    GUISetState(@SW_DISABLE, $MainGui)
    $CurrentGui = "MovieDataGui"
    $MovieDataGui = GUICreate("Add NewMovie", 400, 520)

    GUICtrlCreateLabel("Movie Title", 150, 10, 200)
    GUICtrlSetFont(-1, 16)
    GUICtrlSetColor(-1, 0xFFFFFF)
    $CurrentMovieTitleDisplay = GUICtrlCreateInput("", 10, 40, 380, 30, $ES_CENTER)
    GUICtrlSetFont(-1, 12)
    GUICtrlSetColor(-1, 0x00CCFF)
    GUICtrlSetColor($CurrentMovieTitleDisplay, 0xfb0000)

    GUICtrlCreateLabel("Movie Genre", 140, 90, 200)
    GUICtrlSetFont(-1, 16)
    GUICtrlSetColor(-1, 0xFFFFFF)
    $CurrentMovieGenreDisplay = GUICtrlCreateInput("", 10, 120, 380, 30, $ES_Center)
    GUICtrlSetFont(-1, 12)
    GUICtrlSetColor(-1, 0x00CCFF)
    GUICtrlSetColor($CurrentMovieGenreDisplay, 0xfb0000)



    GUICtrlCreateLabel("Movie Picture", 140, 170, 200)
    GUICtrlSetFont(-1, 16)
    GUICtrlSetColor(-1, 0xFFFFFF)
    GUIStartGroup()
    $MoviePictureYesRadio = GUICtrlCreateRadio("Yes", 145, 210, 60, 20, $BS_Center)
    GUICtrlSetFont(-1, 14)
    GUICtrlSetOnEvent(-1, "_YesPicture")
    $MoviePictureNoRadio = GUICtrlCreateRadio("No", 215, 210, 60, 20, $BS_Center)
    GUICtrlSetFont(-1, 14)
    GUICtrlSetOnEvent(-1, "_NoPicture")
    If $CurrentMoviePictureCheck = 1 Then
        $DisplayPicture = "Yes"
        $EditMoviePicture = "1"
        GUICtrlSetState($MoviePictureYesRadio, $GUI_CHECKED)
    Else
        $DisplayPicture = "No"
        $EditMoviePicture = "0"
        GUICtrlSetState($MoviePictureNoRadio, $GUI_CHECKED)
    EndIf

    GUICtrlCreateLabel("Movie Favorited", 125, 250, 200)
    GUICtrlSetFont(-1, 16)
    GUICtrlSetColor(-1, 0xFFFFFF)
    GUIStartGroup()
    $MovieFavoriteYesRadio = GUICtrlCreateRadio("Yes", 145, 290, 60, 20, $BS_Center)
    GUICtrlSetFont(-1, 14)
    GUICtrlSetOnEvent(-1, "_YesFavorite")
    $MovieFavoriteNoRadio = GUICtrlCreateRadio("No", 215, 290, 60, 20, $BS_Center)
    GUICtrlSetFont(-1, 14)
    GUICtrlSetOnEvent(-1, "_NoFavorite")
    If $CurrentMovieFavoriteCheck = 1 Then
        $EditMovieFavorite = "1"
        $DisplayFavorite = "Yes"
        GUICtrlSetState($MovieFavoriteYesRadio, $GUI_CHECKED)
    Else
        $DisplayFavorite = "No"
        $EditMovieFavorite = "0"
        GUICtrlSetState($MovieFavoriteNoRadio, $GUI_CHECKED)
    EndIf

    GUICtrlCreateLabel("Movie Description", 120, 330, 200)
    GUICtrlSetFont(-1, 16)
    GUICtrlSetColor(-1, 0xFFFFFF)
    $CurrentMovieDescriptionDisplay = GUICtrlCreateEdit("", 10, 360, 380, 100, $ES_Center)
    GUICtrlSetFont(-1, 12)
    GUICtrlSetColor(-1, 0x00CCFF)
    GUICtrlSetColor($CurrentMovieDescriptionDisplay, 0xfb0000)

    $AddMovieFinishedButton = GUICtrlCreateButton("Add Movie", 10, 470, 180, 50)
    GUICtrlSetOnEvent(-1, "_AddMovieFinished")
    GUICtrlSetFont(-1, 16)

    $CloseButton = GUICtrlCreateButton("Cancel", 210, 470, 180, 50)
    GUICtrlSetOnEvent(-1, "_CancelAddMovie")
    GUICtrlSetFont(-1, 16)
    GUISetState()
EndFunc   ;==>_AddMovie

Func _CancelAddMovie()
    MsgBox(48, "Cancel", "Addition of movie has been cancelled!")
    $Stop = 0
    $InputMovieDescription = 0
    $InputMovieGenre = 0
    $InputMovieTitle = 0
    $CheckMovieAddition = 0
    $CheckPicture = 0
    $CheckFavorite = 0
    GUISetState(@SW_ENABLE, $MainGui)
    $CurrentGui = "Main"
    GUIDelete($MovieDataGui)
EndFunc   ;==>_CancelAddMovie

Func _AddMovieFinished()
    $InputMovieGenre = GUICtrlRead($CurrentMovieGenreDisplay)
    $InputMovieDescription = GUICtrlRead($CurrentMovieDescriptionDisplay)
    $InputMovieTitle = GUICtrlRead($CurrentMovieTitleDisplay)
    If $InputMovieGenre = "" Then
        $Stop = 1
        MsgBox(48, "Error", "You must input a genre to continue!")
    EndIf
    If $InputMovieDescription = "" Then
        $Stop = 1
        MsgBox(48, "Error", "You must input a movie description to continue!")
    EndIf
    If $InputMovieTitle = "" Then
        $Stop = 1
        MsgBox(48, "Error", "You must input a movie title to continue!")
    EndIf
    If $Stop = 0 Then
        $GetTitleLength = StringLen($InputMovieTitle)
        $TrimTitleForAZList = StringTrimRight($InputMovieTitle, $GetTitleLength - 1)

        If StringIsDigit($TrimTitleForAZList) Then
            IniWrite(@ScriptDir & "/Data/# List/" & $InputMovieTitle & ".ini", $InputMovieTitle, "Genre", $InputMovieGenre)
            IniWrite(@ScriptDir & "/Data/# List/" & $InputMovieTitle & ".ini", $InputMovieTitle, "Description", $InputMovieDescription)
            IniWrite(@ScriptDir & "/Data/# List/" & $InputMovieTitle & ".ini", $InputMovieTitle, "Picture", $EditMoviePicture)
            IniWrite(@ScriptDir & "/Data/# List/" & $InputMovieTitle & ".ini", $InputMovieTitle, "Favorite", $EditMovieFavorite)
        Else
            $CheckIfDirExists = DirGetSize(@ScriptDir & "/Data/AZList/" & $TrimTitleForAZList)
            If @error Then
                DirCreate(@ScriptDir & "/Data/AZList/" & $TrimTitleForAZList)
                IniWrite(@ScriptDir & "/Data/AZList/" & $TrimTitleForAZList & "/" & $InputMovieTitle & ".ini", $InputMovieTitle, "Genre", $InputMovieGenre)
                IniWrite(@ScriptDir & "/Data/AZList/" & $TrimTitleForAZList & "/" & $InputMovieTitle & ".ini", $InputMovieTitle, "Description", $InputMovieDescription)
                IniWrite(@ScriptDir & "/Data/AZList/" & $TrimTitleForAZList & "/" & $InputMovieTitle & ".ini", $InputMovieTitle, "Picture", $EditMoviePicture)
                IniWrite(@ScriptDir & "/Data/AZList/" & $TrimTitleForAZList & "/" & $InputMovieTitle & ".ini", $InputMovieTitle, "Favorite", $EditMovieFavorite)
            Else
                IniWrite(@ScriptDir & "/Data/AZList/" & $TrimTitleForAZList & "/" & $InputMovieTitle & ".ini", $InputMovieTitle, "Genre", $InputMovieGenre)
                IniWrite(@ScriptDir & "/Data/AZList/" & $TrimTitleForAZList & "/" & $InputMovieTitle & ".ini", $InputMovieTitle, "Description", $InputMovieDescription)
                IniWrite(@ScriptDir & "/Data/AZList/" & $TrimTitleForAZList & "/" & $InputMovieTitle & ".ini", $InputMovieTitle, "Picture", $EditMoviePicture)
                IniWrite(@ScriptDir & "/Data/AZList/" & $TrimTitleForAZList & "/" & $InputMovieTitle & ".ini", $InputMovieTitle, "Favorite", $EditMovieFavorite)
            EndIf
        EndIf

        If $CheckFavorite = 1 Then
            If StringIsDigit($TrimTitleForAZList) Then
                FileCopy(@ScriptDir & "/Data/# List/" & $InputMovieTitle & ".ini", @ScriptDir & "/Data/Favorites/" & $InputMovieTitle & ".ini", 1)
            Else

                FileCopy(@ScriptDir & "/Data/AZList/" & $TrimTitleForAZList & "/" & $InputMovieTitle & ".ini", @ScriptDir & "/Data/Favorites/" & $InputMovieTitle & ".ini", 1)
            EndIf


        EndIf
        MsgBox(0, "Movie Added", "Movie " & $InputMovieTitle & " has been added!")
        $Stop = 0
        $InputMovieDescription = 0
        $InputMovieGenre = 0
        $InputMovieTitle = 0
        $CheckMovieAddition = 0
        $CheckPicture = 0
        $CheckFavorite = 0
        GUISetState(@SW_ENABLE, $MainGui)
        GUIDelete($MovieDataGui)
    EndIf


EndFunc   ;==>_AddMovieFinished

Func _RemoveMovie()
    $InputMovieToRemove = InputBox("Remove Movie", "Please input the name of the movie you wish to remove.")
    If @error = 1 Then
        MsgBox(48, "Cancelled", "Cancel was pushed, cancelling removal of movie!")
    EndIf
    If $InputMovieToRemove = "" Then
        MsgBox(48, "Cancelled", "No movie name input, cancelling removal of movie!")
    Else
        $GetTitleLength = StringLen($InputMovieToRemove)
        $TrimTitleForAZList = StringTrimRight($InputMovieToRemove, $GetTitleLength - 1)
        If StringIsDigit($TrimTitleForAZList) Then
            $CheckForIni = IniRead(@ScriptDir & "/Data/# List/" & $InputMovieToRemove & ".ini", $InputMovieToRemove, "Genre", "NA")
            If $CheckForIni = "NA" Then
                MsgBox(48, "Error", "Movie name not found, please try again!")
            Else
                $CheckDeletion = MsgBox(4, "Delete Movie", "Are you sure you wish to remove this movie?" & @CRLF & @CRLF & $InputMovieToRemove)
                If $CheckDeletion = 6 Then
                    FileDelete(@ScriptDir & "/Data/# List/" & $InputMovieToRemove & ".ini")
                    FileDelete(@ScriptDir & "/Data/Favorites/" & $InputMovieToRemove & ".ini")
                Else
                    MsgBox(48, "Cancelled", "Cancelling removal of the movie!")
                EndIf
            EndIf
        Else
            $CheckIfDirExists = DirGetSize(@ScriptDir & "/Data/AZList/" & $TrimTitleForAZList)
            If @error Then
                MsgBox(48, "Error", "AZ Listing not found, please double check your input!")
            Else
                $CheckForIni = IniRead(@ScriptDir & "/Data/AZList/" & $TrimTitleForAZList & "/" & $InputMovieToRemove & ".ini", $InputMovieToRemove, "Genre", "NA")
                If $CheckForIni = "NA" Then
                    MsgBox(48, "Error", "Movie name not found, please try again!")
                Else
                    $CheckDeletion = MsgBox(4, "Delete Movie", "Are you sure you wish to remove this movie?" & @CRLF & @CRLF & $InputMovieToRemove)
                    If $CheckDeletion = 6 Then
                        FileDelete(@ScriptDir & "/Data/AZList/" & $TrimTitleForAZList & "/" & $InputMovieToRemove & ".ini")
                        FileDelete(@ScriptDir & "/Data/Favorites/" & $InputMovieToRemove & ".ini")
                    Else
                        MsgBox(48, "Cancelled", "Cancelling removal of the movie!")
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf

    $InputMovieToRemove = ""
    GUISetState(@SW_ENABLE, $MainGui)
    _UpdateDatabase()
EndFunc   ;==>_RemoveMovie

Func _UpdateDatabase()
    GUIDelete($MainGui)
    _ReCreateMainGui()
    $ReadAZListFolders = _FileListToArray(@ScriptDir & "/Data/AZList", Default, 2)
    If @error Then
        Sleep(10)
    Else
        For $a = 1 To $ReadAZListFolders[0]
            $ReadAZListFiles = _FileListToArray(@ScriptDir & "/Data/AZList/" & $ReadAZListFolders[$a], Default, 1)
            If @error Then
                Sleep(10)
            Else
                For $b = 1 To $ReadAZListFiles[0]
                    For $c = 1 To 26
                        If $Alphabet[$c] = $ReadAZListFolders[$a] Then
                            $AZListLetterToAdd = $c
                        EndIf
                    Next
                    $TrimMovieTitleAZList = StringTrimRight($ReadAZListFiles[$b], 4)
                    GUICtrlCreateTreeViewItem($TrimMovieTitleAZList, $AZList[$AZListLetterToAdd])
                Next
            EndIf
        Next

        $ReadFavoritesFiles = _FileListToArray(@ScriptDir & "/Data/Favorites", Default, 1)
        If @error Then
            Sleep(10)
        Else
            For $d = 1 To $ReadFavoritesFiles[0]
                $TrimMovieTitleAZList = StringTrimRight($ReadFavoritesFiles[$d], 4)
                GUICtrlCreateTreeViewItem($TrimMovieTitleAZList, $FavoritesList)
            Next
        EndIf

        $ReadNumberFiles = _FileListToArray(@ScriptDir & "/Data/# List", Default, 1)
        If @error Then
            Sleep(10)
        Else
            For $d = 1 To $ReadNumberFiles[0]
                $TrimMovieTitleAZList = StringTrimRight($ReadNumberFiles[$d], 4)
                GUICtrlCreateTreeViewItem($TrimMovieTitleAZList, $NumberList)
            Next
        EndIf
    EndIf
    _WinAPI_RedrawWindow(GUICtrlGetHandle($AZTreeView))

EndFunc   ;==>_UpdateDatabase

Func _CloseProgram()
    Exit
EndFunc   ;==>_CloseProgram

Func _Exit()
    If $CurrentGui = "Main" Then
        Exit
    EndIf
    If $CurrentGui = "MovieDataGui" Then
        GUIDelete($MovieDataGui)
        GUISetState(@SW_ENABLE, $MainGui)
        Sleep(100)
        $CurrentGui = "Main"
        WinActivate($MainGui)
    EndIf
EndFunc   ;==>_Exit

While 1
    $Msg = GUICtrlRead($AZTreeView, 1)
    $OldListSelection = $CurrentListSelection
    $CurrentListSelection = $Msg
    If $OldListSelection = $CurrentListSelection Then
        Sleep(10)
    Else
        If $CurrentListSelection = "Favorites" Then
            Sleep(10)
        Else
            $CheckStringLength = StringLen($CurrentListSelection)
            If $CheckStringLength > 1 Then
                _GetMovieData()
            EndIf
        EndIf
    EndIf
    Sleep(10)
WEnd