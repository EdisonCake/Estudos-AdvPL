#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'

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
    Local oBrowseUp  
    Local oBrowseDown 
    Local oDialog

    Local nBloco    := 0
    Local nLinha    := 0
    Local nTotal    := 0
    Local nCount    := 0
    Local aBloco    := {}
    Local aReg      := {}
    Local aItens    := {}
    Local aItens2   := {}
    Local aColunas  := {}
    
    oDialog := TDialog():New(0, 0, 1920, 1080,,,,,,,,,,.T.)
    oBrowseUp := FwBrowse():New(oDialog)
    oBrowseUp:SetDataArrayoBrowse()

    nTotal := len(aConteudo)
    ProcRegua(nTotal)

    // Percorre o array de conteúdo
    For nBloco := 1 To Len(aConteudo)
        aBloco := aConteudo[nBloco]
        For nLinha := 1 To Len(aBloco)
            aReg := aBloco[nLinha]

            // Apenas registros do tipo "CALL"
            If aReg[2] == "CALL"
                aAdd(aItens, {nBloco, aReg[3], aReg[4], Val(aReg[6]), aReg[7], aReg[8]})

            Elseif aReg[2] == "FROM"
                aAdd(aItens2, {nBloco, aReg[3], aReg[4], Val(Reg[5]), aReg[6], aReg[7], aReg[8]})
                
            EndIf
            

            IncProc()
        Next
    Next

    oBrowseUp:SetArray(aItens)

    aAdd(aColunas, {;
                        "Bloco",;                           // [n][01] Título da coluna
                        {|oBrw| aItens[oBrw:At(), 1]},;     // [n][02] Code-Block de carga dos dados
                        "N",;                               // [n][03] Tipo de dados
                        "@E 9999999999",;                   // [n][04] Máscara
                        1,;                                 // [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
                        10,;                                // [n][06] Tamanho
                        0,;                                 // [n][07] Decimal
                        .F.,;                               // [n][08] Indica se permite a edição
                        {|| },;                             // [n][09] Code-Block de validação da coluna após a edição
                        .F.,;                               // [n][10] Indica se exibe imagem
                        Nil,;                               // [n][11] Code-Block de execução do duplo clique
                        "__ReadVar",;                       // [n][12] Variável a ser utilizada na edição (ReadVar)
                        {|| AlwaysTrue()},;                 // [n][13] Code-Block de execução do clique no header
                        .F.,;                               // [n][14] Indica se a coluna está deletada
                        .F.,;                               // [n][15] Indica se a coluna será exibida nos detalhes do Browse
                        {},;                                // [n][16] Opções de carga dos dados
                        "ID1"})                             // [n][17] Id da coluna

    aAdd(aColunas, {;
                        "Função",;                          // [n][01]
                        {|oBrw| aItens[oBrw:At(), 2]},;     // [n][02]
                        "N",;                               // [n][03]
                        "@!",;                              // [n][04]
                        1,;                                 // [n][05]
                        20,;                                // [n][06]
                        0,;                                 // [n][07]
                        .F.,;                               // [n][08]
                        {|| },;                             // [n][09]
                        .F.,;                               // [n][10]
                        Nil,;                               // [n][11]
                        "__ReadVar",;                       // [n][12]
                        {|| AlwaysTrue()},;                 // [n][13]
                        .F.,;                               // [n][14]
                        .F.,;                               // [n][15]
                        {},;                                // [n][16]
                        "ID2"})                             // [n][17]

    aAdd(aColunas, {;
                        "Fonte",;                           // [n][01]
                        {|oBrw| aItens[oBrw:At(), 3]},;     // [n][02]
                        "N",;                               // [n][03]
                        "@!",;                              // [n][04]
                        1,;                                 // [n][05]
                        20,;                                // [n][06]
                        0,;                                 // [n][07]
                        .F.,;                               // [n][08]
                        {|| },;                             // [n][09]
                        .F.,;                               // [n][10]
                        Nil,;                               // [n][11]
                        "__ReadVar",;                       // [n][12]
                        {|| AlwaysTrue()},;                 // [n][13]
                        .F.,;                               // [n][14]
                        .F.,;                               // [n][15]
                        {},;                                // [n][16]
                        "ID3"})                             // [n][17]

    aAdd(aColunas, {;
                        "Qtd. Chamadas",;                   // [n][01]
                        {|oBrw| aItens[oBrw:At(), 4]},;     // [n][02]
                        "N",;                               // [n][03]
                        "",;                                // [n][04]
                        1,;                                 // [n][05]
                        10,;                                // [n][06]
                        0,;                                 // [n][07]
                        .F.,;                               // [n][08]
                        {|| },;                             // [n][09]
                        .F.,;                               // [n][10]
                        Nil,;                               // [n][11]
                        "__ReadVar",;                       // [n][12]
                        {|| AlwaysTrue()},;                 // [n][13]
                        .F.,;                               // [n][14]
                        .F.,;                               // [n][15]
                        {},;                                // [n][16]
                        "ID4"})                             // [n][17]

    aAdd(aColunas, {;
                        "Tempo Total",;                     // [n][01]
                        {|oBrw| aItens[oBrw:At(), 5]},;     // [n][02]
                        "N",;                               // [n][03]
                        "",;                                // [n][04]
                        1,;                                 // [n][05]
                        20,;                                // [n][06]
                        0,;                                 // [n][07]
                        .F.,;                               // [n][08]
                        {|| },;                             // [n][09]
                        .F.,;                               // [n][10]
                        Nil,;                               // [n][11]
                        "__ReadVar",;                       // [n][12]
                        {|| AlwaysTrue()},;                 // [n][13]
                        .F.,;                               // [n][14]
                        .F.,;                               // [n][15]
                        {},;                                // [n][16]
                        "ID5"})                             // [n][17]

    aAdd(aColunas, {;
                        "Tempo Máximo",;                    // [n][01]
                        {|oBrw| aItens[oBrw:At(), 6]},;     // [n][02]
                        "N",;                               // [n][03]
                        "",;                                // [n][04]
                        1,;                                 // [n][05]
                        20,;                                // [n][06]
                        0,;                                 // [n][07]
                        .F.,;                               // [n][08]
                        {|| },;                             // [n][09]
                        .F.,;                               // [n][10]
                        Nil,;                               // [n][11]
                        "__ReadVar",;                       // [n][12]
                        {|| AlwaysTrue()},;                 // [n][13]
                        .F.,;                               // [n][14]
                        .F.,;                               // [n][15]
                        {},;                                // [n][16]
                        "ID6"})                             // [n][17]


    For nCount := 1 to len(aColunas)
        oBrowseUp:AddColumn(aColunas[nCount])
    Next

    oBrowseUp:SetOwner(oDialog)
    oBrowseUp:SetDescription("LogProfiler Reader - ADVPL Version")
    oBrowseUp:Activate()
    oDialog:Activate()
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

