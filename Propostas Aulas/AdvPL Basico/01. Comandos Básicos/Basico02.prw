// Manipulação de números e string.

#INCLUDE 'TOTVS.CH'

User Function Basico02()
    local cTexto    := ""
    local nNumero   := ""

    // Aqui, vamos aprender a transformar string em número, e vice versa!
    // Com as funções Val() e CValToChar()

    // Para transformar uma string em número, usa-se a função Val(), que recebe a string direto ou através de uma variável com o conteúdo atribuído.

    /*
        https://tdn.totvs.com/pages/viewpage.action?pageId=27676954
    */

    cTexto := "500"
    nNumero := Val(cTexto)  // ou nNumero := Val("500")

    // Para realizar a operação inversa, utiliza-se a função cValToChar() que recebe um número direto, ou uma variável com o valor atribuído.

    /*
        https://tdn.totvs.com/pages/viewpage.action?pageId=27676826
    */

    nNumero := 500
    cTexto := cValToChar(nNumero) // ou cTexto := cValToChar(500)

    // Dependendo da função que vai utilizar, ou do programa, é necessária a conversão da variável para evitar incidentes com o código.
Return 
