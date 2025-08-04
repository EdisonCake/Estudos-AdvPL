#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'

/*/{Protheus.doc} PROFREAD

	Rotina para leitura de arquivos de LOG do Protheus. Tradução do LogProfileViewe em Java.

	@history: Primeiro estágio, criação da view para visualizaçào dos arquivos em tabela temporária. Opção de iniciar dentro ou fora do Protheus.

	@type user function
	@author Edison Cake
	@since 10/07/2025
	
/*/
User Function PROFREAD()

	local lProtheus := .F.
	private cDir 		:= ""
	private oFile 	as object

	FwAlertInfo("Iniciando rotina PROFREAD", "Atenção")

	if Select("SX2") <= 0
		PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01'
		FwAlertInfo('Empresa iniciada através de Prepare Environment')
	else
		FwAlertInfo('Chamado a partir do Protheus.')
		lProtheus := .T.
	endif

	// Indica que foi chamado a partir de menu Protheus.
	if lProtheus
		// TODO - Iniciar componentes gráficos MVC.
		// TODO - Criar uma view para exibição de tabela temporária.
		// TODO - Incluir botões de ação "Abrir", "Visualizar", "Limpar View"
	else

		// Indica que foi iniciado sem ser por menu Protheus.
		// TODO - Iniciar interface gráfica
		// DONE - Criar função de leitura de arquivo.

		// Carregamento de interface gráfica para visualização e leitura dos arquivos.
		u_INTRFCE()
		// u_OPNFILE()
	endif

Return FwAlertInfo("Fim da execução.", "Atenção")

/*/{Protheus.doc} OPNFILE

	Função para abertura de arquivo .log do Protheus.

	@type user function
	@author Edison Cake
	@since 10/07/2025
	
/*/
User Function OPNFILE()

	FwAlertInfo("Chamada da função OPNFILE()")

	// Solicita o arquivo para leitura
	cDir := cGetFile("*.log", "Selecione o arquivo para leitura", 1, "C:\Clientes\## GENERICO\GitHub\EdisonCake\Estudos\AdvPL\_Projeto ProfileReader\Arquivos Teste", .T.)

	if empty(cdir)
		FwAlertInfo("Nenhum arquivo selecionado, ou o arquivo está corrompido!")
		return nil
	endif

	oFile := FwFileReader():New(cDir)

	if oFile:Open()
		FwAlertInfo("aberto o arquivo " + cdir + ".", "sucesso")

	else
		msgstop("falha ao abrir o arquivo " + cdir + ".")
	endif

Return

/*/{Protheus.doc} INTRFCE

	Função para inicialização gráfica da interface de leitura do arquivo .log do Protheus.

	@type user function
	@author Edison Cake
	@since 10/07/2025
	
/*/
User Function INTRFCE()

    Local oDlg
	Local cFilter

	Private oSayTipo 
	Private oBtnOpen

    DEFINE DIALOG oDlg TITLE "LogProfiler View (AdvPL Edition)" FROM 0,0 TO 1000,750 PIXEL

    @ 010, 010 BUTTON 	oBtnOpen  		PROMPT "Abrir Arquivo Log"     					SIZE 050, 020 PIXEL OF oDlg ACTION U_TESTE()
	@ 040, 010 MSGET 	cFilter 		VAR cFilter										SIZE 180, 020 PIXEL OF oDlg 
    @ 017, 070 SAY 		oSayTipo 		PROMPT "Arquivo: '' / Tipo: ''" 				SIZE 300, 012 PIXEL OF oDlg COLOR CLR_BLUE, CLR_WHITE 

    ACTIVATE DIALOG oDlg CENTER

Return

user function TESTE()

	oSayTipo:SetText("Arquivo Aberto.")

return
