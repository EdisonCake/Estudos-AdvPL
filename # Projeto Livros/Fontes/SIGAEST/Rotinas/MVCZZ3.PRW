#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Manutenção de Editoras"
Static cTabela := "ZZ3"

/*/{Protheus.doc} MVCZZ3

    Rotina customizada em MVC para manutenção na tabela ZZ3 -> Editoras.

    @type user function
    @author Edison Cake
    @since 11/11/2025

/*/
User Function MVCZZ3()

    Local aArea     := GetArea()
    Local oBrowse   as Object
    Local aRotina   := {}

    aRotina := MenuDef()

    oBrowse := FwMBrowse():New()
    oBrowse:SetAlias(cTabela)
    oBrowse:SetDescription(cTitulo)
    oBrowse:DisableDetails()

    oBrowse:Activate()
    RestArea(aArea)

Return 

Static Function MenuDef()

    Local aRotina := {}

    ADD OPTION aRotina TITLE "Incluir Editora" ACTION "VIEWDEF.MVCZZ3" OPERATION MODEL_OPERATION_INSERT ACCESS 0
    ADD OPTION ARotina TITLE "Alterar Editora" ACTION 'VIEWDEF.MVCZZ3' OPERATION MODEL_OPERATION_UPDATE ACCESS 0
    ADD OPTION ARotina TITLE "Excluir Editora" ACTION 'VIEWDEF.MVCZZ3' OPERATION MODEL_OPERATION_DELETE ACCESS 0

Return aRotina

Static Function ModelDef()

    Local oModel    
    Local oStruZZ3  := FWFormStruct(1, 'ZZ3')

    oModel := MPFormModel():New("ZZ3M")
    oModel:AddFields("ZZ3MASTER",,oStruZZ3)
    oModel:SetPrimaryKey({'ZZ3_FILIAL', 'ZZ3_ID'})
    oModel:SetDescription("Modelo de Gerenciamento de Editoras")
    oModel:GetModel('ZZ3MASTER'):SetDescription("Gerenciamento de Editoras")

Return oModel

Static Function ViewDef()

    Local oView     
    Local oModel    := ModelDef()
    Local oStruZZ3  := FwFormStruct(2, "ZZ3")

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField('VIEW_ZZ3', oStruZZ3, 'ZZ3MASTER')
    oView:CreateHorizontalBox("TELA", 100)
    oView:SetOwnerView("VIEW_ZZ3", "TELA")

Return oView
