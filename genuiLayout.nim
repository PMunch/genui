import macros

type
  ContainerKind = enum
    Row, Column
  UIContainer = object
    children: seq[NimNode]
    width: range[1..12]
    kind: ContainerKind
  UILayout = object
    containers: seq[UIContainer]

proc initUILayout(): UILayout {.compileTime.} =
  UILayout(containers: @[])

proc addRow(layout: var UILayout): UIContainer =
  result = UIContainer(children: @[], width: 12, kind: Row)
  layout.containers.add(result)

proc addColumn(layout: var UILayout, width: range[1..12]) =
  layout.containters.add(UIContainer(children: @[], width: width, kind: Column)

