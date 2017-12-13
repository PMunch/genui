import macros
import tables
import sequtils

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
    classes: Table[string, seq[string]]
    members: Table[string, seq[string]]

static:
  var testUI = UserInterface(widgets: initOrderedTable[string, UIWidget](), classes: initTable[string, seq[string]](), members: initTable[string, seq[string]]())

macro getByName(name: static[string]): untyped =
  let sym = testUI.widgets[name].generatedSym
  return sym

macro getByClass(class: static[string]): untyped =
  var list = nnkBracket.newTree()
  for name in testUI.classes[class]:
    echo name
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

macro createShowWidget(name: static[string], classes: static[seq[string]], arg: typed): untyped =
  testUI.widgets[name] =
    UIWidget(
      variableType: arg.getType.typeKind,
      variableSym: arg,
      kind: UIKind.show,
      generatedSym: genSym(nskVar)
    )
  addToClasses(name, classes)

macro createEditWidget(name: static[string], classes: static[seq[string]], arg: typed, callback: UICallback): untyped =
  testUI.widgets[name] =
    UIWidget(
      variableType: arg.getType.typeKind,
      variableSym: arg,
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