import macros

type
  ContainerKind = enum
    Row, Column, Widget
  UIContainer = ref object
    children: seq[UIContainer]
    case kind: ContainerKind
      of Column:
        width: range[1..12]
        start: range[0..11]
        scroll: bool
      of Row:
        expand: bool
        usedSize: range[0..12]
      of Widget:
        widget: string
  UILayout = object
    root: UIContainer

#static:
#  var testLayout = UILayout(root: nil)

proc initUILayout(): UILayout {.compileTime.} =
  UILayout(root: nil)

proc addRow(layout: var UILayout, expand: bool): UIContainer {.compileTime.} =
  assert(layout.root == nil, "Cannot add more than one row to the root of a layout")
  result = UIContainer(children: @[], kind: Row, expand: expand, usedSize: 0)
  layout.root = result

proc addRow(layout: var UIContainer, expand: bool): UIContainer {.compileTime.} =
  assert(layout.kind == Column, "Rows must be added to columns")
  result = UIContainer(children: @[], kind: Row, expand: expand, usedSize: 0)
  layout.children.add(result)

proc addColumn(layout: var UIContainer, width: range[1..12], scroll: bool): UIContainer {.compileTime.} =
  assert(layout.kind == Row, "Columns must be added to rows")
  assert(layout.usedSize + width <= 12, "Total size of columns in  row can't be more than 12")
  result = UIContainer(children: @[], width: width, start: layout.usedSize, kind: Column, scroll: scroll)
  layout.usedSize += width
  layout.children.add(result)

macro addWidget(layout: static[var UIContainer], widget: static[string]): untyped =
  #assert(layout.kind == Column, "Widgets can only be added to columns")
  layout.children.add(UIContainer(children: nil, kind: Widget, widget: widget))
