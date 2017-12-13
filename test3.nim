include genuiLayout
include genuiLayoutGtk
import oldgtk3/ [gtk, gdk, gio, gobject, glib]

gtk.initWithArgv()

var
  label = newLabel("Hello world")
  button = newButton("Hi there")

static:
  var layout = initUILayout()
  var
    row1 = layout.addRow(true)
    col1 = row1.addColumn(6,false)
    col2 = row1.addColumn(6,false)
  col1.addWidget(label)
  col2.addWidget(button)
layout.createLayout()
gtk.main()
