import macros
from gtk3 import nil
from gobject import nil
from glib import nil

template initUI() =
  gtk3.initWithArgv()

macro createUI(): untyped =
  result = newStmtList()
  var callbackList = newStmtList()
  let
    windowSym = genSym(nskLet)
    boxSym = genSym(nskLet)
  result.add(quote do:
    proc setValue(label: gtk3.Label, value: string) =
      gtk3.setText(label, cstring(value))
    proc setValue(button: gtk3.Button, value: string) =
      gtk3.setLabel(button, cstring(value))
    let `windowSym` = gtk3.newWindow()
    let `boxSym` = gtk3.newBox(gtk3.Orientation.VERTICAL, 5)
  )
  for elem in testUI.widgets.values:
    #echo elem.variableType.treeRepr
    case elem.kind:
      of UIKind.call:
        let
          s1 = elem.generatedSym
          s2 = elem.variableSym
          cb = elem.callback
        case elem.variableType:
          of ntyString, ntyInt:
            result.add(quote do:
              var `s1` = gtk3.newButton($`s2`)
              gtk3.add(`boxSym`, `s1`)
              discard gobject.gSignalConnect(`s1`, "clicked", gobject.gCALLBACK(
                proc (widget: gtk3.Widget, data: glib.Gpointer) {.cdecl.}  =
                  `cb`()
              ), nil)
            )
          else: discard
      of UIKind.show:
        case elem.variableType:
          of ntyInt, ntyFloat, ntyString:
            let
              s1 = elem.generatedSym
              s2 = elem.variableSym
            result.add(quote do:
              var `s1` = gtk3.newLabel(cstring($`s2`))
              gtk3.add(`boxSym`, `s1`)
            )
          else:
            echo elem.variableType
      of UIKind.edit:
        let
          s1 = elem.generatedSym
          s2 = elem.variableSym
          cb = elem.callback
        case elem.variableType:
          of ntyString:
            result.add(quote do:
              var `s1` = gtk3.newEntry()
              gtk3.setText(`s1`, `s2`)
              gtk3.add(`boxSym`, `s1`)
              discard gobject.gSignalConnect(`s1`, "changed", gobject.gCALLBACK(
                proc (widget: gtk3.Widget, data: glib.Gpointer) {.cdecl.} =
                  `s2` = $gtk3.getText(`s1`)
                  `cb`()
              ), nil)
            )
            for widgetDef in testUI.widgets.values:
              if widgetDef.variableSym == elem.variableSym and widgetDef.generatedSym != elem.generatedSym:
                let s3 = widgetDef.generatedSym
                callbackList.add(quote do:
                  discard gobject.gSignalConnect(`s1`, "changed", gobject.gCALLBACK(
                    proc (widget: gtk3.Widget, data: glib.Gpointer) {.cdecl.}  =
                      setValue(`s3`, $gtk3.getText(`s1`))
                  ), nil)
                )
          of ntyInt:
            result.add(quote do:
              var `s1` = gtk3.newSpinButton(0, cdouble(`s2`.high), 1)
              gtk3.setValue(`s1`, cdouble(`s2`))
              gtk3.add(`boxSym`, `s1`)
              discard gobject.gSignalConnect(`s1`, "value-changed", gobject.gCALLBACK(
                proc (widget: gtk3.Widget, data: glib.Gpointer) {.cdecl.}  =
                  `s2` = gtk3.getValueAsInt(`s1`)
                  `cb`()
              ), nil)
            )
            for widgetDef in testUI.widgets.values:
              if widgetDef.variableSym == elem.variableSym and widgetDef.generatedSym != elem.generatedSym:
                let s3 = widgetDef.generatedSym
                callbackList.add(quote do:
                  discard gobject.gSignalConnect(`s1`, "value-changed", gobject.gCALLBACK(
                    proc (widget: gtk3.Widget, data: glib.Gpointer) {.cdecl.}  =
                      setValue(`s3`, $gtk3.getValueAsInt(`s1`))
                  ), nil)
                )
          else:
            echo elem.variableType
      else: continue
    #result.add(
    #  nnkAsgn.newTree(
    #    elem.variableSym,
    #    newLit(42)
    #  )
    #)
  result.add(callbackList)
  result.add(quote do:
    gtk3.add(`windowSym`, `boxSym`)
    gtk3.showAll(`windowSym`)
    discard gobject.gSignalConnect(`windowSym`, "destroy", gobject.gCALLBACK(gtk3.mainQuit), nil)
  )
  echo result.toStrLit

template startUI() =
  gtk3.main()

