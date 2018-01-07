import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.VirtualKeyboard 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4

Window {
    id: window
    visible: true
    width: 640
    height: 480
    color: "#EEEEEE"
    title: qsTr("ListView")
    Component {  // ListView的delegate
        id: phoneDelegate

        Item {
            id: wrapper
            width: parent.width
            height: 30

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    // ListView给delegate暴露了一个index属性，代表当前delegate实例对应的Item的索引位置
                    wrapper.ListView.view.currentIndex = index
                    mouse.accepted = true;
                }
                onDoubleClicked: {
                    wrapper.ListView.view.model.remove(index)  // 效果和 listView.model.remove(index)是一样的
                    mouse.accepted = true;
                }

                // 修改数据：listView.model.setProperty(index,role-name,role-value)
                /** 替换数据：listView.model.set(index,
                {"role1-name":"role1-value","role2-name":"role2-value","role3-name":"role3-value"}) */
            }

            RowLayout {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Text {
                    id: coll
                    text: name
                    color: wrapper.ListView.isCurrentItem ? "red" : "black"
                    font.pixelSize: wrapper.ListView.isCurrentItem ? 22 : 18
                    Layout.preferredWidth: 140
                }

                Text {
                    text: cost
                    color: wrapper.ListView.isCurrentItem ? "red" : "black"
                    font.pixelSize: wrapper.ListView.isCurrentItem ? 22 : 18
                    Layout.preferredWidth: 120
                }

                Text {
                    text: manufacturer
                    color: wrapper.ListView.isCurrentItem ? "red" : "black"
                    font.pixelSize: wrapper.ListView.isCurrentItem ? 22 : 18
                }
            }
        }
    }

    Component {  // ListView的header
        id: headerView

        Item {
            width: parent.width
            height: 30

            RowLayout {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Text {
                    text: "Name"
                    font.bold: true
                    font.pixelSize: 20
                    Layout.preferredWidth: 140
                }

                Text {
                    text: "Cost"
                    font.bold: true
                    font.pixelSize: 20
                    Layout.preferredWidth: 120
                }

                Text {
                    text: "Manufaturer"
                    font.bold: true
                    font.pixelSize: 20
                    Layout.fillWidth: true
                }
            }
        }
    }

    Component {  // ListView的footer
        id: footerView

        Item {
            id: footerRootItem
            width: parent.width
            height: 30
            property alias text: txt.text
            signal clean()  // 声明信号的时候可以不用加括号，但是发射信号的时候一定要加括号
            signal add()
            signal insert()
            signal moveDown()

            Text {
                id: txt
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                font.italic: true
                color: "blue"
                verticalAlignment: Text.AlignVCenter
            }

            Button {
                id: clearAll
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: "Clear"
                onClicked: footerRootItem.clean()
            }

            Button {
                id: addOne
                anchors.right: clearAll.left
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: "Add"
                onClicked: footerRootItem.add()
            }

            Button {
                id: insertOne
                anchors.right: addOne.left
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: "Insert"
                onClicked: footerRootItem.insert()
            }

            Button {
                id: moveDown
                anchors.right: insertOne.left
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: "Down"
                onClicked: footerRootItem.moveDown()
            }
        }
    }

    Component {  // ListView的model
        id: phoneModel

        ListModel {
            ListElement {  // 一个ListElement对象代表一条数据
                name: "iPhone 6"  // <role-name>:<role-value> role可以在Delegate中通过role-name访问
                cost: "3000"
                manufacturer: "Apple"
            }

            ListElement {
                name: "iPhone 6 Plus"
                cost: "4000"
                manufacturer: "Apple"
            }

            ListElement {
                name: "iPhone 7"
                cost: "5000"
                manufacturer: "Apple"
            }

            ListElement {
                name: "iPhone 7 Plus"
                cost: "5500"
                manufacturer: "Apple"
            }
            ListElement {
                name: "iPhone 8"
                cost: "6000"
                manufacturer: "Apple"
            }
            ListElement {
                name: "iPhone 8 Plus"
                cost: "6500"
                manufacturer: "Apple"
            }
            ListElement {
                name: "iPhone X"
                cost: "9000"
                manufacturer: "Apple"
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        interactive: false
        delegate: phoneDelegate
        focus: true
        header: headerView  // 表头，不会影响在delegate中的index值（依然是从0开始）
        footer:footerView  // 页脚
//        highlightFollowsCurrentItem: true  // 指定高亮背景是否跟随当前条目
        highlight: Rectangle {  // 高亮背景的z序小于实例化出来的Item对象
            color: "lightblue"
        }
        model: phoneModel.createObject(listView)  // 创建并返回该组件的一个对象实例，该组件将具有给定的父元素和属性

        add: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1.0
                    duration: 1000
                }
                NumberAnimation {
                    property: "x,y"
                    from: 0
                    duration: 1000
                }
            }
        }

        displaced: Transition {  // 指定由于model变化导致Item移位时的动画效果
            SpringAnimation {
                property: "y"
                spring: 3
                damping: 0.1
                epsilon: 0.25
            }
        }

        remove: Transition {  // 指定将一个Item从ListView中移除时应用的过渡动画
            SequentialAnimation {
                NumberAnimation {
                    properties: "y"
                    to: 0
                    duration: 600
                }
                NumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: 400
                }
            }
        }

        move: Transition {  // 指定移动一个Item时要应用的过渡动画，移动一个Item会导致其他Item移位，进而触发moveDisplaced或displaced动画
            NumberAnimation {
                property: "y"
                duration: 700
                easing.type: Easing.InQuart
            }
        }

//        populate: Transition {  // 指定一个过渡动画，在ListView第一次实例化或者因model变化而需要创建Item时应用
//            NumberAnimation {
//                property: "opacity"
//                from: 0
//                to: 1.0
//                duration: 2000
//            }
//        }

        onCurrentIndexChanged: {
            if (listView.currentIndex >= 0) {
                var data = listView.model.get(listView.currentIndex);
                listView.footerItem.text = data.name + "," + data.cost + "," + data.manufacturer;
            } else {
                listView.footerItem.text = " ";
            }
        }

        Component.onCompleted: {
            listView.footerItem.clean.connect(listView.model.clear);
            listView.footerItem.add.connect(listView.addOne);
            listView.footerItem.insert.connect(listView.insertOne);
            listView.footerItem.moveDown.connect(listView.moveDown);
        }

        function addOne() {
            model.append(
                {
                    "name" : "Pixel",
                    "cost" : "4500",
                    "manufacturer" : "Google"
                });
            /** 插入数据：listView.model.insert(index,
            {"role1-name":"role1-value","role2-name":"role2-value","role3-name":"role3-value"}) */
        }

        function insertOne() {
            model.insert(Math.round(Math.random() * model.count),
                         {
                             "name" : "Nexus",
                             "cost" : "3500",
                             "manufacturer" : "Google"
                         });
        }

        function moveDown() {
            if (currentIndex + 1 < model.count) {
                model.move(currentIndex, currentIndex + 1, 1);
            }
        }
    }
}
