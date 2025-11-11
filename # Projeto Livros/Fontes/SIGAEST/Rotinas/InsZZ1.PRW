#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} InsZZ1

    Rotina customizada para inserção dos registros dos livros entre as tabelas SB1 e ZZ1 com informações adicionais.

    @type user function
    @author Edison Cake
    @since 11/11/2025
/*/
User Function InsZZ1()

    local oDialog as Object
    
    local oSayISBN as Object
    local cSayISBN := "ISBN:"
    local oGetISBN as Object
    local cGetISBN := Space(17)

    local oSayAutor as Object
    local cSayAutor := "Autor:"
    local oGetAutor as Object
    local cGetAutor := Space(150)

    local oSayEditora as Object
    local cSayEditora := "Editora:"
    local oGetEditora as Object
    local cGetEditora := Space(150)

    local oConfirm as Object

    oDialog := MSDialog():New(000, 000, 200, 350, "Informações adicionais:",,,.F.,,,,,,.T.,,,.T. )

    oSayISBN := TSAY():New(013, 010, {|| cSayISBN}, oDialog, , , , , , .T., , , 150, 075, , , , , ,)
    oGetISBN := TGET():New(010, 050, bSetGet(cGetISBN), oDialog, 100, 010, "@R 999-99-9999-999-9", , , /*10*/, , , , .T., /*15*/, , , , , /*20*/, , , , cGetISBN)

    oSayAutor := TSAY():New(033, 010, {|| cSayAutor}, oDialog, , , , , , .T., , , 150, 075, , , , , ,)
    oGetAutor := TGET():New(030, 050, bSetGet(cGetAutor), oDialog, 100, 010, "@!", , , /*10*/, , , , .T., /*15*/, , , , , /*20*/, , , , cGetAutor)
    oGetAutor:cF3 := "ZZ2"

    oSayEditora := TSAY():New(053, 010, {|| cSayEditora}, oDialog, , , , , , .T., , , 150, 075, , , , , ,)
    oGetEditora := TGET():New(050, 050, bSetGet(cGetEditora), oDialog, 100, 010, "@!", , , /*10*/, , , , .T., /*15*/, , , , , /*20*/, , , , cGetEditora)
    oGetEditora:cF3 := "ZZ3"

    oConfirm := TBUTTON():New(070, 010, "Confirmar", oDialog, {|| U_RecZZ1(alltrim(cGetISBN), cGetAutor, cGetEditora)}, 150, 010, , , , .T., , , , , , )

    oDialog:Activate()

Return

User Function (RecZZ1)
    // TODO
Return

User Function xPTO()

    RPCSETENV("99", "01", "admin", "admin", "EST")
    U_InsZZ1()
    
Return