/* Backup 
    User Function ShowCont()
        Local oBrowse   
        Local oDialog

        Local nBloco    := 0
        Local nLinha    := 0
        Local nTotal    := 0
        Local nCount    := 0
        Local aBloco    := {}
        Local aReg      := {}
        Local aItens    := {}
        Local aItens2   := {}
        Local aColunas  := {}

        oDialog := TDialog():New(0, 0, 1920, 1080,,,,,,,,,,.T.)
        oBrowse := FwBrowse():New(oDialog)
        oBrowse:SetDataArrayoBrowse()

        nTotal := len(aConteudo)
        ProcRegua(nTotal)

        // Percorre o array de conteúdo
        For nBloco := 1 To Len(aConteudo)
            aBloco := aConteudo[nBloco]
            For nLinha := 1 To Len(aBloco)
                aReg := aBloco[nLinha]

                // Apenas registros do tipo "CALL"
                If aReg[2] == "CALL"
                    aAdd(aItens, {nBloco, aReg[3], aReg[4], Val(aReg[6]), aReg[7], aReg[8]})

                Elseif aReg[2] == "FROM"
                    aAdd(aItens2, {nBloco, aReg[3], aReg[4], Val(Reg[5]), aReg[6], aReg[7], aReg[8]})

                EndIf


                IncProc()
            Next
        Next

        oBrowse:SetArray(aItens)

        aAdd(aColunas, {;
                            "Bloco",;                           // [n][01] Título da coluna
                            {|oBrw| aItens[oBrw:At(), 1]},;     // [n][02] Code-Block de carga dos dados
                            "N",;                               // [n][03] Tipo de dados
                            "@E 9999999999",;                   // [n][04] Máscara
                            1,;                                 // [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
                            10,;                                // [n][06] Tamanho
                            0,;                                 // [n][07] Decimal
                            .F.,;                               // [n][08] Indica se permite a edição
                            {|| },;                             // [n][09] Code-Block de validação da coluna após a edição
                            .F.,;                               // [n][10] Indica se exibe imagem
                            Nil,;                               // [n][11] Code-Block de execução do duplo clique
                            "__ReadVar",;                       // [n][12] Variável a ser utilizada na edição (ReadVar)
                            {|| AlwaysTrue()},;                 // [n][13] Code-Block de execução do clique no header
                            .F.,;                               // [n][14] Indica se a coluna está deletada
                            .F.,;                               // [n][15] Indica se a coluna será exibida nos detalhes do Browse
                            {},;                                // [n][16] Opções de carga dos dados
                            "ID1"})                             // [n][17] Id da coluna

        aAdd(aColunas, {;
                            "Função",;                          // [n][01]
                            {|oBrw| aItens[oBrw:At(), 2]},;     // [n][02]
                            "N",;                               // [n][03]
                            "@!",;                              // [n][04]
                            1,;                                 // [n][05]
                            20,;                                // [n][06]
                            0,;                                 // [n][07]
                            .F.,;                               // [n][08]
                            {|| },;                             // [n][09]
                            .F.,;                               // [n][10]
                            Nil,;                               // [n][11]
                            "__ReadVar",;                       // [n][12]
                            {|| AlwaysTrue()},;                 // [n][13]
                            .F.,;                               // [n][14]
                            .F.,;                               // [n][15]
                            {},;                                // [n][16]
                            "ID2"})                             // [n][17]

        aAdd(aColunas, {;
                            "Fonte",;                           // [n][01]
                            {|oBrw| aItens[oBrw:At(), 3]},;     // [n][02]
                            "N",;                               // [n][03]
                            "@!",;                              // [n][04]
                            1,;                                 // [n][05]
                            20,;                                // [n][06]
                            0,;                                 // [n][07]
                            .F.,;                               // [n][08]
                            {|| },;                             // [n][09]
                            .F.,;                               // [n][10]
                            Nil,;                               // [n][11]
                            "__ReadVar",;                       // [n][12]
                            {|| AlwaysTrue()},;                 // [n][13]
                            .F.,;                               // [n][14]
                            .F.,;                               // [n][15]
                            {},;                                // [n][16]
                            "ID3"})                             // [n][17]

        aAdd(aColunas, {;
                            "Qtd. Chamadas",;                   // [n][01]
                            {|oBrw| aItens[oBrw:At(), 4]},;     // [n][02]
                            "N",;                               // [n][03]
                            "",;                                // [n][04]
                            1,;                                 // [n][05]
                            10,;                                // [n][06]
                            0,;                                 // [n][07]
                            .F.,;                               // [n][08]
                            {|| },;                             // [n][09]
                            .F.,;                               // [n][10]
                            Nil,;                               // [n][11]
                            "__ReadVar",;                       // [n][12]
                            {|| AlwaysTrue()},;                 // [n][13]
                            .F.,;                               // [n][14]
                            .F.,;                               // [n][15]
                            {},;                                // [n][16]
                            "ID4"})                             // [n][17]

        aAdd(aColunas, {;
                            "Tempo Total",;                     // [n][01]
                            {|oBrw| aItens[oBrw:At(), 5]},;     // [n][02]
                            "N",;                               // [n][03]
                            "",;                                // [n][04]
                            1,;                                 // [n][05]
                            20,;                                // [n][06]
                            0,;                                 // [n][07]
                            .F.,;                               // [n][08]
                            {|| },;                             // [n][09]
                            .F.,;                               // [n][10]
                            Nil,;                               // [n][11]
                            "__ReadVar",;                       // [n][12]
                            {|| AlwaysTrue()},;                 // [n][13]
                            .F.,;                               // [n][14]
                            .F.,;                               // [n][15]
                            {},;                                // [n][16]
                            "ID5"})                             // [n][17]

        aAdd(aColunas, {;
                            "Tempo Máximo",;                    // [n][01]
                            {|oBrw| aItens[oBrw:At(), 6]},;     // [n][02]
                            "N",;                               // [n][03]
                            "",;                                // [n][04]
                            1,;                                 // [n][05]
                            20,;                                // [n][06]
                            0,;                                 // [n][07]
                            .F.,;                               // [n][08]
                            {|| },;                             // [n][09]
                            .F.,;                               // [n][10]
                            Nil,;                               // [n][11]
                            "__ReadVar",;                       // [n][12]
                            {|| AlwaysTrue()},;                 // [n][13]
                            .F.,;                               // [n][14]
                            .F.,;                               // [n][15]
                            {},;                                // [n][16]
                            "ID6"})                             // [n][17]


        For nCount := 1 to len(aColunas)
            oBrowse:AddColumn(aColunas[nCount])
        Next

        oBrowse:SetOwner(oDialog)
        oBrowse:SetDescription("LogProfiler Reader - ADVPL Version")
        oBrowse:Activate()
        oDialog:Activate()
    Return
    */
