#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'

user function db003()

    local aArea     := GetArea()
    local aDados    := {}
    local cAlias    := GetNextAlias()
    local cQuery    := ""
    local nCount    := 1
    local nTotal    := 0
    Local lCadastra := .F.

    PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' TABLES 'ZZ1'

    // Preparar query para consultar as informações de ISBN e título de todos os registros da tabela.
    cQuery := "SELECT COUNT(*) AS TOTAL FROM " + RetSqlName("ZZ1")

    TCQUERY cQuery ALIAS &(cAlias) NEW

    &(cAlias)->(DbGoTop())
    If &(cAlias)->TOTAL == 0
        If MsgYesNo("Atenção!", "Não existem registros na tabela. Deseja inserir?")

            // TODO
            /*  Criar função para cadastrar livro a livro.
                No futuro, implementar interface visual na rotina.
            */

        Endif
    Else
        // TODO
        /*
            Criar interação e perguntar se o usuário gostaria de visualizar os títulos cadastrados, ou cadastrar um novo item.
        */
    Endif

    &(cAlias)->(DbCloseArea())
    RestArea(aArea)
    
return
