import macros
from oldgtk3/gtk import nil
from oldgtk3/gobject import nil
from oldgtk3/glib import nil

macro createLayout(layout: static[UILayout]): untyped =
  result = newStmtList()
  macro generateLayer(oldSym: NimNode, layout: static[UIContainer]): untyped =
    result = newStmtList()
    var sym: NimNode
    case layout.kind:
      of Row, Widget:
        sym = oldSym
      of Column:
        sym = genSym(nskVar)
        result.add(quote do:
          `sym` = gtk.newGrid()
          gtk.setColumnHomogeneous(`sym`, true)
        )

  let base = genSym(nskVar)
  result.add(quote do:
    `base` = gtk.newBox(gtk.Orientation.VERTICAL, 5)
  )
  
