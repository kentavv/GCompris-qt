import QtQuick 2.6
import GCompris 1.0
import QtQuick.Controls 1.5
import QtQuick.Controls.Styles 1.4
import "../../core"
import "paint.js" as Activity
import "qrc:/gcompris/src/core/core.js" as Core

Item {
    id: root
    property int tabWidth: background.width * 0.15
    property int tabHeight: background.height * 0.06
    property alias colorModel: colorModel
    property string activePanel: "menuPanel"
    property alias toolsMode: toolsMode

    function hideAllTabs() {
        menuTitle.visible = false
        toolsTitle.visible = false
        colorsTitle.visible = false
        toolsOptionTitle.visible = false
        //menuGrid.visible = false
        //colorGrid.visible = false
    }

    function showAllTabs() {
        menuTitle.visible = true
        toolsTitle.visible = true
        colorsTitle.visible = true
        toolsOptionTitle.visible = true
    }

    ListModel {
        id: menuModel
        ListElement { itemName: qsTr("Save")
            imgSource: "qrc:/gcompris/src/activities/paint/resource/filesaveas.svg" }
        ListElement { itemName: qsTr("Load")
            imgSource: "qrc:/gcompris/src/activities/paint/resource/fileopen.svg" }
        ListElement { itemName: qsTr("Undo")
            imgSource: "qrc:/gcompris/src/activities/paint/resource/undo.svg" }
        ListElement { itemName: qsTr("Redo")
            imgSource: "qrc:/gcompris/src/activities/paint/resource/redo.svg" }
        ListElement { itemName: qsTr("Erase all")
            imgSource: "qrc:/gcompris/src/activities/paint/resource/empty.svg" }
        ListElement { itemName: qsTr("Background color")
            imgSource: "qrc:/gcompris/src/activities/paint/resource/color_wheel.svg" }
        ListElement { itemName: qsTr("Export to PNG")
            imgSource: "qrc:/gcompris/src/activities/paint/resource/empty.svg" }
    }

    ListModel {
        id: toolsModel
        ListElement { itemName: qsTr("Pencil")
            imgSource: "qrc:/gcompris/src/activities/paint/resource/pen.svg" }
        ListElement { itemName: qsTr("Geometric")
            imgSource: "qrc:/gcompris/src/activities/paint/resource/empty.svg" }
        ListElement { itemName: qsTr("Text")
            imgSource: "qrc:/gcompris/src/activities/paint/resource/empty.svg" }
        ListElement { itemName: qsTr("Brush")
            imgSource: "qrc:/gcompris/src/activities/paint/resource/brush_paint.png" }
        ListElement { itemName: qsTr("Eraser")
            imgSource: "qrc:/gcompris/src/activities/paint/resource/erase.svg" }
        ListElement { itemName: qsTr("Bucket fill")
            imgSource: "qrc:/gcompris/src/activities/paint/resource/fill.svg" }
    }

    ListModel {
        id: colorModel
        ListElement {colorCode: "#ff0000"} ListElement {colorCode: "#000000"} ListElement {colorCode: "#0000ff"}
        ListElement {colorCode: "#ffff00"} ListElement {colorCode: "#00ffff"} ListElement {colorCode: "#ff00ff"}
        ListElement {colorCode: "#800000"} ListElement {colorCode: "#000080"} ListElement {colorCode: "#ff4500"}
        ListElement {colorCode: "#A0A0A0"} ListElement {colorCode: "#d2691e"} ListElement {colorCode: "#8b008b"}
    }

    ListModel {
        id: toolsOptionModels
        ListElement { itemName: qsTr("Modes") }
        ListElement { itemName: qsTr("Size") }
        ListElement { itemName: qsTr("More to be added") }
    }

    Rectangle {
        id: menuPanel
        anchors.leftMargin: 5
        width: background.width
        height: background.height / 2.4
        color: "#1A1A1A"
        y: -height
        border.color: "white"
        property bool panelUnFolded: y >= -5
        //property alias

        NumberAnimation {
            id: foldAnimation
            target: menuPanel
            property: "y"
            to: - menuPanel.height
            duration: 200
            easing.type: Easing.InOutQuad
            onStarted: foldTitle.start()
        }

        NumberAnimation {
            id: unfoldAnimation
            target: menuPanel
            property: "y"
            to: 0
            duration: 200
            easing.type: Easing.InOutQuad
            onStarted: unfoldTitle.start()
        }

        GridView {
            id: menuGrid
            width: parent.width * 0.40
            height: parent.height * 0.80
            anchors.centerIn: parent
            visible: root.activePanel == "menuPanel"
            anchors.topMargin: 30
            cellWidth: width / 4
            cellHeight: height / 2.2
            model: menuModel
            delegate:Item {
                Image {
                    id: img
                    source: imgSource
                    sourceSize.width: menuGrid.cellWidth * 0.60
                    sourceSize.height: menuGrid.cellHeight * 0.60

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.scale = 1.1
                        onExited: parent.scale = 1.0
                        onClicked: {
                            console.log(itemName)
                            Activity.selectTool(itemName)
                            foldAnimation.start()
                        }
                    }
                }
                GCText {
                    text: itemName
                    anchors.horizontalCenter: img.horizontalCenter
                    anchors.top: img.bottom
                    fontSize: tinySize
                    color: "white"
                }
            }
        }

        GridView {
            id: colorGrid
            width: parent.width * 0.75
            height: parent.height * 0.80
            anchors.left: selectedColor.right
            anchors.verticalCenter: menuPanel.verticalCenter
            anchors.leftMargin: 30
            anchors.rightMargin: 10
            anchors.topMargin: 10
            cellWidth: width / 4.7
            cellHeight: height / 3.6
            model: colorModel
            visible: root.activePanel == "colorPanel"
            z: 1800
            delegate: Rectangle {
                id: root1
                radius: 8
                width: colorGrid.cellWidth * 0.80
                height: colorGrid.cellHeight * 0.90
                color: modelData
                scale: items.activeColorIndex === index ? 1.2 : 1
                border.width: 3
                border.color: modelData
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: {
                        if(items.activeColorIndex != index) {
                            parent.border.color = "grey"
                            root1.scale = 1.1
                        }
                    }
                    onExited: {
                        if(items.activeColorIndex != index) {
                            root1.scale = 1
                            parent.border.color = modelData
                        }
                    }

                    //                    // choose other color:
                    //                    onDoubleClicked: {
                    //                        items.activeColorIndex = index
                    //                        colorDialog.visible = true
                    //                    }

                    // set this color as current paint color
                    onClicked: {
                        items.activeColorIndex = index
                        items.paintColor = root1.color
                        background.hideExpandedTools()
                        items.paintColor = color
                        background.reloadSelectedPen()
                        colorPicker.updateColor((items.paintColor).toString())
                        //if()

                        //colorPalette.visible = false
                        foldAnimation.start()
                        root.showAllTabs()
                    }
                }

                Rectangle {
                    width: parent.width * 0.30
                    height: parent.height * 0.30
                    anchors.top: parent.top
                    anchors.right: parent.right
                    color: "transparent"
                    Image {
                        source: Activity.url + "color_wheel.svg"
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            items.activeColorIndex = index
                            colorDialog.visible = true
                            console.log("Clicked on color picker!")
                        }
                    }
                }
            }
        }

        ColorDialogue {
            id: colorPicker
            anchors.left: menuPanel.left
            anchors.verticalCenter: menuPanel.verticalCenter
            visible: colorGrid.visible
            //anchors.topMargin: menuPanel.height * 0.10
            anchors.leftMargin: 20
            //onVisibleChanged: visible ?  colorPicker.updateColor((items.paintColor).toString()) : null
        }

        Rectangle {
            id: selectedColor
            width: menuPanel.width * 0.08
            height: menuPanel.height * 0.30
            visible: colorGrid.visible
            radius: 8
            border.width: 3
            z: colorGrid.z
            anchors.left: colorPicker.right
            anchors.leftMargin: 10
            anchors.bottom: colorGrid.bottom
            anchors.bottomMargin: 30
            color: colorPicker.currentColorCode
//            MouseArea {
//                anchors.fill: parent
//                onClicked: {
//                    colorPicker.updateColor((items.paintColor).toString())
//                }
//            }
        }

        Button {
            style: GCButtonStyle { textSize: "title"}
            text: qsTr("Save")
            width: selectedColor.width
            anchors.left: selectedColor.left
            anchors.bottomMargin: 30
            //anchors.verticalCenter: selectedColor.verticalCenter
            anchors.bottom: selectedColor.top
            onClicked: {
                root.colorModel.remove(items.activeColorIndex)
                root.colorModel.insert(items.activeColorIndex, {colorCode: (colorPicker.currentColor()).toString()})
                items.paintColor = (colorPicker.currentColor()).toString()
            }
        }

        ToolsMode {
            id: toolsMode
            visible: root.activePanel == "toolOptions"
        }
    }

    Rectangle {
        id: menuTitle
        width: root.tabWidth
        height: root.tabHeight
        radius: 10
        color: "#1A1A1A"
        border.color: "white"
        y: -7
        z: menuPanel.z - 1
        MouseArea {
            anchors.fill: parent
            onClicked: {
                animTarget = menuTitle
                colorGrid.visible = false
                menuGrid.visible = true
                root.activePanel = "menuPanel"
                if(menuPanel.panelUnFolded) {
                    foldAnimation.start()
                    //foldTitle.start()
                    //root.showAllTabs()
                }
                else {
                    //root.hideAllTabs()
                    menuGrid.model = menuModel
                    menuTitle.visible = true
                    menuGrid.visible = true
                    unfoldAnimation.start()
                    //unfoldTitle.start()
                }
            }
        }

        GCText {
            text: "Menu"
            fontSize: tinySize
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            fontSizeMode: Text.Fit
            color: "white"
        }
    }

    Rectangle {
        id: toolsTitle
        width: root.tabWidth
        height: root.tabHeight
        radius: 10
        color: "#1A1A1A"
        border.color: "white"
        x: width + 2
        y: -7
        anchors.topMargin: -8
        z: menuPanel.z - 1

        MouseArea {
            anchors.fill: parent
            onClicked: {
                animTarget = toolsTitle
                colorGrid.visible = false
                menuGrid.visible = true
                root.activePanel = "menuPanel"
                if(menuPanel.panelUnFolded) {
                    foldAnimation.start()
                    //foldTitle.start()
                    //root.showAllTabs()
                }
                else {
                    //root.hideAllTabs()
                    toolsTitle.visible = true
                    menuGrid.model = toolsModel
                    menuGrid.visible = true
                    unfoldAnimation.start()
                    //unfoldTitle.start()
                }
            }
        }

        GCText {
            text: "Tools"
            fontSize: tinySize
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            fontSizeMode: Text.Fit
            color: "white"
        }
    }

    Rectangle {
        id: colorsTitle
        width: root.tabWidth
        height: root.tabHeight
        radius: 10
        color: "#1A1A1A"
        border.color: "white"
        x: background.width - 2 * width - 2
        y: -7
        z: menuPanel.z - 1
        MouseArea {
            anchors.fill: parent
            onClicked: {
                animTarget = colorsTitle
                menuGrid.visible = false
                colorGrid.visible = true
                root.activePanel = "colorPanel"
                if(menuPanel.panelUnFolded) {
                    foldAnimation.start()
                    //foldTitle.start()
                    //root.showAllTabs()
                }
                else {
                    //root.hideAllTabs()
                    colorsTitle.visible = true
                    unfoldAnimation.start()
                    //unfoldTitle.start()
                }
            }
        }

        GCText {
            text: "Color"
            fontSize: tinySize
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            fontSizeMode: Text.Fit
            color: "white"
        }
    }

    Rectangle {
        id: toolsOptionTitle
        width: root.tabWidth
        height: root.tabHeight
        radius: 10
        color: "#1A1A1A"
        border.color: "white"
        x: background.width - width
        y: -7
        z: menuPanel.z - 1

        MouseArea {
            anchors.fill: parent
            onClicked: {
                animTarget = toolsOptionTitle
                root.activePanel = "toolOptions"
                menuGrid.visible = false
                colorGrid.visible = false
                if(menuPanel.panelUnFolded) {
                    foldAnimation.start()
                    //foldTitle.start()
                    //root.showAllTabs()
                }
                else {
                    //root.hideAllTabs()
                    toolsOptionTitle.visible = true
                    unfoldAnimation.start()
                    //unfoldTitle.start()
                }
            }
        }

        GCText {
            text: "Tool Options"
            fontSize: tinySize
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            fontSizeMode: Text.Fit
            color: "white"
        }
    }

    property var animTarget: menuTitle

    NumberAnimation {
        id: unfoldTitle
        target: animTarget
        property: "y"
        to: menuPanel.height - 7
        duration: 200
        easing.type: Easing.InOutQuad
    }
    NumberAnimation {
        id: foldTitle
        target: animTarget
        property: "y"
        to: -7
        duration: 200
        easing.type: Easing.InOutQuad
    }

    Rectangle {
        width: root.tabWidth
        height: 8
        x: animTarget.x
        y: animTarget.y
        color: "#1A1A1A"
    }

}
