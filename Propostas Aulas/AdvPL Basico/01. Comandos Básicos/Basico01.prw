//  Inserção e exibição de informação/string.

#INCLUDE 'TOTVS.CH'

User Function Basico01()
	local cTitulo   := ""
	local cMensagem := ""

	// Vamos utilizar a função FwInputBox para atribuir uma string à uma variável do tipo caractere.
	FwInputBox("Descrição a ser exibida na caixa de diálogo", "conteúdo não obrigatório")

    /* DOCUMENTAÇÃO

        https://tdn.totvs.com/display/public/framework/FWInputBox

    */

	cTitulo     := FwInputBox("Insira o título aqui!")
	cMensagem   := FwInputBox("Insira o conteúdo aqui")


	// Pra exibir a mensagem, vamos utilizar as funções abaixo:
	FWAlertError(cMensagem, cTitulo)
	FWAlertExitPage(cMensagem, cTitulo)
	FWAlertHelp(cMensagem, cTitulo)
	FWAlertInfo(cMensagem, cTitulo)
	FWAlertNoYes(cMensagem, cTitulo)
	FWAlertSuccess(cMensagem, cTitulo)
	FWAlertWarning(cMensagem, cTitulo)
	FWAlertYesNo(cMensagem, cTitulo)

    /*
        https://terminaldeinformacao.com/2021/04/28/utilizando-fwalert-para-exibir-mensagens-no-protheus/
    */
Return

