import macros
import tables

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

macro createShowWidget(name: static[string], arg: typed): untyped =
  #echo arg.treeRepr
  testUI.widgets[name] =
    UIWidget(
      variableType: arg.getType.typeKind,
      variableSym: arg,
      kind: UIKind.show,
      generatedSym: genSym(nskVar)
    )

macro createEditWidget(name: static[string], arg: typed, callback: UICallback): untyped =
  #echo arg.treeRepr
  testUI.widgets[name] =
    UIWidget(
      variableType: arg.getType.typeKind,
      variableSym: arg,
      kind: UIKind.edit,
      generatedSym: genSym(nskVar),
      callback: callback
    )

macro createCallWidget(name: static[string], arg: typed, callback: UICallback): untyped =
  testUI.widgets[name] =
    UIWidget(
      kind: UIKind.call,
      generatedSym: genSym(nskVar),
      variableSym: arg,
      variableType: arg.getType.typeKind,
      callback: callback
    )

#template initUI()
#template createUI()
#template startUI()
