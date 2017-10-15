import macros
from karax/karax import nil
from karax/vdom import nil
from karax/kdom import nil
from karax/karaxdsl import nil
#import karax / [karax, vdom, kdom, karaxdsl]
from strutils import nil

template initUI() =
  discard

macro createUI(after: untyped = nil): untyped =
  var
    innerblock = newStmtList()
    outerblock = newStmtList()
    layoutBlock = newStmtList()
  for pair in testUI.widgets.pairs:
    let
      name = pair[0]
      elem = pair[1]
      s1 = elem.generatedSym
      s2 = elem.variableSym
      classes = strutils.join(testUI.members[name], " ")
      cb = elem.callback
    case elem.kind:
      of UIKind.call:
        case elem.variableType:
          of ntyString, ntyInt:
            var cbBlock = newStmtList()
            if cb != nil:
              cbBlock.add(quote do:
                karax.addEventHandler(`s1`, vdom.EventKind.onclick, `cb`, karax.kxi)
              )
            innerblock.add(quote do:
              `s1` = vdom.tree(vdom.VNodeKind.button)
              `cbBlock`
              vdom.add(`s1`, vdom.text($`s2`))
            )
            layoutblock.add(quote do:
              tdiv(`s1`)
            )
          else:
            discard
      of UIKind.edit:
        case elem.variableType:
          of ntyString:
            var cbBlock = newStmtList()
            if cb != nil:
              cbBlock.add(quote do:
                karax.addEventHandler(`s1`, vdom.EventKind.oninput, `cb`, karax.kxi)
              )
            innerblock.add(quote do:
              `s1` = vdom.tree(vdom.VNodeKind.input)
              vdom.setAttr(`s1`, "type", "text")
              `s1`.text = `s2`
              `cbBlock`
              karax.addEventHandler(`s1`, vdom.EventKind.oninput, proc (ev: kdom.Event, n: vdom.VNode) =
                `s2` = $vdom.value(n)
              , karax.kxi)
            )
            layoutblock.add(quote do:
              tdiv(`s1`)
            )
          of ntyInt:
            var cbBlock = newStmtList()
            if cb != nil:
              cbBlock.add(quote do:
                karax.addEventHandler(`s1`, vdom.EventKind.oninput, `cb`, karax.kxi)
              )
            innerblock.add(quote do:
              `s1` = vdom.tree(vdom.VNodeKind.input)
              `s1`.text = $`s2`
              vdom.setAttr(`s1`, "type", "number")
              vdom.setAttr(`s1`, "step", "1")
              `cbBlock`
              karax.addEventHandler(`s1`, vdom.EventKind.oninput, proc (ev: kdom.Event, n: vdom.VNode) =
                try:
                  `s2` = strutils.parseInt($vdom.value(n))
                except ValueError:
                  try:
                    `s2` = strutils.parseFloat($vdom.value(n)).int
                  except ValueError:
                    `s2` = 0
                  n.value = $`s2`
              , karax.kxi)
            )
            layoutblock.add(quote do:
              tdiv(`s1`)
            )
          else: discard
      of UIKind.show:
        case elem.variableType:
          of ntyInt, ntyFloat, ntyString:
            innerblock.add(quote do:
              `s1` = vdom.tree(vdom.VNodeKind.tdiv, vdom.text($`s2`))
            )
            layoutblock.add(quote do:
              `s1`
            )
          else:
            discard
    innerblock.add(quote do:
      vdom.setAttr(`s1`, "id", `name`)
      vdom.setAttr(`s1`, "class", `classes`)
    )
    outerblock.add(quote do:
      var `s1`:vdom.VNode
    )
  var afterBlock = after
  if after == nil:
    afterBlock = newStmtList()

  result = quote do:
    `outerblock`
    proc createDom(): vdom.VNode =
      `innerblock`
      `afterBlock`
      #return karaxdsl.buildHtml(tdiv):
      #  `layoutblock`
  echo result.toStrLit

template startUI() =
  karax.setRenderer createDom

dumpTree:
  buildHtml():
    tdiv(onscroll = hello):
      tdiv:
        text &hi
        text hey
