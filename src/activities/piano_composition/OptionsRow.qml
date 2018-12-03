/* GCompris - OptionsRow.qml
*
* Copyright (C) 2018 Aman Kumar Gupta <gupta2140@gmail.com>
*
* Authors:
*   Beth Hadley <bethmhadley@gmail.com> (GTK+ version)
*   Johnny Jazeix <jazeix@gmail.com> (Qt Quick port)
*   Aman Kumar Gupta <gupta2140@gmail.com> (Qt Quick port)
*   Timothée Giet <animtim@gmail.com> (refactoring)
*
*   This program is free software; you can redistribute it and/or modify
*   it under the terms of the GNU General Public License as published by
*   the Free Software Foundation; either version 3 of the License, or
*   (at your option) any later version.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with this program; if not, see <http://www.gnu.org/licenses/>.
*/
import QtQuick 2.6
import GCompris 1.0

import "../../core"

Grid {
    id: optionsRow
    columns: 2

    //: Whole note, Half note, Quarter note and Eighth note are the different length notes in the musical notation.
    readonly property var noteLengthName: [[qsTr("Whole note"), "Whole"], [qsTr("Half note"), "Half"], [qsTr("Quarter note"), "Quarter"], [qsTr("Eighth note"), "Eighth"]]

    //: Whole rest, Half rest, Quarter rest and Eighth rest are the different length rests (silences) in the musical notation.
    readonly property var restAddedMessage: [qsTr("Added whole rest"), qsTr("Added half rest"), qsTr("Added quarter rest"), qsTr("Added eighth rest")]
    readonly property var translatedRestNames: [qsTr("Whole rest"), qsTr("Half rest"), qsTr("Quarter rest"), qsTr("Eighth rest")]
    readonly property var lyricsOrPianoModes: [[qsTr("Piano"), "piano"], [qsTr("Lyrics"), "lyrics"]]

    property real iconsWidth: score.height * 1.2
    property alias noteOptionsIndex: noteOptions.currentIndex
    property alias lyricsOrPianoModeIndex: lyricsOrPianoModeOption.currentIndex
    property alias keyOption: keyOption
    property alias bpmMeter: bpmMeter
    property alias restOptionIndex: restOptions.currentIndex
    
    property bool restOptionsVisible: false
    property bool noteOptionsVisible: false
    property bool playButtonVisible: false
    property bool clearButtonVisible: false
    property bool undoButtonVisible: false
    property bool openButtonVisible: false
    property bool saveButtonVisible: false
    property bool changeAccidentalStyleButtonVisible: false
    property bool lyricsOrPianoModeOptionVisible: false
    property bool bpmVisible: false

    signal undoButtonClicked
    signal clearButtonClicked
    signal openButtonClicked
    signal saveButtonClicked
    signal playButtonClicked
    signal bpmIncreased
    signal bpmDecreased
    signal emitOptionMessage(string message)


    BpmMeter {
        id: bpmMeter
    }

    BarButton {
        id: playButton
        source: "qrc:/gcompris/src/activities/piano_composition/resource/play.svg"
        sourceSize.width: optionsRow.iconsWidth
        visible: playButtonVisible
        onClicked: {
                optionsRow.playButtonClicked()
                emitOptionMessage(qsTr("Play melody"))
                multipleStaff.play()
        }
    }

    BarButton {
        id: clearButton
        source: "qrc:/gcompris/src/activities/piano_composition/resource/erase.svg"
        sourceSize.width: optionsRow.iconsWidth
        visible: clearButtonVisible
        onClicked: clearButtonClicked()
    }

    BarButton {
        id: undoButton
        source: "qrc:/gcompris/src/activities/piano_composition/resource/undo.svg"
        sourceSize.width: optionsRow.iconsWidth
        visible: undoButtonVisible
        onClicked: {
                emitOptionMessage(qsTr("Undo"))
                undoButtonClicked()
        }
    }

    KeyOption {
        id: keyOption
        
    }
    
    Item {
        id: rests
        width: optionsRow.iconsWidth * 2
        height: optionsRow.iconsWidth
        visible: restOptionsVisible
        Rectangle {
            color: "yellow"
            opacity: 0.1
            border.width: 2
            border.color: "black"
            anchors.fill: parent
            radius: 10
        }
        
        // Since the half rest image is just the rotated image of whole rest image, we check if the current rest type is half, we assign the source as whole rest and rotate it by 180 degrees.
        SwitchableOptions {
            id: restOptions
            
            readonly property string restTypeImage: (optionsRow.noteLengthName[currentIndex][1]).toLowerCase()
            
            source: "qrc:/gcompris/src/activities/piano_composition/resource/%1Rest.svg".arg(restTypeImage)
            nbOptions: optionsRow.noteLengthName.length
            onClicked: {
                background.restType = optionsRow.noteLengthName[currentIndex][1]
                emitOptionMessage(optionsRow.translatedRestNames[currentIndex])
            }
            width: optionsRow.iconsWidth * 0.9
            sourceSize.width: width
            visible: restOptionsVisible
            anchors.topMargin: -3
            anchors.left: parent.left
            anchors.leftMargin: 5
        }
        
        BarButton {
            id: addRestButton
            width: restOptions.width
            sourceSize.width: width
            source: "qrc:/gcompris/src/activities/piano_composition/resource/add.svg"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: restOptions.visible
            onClicked: {
                emitOptionMessage(optionsRow.restAddedMessage[restOptionIndex])
                parent.scale = 1
                background.addMusicElementAndPushToStack(restType.toLowerCase(), "Rest")
            }
        }
    }
    
    BarButton {
        id: changeAccidentalStyleButton
        source: changeAccidentalStyleButtonVisible ? (piano.useSharpNotation ? "qrc:/gcompris/src/activities/piano_composition/resource/blacksharp.svg"
                                                   : "qrc:/gcompris/src/activities/piano_composition/resource/blackflat.svg")
                                                   : ""
        sourceSize.width: optionsRow.iconsWidth
        visible: changeAccidentalStyleButtonVisible
        onClicked: {
            piano.useSharpNotation = !piano.useSharpNotation
            //: Sharp notes and Flat notes represents the accidental style of the notes in the music.
            emitOptionMessage(piano.useSharpNotation ? qsTr("Sharp notes") : qsTr("Flat notes"))
        }
    }
    
    SwitchableOptions {
        id: noteOptions
        source: "qrc:/gcompris/src/activities/piano_composition/resource/genericNote%1.svg".arg(optionsRow.noteLengthName[currentIndex][1])
        nbOptions: optionsRow.noteLengthName.length
        currentIndex: 2
        onClicked: {
            background.currentType = optionsRow.noteLengthName[currentIndex][1]
            emitOptionMessage(optionsRow.noteLengthName[currentIndex][0])
        }
        visible: noteOptionsVisible
    }

    BarButton {
        id: openButton
        source: "qrc:/gcompris/src/activities/piano_composition/resource/open.svg"
        sourceSize.width: optionsRow.iconsWidth
        visible: openButtonVisible
        onClicked: openButtonClicked()
    }

    BarButton {
        id: saveButton
        source: "qrc:/gcompris/src/activities/piano_composition/resource/save.svg"
        sourceSize.width: optionsRow.iconsWidth
        visible: saveButtonVisible
        onClicked: saveButtonClicked()
    }

    SwitchableOptions {
        id: lyricsOrPianoModeOption
        nbOptions: optionsRow.lyricsOrPianoModes.length
        source: "qrc:/gcompris/src/activities/piano_composition/resource/%1.svg".arg(optionsRow.lyricsOrPianoModes[currentIndex][1])
        visible: lyricsOrPianoModeOptionVisible
        onClicked: emitOptionMessage(optionsRow.lyricsOrPianoModes[currentIndex][0])
    }
    
}
