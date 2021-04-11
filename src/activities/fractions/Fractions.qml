/* GCompris - Fractions.qml
 *
 * SPDX-FileCopyrightText: 2020 Johnny Jazeix <jazeix@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.6
import QtCharts 2.0
import GCompris 1.0

import "../../core"
import "fractions.js" as Activity

ActivityBase {
    id: activity

    onStart: focus = true
    onStop: {}

    pageComponent: Rectangle {
        id: background
        color: "#373737"
        anchors.fill: parent
        signal start
        signal stop

        Component.onCompleted: {
            dialogActivityConfig.initialize()
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
            property alias pieSeries: pieSeries
            property alias numeratorValue: numeratorText.value
            property alias denominatorValue: denominatorText.value
            property var levels: activity.datasetLoader.data
        }

        onStart: { Activity.start(items) }
        onStop: { Activity.stop() }

        //instruction rectangle
        Rectangle {
            id: instruction
            anchors.fill: instructionTxt
            opacity: 0.8
            radius: 10
            border.width: 2
            z: 10
            border.color: "#DDD"
            color: "#373737"
        }
        //instruction for playing the game
        GCText {
            id: instructionTxt
            anchors {
                top: parent.top
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
            text: items.levels[bar.level-1].instruction
            opacity: instruction.opacity
            z: instruction.z
            fontSize: background.vert ? regularSize : smallSize
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            width: Math.max(Math.min(parent.width * 0.8, text.length * 8), parent.width * 0.3)
            wrapMode: TextEdit.WordWrap
        }

        ChartView {
            id: chart
            width: Math.min(parent.width - 2 * (okButton.width + okButton.anchors.rightMargin), parent.height-bar.height * 1.5 - instruction.height)
            height: width
            backgroundColor: "#80FFFFFF"
            legend.visible: false
            antialiasing: true
            anchors {
                top: instruction.bottom
                horizontalCenter: parent.horizontalCenter
            }
            readonly property string selectedColor: "#ff0000"
            readonly property string unselectedColor: "#00ffff"
            PieSeries {
                id: pieSeries
                size: 0.9
                PieSlice {
                    value: 1;
                    color: chart.unselectedColor
                    borderColor: "#373737"
                    borderWidth: 5
                }

                onClicked: {
                    if(slice.color == chart.selectedColor) {
                        numeratorText.value --;
                        slice.color = chart.unselectedColor;
                    }
                    else {
                        numeratorText.value ++;
                        slice.color = chart.selectedColor;
                    }
                }

                function setSliceStyle(sliceNumber, selected) {
                    var slice = pieSeries.at(sliceNumber);
                    slice.borderColor = "#373737";
                    slice.borderWidth = 5;
                    slice.color = selected ? chart.selectedColor : chart.unselectedColor;
                }
            }
        }

        Column {
            id: fractionDisplay
            anchors.verticalCenter: chart.verticalCenter
            anchors.left: chart.right
            spacing: 15
            width: 80
            GCText {
                id: numeratorText
                width: fractionDisplay.width
                horizontalAlignment: Text.AlignHCenter
                font.weight: Font.DemiBold
                style: Text.Outline
                styleColor: "black"
                color: "white"
                text: "" + value
                property int value: 0
            }

            Rectangle {
                width: fractionDisplay.width
                height: 5
                border.width: 5
                color: "black"
            }

            GCText {
                id: denominatorText
                width: fractionDisplay.width
                horizontalAlignment: Text.AlignHCenter
                font.weight: Font.DemiBold
                style: Text.Outline
                styleColor: "black"
                color: "white"
                text: "" + value
                property int value: 0
            }
        }

        /*Column {
            anchors.verticalCenter: chart.verticalCenter
            anchors.left: chart.right
            spacing: 50
            Number {
                id: numerator
                value: 0
                width: 50
                height: 50
                onLeftClicked: {
                    if(value > 0) {
                        -- value;
                        pieSeries.at(startingPieIndex).color = chart.unselectedColor;
                    }
                }
                onRightClicked: {
                    if(value < denominator.value) { // Do we want a max
                        pieSeries.at(value).color = chart.selectedColor;
                        ++ value;
                    }
                }
            }

            Rectangle {
                width: 150
                height: 5
                border.width: 5
                color: "black"
            }

            Number {
                id: denominator
                value: 1
                width: 50
                height: 50
                onLeftClicked: {
                    if(value > 1) {
                        -- value
                        pieSeries.remove(pieSeries.at(value));
                        if(numerator.value > value) {
                            numerator.value = value;
                        }
                    }
                }
                onRightClicked: {
                    if(value < 50) { // Do we want a max?
                        ++ value
                        var size = 1./value;
                        for(var i = 0 ; i < pieSeries.count ; ++ i) {
                           pieSeries.at(i).value = size;
                        }
                        pieSeries.append(value, size);
                        pieSeries.at(pieSeries.count-1).color = chart.unselectedColor;
                        setSliceStyle(pieSeries.count-1);
                    }
                }
            }
        }*/

        BarButton {
            id: okButton
            enabled: !bonus.isPlaying
            anchors {
                bottom: bar.top
                right: parent.right
                rightMargin: 10 * ApplicationInfo.ratio
                bottomMargin: height * 0.5
            }
            source: "qrc:/gcompris/src/core/resource/bar_ok.svg"
            sourceSize.width: 60 * ApplicationInfo.ratio

            onClicked: {
                // count how many selected
                var selected = 0;
                for(var i = 0 ; i < pieSeries.count ; ++ i) {
                    if(pieSeries.at(i).color == chart.selectedColor) {
                        selected ++;
                    }
                }
                if(selected == items.levels[bar.level-1].numerator) {
                    bonus.good("lion");
                }
                else {
                    bonus.bad("lion");
                }
            }
        }
        DialogChooseLevel {
            id: dialogActivityConfig
            currentActivity: activity.activityInfo

            onSaveData: {
                levelFolder = dialogActivityConfig.chosenLevels
                currentActivity.currentLevels = dialogActivityConfig.chosenLevels
                ApplicationSettings.setCurrentLevels(currentActivity.name, dialogActivityConfig.chosenLevels)
            }
            onClose: {
                home()
            }
            onStartActivity: {
                background.stop()
                background.start()
            }
        }

        DialogHelp {
            id: dialogHelp
            onClose: home()
        }

        Bar {
            id: bar
            content: BarEnumContent { value: help | home | level | activityConfig }
            onHelpClicked: {
                displayDialog(dialogHelp)
            }
            onActivityConfigClicked: {
                displayDialog(dialogActivityConfig)
            }
            onPreviousLevelClicked: Activity.previousLevel()
            onNextLevelClicked: Activity.nextLevel()
            onHomeClicked: activity.home()
        }

        Bonus {
            id: bonus
            Component.onCompleted: win.connect(Activity.nextLevel)
        }
    }

}
