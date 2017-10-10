import tables
import macros
from oldgtk3/gtk import nil
from oldgtk3/gobject import nil
from oldgtk3/glib import nil

type
  UICallback = proc()
  UIKind = enum
    show,
    edit,
    call
  UIWidget = object
    kind: UIKind
    generatedSym: NimNode
    variableType: NimTypeKind
    variableSym: NimNode
    callback: NimNode
  UserInterface = object
    widgets: OrderedTable[string, UIWidget]

static:
  var testUI = UserInterface(widgets: initOrderedTable[string, UIWidget]())

macro createShowWidget(name:string, arg: typed): untyped =
  #echo arg.treeRepr
  testUI.widgets[$name] =
    UIWidget(
      variableType: arg.getType.typeKind,
      variableSym: arg,
      kind: UIKind.show,
      generatedSym: genSym(nskVar)
    )

macro createEditWidget(name:string, arg: typed, callback: UICallback): untyped =
  #echo arg.treeRepr
  testUI.widgets[$name] =
    UIWidget(
      variableType: arg.getType.typeKind,
      variableSym: arg,
      kind: UIKind.edit,
      generatedSym: genSym(nskVar),
      callback: callback
    )

macro createCallWidget(name: string, arg: typed, callback: UICallback): untyped =
  testUI.widgets[$name] =
    UIWidget(
      kind: UIKind.call,
      generatedSym: genSym(nskVar),
      variableSym: arg,
      variableType: arg.getType.typeKind,
      callback: callback
    )

template initUI() =
  gtk.initWithArgv()

macro createUI(): untyped =
  result = newStmtList()
  var callbackList = newStmtList()
  let
    windowSym = genSym(nskLet)
    boxSym = genSym(nskLet)
  result.add(quote do:
    proc setValue(label: gtk.Label, value: string) =
      gtk.setText(label, cstring(value))
    proc setValue(button: gtk.Button, value: string) =
      gtk.setLabel(button, cstring(value))
    let `windowSym` = gtk.newWindow()
    let `boxSym` = gtk.newBox(gtk.Orientation.VERTICAL, 5)
  )
  for elem in testUI.widgets.values:
    #echo elem.variableType.treeRepr
    case elem.kind:
      of UIKind.call:
        let
          s1 = elem.generatedSym
          s2 = elem.variableSym
          cb = elem.callback
        case elem.variableType:
          of ntyString, ntyInt:
            result.add(quote do:
              var `s1` = gtk.newButton($`s2`)
              gtk.add(`boxSym`, `s1`)
              discard gobject.gSignalConnect(`s1`, "clicked", gobject.gCALLBACK(
                proc (widget: gtk.Widget, data: glib.Gpointer) {.cdecl.}  =
                  `cb`()
              ), nil)
            )
          else: discard
      of UIKind.show:
        case elem.variableType:
          of ntyInt, ntyFloat:
            let
              s1 = elem.generatedSym
              s2 = elem.variableSym
            result.add(quote do:
              var `s1` = gtk.newLabel(cstring($`s2`))
              gtk.add(`boxSym`, `s1`)
            )
          else:
            echo elem.variableType
      of UIKind.edit:
        let
          s1 = elem.generatedSym
          s2 = elem.variableSym
          cb = elem.callback
        case elem.variableType:
          of ntyInt:
            result.add(quote do:
              var `s1` = gtk.newSpinButton(0, cdouble(`s2`.high), 1)
              gtk.setValue(`s1`, cdouble(`s2`))
              gtk.add(`boxSym`, `s1`)
              discard gobject.gSignalConnect(`s1`, "value-changed", gobject.gCALLBACK(
                proc (widget: gtk.Widget, data: glib.Gpointer) {.cdecl.}  =
                  `s2` = gtk.getValueAsInt(`s1`)
                  `cb`()
              ), nil)
            )
            for widgetDef in testUI.widgets.values:
              if widgetDef.variableSym == elem.variableSym and widgetDef.generatedSym != elem.generatedSym:
                let s3 = widgetDef.generatedSym
                callbackList.add(quote do:
                  discard gobject.gSignalConnect(`s1`, "value-changed", gobject.gCALLBACK(
                    proc (widget: gtk.Widget, data: glib.Gpointer) {.cdecl.}  =
                      setValue(`s3`, $gtk.getValueAsInt(`s1`))
                  ), nil)
                )
          else:
            echo elem.variableType
      else: continue
    #result.add(
    #  nnkAsgn.newTree(
    #    elem.variableSym,
    #    newLit(42)
    #  )
    #)
  result.add(callbackList)
  result.add(quote do:
    gtk.add(`windowSym`, `boxSym`)
    gtk.showAll(`windowSym`)
    discard gobject.gSignalConnect(`windowSym`, "destroy", gobject.gCALLBACK(gtk.mainQuit), nil)
  )
  echo result.toStrLit

template startUI() =
  gtk.main()

type
  myType = distinct int
  myObject = object
    z: int

var
  a: int = 10
  b: float = 2.5
  str = "Hello, world"

proc test() =
  echo "This is a test"
  echo a

initUI()

createShowWidget("test", a)
createShowWidget("test1", a)
createShowWidget("test2", b)
createEditWidget("test3", a, test)
createCallWidget("test4", a, test)
createShowWidget("test5", a)

createUI()

echo a
echo b

startUI()

