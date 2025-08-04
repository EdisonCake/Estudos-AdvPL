#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'

/*/{Protheus.doc} ROTAUT002

    Rotina automática para cadastro de cliente (SA1) utilizando MVC.
    É possível executar um MsExecAuto() com a rotina CRMA980 também (vide documentação em anexo).

    @author Edison Cake
    @since 07/07/2025

    @see https://terminaldeinformacao.com/knowledgebase/execauto-mata030-mvc/
    @see https://centraldeatendimento.totvs.com/hc/pt-br/articles/12121892912151--Cross-Segmento-TOTVS-Backoffice-Linha-Protheus-SIGAFAT-EXECAUTO-CRMA980
    @see https://tdn.totvs.com/display/public/PROT/DT+Novo+Fonte+de+Cadastro+de+Clientes+em+MVC
/*/
User Function ROTAUT002()

	local oModel    as object
	local oSA1model as object
	local nOper     as numeric

	PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01'

	// Carregando o modelo de dados e definindo a operação.
	oModel := FwLoadModel('CRMA980')    // antiga MATA030.
	oModel:SetOperation(nOper)          // 3 para inclusão.
	oModel:Activate()

	// Pegando o modelo dos campos da SA1.
	oSa1Model := oModel:GetModel("SA1MASTER") // Conversaremos sobre isso na aula de MVC.
	oSa1Model:setValue("A1_FILIAL", FWxFilial("SA1"))
	oSa1Model:setValue("A1_COD",    '00000T')
	oSa1Model:setValue("A1_LOJA",    '01')
	oSa1Model:setValue('A1_NOME',    'TESTE')
	oSa1Model:setValue('A1_NREDUZ',  'TEST')
	oSa1Model:setValue('A1_END',     'AV. TESTE')
	oSa1Model:setValue('A1_TIPO',    'F')
	oSa1Model:setValue('A1_MUN',     'TESTEY')
	oSa1Model:setValue('A1_EST',     'SP')
	oSa1Model:setValue('A1_TEL',     '99999999')

    // Verifica se é possível validar as informações.
    if oModel:VldData()
        
        // Verifica se é possível realizar o commit das informações na tabela.
        if !oModel:CommitData()
            if !IsBlind()
                Mostraerro()
            endif
        endif
    endif

    // Desativando o modelo de dados carregado.
    oModel:Deactivate()
Return
