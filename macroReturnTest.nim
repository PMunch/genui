import macros

type
  StrObjKind = enum
    String, Stringable
  StrObj = object
    case kind: StrObjKind
    of String:
      str: string
    of Stringable:
      obj: NimNode
  StrList = object
    list: seq[StrObj]

proc hello(str: static[string]): StrList {.compileTime.} =
  result = StrList(list: @[StrObj(kind: String, str: str)])

macro world(list: static[var StrList], str: static[string]): untyped =
  list.list.add StrObj(kind: String, str: str)

macro stringify(list: static[var StrList], stringable: typed): untyped =
  list.list.add StrObj(kind: Stringable, obj: stringable)
  

macro print(list: static[var StrList]): untyped =
  for str in list.list:
    if str.kind == String:
      echo str.str
    else:
      echo "Stringable: " & $str.obj

var test {.compileTime.} = hello("Hi there")
var a = 10
test.world("Hello world")
test.world("More strings")
test.stringify(a)
test.print()
