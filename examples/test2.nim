include "../genui/genui"
when defined(js):
  include "../genui/platforms/karax"
  import karax / [karax, vdom]
else:
  include "../genui/platforms/gtk3"
  import oldgtk3/ [gtk, gdk, gio, gobject, glib]
# Set up some basic types that will be shown in the UI
var
  a: int = 10
  b: float = 2.5
  str = "Hello, world"
  tupl = (z: 10, x: "Hello")

# Create a simple little callback function
proc test() =
  b = 10.3
  echo "Callback called!"
  
initUI()

when not defined(js):
  # Time to load the stylesheet for GTK3, the JS stylesheet is linked from the HTML
  var
    provider = newCssProvider()
    display = displayGetDefault()
    screen = getDefaultScreen(display)
    myCssFile = "gtk3/mystyle.css"
    error: GError = nil

  styleContextAddProviderForScreen(screen, cast[StyleProvider](provider), STYLE_PROVIDER_PRIORITY_APPLICATION)
  discard provider.loadFromFile(newFileForPath(myCssFile), error)
  provider.objectUnref()

dumpTree:
  row:
    column(6):
      "test" show: a / ["red"]
      "test6" edit: tupl.z -> test / ["test", "class"]
    column(6):
      "test8" call: str -> test / ["buttons"]

# Creating our basic widgets and assigning them to classes for styling, some are also given a callback
createShowWidget("test", @["red"], a)
createShowWidget("test1", @[], a)
createShowWidget("test7", @[], tupl.z)
createShowWidget("test2", @[], b)
createEditWidget("test6", @["test", "class"], tupl.z, test)
createEditWidget("test3", @[], str, nil)
createCallWidget("test4", @["buttons"], str, test)
createCallWidget("test8", @["buttons"], str, test)
createShowWidget("test5", @[], str)

# Define the layout
var
  layout {.compileTime.} = initUILayout()
  row1 {.compileTime.} = layout.addRow(true)
  col1 {.compileTime.} = row1.addColumn(6,false)
  col2 {.compiletime.}  = row1.addColumn(6,false)
col1.addWidget("test")
col1.addWidget("test1")
col1.addWidget("test7")
col1.addWidget("test2")
col2.addWidget("test6")
col2.addWidget("test3")
col2.addWidget("test4")
col2.addWidget("test8")
col2.addWidget("test5")

# Create the UI. Notice  that createUI takes a block which is guaranteed to be in the same scope as the generated UI code
createUI:
  # Create a new callback
  proc newCallback() =
    echo "Hello from the new callback!"
    getByName("test1").show()
  # Get all elements from a given class, type is automatically recognised based on compile target
  var buttons = getByClass("buttons")
  for button in buttons.mitems:
    # Do some platform specific callback attachment here
    when not defined(js):
      discard button.gSignalConnect("clicked", gCallback(newCallback), nil)
    else:
      button.widget.addEventHandler(EventKind.onclick, newCallback, kxi)
  # Create the code for the layout we defined earlier. Must happen here to be in the correct scope
  layout.createLayout()

getByName("test4").disable()
getByName("test1").hide()
# Hand over control to the UI framework
startUI()
