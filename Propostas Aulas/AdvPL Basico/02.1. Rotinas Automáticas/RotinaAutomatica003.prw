#INCLUDE 'TOTVS.CH'
#INCLUDE 'TBICONN.CH'

/*/{Protheus.doc} ROTAUT003

    Rotina automática para cadastro de pedido de compra (MATA120) utilizando MsExecAuto().

    @author Edison Cake
    @since 07/07/2025

    @see (links_or_references)
/*/
User Function ROTAUT003()

	local aCab      := {} // Cabeçalho do pedido de compra.
	local aItens    := {} // Itens a serem adicionados ao pedido de compra.
	local aLinha    := {} // Linha a ser adicionada no grid de itens do pedido de compra.
	local cDoc      := ""
	local nOper     := 3 // Operação de inclusão

	private lMsErroAuto := .F.

	PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' MODULO 'COM'

	// Obtendo o próximo número sequencial para registrar o documento.
	cDoc := GetSXENum("SC7", "C7_NUM")

	// Adicionando as informações de cabeçalho.
	aAdd(aCab, {"C7_NUM",       cDoc,           NIL})
	aadd(aCab, {"C7_EMISSAO",   dDataBase, 		NIL})
	aadd(aCab, {"C7_FORNECE",   "001 ",			NIL})
	aadd(aCab, {"C7_LOJA",      "01", 			NIL})
	aadd(aCab, {"C7_COND",      "001", 			NIL})
	aadd(aCab, {"C7_CONTATO",   "AUTO",			NIL})
	aadd(aCab, {"C7_FILENT",    cFilAnt, 		NIL})
	aadd(aCab, {"C7_TPFRETE",   "C", 			NIL})
	aadd(aCab, {"C7_FRETE",     15, 			NIL})

	// Adicionando as informações de itens
	aLinha := {}
	aadd(aLinha,{"C7_PRODUTO",	"0001",	Nil})
	aadd(aLinha,{"C7_QUANT",	1,		Nil})
	aadd(aLinha,{"C7_PRECO",	100,	Nil})
	aadd(aLinha,{"C7_TOTAL",	100,	Nil})
	aadd(aItens,aLinha)

	lMsErroAuto := .F.
	MsExecAuto({|a, b, c, d|}, 1, aCab, aItens, nOper, .F.)

	If !lMsErroAuto
		If !IsBlind()
			MostraErro()
		Endif
	Endif

	RESET ENVIRONMENT
Return
