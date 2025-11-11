#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Gerenciamento de Livros"
Static cTabela := "ZZ1"

/*/{Protheus.doc} MVCZZ1

    Rotina customizada em MVC para manutenção na tabela ZZ1 -> Gerenciamento de Livros.

    @type user function
    @author Edison Cake
    @since 11/11/2025

/*/
User Function MVCZZ1()

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

    ADD OPTION aRotina TITLE "Visualizar Livro" ACTION "VIEWDEF.MVCZZ1" OPERATION MODEL_OPERATION_VIEW ACCESS 0

Return aRotina

Static Function ModelDef()

    Local oModel    
    Local oStruZZ1  := FWFormStruct(1, 'ZZ1')

    oModel := MPFormModel():New("ZZ1M")
    oModel:AddFields("ZZ1MASTER",,oStruZZ1)
    oModel:SetPrimaryKey({'ZZ1_FILIAL', 'ZZ1_ID'})
    oModel:SetDescription("Modelo de Gerenciamento de Livros")
    oModel:GetModel('ZZ1MASTER'):SetDescription("Gerenciamento de Livros")

Return oModel

Static Function ViewDef()

    Local oView     
    Local oModel    := ModelDef()
    Local oStruZZ1  := FwFormStruct(2, "ZZ1")

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField('VIEW_ZZ1', oStruZZ1, 'ZZ1MASTER')
    oView:CreateHorizontalBox("TELA", 100)
    oView:SetOwnerView("VIEW_ZZ1", "TELA")

Return oView
