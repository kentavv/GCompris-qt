/* GCompris - DevicesView.qml
 *
 * SPDX-FileCopyrightText: 2021 Johnny Jazeix <jazeix@gmail.com>
 *
 * Authors:
 *   Johnny Jazeix <jazeix@gmail.com>
 *
 *   SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.9
import "../components"
import "../../core"

Item {
    Rectangle {
        anchors.fill: parent
        color: Style.colourBackground
        Column {
            anchors.centerIn: parent
            ViewButton {
                id: connectDevicesButton

                text: qsTr("Connect devices")

                onClicked: {
                   networkController.broadcastDatagram();
                }
            }
            ViewButton {
                id: loginListButton

                text: qsTr("Send login list")

                onClicked: {
                   networkController.sendLoginList();
                }
            }
        }
    }
}
