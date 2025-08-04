#INCLUDE 'TOTVS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'

// Para realizar consultas e manipulação de dados em AdvPL, deve-se incluir as bibliotecas nativas do Protheus/AdvPL que contém as funções de comunicação e manipulação. As mesmas são a TBIConn e a TOPConn.

user function db001()

    // Declaração de variáveis
    local aArea     := GetArea()
    local aDados    := {}
    local cAlias    := GetNextAlias()
    local cQuery    := ""
    local nCount    as numeric // A variável foi declarada como NULA, logo, não se pode realizar operações numéricas com o conteúdo atual, somente após atribuição.

    /*
        Ao utilizar a função GetArea() e atribuir a um array seu conteúdo, todos os status das workspaces abertas no momento são mantidos, posicionamentos são mantidos, etc. Após o uso da lógica para consultas, etc, deve-se utilizar o RestArea() no final da rotina para restaurar os estados anteriormente salvos. 

        Quando usar:
        • Ao mexer com múltiplas tabelas e não quiser alterar o contexto principal.
        • Criar funções reutilizáveis que abrem tabelas, mas que precisam preservar o estado do chamados.
        • Fazer processos temporários dentro de loops.

        Agora que já iniciamos a rotina, vamos consultar uma tabela customizada e trazer os dados da mesma para exibição em tela com uma função de aviso.
    */

    // Vamos abrir o ambiente, sem a necessidade de iniciar o Protheus.
    PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' TABLES 'ZZ1' MODULO 'COM'

    /*
        Acima, iniciamos o ambiente do Protheus sem de fato termos aberto o programa e esse comando é geralmente utilizado em rotinas automáticas (execautos).
        Especificamente aqui, iniciamos a Empresa 99, Filial 01, e carregamos o conteúdo somente da tabela customizada ZZ1, no módulo de compras.
    */

    // Atribuindo a query para nossa pesquisa.
    cQuery := "SELECT * FROM " + RetSqlName("ZZ1") + " WHERE D_E_L_E_T_ = ' '"

    /*
        A variável cQuery recebe a consulta que realizaremos no banco de dados do Protheus.
        Para se comunicar em SQL, o AdvPL tem algumas funções específicas que permitem a tradução dos comandos entre as linguagens. Um exemplo, é a função RetSqlName().
        No AdvPL, normalmente trabalhamos com nomes (ou "Alias") tipo SA1, SE1, SC5, etc, mas no banco de dados, temos nomes reais, como SA1990 ou ZZ1991, e com isso, a função retorna o nome correto para que a consulta em SQL retorne as informações que precisamos na empresa/filial corretas.
    */

    // Iniciando a consulta no banco de dados.
    TCQUERY cQuery ALIAS &(cAlias) NEW

    /*
        Com o TCQuery, iniciamos a consulta no banco de dados do Protheus, atendendo aos critérios da query montada.
        O alias utilizado foi atribuído no início da rotina com a função GetNextAlias(), que gera um nome temporário para que a consulta não tenha conflitos com outros dados que não queiramos consultar.
    */

    // Após a consulta, posicionamos o ponteiro no início da tabela.
    &(cAlias)->(DbGoTop())

    // Atribuindo o inicio do nosso contador à variável.
    /*
        Outra forma de realizar isso seria:
        nCount := 0
        nCount ++
    */
    nCount := 1

    // Iniciando loop para obter as informações desejadas.
    While &(cAlias)->(!EoF())

        /*
            Utilizar a função EoF() "End of File" é vital para identificar se a consulta retornou dados ou não. Caso, após posicionar no topo, a função EoF() retornar um positivo, significa que não há dados a serem exibidos pela consulta. Pode-se utilizar com IF também, a fim de validar processos e/ou retornar informações na customização.
        */

        aAdd(aDados, {})
        nCount++

        // Ao obter as informações necessárias, pula para o próximo registro da tabela consultada.
        &(cAlias)->(DbSkip())

    End do

    // Realizar tratamento dos dados.

    // TODO
    //* Criar função para transformar array em caractere e exibir informações, passando o array e o contador!

    // Exibindo as informações
    FwAlertInfo("", "Informações")

    // Fechando a tabela, e o ambiente para encerrar a rotina.
    &(cAlias)->(DbCloseArea())
    RestArea(aArea)
    
return
