import macros
#from karax/karax import nil
#from karax/vdom import nil
#from karax/karaxdsl import nil
import karax / [karax, vdom, kdom, karaxdsl]
from strutils import nil

template initUI() =
  discard

macro createUI(): untyped =
  var innerblock = newStmtList()
  var layoutBlock = newStmtList()
  for pair in testUI.widgets.pairs:
    var elem = pair[1]
    case elem.kind:
      of UIKind.call:
        let
          s1 = elem.generatedSym
          s2 = elem.variableSym
          cb = elem.callback
        case elem.variableType:
          of ntyString, ntyInt:
            var cbBlock = newStmtList()
            if cb != nil:
              cbBlock.add(quote do:
                addEventHandler(`s1`, EventKind.onclick, `cb`, kxi)
              )
            innerblock.add(quote do:
              var `s1` = tree(VNodeKind.button)
              `cbBlock`
              add(`s1`, text($`s2`))
            )
            layoutblock.add(quote do:
              tdiv(`s1`)
            )
          else:
            discard
      of UIKind.edit:
        let
          s1 = elem.generatedSym
          s2 = elem.variableSym
          id = pair[0]
          cb = elem.callback
        case elem.variableType:
          of ntyString:
            var cbBlock = newStmtList()
            if cb != nil:
              cbBlock.add(quote do:
                addEventHandler(`s1`, EventKind.oninput, `cb`, kxi)
              )
            innerblock.add(quote do:
              var `s1` = tree(VNodeKind.input)
              `s1`.value = `s2`
              `cbBlock`
              addEventHandler(`s1`, EventKind.oninput, proc (ev: Event, n: VNode) =
                `s2` = $n.value
              , kxi)
            )
            layoutblock.add(quote do:
              tdiv(`s1`)
            )
          of ntyInt:
            var cbBlock = newStmtList()
            if cb != nil:
              cbBlock.add(quote do:
                addEventHandler(`s1`, EventKind.oninput, `cb`, kxi)
              )
            innerblock.add(quote do:
              var `s1` = tree(VNodeKind.input)
              `s1`.value = $`s2`
              `s1`.setAttr("id", `id`)
              `s1`.setAttr("type", "number")
              `s1`.setAttr("step", "1")
              `cbBlock`
              addEventHandler(`s1`, EventKind.oninput, proc (ev: Event, n: VNode) =
                try:
                  `s2` = strutils.parseInt($n.value)
                except ValueError:
                  try:
                    `s2` = strutils.parseFloat($n.value).int
                  except ValueError:
                    `s2` = 0
                  document.getElementById(`id`).value = $`s2`
              , kxi)
            )
            layoutblock.add(quote do:
              tdiv(`s1`)
            )
          else: discard
      of UIKind.show:
        case elem.variableType:
          of ntyInt, ntyFloat, ntyString:
            let
              s1 = elem.generatedSym
              s2 = elem.variableSym
            innerblock.add(quote do:
              var `s1` = text($`s2`)
            )
            layoutblock.add(quote do:
              tdiv(`s1`)
            )
          else:
            discard
  result = quote do:
    proc createDom(): vdom.VNode =
      `innerblock`
      return buildHtml(tdiv):
        `layoutblock`
  echo result.toStrLit

template startUI() =
  karax.setRenderer createDom

dumpTree:
  buildHtml():
    tdiv(onscroll = hello):
      tdiv:
        text &hi
        text hey
