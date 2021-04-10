/* GCompris - Fractions.qml
 *
 * Copyright (C) 2020 Johnny Jazeix <jazeix@gmail.com>
 *
 * Authors:
 *   Johnny Jazeix <jazeix@gmail.com>
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
import QtCharts 2.6

import "../../core"
import "fractions.js" as Activity

ActivityBase {
    id: activity

    onStart: focus = true
    onStop: {}

    pageComponent: Rectangle {
        id: background
        anchors.fill: parent
        signal start
        signal stop

        Component.onCompleted: {
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
        }

        onStart: { Activity.start(items) }
        onStop: { Activity.stop() }

        ChartView {
            id: chart
            width: Math.min(parent.width, parent.height-bar.height)
            height: width
            legend.visible: false
            antialiasing: true

            PieSeries {
                id: pieSeries
                PieSlice { value: 1; color: "red" }
                onClicked: print(slice.color)
            }
        }

        Column {
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
                        pieSeries.at(value).color = "red";
                    }
                }
                onRightClicked: {
                    if(value < denominator.value) { // Do we want a max
                        pieSeries.at(value).color = "blue";
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
                        pieSeries.at(pieSeries.count-1).color = "red";
                    }
                }
            }
        }

        DialogHelp {
            id: dialogHelp
            onClose: home()
        }

        Bar {
            id: bar
            content: BarEnumContent { value: help | home | level }
            onHelpClicked: {
                displayDialog(dialogHelp)
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
