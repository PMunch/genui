include genui
when defined(js):
  include genuiWidgetsKarax
  import karax / [karax, vdom]
else:
  include genuiWidgetsGtk
  import oldgtk3/ [gtk, gdk, gio, gobject, glib]

var
  a: int = 10
  b: float = 2.5
  str = "Hello, world"
  tupl = (z: 10, x: "Hello")

proc test() =
  b = 10.3
  echo "Callback called!"
  

initUI()

when not defined(js):
  # Time to load the stylesheet for GTK3
  var
    provider = newCssProvider()
    display = displayGetDefault()
    screen = getDefaultScreen(display)
    myCssFile = "mystyle.css"
    error: GError = nil

  styleContextAddProviderForScreen(screen, cast[StyleProvider](provider), STYLE_PROVIDER_PRIORITY_APPLICATION)
  discard provider.loadFromFile(newFileForPath(myCssFile), error)
  provider.objectUnref()

createShowWidget("test", @["red"], a)
createShowWidget("test1", @[], a)
createShowWidget("test7", @[], tupl.z)
createShowWidget("test2", @[], b)
createEditWidget("test6", @["test", "class"], tupl.z, test)
createEditWidget("test3", @[], str, nil)
createCallWidget("test4", @["buttons"], str, test)
createCallWidget("test8", @["buttons"], str, test)
createShowWidget("test5", @[], str)

#let vert = createLayoutVertical("test3", "test4")
#createLayoutHorizontal("test", "test1", "test2", vert)

createUI:
  proc newCallback() =
    echo "Hello from the new callback!"

  var buttons = getByClass("buttons")
  for button in buttons:
    # Do some platform specific stuff here
    when not defined(js):
      discard button.gSignalConnect("clicked", gCallback(newCallback), nil)
    else:
      button.addEventHandler(EventKind.onclick, newCallback, kxi)

startUI()
