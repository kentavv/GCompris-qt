/* GCompris - Number.qml
 *
 * SPDX-FileCopyrightText: 2020 Johnny Jazeix <jazeix@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
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
