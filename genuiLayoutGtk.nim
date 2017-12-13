import macros
from oldgtk3/gtk import nil
from oldgtk3/gobject import nil
from oldgtk3/glib import nil

macro createLayout(layout: static[UILayout]): untyped =
  result = nemStmtList()
  let base = genSym(nskVar)
  result.add(quote do:
    `base` = gtk.newBox(gtk.Orientation.VERTICAL, 5)
  )
  
