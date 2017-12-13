import macros
from karax/karax import nil
from karax/vdom import nil
from karax/kdom import nil
from karax/karaxdsl import nil

static:
  var sizeClasses = @[
    "one column",
    "two columns",
    "three columns",
    "four columns",
    "five columns",
    "six columns",
    "seven columns",
    "eight columns",
    "nine columns",
    "ten columns",
    "eleven columns",
    "twelve columns"
  ]

proc setSizeClasses(newClasses: seq[string]) {.compileTime.} =
  sizeClasses = newClasses

macro createLayout(layout: static[UILayout]): untyped =
  proc generateLayer(layout: UIContainer): untyped =
    case layout.kind:
      of Row:
        result = nnkCall.newTree(
          newIdentNode(!"tdiv"),
          nnkExprEqExpr.newTree(
            newIdentNode(!"class"),
            newLit("row")
          )
        )
        for child in layout.children:
          result.add generateLayer(child)
      of Widget:
        result = newStmtList()
        #result.add(nnkDotExpr.newTree(testUI.widgets[layout.widget].generatedSym,newIdentNode("widget")))
        let sym = testUI.widgets[layout.widget].generatedSym
        result.add(quote do:
          if `sym`.shown:
            `sym`.widget
        )
          
      of Column:
        let size = sizeClasses[layout.width-1]
        result = nnkCall.newTree(
          newIdentNode(!"tdiv"),
          nnkExprEqExpr.newTree(
            newIdentNode(!"class"),
            newLit(`size`)
          )
        )
        for child in layout.children:
          result.add generateLayer(child)

  var layoutAst = generateLayer(layout.root)
  result = quote do:
    return karaxdsl.buildHtml(tdiv):
      tdiv(class = "container"):
        `layoutAst`

  echo result.toStrLit
