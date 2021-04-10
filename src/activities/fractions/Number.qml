/* GCompris - Number.qml
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

import "../../core"
import "fractions.js" as Activity

Item {
    property int value: 0
    signal leftClicked
    signal rightClicked

    Row {
        Image {
            id: shiftKeyboardLeft
            source: "qrc:/gcompris/src/core/resource/bar_previous.svg"
            sourceSize.width: 50
            width: sourceSize.width
            height: width
            fillMode: Image.PreserveAspectFit
            z: 11
            MouseArea {
                enabled: true
                anchors.fill: parent
                onClicked: {
                    leftClicked()
                }
            }
        }
        GCText {
            id: valueText
            text: "" + value
            font.weight: Font.DemiBold
            style: Text.Outline
            styleColor: "black"
            color: "white"
            onTextChanged: {
                print("new value", value)
            }
        }
        Image {
            id: shiftKeyboardRight
            source: "qrc:/gcompris/src/core/resource/bar_next.svg"
            sourceSize.width: 50
            width: sourceSize.width
            height: width
            fillMode: Image.PreserveAspectFit
            z: 11
            MouseArea {
                enabled: true
                anchors.fill: parent
                onClicked: {
                    rightClicked()
                }
            }
        }
    }
}
