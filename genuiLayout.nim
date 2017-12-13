import macros

type
  ContainerKind = enum
    Row, Column, Widget
  UIContainer = object
    children: seq[UIContainer]
    case kind: ContainerKind
      of Column:
        width: range[1..12]
        scroll: bool
      of Row:
        expand: bool
      of Widget:
        widget: NimNode
  UILayout = object
    root: UIContainer

proc initUILayout(): UILayout {.compileTime.} =
  UILayout(containers: @[])

proc addRow(layout: var UIContainer, expand: bool): UIContainer {.compileTime.} =
  result = UIContainer(children: @[], kind: Row, expand: expand)
  layout.children.add(result)

proc addColumn(layout: var UIContainer, width: range[1..12], scroll: bool): UIContainer {.compileTime.} =
  result = UIContainer(children: @[], width: width, kind: Column, scroll: scroll)
  layout.children.add(result)

proc addWidget(layout: var UIContainer, widget: NimNode) {.compileTime.} =
  layout.children.add(UIContainer(children: nil, kind: Widget, widget: widget)
