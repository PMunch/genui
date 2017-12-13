include genuiLayout
include genuiLayoutKarax
import karax / [karax, karaxdsl, vdom, kdom]
#import oldgtk3/ [gtk, gdk, gio, gobject, glib]

#gtk.initWithArgv()

#var
#  label = newLabel("Hello world")
#  button = newButton("Hi there")
var label, button: VNode
var
  layout {.compileTime.} = initUILayout()
  row1 {.compileTime.} = layout.addRow(true)
  col1 {.compileTime.} = row1.addColumn(6,false)
  col2 {.compiletime.}  = row1.addColumn(6,false)
col1.addWidget(label)
col2.addWidget(button)
proc createDom(): Vnode =
  label = text("Hello world")
  button = VNodeKind.button.tree()
  layout.createLayout()
#gtk.main()
setRenderer createDom
