#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'

/*/{Protheus.doc} PROFREAD
    Rotina para leitura de arquivos de LOG do Protheus.
    Tradução do LogProfileViewer em Java.

    @type user function
    @author Edison Cake
    @since 10/07/2025
    @history  Primeiro estágio, criação da view para visualização dos arquivos.
*/
User Function PROFREAD()

    Local lProtheus := .F.

    Private cDir      := ""
    Private oFile     := Nil
    Private aCab      := {}
    Private aConteudo := {}
    Private aBloco    := {}
    Private nType     := 0

    If Select("SX2") <= 0
        PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01'
        FwAlertInfo("Empresa iniciada através de Prepare Environment")
    Else
        lProtheus := .T.
    EndIf

    If lProtheus
        // TODO - Iniciar componentes gráficos MVC
    Else
        u_OPNFILE()
        u_ShowCont()
    EndIf

    If !Empty(oFile)
        oFile:Close()
    EndIf

Return FwAlertInfo("Fim da Execução", "Fim!")

User Function OPNFILE()

    Local cDir      := cGetFile("*.txt", "Selecione o arquivo para leitura", 1, "", .T.)
    Private nBloco  := 0

    If Empty(cDir)
        FwAlertInfo("Nenhum arquivo selecionado ou arquivo corrompido!")
        Return Nil
    EndIf

    oFile := FwFileReader():New(cDir)

    If oFile:Open()
        FwAlertInfo("Leitura do arquivo " + cDir + ".", "Sucesso!")
        Do While oFile:HasLine()
            u_FileLine(oFile:GetLine())
        EndDo
        If Len(aBloco) > 0
            AAdd(aConteudo, aClone(aBloco))
            aBloco := {}
        EndIf
        oFile:Close()
    Else
        MsgStop("Falha ao abrir o arquivo " + cDir + ".")
    EndIf

Return

User Function FileLine(cContent)

    Local aIdent    := {"/* ========================================", "Request Profiler Log"}
    Local aCabec    := {"DATETIME", "SERVICE", "METHOD", "THREAD", "T.TIMER"}
    Local cTrim     := AllTrim(cContent)
    Local cFirstTok := AllTrim(SubStr(cTrim, 1, At(" ", cTrim + " ", 1) - 1))

    If aScan(aIdent, cTrim) > 0
        nType := 1
        Return
    EndIf

    If aScan(aCabec, Upper(cFirstTok)) > 0
        nType := 2
        AAdd(aCab, {cFirstTok, AllTrim(SubStr(cTrim, At(":", cTrim) + 1))})
        Return
    EndIf

    If nType >= 2
        If Left(cTrim, 4) == "CALL"
            nBloco ++
            AAdd(aBloco, ParseCall(cTrim))
            Return
        EndIf
        If Left(cTrim, 7) == "-- FROM"
            AAdd(aBloco, ParseFrom(cTrim))
            Return
        EndIf
        If Empty(cTrim) .And. Len(aBloco) > 0
            AAdd(aConteudo, aClone(aBloco))
            aBloco := {}
            Return
        EndIf
    EndIf

Return

