include genui
include genuiWidgetsGtk

var
  a: int = 10
  b: float = 2.5
  str = "Hello, world"
  tupl = (z: 10, x: "Hello")

proc test() =
  echo "This is a test"
  b = 10.3
  echo tupl.z

initUI()

createShowWidget("test", a)
createShowWidget("test1", a)
createShowWidget("test2", b)
createEditWidget("test3", tupl.z, test)
createEditWidget("test3", str, test)
createCallWidget("test4", str, test)
createShowWidget("test5", str)

#let vert = createLayoutVertical("test3", "test4")
#createLayoutHorizontal("test", "test1", "test2", vert)

#var button = getNative("test4")

createUI()

echo a
echo b

startUI()

