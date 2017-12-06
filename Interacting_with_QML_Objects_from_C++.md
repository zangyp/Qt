## 在C++中与QML对象交互
所有QML对象类型都是`QObject`派生类型，无论它们是由引擎内部实现的，还是由第三方源定义的。这意味着QML引擎可以使用Qt元对象系统来动态地实例化任何QML对象类型，并检查所创建的对象。  
  
这对于从C++代码中创建QML对象非常有用，无论是显示一个可以可视化呈现的QML对象，还是将非可视的QML对象数据集成到一个C++应用程序中。一旦创建了QML对象，就可以从C++中对其进行检查，以读取和写入属性、调用方法和接收信号通知。  
  
### 在C++中加载QML对象
QML文档可以加载到腾中或QQuickView中。作为一个C++对象，它可以从C++代码中修改一个QML文档。QQuickView也是这样做的，但是由于QQuickView是一个q窗口继承的类，加载的对象也会被呈现为一个可视的显示；QQuickView通常用于将可显示的QML对象集成到应用程序的用户界面中。  
  
例如，假设有一个MyItem.qml文件是这样的:
```qml
import QtQuick 2.0

Item {
    width: 100; height: 100
}
```
  
这个QML文档可以用下面的C++代码加载到QQmlComponent中或QQuickView中。使用qq mlcomponent需要调用qq mlcomponent::create()来创建组件的新实例，而QQuickView自动创建组件的实例，该组件可以通过QQuickView::rootObject():
```qml
// Using QQmlComponent
QQmlEngine engine;
QQmlComponent component(&engine,
        QUrl::fromLocalFile("MyItem.qml"));
QObject *object = component.create();
...
delete object;
```

```qml
// Using QQuickView
QQuickView view;
view.setSource(QUrl::fromLocalFile("MyItem.qml"));
view.show();
QObject *object = view.rootObject();
```
这个对象是MyItem的实例。已经创建的qml组件。现在，您可以使用QObject::setProperty()或qq mlproperty来修改条目的属性。  
```qml
object->setProperty("width", 500);
QQmlProperty(object, "width").write(500);
```
或者，您可以将对象转换为它的实际类型，并使用编译时安全性调用方法。在本例中是MyItem的基本对象。qml是一个项目，它由QQuickItem类定义:  
```qml
QQuickItem *item = qobject_cast<QQuickItem*>(object);
item->setWidth(500);
```
或者，您可以将对象转换为它的实际类型，并使用编译时安全性调用方法。在本例中是MyItem的基本对象。qml是一个项目，它由QQuickItem类定义:
```qml
QQuickItem *item = qobject_cast<QQuickItem*>(object);
item->setWidth(500);
```
你也可以连接到任何信号或调用方法中定义的组件使用QMetaObject::invokeMethod()和QObject:connect()。请参阅`Invoking QML Methods`和`Connecting to QML Signals`获得更多信息。
  
## 通过对象名称访问加载的QML对象
QML组件本质上是对象树，其中有兄弟，有兄弟姐妹和他们自己的孩子。QML组件的子对象可以使用QObject::::findChild()对象的objectName属性。例如，如果是MyItem中的根项。qml有一个子矩形项:
```qml
import QtQuick 2.0

Item {
    width: 100; height: 100

    Rectangle {
        anchors.fill: parent
        objectName: "rect"
    }
}
```
