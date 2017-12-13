import macros
import tables
import sequtils

type
  UICallback = proc()
  UIKind {.pure.} = enum
    show,
    edit,
    call
  UIWidget = object
    kind: UIKind
    generatedSym: NimNode
    variableType: NimTypeKind
    variableSym: NimNode
    optionsSym: NimNode
    callback: NimNode
  UICustomWidget = object
    showProc: NimNode#proc(widget: UIWidget): NimNode
    editProc: NimNode
    callProc: NimNode
  UserInterface = object
    widgets: OrderedTable[string, UIWidget]
    classes: Table[string, seq[string]]
    members: Table[string, seq[string]]
    customWidgets: Table[string, UICustomWidget]

static:
  var testUI =
    UserInterface(
      widgets: initOrderedTable[string, UIWidget](),
      classes: initTable[string, seq[string]](),
      members: initTable[string, seq[string]](),
      customWidgets: initTable[string, UICustomWidget]())

macro getByName(name: static[string]): untyped =
  let sym = testUI.widgets[name].generatedSym
  return sym

macro getByClass(class: static[string]): untyped =
  var list = nnkBracket.newTree()
  for name in testUI.classes[class]:
    list.add(testUI.widgets[name].generatedSym)
  return nnkPrefix.newTree(newIdentNode("@"), list)

proc addToClasses(name: string, classes: seq[string]) {.compileTime.} =
  if classes != nil:
    for class in classes:
      if not testUI.classes.hasKey(class):
        testUI.classes[class] = @[name]
      else:
        testUI.classes[class].add(name)
    if not testUI.members.hasKey(name):
      testUI.members[name] = @[]
    testUI.members[name].insert(classes)

macro registerCustomWidget(arg: typed, showProc: NimNode = nil, editProc: NimNode = nil, callProc: NimNode = nil): untyped =
  if showProc == nil and editProc == nil and callProc == nil:
    raise newException(AssertionError, "Can't register custom handler without any procedure")
  echo "Adding \"" & $arg.getType[1].toStrLit & "\""
  testUI.customWidgets[$arg.getType[1].toStrLit] = UICustomWidget(showProc: showProc, editProc: editProc, callProc: callProc)

macro createShowWidget(name: static[string], classes: static[seq[string]], arg: typed): untyped =
  echo "Looking for \"" & $arg.getTypeInst.toStrLit & "\""
  if testUI.customWidgets.hasKey($arg.getTypeInst.toStrLit):
    echo "Found \"" & $arg.getTypeInst.toStrLit & "\""
    if testUI.customWidgets[$arg.getTypeInst.toStrLit].showProc != nil:
      echo "\"" & $arg.getTypeInst.toStrLit & "\" has showProc"
      return testUI.customWidgets[$arg.getTypeInst.toStrLit].showProc
  testUI.widgets[name] =
    UIWidget(
      variableType: arg.getType.typeKind,
      variableSym: arg,
      kind: UIKind.show,
      generatedSym: genSym(nskVar)
    )
  addToClasses(name, classes)

macro createEditWidget(name: static[string], classes: static[seq[string]], arg: typed, callback: UICallback, options: typed = nil): untyped =
  testUI.widgets[name] =
    UIWidget(
      variableType: arg.getType.typeKind,
      variableSym: arg,
      optionsSym: options,
      kind: UIKind.edit,
      generatedSym: genSym(nskVar),
      callback: callback
    )
  addToClasses(name, classes)

macro createCallWidget(name: static[string], classes: static[seq[string]], arg: typed, callback: UICallback): untyped =
  testUI.widgets[name] =
    UIWidget(
      kind: UIKind.call,
      generatedSym: genSym(nskVar),
      variableSym: arg,
      variableType: arg.getType.typeKind,
      callback: callback
    )
  addToClasses(name, classes)

#template initUI()
#template createUI()
#template startUI()
