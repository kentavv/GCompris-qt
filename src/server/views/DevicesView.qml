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
import QtQuick.Controls 2.2

import "../components"
import "../../core"

Item {
    Rectangle {
        anchors.fill: parent
        color: Style.colourBackground
        Column {
            anchors.centerIn: parent
            Label {
                text: qsTr("Broadcast ip")
            }
            TextInput {
                id: broadcastIpText
                // todo set default from conf, get a list of possible ip from https://doc.qt.io/qt-5/qnetworkinterface.html?
                text: "255.255.255.255"
            }
            ViewButton {
                id: connectDevicesButton

                text: qsTr("Connect devices")

                onClicked: {
                   networkController.broadcastDatagram(broadcastIpText.text);
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
