#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'

/*/{Protheus.doc} PROFREAD

    Rotina para leitura de arquivos de LOG do Protheus.
    Tradução do LogProfileViewer em Java.

    @type user function
    @author Edison Cake
    @since 10.07.2025
    
    @history 13.10.2025 - Criado vínculo entre tabelas temporárias para exibição do grid.
*/
User Function PROFREAD()

    Private lProtheus := .F.
    Private cDir      := ""
    Private oFile     := Nil
    Private aCab      := {}
    Private aConteudo := {}
    Private aBloco    := {}
    Private nType     := 0
    Private nBloco    := 0
    Private aItens := {}
    Private aItens2 := {}

    If Select("SX2") <= 0
        PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' USER "Administrador" PASSWORD "123456"
    Else
        lProtheus := .T.
    EndIf

    If lProtheus
        MsgRun("Abrindo Arquivo...",    "Aguarde!",     {|| u_OPNFILE()})
        MsgRun("Preenchendo View...",   "Aguarde!",     {|| U_ShowCont()})
    Else
        u_OPNFILE()
        u_blindView()
    EndIf

    If !Empty(oFile)
        oFile:Close()
    EndIf
Return 

User Function OPNFILE()

    Local cDir      := cGetFile("*.txt", "Selecione o arquivo para leitura", 1, "", .T.)
    Local aReg      := {}
    Local nLinha    := 0
    Local nBlock    := 0

    Local nPosBar   := 0
    Local cFile     := ""

    If Empty(cDir)
        FwAlertInfo("Nenhum arquivo selecionado ou arquivo corrompido!")
        Return Nil
    EndIf

    oFile   := FwFileReader():New(cDir)
    nPosBar := rAt("\", cDir)
    cFile   := SubStr(cDir, nPosBar+1, len(cDir))

    If oFile:Open()
        FwAlertInfo("Leitura do arquivo " + upper(cFile) + ".", "Sucesso!")
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

    For nBlock := 1 To Len(aConteudo)
        aBloco := aConteudo[nBlock]
        For nLinha := 1 To Len(aBloco)
            aReg := aBloco[nLinha]

            If aReg[2] == "CALL"
                //? Estrutura do ParseCall: {nBloco, "CALL", cFunc, cFonte, cRest, cContCall, cTotTempo, cMaiorTempo}
                //* aAdd(aItens, {nBlock, Funcao, Fonte, QTD_CHAM, TEMPO_CPU, MEM_ALOC})
                aAdd(aItens, {nBlock, aReg[3], aReg[4], Val(aReg[6]), aReg[7], aReg[8]})
            
            Elseif aReg[2] == "FROM"
                //? Estrutura do ParseFrom: {nBloco, "FROM", cFunc, cFonte, nLinha, cContCall, cTotTempo, cMaiorTempo}
                //* aAdd(aItens2, {nBlock, Funcao, Fonte, Linha, QTD_CHAM, TEMPO_CPU, MEM_ALOC})
                aAdd(aItens2, {nBlock, aReg[3], aReg[4], aReg[5], aReg[6], aReg[7], aReg[8]})
                
            EndIf
        Next
    Next

Return

User Function blindView()

    Local oDialog := TDialog():New(000, 000, 100, 500, "Aguarde, preenchendo view...", /* Param */, /* Param */, /* Param */, /* Param */, CLR_BLACK, CLR_WHITE, /* Param */, , .T., /* Param */, /* Param */, /* Param */, 500, 100, .F.)

    oDialog:Activate()

    u_ShowCont()

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

    Local nCount        as Numeric
    Local aColunas      as Array
    Local aColunas2     as Array
    Local aFiltro       as Array
    Local cIdUp         as Character
    Local cIdDown       as Character

    Private cAliasTemp  as Character
    Private aCampos     as Array
    Private oTempTable  as Object
    Private oBrowse     as Object
    Private oPanelUp    as Object
    Private oDlg        as Object
    Private oTela
    Private aRotina     := MenuDef()

    Private cAliasTmp2  as Character
    Private aCampos2    as Array
    Private oTempDown   as Object
    Private oBrowseDown as Object
    Private oPanelDown  as Object

    Private oRelation   as Object
    Private aRelation   as Array
    
    aCampos     := retColumns("CALL", 1)
    aColunas    := retColumns("CALL", 2)
    aCampos2    := retColumns("FROM", 1)
    aColunas2   := retColumns("FROM", 2)
    aFiltro     := {}

    DEFINE MSDIALOG oDlg TITLE "LogProfiler Reader (AdvPL)" FROM 000, 000 TO 800, 1750 OF oMainWnd PIXEL
        oTela   := FwFormContainer():New(oDlg)
        cIdUp   := oTela:CreateHorizontalBox(50)
        cIdDown := oTela:CreateHorizontalBox(50)
        oTela:Activate(oDlg, .F.)

        oPanelUp    := oTela:Getpanel(cIdUp)
        oPanelDown  := oTela:Getpanel(cIdDown)

        oTempTable := FWTemporaryTable():New()
        oTempTable:SetFields(aCampos)
        oTempTable:AddIndex("Bloco", {"BLOCO", "FUNCAO"})
        oTempTable:Create()

        oTempDown := FwTemporaryTable():New()
        oTempDown:SetFields(aCampos2)
        oTempDown:AddIndex("Bloco", {"BLOCO_CHAM", "FUNCAO"})
        oTempDown:Create()

        cAliasTemp := oTempTable:GetAlias()
        oBrowse := NIL

        cAliasTmp2 := oTempDown:GetAlias()
        oBrowseDown := NIL

        DbSelectArea(cAliasTemp)

        For nCount := 1 to 10
            If (RecLock(cAliasTemp, .T.))
                (cAliasTemp)->BLOCO     := aItens[nCount][1]
                (cAliasTemp)->FUNCAO    := aItens[nCount][2]
                (cAliasTemp)->FONTE     := aItens[nCount][3]
                (cAliasTemp)->QTD_CHAM  := aItens[nCount][4]
                (cAliasTemp)->TEMPO_CPU := Val(aItens[nCount][5])
                (cAliasTemp)->MEM_ALOC  := Val(aItens[nCount][6])

                (cAliasTemp)->(MSUnlock())
            Endif
            (cAliasTemp)->(DbSkip())
        Next nCount

        (cAliasTemp)->(DbGoTop())

        DbSelectArea(cAliasTmp2)
        nCount := 1
        While nCount <= 10
            If (RecLock(cAliasTmp2, .T.))
                (cAliasTmp2)->BLOCO_CHAM  := aItens2[nCount][1]
                (cAliasTmp2)->FUNCAO      := aItens2[nCount][2]
                (cAliasTmp2)->FONTE       := aItens2[nCount][3]
                (cAliasTmp2)->LINHA       := aItens2[nCount][4]
                (cAliasTmp2)->QTD_CHAM    := Val(aItens2[nCount][5])
                (cAliasTmp2)->TEMPO_CPU   := Val(aItens2[nCount][6])
                (cAliasTmp2)->MEM_ALOC    := Val(aItens2[nCount][7])

                (cAliasTmp2)->(MSUnlock())
            Endif
            (cAliasTmp2)->(DbSkip())
            nCount ++
        End do

        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias(cAliasTemp)
        oBrowse:AddLegend("Substr(FUNCAO, 1, 2) == 'U_'", "BLUE", "Customizado")
        oBrowse:AddLegend("Substr(FUNCAO, 1, 2) != 'U_'", "GREEN", "Padrão")
        oBrowse:SetColumns(aColunas)
        oBrowse:SetOwner(oPanelUp)
        oBrowse:SetDescription("Funções Chamadas (CALL):")
        oBrowse:SetTemporary(.T.)
        oBrowse:SetUseFilter(.T.)
        oBrowse:OptionReport(.F.)
        oBrowse:DisableDetails()
        oBrowse:Activate()

        oBrowseDown := FwMBrowse():New()
        oBrowseDown:SetOwner(oPanelDown)
        oBrowseDown:SetDescription("Funções Chamadoras (FROM):")
        oBrowseDown:DisableDetails()
        oBrowseDown:SetAlias(cAliasTmp2)
        oBrowseDown:SetColumns(aColunas2)
        oBrowseDown:SetTemporary(.T.)
        oBrowseDown:SetCacheView(.F.)
        oBrowseDown:Activate()

        oRelation := FWBrwRelation():New()
        oRelation:AddRelation(oBrowse, oBrowseDown, {{'BLOCO_CHAM', 'BLOCO'}}) 
        oRelation:Activate()

    ACTIVATE DIALOG oDlg CENTER

Return

Static Function ParseCall(cLine)

    Local cFunc       := AllTrim(SubStr(cLine, 6, At("(", cLine) - 6))
    Local cFonte      := SubStr(cLine, At("(", cLine) + 1, At(")", cLine) - At("(", cLine) - 1)
    Local cRest       := AllTrim(SubStr(cLine, At(")", cLine) + 1))
    Local cContCall   := ""
    Local cTotTempo   := ""
    Local cMemoria    := ""
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
            cMemoria := AllTrim(SubStr(cRest, nPosM + 1))
        EndIf
    EndIf

    
Return {nBloco, "CALL", cFunc, cFonte, cRest, cContCall, cTotTempo, cMemoria}

Static Function ParseFrom(cLine)

    Local cFunc       := AllTrim(SubStr(cLine, 8, At("(", cLine) - 8))
    Local cFonte      := SubStr(cLine, At("(", cLine) + 1, At(")", cLine) - At("(", cLine) - 1)
    Local nLinha      := 0
    Local cRest       := ""
    Local cContCall   := ""
    Local cTotTempo   := ""
    Local cMemoria    := ""
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
            cMemoria := AllTrim(SubStr(cRest, nPosM + 1))
        EndIf
    EndIf
    
Return {nBloco, "FROM", cFunc, cFonte, nLinha, cContCall, cTotTempo, cMemoria}

Static Function retColumns(cBlock, nType)

    Local aCampos  := {}
    Local aColunas := {}
    Local nDec     := 3

    Do Case
        Case Upper(cBlock) == "CALL"

            aAdd(aColunas, {"BLOCO", {|| BLOCO}, "N", "@E 9999999999", 1, 10, 0, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID1"})
            aAdd(aCampos,  {"BLOCO", "N", 10, 0, "@E 9999999999"})

            aAdd(aColunas, {"FUNCAO", {|| FUNCAO}, "C", "@!", 1, 25, 0, .F., {|| }, .F., {|| getHist()}, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID2"})
            aAdd(aCampos,  {"FUNCAO", "C", 25, 0, "@!"})

            aAdd(aColunas, {"FONTE", {|| FONTE}, "C", "@!", 1, 25, 0, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID3"})
            aAdd(aCampos,  {"FONTE", "C", 25, 0, "@!"})

            aAdd(aColunas, {"QTD_CHAM", {|| QTD_CHAM}, "N", "@E 9999", 1, 6, 0, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID4"})
            aAdd(aCampos,  {"QTD_CHAM", "N", 6, 0, "@E 9999"})

            aAdd(aColunas, {"TEMPO_CPU", {|| TEMPO_CPU}, "N", "@E 99999.999", 1, 12, nDec, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID5"})
            aAdd(aCampos,  {"TEMPO_CPU", "N", 12, nDec, "@E 99999.999"})

            aAdd(aColunas, {"MEM_ALOC", {|| MEM_ALOC}, "N", "@E 99999.999", 1, 12, nDec, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID6"})
            aAdd(aCampos,  {"MEM_ALOC", "N", 12, nDec, "@E 99999.999"})

        Case Upper(cBlock) == "FROM"

            aAdd(aColunas, {"BLOCO_CHAM", {|| BLOCO_CHAM}, "N", "@E 9999999999", 1, 10, 0, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID1"})
            aAdd(aCampos,  {"BLOCO_CHAM", "N", 10, 0, "@E 9999999999"})

            aAdd(aColunas, {"FUNCAO", {|| FUNCAO}, "C", "@!", 1, 25, 0, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID2"})
            aAdd(aCampos,  {"FUNCAO", "C", 25, 0, "@!"})

            aAdd(aColunas, {"FONTE", {|| FONTE}, "C", "@!", 1, 25, 0, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID3"})
            aAdd(aCampos,  {"FONTE", "C", 25, 0, "@!"})

            aAdd(aColunas, {"LINHA", {|| LINHA}, "N", "@E 99999", 1, 8, 0, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID4"})
            aAdd(aCampos,  {"LINHA", "N", 8, 0, "@E 99999"})

            aAdd(aColunas, {"QTD_CHAM", {|| QTD_CHAM}, "N", "@E 9999", 1, 6, 0, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID5"})
            aAdd(aCampos,  {"QTD_CHAM", "N", 6, 0, "@E 9999"})

            aAdd(aColunas, {"TEMPO_CPU", {|| TEMPO_CPU}, "N", "@E 99999.999", 1, 12, nDec, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID6"})
            aAdd(aCampos,  {"TEMPO_CPU", "N", 12, nDec, "@E 99999.999"})

            aAdd(aColunas, {"MEM_ALOC", {|| MEM_ALOC}, "N", "@E 99999.999", 1, 12, nDec, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID7"})
            aAdd(aCampos,  {"MEM_ALOC", "N", 12, nDec, "@E 99999.999"})

        Otherwise
            Return {}
    EndCase

    If nType == 1
        Return aCampos
    ElseIf nType == 2
        Return aColunas
    EndIf

Return {}

Static Function MenuDef()

    Local aRotina := {}

    ADD OPTION aRotina TITLE "Abrir Arquivo" ACTION "U_PROFREAD" OPERATION 4 ACCESS 0

Return aRotina

Static Function getHist()

    Local cFuncao   := Upper(Alltrim((cAliasTemp)->FUNCAO))
    Local nBloco    := (cAliasTemp)->BLOCO
    Local cText     := ""
    Local nCount    := 0
    Local cTempo    := Transform((cAliasTemp)->TEMPO_CPU, "@E 99999.999")
    Local cMemoria  := Transform((cAliasTemp)->MEM_ALOC, "@E 99999.999")
    Local aItemFrom := {}

Return 
