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
        u_OPNFILE()
        MsgRun("Preenchendo View...", "Aguarde!", {|| u_ShowCont()})
    Else
        u_OPNFILE()
        FwAlertInfo("Atenção, criando tabelas!", "Prosseguir")
        u_ShowCont()
    EndIf

    If !Empty(oFile)
        oFile:Close()
    EndIf

Return 

// Abre o arquivo .log e preenche os arrays com os blocos de chamada.
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

            // Apenas registros do tipo "CALL"
            If aReg[2] == "CALL"
                aAdd(aItens, {nBlock, aReg[3], aReg[4], Val(aReg[6]), aReg[7], aReg[8]})

            // Apenas registros do tipo "FROM"
            Elseif aReg[2] == "FROM"
                aAdd(aItens2, {nBlock, aReg[3], aReg[4], aReg[5], aReg[6], aReg[7], aReg[8]})
                
            EndIf
        Next
    Next

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
    Local aFiltro       as Array
    Private cAliasTemp  as Character
    Private aCampos     as Array
    Private oTempTable  as Object
    Private oBrowse     as Object
    Private oDlg        as Object
    Private aRotina     := MenuDef()
    
    aCampos     := retColumns("CALL", 1)
    aColunas    := retColumns("CALL", 2)
    aFiltro     := {}

    oTempTable := FWTemporaryTable():New()
    oTempTable:SetFields(aCampos)
    oTempTable:AddIndex("Bloco", {"Bloco", "Funcao"})
    oTempTable:Create()

    cAliasTemp := oTempTable:GetAlias()
    oBrowse := NIL

    DbSelectArea(cAliasTemp)
    For nCount := 01  to len(aItens)
        If (RecLock(cAliasTemp, .T.))
            (cAliasTemp)->Bloco     := aItens[nCount][1]
            (cAliasTemp)->Funcao    := aItens[nCount][2]
            (cAliasTemp)->Fonte     := aItens[nCount][3]
            (cAliasTemp)->QTD_CHAM  := aItens[nCount][4]
            (cAliasTemp)->TMP_TOTAL := aItens[nCount][5]
            (cAliasTemp)->TMP_MAX   := aItens[nCount][6]

            (cAliasTemp)->(MSUnlock())
        Endif
            (cAliasTemp)->(DbSkip())
    Next nCount

    (cAliasTemp)->(DbGoTop())

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias(cAliasTemp)
    oBrowse:SetColumns(aColunas)
    oBrowse:SetDescription("LogProfiler Reader - AdvPL Ver.")
    oBrowse:AddLegend("Substr(Funcao, 1, 2) == 'U_'", "RED", "Customizado")
    oBrowse:AddLegend("Substr(Funcao, 1, 2) != 'U_'", "BLUE", "Padrão")
    oBrowse:SetTemporary(.T.)
    oBrowse:SetUseFilter(.T.)
    oBrowse:OptionReport(.F.)
    oBrowse:DisableDetails()

    if lProtheus
        oBrowse:Activate()
    Else
        oDlg := TDialog():New(0, 0, 800, 1750,,,,,,,,,,.T.)
        oBrowse:Activate(oDlg)
        oDlg:Activate()
    Endif

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

Static Function retColumns(cBlock, nType)

    Local aCampos  := {}
    Local aColunas := {}

    Do Case
    Case Upper(cBlock) == "CALL"

        // Codeblock: {|| BLOCO}
        aAdd(aColunas, {"CALL_BLOCO", {|| BLOCO}, "N", "@E 9999999999", 1, 10, 0, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID1"})
        aAdd(aCampos,  {"BLOCO", "N", 10, 0, "@E 9999999999"})

        // Codeblock: {|| FUNCAO}
        aAdd(aColunas, {"FUNCAO", {|| FUNCAO}, "C", "@!", 1, 20, 0, .F., {|| }, .F., {|| getHist()}, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID2"})
        aAdd(aCampos,  {"FUNCAO", "C", 20, 0, "@!"})

        // Codeblock: {|| FONTE}
        aAdd(aColunas, {"FONTE", {|| FONTE}, "C", "@!", 1, 20, 0, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID3"})
        aAdd(aCampos,  {"FONTE", "C", 20, 0, "@!"})

        // Codeblock: {|| QTD_CHAM}
        aAdd(aColunas, {"QTD_CHAM", {|| QTD_CHAM}, "N", "@E 9999999999", 1, 10, 0, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID4"})
        aAdd(aCampos,  {"QTD_CHAM", "N", 10, 0, "@E 9999999999"})

        // Codeblock: {|| TMP_TOTAL}
        aAdd(aColunas, {"TMP_TOTAL", {|| TMP_TOTAL}, "C", "@!", 1, 20, 0, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID5"})
        aAdd(aCampos,  {"TMP_TOTAL", "C", 20, 0, "@!"})

        // Codeblock: {|| TMP_MAX}
        aAdd(aColunas, {"TMP_MAX", {|| TMP_MAX}, "C", "@!", 1, 20, 0, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID6"})
        aAdd(aCampos,  {"TMP_MAX", "C", 20, 0, "@!"})

    Case Upper(cBlock) == "FROM"

        // Codeblock: {|| FROM_BLOC}
        aAdd(aColunas, {"FROM_BLOC", {|| FROM_BLOC}, "C", "@E 9999999999", 1, 10, 0, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID1"})
        aAdd(aCampos,  {"FROM_BLOC", "C", 10, 0, "@E 9999999999"})

        // Codeblock: {|| FUNCAO}
        aAdd(aColunas, {"FUNCAO", {|| FUNCAO}, "C", "@!", 1, 20, 0, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID2"})
        aAdd(aCampos,  {"FUNCAO", "C", 20, 0, "@!"})

        // Codeblock: {|| FONTE}
        aAdd(aColunas, {"FONTE", {|| FONTE}, "C", "@!", 1, 20, 0, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID3"})
        aAdd(aCampos,  {"FONTE", "C", 20, 0, "@!"})

        // Codeblock: {|| LINHA}
        aAdd(aColunas, {"LINHA", {|| LINHA}, "N", "@E 9999999999", 1, 10, 0, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID4"})
        aAdd(aCampos,  {"LINHA", "N", 10, 0, "@E 9999999999"})

        // Codeblock: {|| QTDCHAM}
        aAdd(aColunas, {"QTDCHAM", {|| QTDCHAM}, "C", "@!", 1, 10, 0, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID5"})
        aAdd(aCampos,  {"QTDCHAM", "C", 10, 0, "@!"})

        // Codeblock: {|| TMP_TOT}
        aAdd(aColunas, {"TMP_TOT", {|| TMP_TOT}, "C", "@!", 1, 20, 0, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID6"})
        aAdd(aCampos,  {"TMP_TOT", "C", 20, 0, "@!"})

        // Codeblock: {|| TMP_MAX}
        aAdd(aColunas, {"TMP_MAX", {|| TMP_MAX}, "C", "@!", 1, 20, 0, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .F., {}, "ID7"})
        aAdd(aCampos,  {"TMP_MAX", "C", 20, 0, "@!"})

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

    ADD OPTION aRotina TITLE "Fechar" ACTION "MsgInfo('Deu certo', 'Oba')" OPERATION 4 ACCESS 0

Return aRotina

Static Function getHist()

    Local cFuncao := Upper(Alltrim((cAliasTemp)->Funcao))

    FwAlertInfo(cFuncao, "Atenção")

Return