User Function ShowCont()

    Local oDlgPrinc

    Local oBrowseUp  
    Local oPanelUp
    Local oTemp1
    Local cAlias1 := "TMP_CALL"
    Local aItens    := {}
    Local aColunas1  := {}

    Local oBrowseDown 
    Local oPanelDown
    Local oTemp2
    Local cAlias2   := "TMP_FROM"
    Local aItens2   := {}
    Local aColunas2  := {}

    Local oTela
    Local oRelation
    Local aRelation := {}

    Local cIdCall := ""
    Local cIdFrom := ""

    Local nBloco    := 0
    Local nLinha    := 0
    Local nCount    := 0
    Local aBloco    := {}
    Local aReg      := {}

    // Percorre o array de conteúdo
    For nBloco := 1 To Len(aConteudo)
        aBloco := aConteudo[nBloco]
        For nLinha := 1 To Len(aBloco)
            aReg := aBloco[nLinha]

            // Apenas registros do tipo "CALL"
            If aReg[2] == "CALL"
                aAdd(aItens, {nBloco, aReg[3], aReg[4], Val(aReg[6]), aReg[7], aReg[8]})

            // Apenas registros do tipo "FROM"
            Elseif aReg[2] == "FROM"
                aAdd(aItens2, {nBloco, aReg[3], aReg[4], aReg[5], aReg[6], aReg[7], aReg[8]})
                
            EndIf
        Next
    Next

    // Criação das tabelas temporárias para popular com as informações
    oTemp1 := FWTemporaryTable():New(cAlias1)
    oTemp2 := FWTemporaryTable():New(cAlias2)

    aColunas1 := {}
    aAdd(aColunas1, {"CALL_BLOCO",   "C", 10, 0})
    aAdd(aColunas1, {"FUNCAO",  "C", 20, 0})
    aAdd(aColunas1, {"FONTE",   "C", 20, 0})
    aAdd(aColunas1, {"QTDCHAM", "N", 10, 0})
    aAdd(aColunas1, {"TEMPTOT", "C", 20, 0})
    aAdd(aColunas1, {"TEMPMAX", "C", 20, 0})

    aColunas2 := {}
    aAdd(aColunas2, {"FROM_BLOCO",   "C", 10, 0})
    aAdd(aColunas2, {"FUNCAO",  "C", 20, 0})
    aAdd(aColunas2, {"FONTE",   "C", 20, 0})
    aAdd(aColunas2, {"LINHA",   "N", 10, 0})
    aAdd(aColunas2, {"QTDCHAM", "C", 10, 0})
    aAdd(aColunas2, {"TEMPTOT", "C", 20, 0})
    aAdd(aColunas2, {"TEMPMAX", "C", 20, 0})

    oTemp1:SetFields(aColunas1)
    oTemp1:AddIndex("1", {"CALL_BLOCO"})
    oTemp2:SetFields(aColunas2)
    oTemp2:AddIndex("1", {"FROM_BLOCO"})
    oTemp1:Create()
    oTemp2:Create()

    dbSelectArea(cAlias1)
    (cAlias1)->(dbGoTop())
    For nCount := 1 to 10

        If Reclock(cAlias1, .T.)

            (cAlias1)->CALL_BLOCO    := CVALTOCHAR(aItens[nCount][1])
            (cAlias1)->FUNCAO   := aItens[nCount][2]
            (cAlias1)->FONTE    := aItens[nCount][3]
            (cAlias1)->QTDCHAM  := aItens[nCount][4]
            (cAlias1)->TEMPTOT  := aItens[nCount][5]
            (cAlias1)->TEMPMAX  := aItens[nCount][6]
            (cAlias1)->(msUnlock())

            (cAlias1)->(dbSkip())
        Endif
    Next nCount

    dbSelectArea(cAlias2)
    (cAlias2)->(dbGoTop())
    For nCount := 1 to 10
        If Reclock(cAlias2, .T.)

            (cAlias2)->FROM_BLOCO    := CVALTOCHAR(aItens2[nCount][1])
            (cAlias2)->FUNCAO   := aItens2[nCount][2]
            (cAlias2)->FONTE    := aItens2[nCount][3]
            (cAlias2)->LINHA    := aItens2[nCount][4]
            (cAlias2)->QTDCHAM  := aItens2[nCount][5]
            (cAlias2)->TEMPTOT  := aItens2[nCount][6]
            (cAlias2)->TEMPMAX  := aItens2[nCount][7]
            (cAlias2)->(msUnlock())

            (cAlias2)->(dbSkip())
        Endif
    Next nCount

    DEFINE MSDIALOG oDlgPrinc TITLE "LogProfiler Reader (ADVPL)" FROM 000, 000 TO 1920, 1080 OF oMainWnd PIXEL 

    oTela := FwFormContainer():New(oDlgPrinc)
    cIdCall := oTela:CreateHorizontalBox(40)
    cIdFrom := oTela:CreateHorizontalBox(60)
    oTela:Activate(oDlgPrinc, .F.)

    oPanelUp    := oTela:GetPanel(cIdCall)
    oPanelDown  := oTela:GetPanel(cIdFrom)

    oBrowseUp := FWmBrowse():New()
    oBrowseUp:SetOwner(oPanelUp)
    oBrowseUp:SetDescription("Funções Chamadas")
    oBrowseUp:SetAlias(cAlias1)
    oBrowseUp:DisableDetails()
    oBrowseUp:SetProfileID("1")
    oBrowseUp:Activate()

    oBrowseDown := FWmBrowse():New
    oBrowseDown:SetOwner(oPanelDown)
    oBrowseDown:SetDescription("Chamadores")
    oBrowseDown:SetAlias(cAlias2)
    oBrowseDown:DisableDetails()
    oBrowseDown:SetProfileID("2")

    oRelation := FWBrwRelation():New()
    oRelation:AddRelation(oBrowseUp, oBrowseDown, {{'CALL_BLOCO', 'FROM_BLOCO'}})
    oRelation:Activate()
    oBrowseDown:Activate()

    oBrowseUp:Refresh()
    oBrowseDown:Refresh()

    ACTIVATE MSDIALOG oDlgPrinc CENTER

