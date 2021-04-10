/* GCompris - position_object.qml
 *
 * Copyright (C) 2018 YOUR NAME <xx@yy.org>
 *
 * Authors:
 *   <THE GTK VERSION AUTHOR> (GTK+ version)
 *   YOUR NAME <YOUR EMAIL> (Qt Quick port)
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
 *   along with this program; if not, see <https://www.gnu.org/licenses/>.
 */
import QtQuick 2.6
import GCompris 1.0

import "../../core"
import "position_object.js" as Activity

ActivityBase {
    id: activity

    onStart: focus = true
    onStop: {}

    pageComponent: Image {
        id: background
        source: Activity.url + "background.svg"
        sourceSize.width: Math.max(parent.width, parent.height)
        fillMode: Image.PreserveAspectCrop

        // system locale by default
        property string locale: "system"

        property bool englishFallback: false
        property bool downloadWordsNeeded: false

        signal start
        signal stop

        Component.onCompleted: {
            dialogActivityConfig.getInitialConfiguration()
            activity.start.connect(start)
            activity.stop.connect(stop)
        }

        // Add here the QML items you need to access in javascript
        QtObject {
            id: items
            property Item main: activity.main
            property alias background: background
            property alias bar: bar
            property alias bonus: bonus
            property alias score: score
            property alias questionImage: questionImage
            property alias questionText: questionText
            property alias answers: answers
            property GCAudio audioVoices: activity.audioVoices
            property string answer
            property bool isGoodAnswer: false
            property bool buttonsBlocked: false
            property var dataset: datasetLoader.item.data
            property var allWords: datasetLoader.item.allWords
            property string levelMode
        }

        onStart: {
            Activity.start(items)
        }
        onStop: {
            Activity.stop()
        }

        // Buttons with possible answers shown on the left of screen
        Column {
            id: buttonHolder
            spacing: 10 * ApplicationInfo.ratio
            x: holder.x - width - 10 * ApplicationInfo.ratio
            y: holder.y

            add: Transition {
                NumberAnimation { properties: "y"; from: holder.y; duration: 500 }
            }

            Repeater {
                id: answers

                Item {
                    width: 120 * ApplicationInfo.ratio
                    height: (holder.height
                             - buttonHolder.spacing * answers.model.length) / answers.model.length
                    AnswerButton {
                        anchors.fill: parent
                        visible: items.levelMode === "guessName"
                        textLabel: modelData.translatedText
                        blockAllButtonClicks: items.buttonsBlocked
                        isCorrectAnswer: modelData.text === items.answer
                        onCorrectlyPressed: questionAnim.start()
                        onPressed: items.buttonsBlocked = true
                        onIncorrectlyPressed: items.buttonsBlocked = false
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        visible: items.levelMode === "guessImage"
                        width: 120 * ApplicationInfo.ratio
                        height: (holder.height
                        - buttonHolder.spacing * answers.model.length) / answers.model.length
                        border.color: "black"
                        border.width: 3
                        radius: 10
                        MouseArea {
                            anchors.fill: parent
                            enabled: !items.buttonsBlocked
                            onClicked: {
                                if(modelData.text === items.answer) {
                                    items.buttonsBlocked = true
                                    questionAnim.start()
                                }
                            }
                        }
                        Image {
                            anchors.centerIn: parent
                            source: parent.visible ? "resource/" + modelData.text + ".png" : ""
                            sourceSize.width: Math.min(parent.width, parent.height)
                            sourceSize.height: Math.min(parent.width, parent.height)
                        }
                    }
                }
            }
        }

        // Picture holder for different images being shown
        Rectangle {
            id: holder
            width: Math.max(questionImage.width * 1.1, questionImage.height * 1.1)
            height: questionTextBg.y + questionTextBg.height
            x: (background.width - width - 130 * ApplicationInfo.ratio) / 2 +
               130 * ApplicationInfo.ratio
            y: 20
            color: "black"
            radius: 10
            border.width: 2
            border.color: "black"
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#80FFFFFF" }
                GradientStop { position: 0.9; color: "#80EEEEEE" }
                GradientStop { position: 1.0; color: "#80AAAAAA" }
            }

            Item {
                id: spacer
                height: 20
            }

            Image {
                id: questionImage
                visible: items.levelMode === "guessName"
                anchors.horizontalCenter: holder.horizontalCenter
                anchors.top: spacer.bottom
                width: Math.min((background.width - 120 * ApplicationInfo.ratio) * 0.7,
                                (background.height - 100 * ApplicationInfo.ratio) * 0.7)
                height: width
            }

            Rectangle {
                id: questionTextBg
                visible: items.levelMode === "guessImage"
                width: holder.width
                height: questionText.height * 1.1
                anchors.horizontalCenter: holder.horizontalCenter
                anchors.top: questionImage.bottom
                radius: 10
                border.width: 2
                border.color: "black"
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#000" }
                    GradientStop { position: 0.9; color: "#666" }
                    GradientStop { position: 1.0; color: "#AAA" }
                }

                GCText {
                    id: questionText
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    style: Text.Outline
                    styleColor: "black"
                    color: "white"
                    fontSize: largeSize
                    wrapMode: Text.WordWrap
                    width: holder.width

                    SequentialAnimation {
                        id: questionAnim
                        NumberAnimation {
                            target: questionText
                            property: 'scale'
                            to: 1.05
                            duration: 500
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            target: questionText
                            property: 'scale'
                            to: 0.95
                            duration: 1000
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            target: questionText
                            property: 'scale'
                            to: 1.0
                            duration: 500
                            easing.type: Easing.OutQuad
                        }
                        ScriptAction {
                            script: Activity.nextSubLevel()
                        }
                    }
                }
            }
        }

        Score {
            id: score
            anchors.bottom: undefined
            anchors.bottomMargin: 10 * ApplicationInfo.ratio
            anchors.right: parent.right
            anchors.rightMargin: 10 * ApplicationInfo.ratio
            anchors.top: parent.top
        }

        DialogHelp {
            id: dialogHelp
            onClose: home()
        }

        Bar {
            id: bar
            content: BarEnumContent { value: help | home | level | repeat }
            onHelpClicked: displayDialog(dialogHelp)
            onPreviousLevelClicked: Activity.previousLevel()
            onNextLevelClicked: Activity.nextLevel()
            onHomeClicked: activity.home()
            onRepeatClicked: Activity.playCurrentWord()
        }

        Bonus {
            id: bonus
            onStart: items.buttonsBlocked = true
            onStop: items.buttonsBlocked = false
            Component.onCompleted: win.connect(Activity.nextLevel)
        }

        Loader {
            id: datasetLoader
            asynchronous: false
            property string resourceUrl: "qrc:/gcompris/src/activities/position_object/resource/"
            property string levelFolder: "1"
            source: resourceUrl + levelFolder + "/Data.qml"
            active: levelFolder != ""
        }
    }
}
