import macros
from karax/karax import nil
from karax/vdom import nil
from karax/kdom import nil
from karax/karaxdsl import nil
#import karax / [karax, vdom, kdom, karaxdsl]
from strutils import nil

static:
  var KaraxWidgetWrapper = genSym(nskType)

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
      optionsSym = elem.optionsSym
    case elem.kind:
      of UIKind.call:
        case elem.variableType:
          of ntyString, ntyInt:
            var cbBlock = newStmtList()
            if cb != nil:
              cbBlock.add(quote do:
                karax.addEventHandler(`s1`.widget, vdom.EventKind.onclick, `cb`, karax.kxi)
              )
            innerblock.add(quote do:
              `s1`.widget = vdom.tree(vdom.VNodeKind.button)
              if `s1`.active:
                `cbBlock`
              else:
                vdom.setAttr(`s1`.widget, "disabled")
              vdom.add(`s1`.widget, vdom.text($`s2`))
            )
          else:
            discard
      of UIKind.edit:
        case elem.variableType:
          of ntyString:
            var cbBlock = newStmtList()
            if cb != nil:
              cbBlock.add(quote do:
                karax.addEventHandler(`s1`.widget, vdom.EventKind.oninput, `cb`, karax.kxi)
              )
            if optionsSym == nil:
              innerblock.add(quote do:
                `s1`.widget = vdom.tree(vdom.VNodeKind.input)
                vdom.setAttr(`s1`.widget, "type", "text")
                `s1`.widget.text = `s2`
                if `s1`.active:
                  `cbBlock`
                else:
                  vdom.setAttr(`s1`.widget, "disabled")
                karax.addEventHandler(`s1`.widget, vdom.EventKind.oninput, proc (ev: kdom.Event, n: vdom.VNode) =
                  `s2` = $vdom.value(n)
                , karax.kxi)
              )
            else:
              innerblock.add(quote do:
                `s1`.widget = vdom.tree(vdom.VNodeKind.input)
                vdom.setAttr(`s1`.widget, "type", "text")
                vdom.setAttr(`s1`.widget, "list", `name` & "DataList")
                var list = vdom.tree(vdom.VNodeKind.datalist)
                vdom.setAttr(list, "id", `name` & "DataList")
                for option in `optionsSym`:
                  let opt = vdom.tree(vdom.VNodeKind.option)
                  opt.add vdom.text(option)
                  list.add opt
                `s1`.widget.add list
                if `s1`.active:
                  `cbBlock`
                else:
                  vdom.setAttr(`s1`.widget, "disabled")
                `s1`.widget.text = $`s2`
                karax.addEventHandler(`s1`.widget, vdom.EventKind.oninput, proc (ev: kdom.Event, n: vdom.VNode) =
                  `s2` = $vdom.value(n)
                , karax.kxi)
              )
          of ntyInt:
            var cbBlock = newStmtList()
            if cb != nil:
              cbBlock.add(quote do:
                karax.addEventHandler(`s1`.widget, vdom.EventKind.oninput, `cb`, karax.kxi)
              )
            if optionsSym == nil:
              innerblock.add(quote do:
                `s1`.widget = vdom.tree(vdom.VNodeKind.input)
                `s1`.widget.text = $`s2`
                vdom.setAttr(`s1`.widget, "type", "number")
                vdom.setAttr(`s1`.widget, "step", "1")
                if `s1`.active:
                  `cbBlock`
                else:
                  vdom.setAttr(`s1`.widget, "disabled")
                karax.addEventHandler(`s1`.widget, vdom.EventKind.oninput, proc (ev: kdom.Event, n: vdom.VNode) =
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
            else:
              innerblock.add(quote do:
                `s1`.widget = vdom.tree(vdom.VNodeKind.select)
                for index, option in pairs(`optionsSym`):
                  let opt = vdom.tree(vdom.VNodeKind.option)                  
                  opt.add vdom.text(option)
                  opt.text = $index
                  `s1`.widget.add opt
                `s1`.widget.text = $`s2`
                if `s1`.active:
                  `cbBlock`
                else:
                  vdom.setAttr(`s1`.widget, "disabled")
                karax.addEventHandler(`s1`.widget, vdom.EventKind.oninput, proc(ev: kdom.Event, n: vdom.VNode) =
                  # This should really be changed to selectedIndex somehow
                  `s2` = strutils.parseInt($n.value)
                , karax.kxi)
              )
          else: discard
      of UIKind.show:
        case elem.variableType:
          of ntyInt, ntyFloat, ntyString:
            innerblock.add(quote do:
              `s1`.widget = vdom.tree(vdom.VNodeKind.tdiv, vdom.text($`s2`))
            )
          else:
            discard
    innerblock.add(quote do:
      vdom.setAttr(`s1`.widget, "id", `name`)
      vdom.setAttr(`s1`.widget, "class", `classes`)
    )
    outerblock.add(quote do:
      var `s1` = `KaraxWidgetWrapper`(widget: nil, active: true, shown: true)
    )
  var afterBlock = after
  if after == nil:
    afterBlock = newStmtList()

  result = quote do:
    type `KaraxWidgetWrapper` = ref object
      widget: vdom.VNode
      active: bool
      shown: bool
    proc hide(elem: `KaraxWidgetWrapper`) =
      elem.shown = false
    proc show(elem: `KaraxWidgetWrapper`) =
      elem.shown = true
    proc disable(elem: `KaraxWidgetWrapper`) =
      elem.active = false
    proc enable(elem: `KaraxWidgetWrapper`) =
      elem.active = true
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
