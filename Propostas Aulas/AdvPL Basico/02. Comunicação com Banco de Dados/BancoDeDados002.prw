#INCLUDE 'TOTVS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'

// Outra forma de realizar consultas no banco de dados do Protheus em AdvPL é utilizando de funções nativas, sem a necessidade de envolver query.

user function db002()

    // Declaração de variáveis
    local aArea     := GetArea()
    local aAreaZZ1  := ZZ1->(GetArea())
    local cCodigo   := "000001"

    // Vamos abrir o ambiente, sem a necessidade de iniciar o Protheus.
    PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' TABLES 'ZZ1' MODULO 'COM'

    // Abrindo e selecionando a tabela que será utilizada.
    DbSelectArea("ZZ1")

    // Indicando qual o índice a ser utilizado.
    ZZ1->(DbSetOrder(1))
    // Filial + Codigo
    
    // Pesquisando um registro através de função genérica.
    ZZ1->(DbSeek( FWxFilial("ZZ1") + cCodigo))

    // Posicionando no topo da tabela.
    ZZ1->(DbGoTop())

    // TODO -- Executar a lógica

    // Finalizando a conexão, e limpando as áreas.
    ZZ1->(DbCloseArea())
    RestArea(aArea)
    RestArea(aAreaZZ1)

return
