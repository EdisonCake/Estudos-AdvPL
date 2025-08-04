#include 'totvs.ch'
#include 'tbiconn.ch'
#include 'topconn.ch'

/*/{Protheus.doc} nomeFunction

    Rotina para exeibir código e descrição de produto em tela.

    @type user function
    @author Edison Cake
    @since 24/07/2025

/*/
User Function Calculadora()

    Local nNum1 := Val(FwInputBox("Primeiro número:"))
    Local nNum2 := Val(FwInputBox("Segundo número:"))
    Local cOper := FwInputBox("Operador (+ - * /):")
    Local nResultado := 0

    If cOper == "+"
        nResultado := nNum1 + nNum2
    ElseIf cOper == "-"
        nResultado := nNum1 - nNum2
    ElseIf cOper == "*"
        nResultado := nNum1 * nNum2
    ElseIf cOper == "/"
        If nNum2 != 0
            nResultado := nNum1 / nNum2
        Else
            MsgInfo("Erro: divisão por zero!") ; Return
        EndIf
    Else
        MsgInfo("Operador inválido!") ; Return
    EndIf

    MsgInfo("Resultado: " + AllTrim(Str(nResultado)))
Return

