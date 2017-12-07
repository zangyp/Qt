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
孩子可以这样定位:
```qml
QObject *rect = object->findChild<QObject*>("rect");
if (rect)
    rect->setProperty("color", "red");
```
注意，对象可能有多个具有相同objectName的子对象。例如，ListView创建了它的委托的多个实例，因此，如果它的委托用一个特定的objectName声明，ListView将有多个具有相同objectName的子对象。在本例中，QObject::findChildren()可用于查找具有匹配对象名称的所有子对象。  
警告:虽然可以使用C++来访问和操纵对象树深处的QML对象，但是我们建议您不要在应用程序测试和原型设计之外采用这种方法。QML和C++集成的一个优点是能够独立于C++逻辑和数据集后端实现QML用户界面，如果C++端深入到QML组件中，直接对其进行操作，那么这种策略就会中断。例如，如果新组件缺少一个必需的objectName，那么就很难将QML视图组件替换为另一个视图。对于C++实现来说，最好尽可能少地了解QML用户接口实现和QML对象树的组合。
  
## 从C++访问QML对象类型的成员
### 属性
在QML对象中声明的任何属性都可以从C++中自动访问。给出这样的QML项目:
```qml
// MyItem.qml
import QtQuick 2.0

Item {
    property int someNumber: 100
}
```
可以使用qq属性或QObject::setProperty()和QObject::property():设置和读取someNumber属性的值。
```qml
QQmlEngine engine;
QQmlComponent component(&engine, "MyItem.qml");
QObject *object = component.create();

qDebug() << "Property value:" << QQmlProperty::read(object, "someNumber").toInt();
QQmlProperty::write(object, "someNumber", 5000);

qDebug() << "Property value:" << object->property("someNumber").toInt();
object->setProperty("someNumber", 100);
```
您应该始终使用QObject::setProperty()、qq mlproperty或QMetaProperty::write()来更改QML属性值，以确保QML引擎能够感知到属性的变化。例如，假设您有一个自定义类型的PushButton，它有一个buttonText属性，该属性在内部反映了一个m buttonText成员变量的值。像这样直接修改成员变量不是一个好主意:
```qml
//bad code
QQmlComponent component(engine, "MyButton.qml");
PushButton *button = qobject_cast<PushButton*>(component.create());
button->m_buttonText = "Click me";
```
由于该值是直接更改的，因此它绕过Qt的元对象系统，而QML引擎并没有意识到属性的变化。这意味着对buttonText的属性绑定将不会被更新，任何onbuttontext更改的处理程序都不会被调用。
### 调用QML方法
所有QML方法暴露在元对象系统和可以从c++调用使用QMetaObject::invokeMethod()。从QML传递的方法参数和返回值总是被转换成C++中的q变量值。  
  
这是一个c++应用程序调用使用QMetaObject QML方法::invokeMethod():
QML：
```qml
// MyItem.qml
import QtQuick 2.0

Item {
    function myQmlFunction(msg) {
        console.log("Got message:", msg)
        return "some return value"
    }
}
```
C++：
```C++
// main.cpp
QQmlEngine engine;
QQmlComponent component(&engine, "MyItem.qml");
QObject *object = component.create();

QVariant returnedValue;
QVariant msg = "Hello from C++";
QMetaObject::invokeMethod(object, "myQmlFunction",
        Q_RETURN_ARG(QVariant, returnedValue),
        Q_ARG(QVariant, msg));

qDebug() << "QML function returned:" << returnedValue.toString();
delete object;
```
注意问返回参数()和Q参数()理由QMetaObject::invokeMethod()必须指定为QVariant类型,因为这是通用数据类型用于QML方法参数和返回值。
  
### 连接QML信号
所有的QML信号都会自动地提供给C++，并且可以像普通C++信号一样，通过QObject::connect()连接。同样，任何C++信号都可以由QML对象进行信号的接收和处理。  
  
下面是一个QML组件，它带有一个名为qmlSignal的信号，并携带一个string类型的参数。这个信号通过QObject::connect()函数被连接到一个C++对象的槽，因此每当`qmlSignal`被发出的时候，槽`cppSlot()`都会被调用：
```qml
// MyItem.qml
import QtQuick 2.0

Item {
    id: item
    width: 100; height: 100

    signal qmlSignal(string msg)

    MouseArea {
        anchors.fill: parent
        onClicked: item.qmlSignal("Hello from QML")
    }
}
```
  
```C++
class MyClass : public QObject
{
    Q_OBJECT
public slots:
    void cppSlot(const QString &msg) {
        qDebug() << "Called the C++ slot with message:" << msg;
    }
};

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    QQuickView view(QUrl::fromLocalFile("MyItem.qml"));
    QObject *item = view.rootObject();

    MyClass myClass;
    QObject::connect(item, SIGNAL(qmlSignal(QString)),
                     &myClass, SLOT(cppSlot(QString)));

    view.show();
    return app.exec();
}
```
当使用QML对象类型作为信号参数时，参数应该使用var作为类型，并且使用q变体类型，应该在C++中使用该值：
```qml
// MyItem.qml
import QtQuick 2.0

Item {
    id: item
    width: 100; height: 100

    signal qmlSignal(var anObject)

    MouseArea {
        anchors.fill: parent
        onClicked: item.qmlSignal(item)
    }
}
```
  
```C++
class MyClass : public QObject
{
    Q_OBJECT
public slots:
    void cppSlot(const QVariant &v) {
       qDebug() << "Called the C++ slot with value:" << v;

       QQuickItem *item =
           qobject_cast<QQuickItem*>(v.value<QObject*>());
       qDebug() << "Item dimensions:" << item->width()
                << item->height();
    }
};

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    QQuickView view(QUrl::fromLocalFile("MyItem.qml"));
    QObject *item = view.rootObject();

    MyClass myClass;
    QObject::connect(item, SIGNAL(qmlSignal(QVariant)),
                     &myClass, SLOT(cppSlot(QVariant)));

    view.show();
    return app.exec();
}
```
