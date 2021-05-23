/* GCompris - GCProgressBar.qml
 *
 * Copyright (C) 2021 Johnny Jazeix <jazeix@gmail.com>
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
import QtQuick 2.9
import QtQuick.Controls 2.2
import GCompris 1.0

ProgressBar {
    id: progressbar
    height: progressbarText.height
    width: bar.width

    property bool displayText: true
    property string message

    background: Rectangle {
        height: progressbar.height
        width: progressbar.width
    }
    contentItem: Item {
        implicitWidth: 200
        implicitHeight: 4

        Rectangle {
            width: progressbar.visualPosition * parent.width
            height: parent.height
            radius: 2
            color: "lightblue"
        }
        GCText {
            id: progressbarText
            anchors.centerIn: parent
            visible: displayText
            fontSize: mediumSize
            font.bold: true
            color: "black"
            text: progressbar.message
        }
    }
}