Return

Static Function ParseCall(cLine)

    Local cFunc       := AllTrim(SubStr(cLine, 6, At("(", cLine) - 6))
    Local cFonte      := SubStr(cLine, At("(", cLine) + 1, At(")", cLine) - At("(", cLine) - 1)
    Local cRest       := AllTrim(SubStr(cLine, At(")", cLine) + 1))
    Local cContCall   := ""
    Local cTotTempo   := ""
    Local cMaiorTempo := ""
    Local nPosC, nPosT, nPosM := 0

    If !Empty(cRest)
        nPosC := At("C", cRest)
        nPosT := At("T", cRest)
        nPosM := At("M", cRest)

        If nPosC > 0 .And. nPosT > nPosC
            cContCall := AllTrim(SubStr(cRest, nPosC + 1, nPosT - nPosC - 1))
        EndIf

        If nPosT > 0 .And. nPosM > nPosT
            cTotTempo := AllTrim(SubStr(cRest, nPosT + 1, nPosM - nPosT - 1))
        EndIf

        If nPosM > 0
            cMaiorTempo := AllTrim(SubStr(cRest, nPosM + 1))
        EndIf
    EndIf

Return {nBloco, "CALL", cFunc, cFonte, cRest, cContCall, cTotTempo, cMaiorTempo}

/*/{Protheus.doc} ParseFrom
    Processa linha do tipo FROM
*/
Static Function ParseFrom(cLine)

    Local cFunc       := AllTrim(SubStr(cLine, 8, At("(", cLine) - 8))
    Local cFonte      := SubStr(cLine, At("(", cLine) + 1, At(")", cLine) - At("(", cLine) - 1)
    Local nLinha      := 0
    Local cRest       := ""
    Local cContCall   := ""
    Local cTotTempo   := ""
    Local cMaiorTempo := ""
    Local nOpen       := Rat("(", cLine)
    Local nClose      := Rat(")", cLine)
    Local nPosC, nPosT, nPosM := 0

    If nOpen > 0 .And. nClose > nOpen
        nLinha := Val(SubStr(cLine, nOpen + 1, nClose - nOpen - 1))
        cRest  := AllTrim(SubStr(cLine, nClose + 1))
    EndIf

    If !Empty(cRest)
        nPosC := At("C", cRest)
        nPosT := At("T", cRest)
        nPosM := At("M", cRest)

        If nPosC > 0 .And. nPosT > nPosC
            cContCall := AllTrim(SubStr(cRest, nPosC + 1, nPosT - nPosC - 1))
        EndIf

        If nPosT > 0 .And. nPosM > nPosT
            cTotTempo := AllTrim(SubStr(cRest, nPosT + 1, nPosM - nPosT - 1))
        EndIf

        If nPosM > 0
            cMaiorTempo := AllTrim(SubStr(cRest, nPosM + 1))
        EndIf
    EndIf

Return {nBloco, "FROM", cFunc, cFonte, nLinha, cContCall, cTotTempo, cMaiorTempo}
