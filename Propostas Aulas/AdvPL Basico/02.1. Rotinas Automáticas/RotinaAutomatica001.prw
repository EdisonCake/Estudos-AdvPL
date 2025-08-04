#INCLUDE 'TOTVS.CH'
#INCLUDE 'TBICONN.CH'

/*/{Protheus.doc} ROTAUT001

    Rotina automática para cadastro de clientes (SA1) utilizando MsExecAuto().

    @author Edison Cake
    @since 07/07/2025

    @see https://centraldeatendimento.totvs.com/hc/pt-br/articles/4403853592471-Cross-Segmentos-Backoffice-Protheus-SIGAFAT-Rotina-cadastro-de-cliente-MATA030-descontinuada
    @see https://centraldeatendimento.totvs.com/hc/pt-br/articles/4411625532567-Cross-Segmentos-Backoffice-Protheus-SIGAFAT-%C3%89-necess%C3%A1ria-adapta%C3%A7%C3%A3o-do-ExecAuto-MATA030-para-CRMA980

/*/
User Function ROTAUT001()

	local aDados    := {}
	local nOper     := 3 //! Operação de inclusão

	// Variável para indicar erro de execução na rotina automática.
	private lMsErroAuto := .F.

	// Preparaçào do ambiente
	PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' MODULO 'COM'

	// Adicionando as informações necessárias para o cadastro do cliente para informar à rotina automática.
	aAdd(aDados, {'A1_FILIAL',  FwxFilial('SA1'),   NIL})
	aAdd(aDados, {'A1_COD',     '00000T',           NIL})
	aAdd(aDados, {'A1_LOJA',    '01',               NIL})
	aAdd(aDados, {'A1_NOME',    'TESTE',            NIL})
	aAdd(aDados, {'A1_NREDUZ',  'TEST',             NIL})
	aAdd(aDados, {'A1_END',     'AV. TESTE',        NIL})
	aAdd(aDados, {'A1_TIPO',    'F',                NIL})
	aAdd(aDados, {'A1_MUN',     'TESTEY',           NIL})
	aAdd(aDados, {'A1_EST',     'SP',               NIL})
	aAdd(aDados, {'A1_TEL',     '99999999',         NIL})

    // Definindo a variável de erro de execução automático para FALSO (redundância para verificação de erro)
    lMsErroAuto := .F.

    /*
        Abaixo é chamada a função de rotina automática, informando através dos Pipes "||" que haverá um bloco de código 
        com dois argumentos. Após os pipes, é informada a rotina, no caso abaixo, MATA030() com seus dois parâmetros. 
        Os parâmetros a serem passados estão após o bloco de código, informando que x será o array "aDados", e y será o
        número da operação, no nosso exemplo, 3 para inclusão.
    */
    MsExecAuto({|x, y| MATA030(x, y)}, aDados, nOper)

    // Se retornou algum erro, será apresentado ao usuário.
    if lMsErroAuto
        if !IsBlind()
            MostraErro()
        endif
    endif

    RESET ENVIRONMENT
Return
