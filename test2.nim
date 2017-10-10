include genui
when defined(js):
  include genuiWidgetsKarax
else:
  include genuiWidgetsGtk

var
  a: int = 10
  b: float = 2.5
  str = "Hello, world"
  tupl = (z: 10, x: "Hello")

proc test() =
  #echo "This is a test"
  b = 10.3
  #echo tupl.z

initUI()

createShowWidget("test", @["red"], a)
createShowWidget("test1", @[], a)
createShowWidget("test7", @[], tupl.z)
createShowWidget("test2", @[], b)
createEditWidget("test6", @["test", "class"], tupl.z, nil)
createEditWidget("test3", @[], str, nil)
createCallWidget("test4", @[], str, test)
createShowWidget("test5", @[], str)

#let vert = createLayoutVertical("test3", "test4")
#createLayoutHorizontal("test", "test1", "test2", vert)

#var button = getNative("test4")

createUI()

#echo a
#echo b

startUI()

