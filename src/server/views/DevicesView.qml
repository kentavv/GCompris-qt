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
import QtQuick.Layouts 1.12
import QtQml.Models 2.12

import "../components"
import "../../core"

Item {
    id: managePupilsView

    ListView {
        id: selectedPupilsListview
    }

    Rectangle {
        anchors.fill: parent
        color: Style.colourBackground
        Text {
            anchors.centerIn: parent
            text: qsTr("Connect devices")
        }
    }

    TopBanner {
        id: topBanner
        text: qsTr("Connect devices")
    }

    ManageGroupsBar {
        id: pupilsNavigationBar
        anchors.top: topBanner.bottom
    }

    Rectangle {
        id: managePupilsViewRectangle
        anchors.left: pupilsNavigationBar.right
        anchors.top: topBanner.bottom
        anchors.bottom: parent.bottom
        width: managePupilsView.width / 2

        ColumnLayout {
            id: pupilsDetailsColumn

            spacing: 2
            anchors.top: parent.top
            width: parent.width

            property int pupilNameColWidth : pupilsDetailsColumn.width / 3

            //pupils header
            Rectangle {
                id: pupilsHeaderRectangle

                height: 60
                width: parent.width

                Rectangle {
                    id: pupilNameHeader
                    width: managePupilsViewRectangle.width - 10
                    height: parent.height
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        color: Style.colourNavigationBarBackground
                        text: qsTr("Pupils Names")
                        font.bold: true
                        leftPadding: 60
                        topPadding: 20
                    }
                }
            }

            //pupils data
            Repeater {
                id: pupilsDetailsRepeater

                model: masterController.ui_users

                Rectangle {
                    id: pupilDetailsRectangle

                    property alias pupilNameCheckBox: pupilNameCheckBox

                    property bool editPupilRectangleVisible: false
                    property bool optionsPupilRectangleVisible: false

                    width: managePupilsViewRectangle.width
                    height: 40

                    border.color: "green"
                    border.width: 5

                    MouseArea {
                        id: pupilDetailsRectangleMouseArea
                        anchors.right: pupilDetailsRectangle.right //right: pupilCommandOptions.right
                        anchors.top: pupilDetailsRectangle.top
                        height: pupilDetailsRectangle.height
                        width: parent.width

                        hoverEnabled: true
                        onEntered: {    //modifyPupilCommandsRectangle.visible = true
                            pupilDetailsRectangle.color = Style.colourPanelBackgroundHover
                            pupilDetailsRectangle.editPupilRectangleVisible = true
                            pupilDetailsRectangle.optionsPupilRectangleVisible = true

                        }
                        onExited: {
                            ///modifyPupilCommandsRectangle.visible = false
                            pupilDetailsRectangle.color = Style.colourBackground
                            pupilDetailsRectangle.editPupilRectangleVisible = false
                            pupilDetailsRectangle.optionsPupilRectangleVisible = false
                        }

                        RowLayout {
                            id: pupilDetailsRectangleRowLayout

                            width: parent.width
                            height: 40

                            Rectangle {
                                id: pupilName
                                Layout.alignment: Qt.AlignLeft
                                Layout.fillHeight: true
                                Layout.minimumWidth: pupilsDetailsColumn.pupilNameColWidth
                                color: "transparent"
                                CheckBox {
                                    id: pupilNameCheckBox
                                    text: modelData.name
                                    anchors.verticalCenter: parent.verticalCenter
                                    leftPadding: 20
                                }
                            }
                        }
                    }
                }
            }
        }
        Column {
            anchors.left: managePupilsViewRectangle.right
            anchors.right: parent.right
            Label {
                text: qsTr("Broadcast ip")
            }
            TextInput {
                id: broadcastIpText
                // todo set default from conf, get a list of possible ip from https://doc.qt.io/qt-5/qnetworkinterface.html?
                text: "255.255.255.255"
            }

            Label {
                text: qsTr("Device id")
            }
            TextInput {
                id: deviceIdText
                text: "test"
            }

            ViewButton {
                id: connectDevicesButton

                text: qsTr("Connect devices")

                onClicked: {
                    networkController.broadcastDatagram(broadcastIpText.text, deviceIdText.text);
                }
            }
            ViewButton {
                id: loginListButton

                text: qsTr("Send login list")

                onClicked: {
                    var users = masterController.ui_users;
                    var usersList = [];
                    for(var i = 0 ; i < users.length; ++ i) {
                        usersList.push(users[i].name);
                    }

                    networkController.sendLoginList(usersList);
                }
            }
        }
    }
}
