/* GCompris - MelodyList.qml
 *
 * Copyright (C) 2017 Divyam Madaan <divyam3897@gmail.com>
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
import QtQuick.Controls 1.5

import "../../core"
import "piano_composition.js" as Activity
import "melodies.js" as Dataset

Rectangle {
    id: dialogBackground
    color: "#696da3"
    border.color: "black"
    border.width: 1
    z: 1000 
    anchors.fill: parent
    visible: false
    focus: true

    Keys.onEscapePressed: close()

    signal close

    property alias melodiesModel: melodiesModel
    property bool horizontalLayout: dialogBackground.width > dialogBackground.height
    property int selectedMelodyIndex: -1

    ListModel {
        id: melodiesModel
    }

    Row {
        spacing: 2
        Item { width: 10; height: 1 }

        Column {
            spacing: 10
            anchors.top: parent.top
            Item { width: 1; height: 10 }
            Rectangle {
                id: titleRectangle
                color: "#e6e6e6"
                radius: 6.0
                width: dialogBackground.width - 30
                height: title.height * 1.2
                border.color: "black"
                border.width: 2

                GCText {
                    id: title
                    text: qsTr("Melodies")
                    width: dialogBackground.width - 30
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: "black"
                    fontSize: 20
                    font.weight: Font.DemiBold
                    wrapMode: Text.WordWrap
                }
            }

            Rectangle {
                color: "#e6e6e6"
                radius: 6.0
                width: dialogBackground.width - 30
                height: dialogBackground.height - 100
                border.color: "black"
                border.width: 2
                anchors.margins: 100

                Flickable {
                    id: flickableList
                    anchors.fill: parent
                    anchors.topMargin: 10
                    anchors.leftMargin: 20
                    contentWidth: parent.width
                    contentHeight: melodiesGrid.height
                    flickableDirection: Flickable.VerticalFlick
                    clip: true

                    Flow {
                        id: melodiesGrid
                        width: parent.width
                        spacing: 40
                        anchors.horizontalCenter: parent.horizontalCenter

                        Repeater {
                            id: melodiesRepeater
                            model: melodiesModel

                            Item {
                                id: melodiesItem
                                width: dialogBackground.horizontalLayout ? dialogBackground.width / 5 : dialogBackground.width / 4
                                height: dialogBackground.height / 5

                                Button {
                                    text: title
                                    onClicked: {
                                        dialogBackground.selectedMelodyIndex = index
                                        items.multipleStaff.stopAudios()
                                        items.multipleStaff.nbStaves = 2
                                        items.multipleStaff.loadFromData(melody)
                                        lyricsArea.setLyrics(title, _origin, lyrics)
                                    }
                                    width: parent.width
                                    height: parent.height * 0.8
                                    style: GCButtonStyle {
                                        theme: "dark"
                                    }

                                    Image {
                                        source: "qrc:/gcompris/src/core/resource/apply.svg"
                                        sourceSize.width: height
                                        sourceSize.height: height
                                        width: height
                                        height: parent.height / 4
                                        anchors.bottom: parent.bottom
                                        anchors.right: parent.right
                                        anchors.margins: 2
                                        visible: dialogBackground.selectedMelodyIndex === index
                                    }
                                }
                            }
                        }
                    }
                }
                // The scroll buttons
                GCButtonScroll {
                    anchors.right: parent.right
                    anchors.rightMargin: 5 * ApplicationInfo.ratio
                    anchors.bottom: flickableList.bottom
                    anchors.bottomMargin: 30 * ApplicationInfo.ratio
                    width: parent.width / 20
                    height: width * heightRatio
                    onUp: flickableList.flick(0, 1400)
                    onDown: flickableList.flick(0, -1400)
                    upVisible: (flickableList.visibleArea.yPosition <= 0) ? false : true
                    downVisible: ((flickableList.visibleArea.yPosition + flickableList.visibleArea.heightRatio) >= 1) ? false : true
                }
            }
            Item { width: 1; height: 10 }
        }
    }

    GCButtonCancel {
        onClose: {
            dialogBackground.selectedMelodyIndex = -1
            parent.close()
        }
    }
}
