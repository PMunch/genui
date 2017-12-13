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
      of Row:
        sym = genSym(nskVar)
        result.add(quote do:
          `sym` = gtk.newGrid()
          gtk.setColumnHomogeneous(`sym`, true)
          gtk.add(`oldSym`, `sym`)
        )
        for child in layout.children:
          result.add generateLayer(sym, child)
        if layout.usedSize < 12:
          let
            start = layout.usedSize
            width = 12 - layout.usedSize
          result.add(quote do:
            gtk.attach(`sym`, gtk.newLabel(""), `start`, 0, `width`, 1)
          )
      of Widget:
        sym = layout.widget
        result.add(quote  do:
          gtk.add(`oldSym`, `sym`)
        )
      of Column:
        sym = genSym(nskVar)
        let
          start = layout.start
          width = layout.width
        result.add(quote do:
          `sym` = gtk.Box(gtk.Orientation.VERTICAL, 0)
          gtk.attach(`oldSym`, `sym`, `start`, 0, `width`, 1)
        )
        for child in layout.children:
          generateLayer(sym, child)

  let windowSym = genSym(nskVar)
  result.add(quote do:
    let `windowSym` = gtk.newWindow()
  )
  generateLayer(windowSym, layout.root)
  result.add(quote do:
    `windowSym`.showAll()
  )
 
