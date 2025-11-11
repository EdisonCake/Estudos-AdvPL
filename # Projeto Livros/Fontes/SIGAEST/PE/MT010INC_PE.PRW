#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} MT010INC

    Ponto de Entrada para complementar a inclusão no cadastro do Produto.

    @type user function
    @author Edison Cake
    @since 11/11/2025
    @see https://tdn.totvs.com/pages/releaseview.action?pageId=6087685
/*/
User Function MT010INC()

    If Existblock("InsZZ1")
        ExecBlock("InsZZ1", .F., .F.)
    Endif

Return 
