#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Manutenção de Autores"
Static cTabela := "ZZ2"

/*/{Protheus.doc} MVCZZ2

    Rotina customizada em MVC para manutenção na tabela ZZ2 -> Autores.

    @type user function
    @author Edison Cake
    @since 11/11/2025

/*/
User Function MVCZZ2()

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

    ADD OPTION aRotina TITLE "Incluir Autor" ACTION "VIEWDEF.MVCZZ2" OPERATION MODEL_OPERATION_INSERT ACCESS 0
    ADD OPTION ARotina TITLE "Alterar Autor" ACTION 'VIEWDEF.MVCZZ2' OPERATION MODEL_OPERATION_UPDATE ACCESS 0
    ADD OPTION ARotina TITLE "Excluir Autor" ACTION 'VIEWDEF.MVCZZ2' OPERATION MODEL_OPERATION_DELETE ACCESS 0

Return aRotina

Static Function ModelDef()

    Local oModel    
    Local oStruZZ2  := FWFormStruct(1, 'ZZ2')

    oModel := MPFormModel():New("ZZ2M")
    oModel:AddFields("ZZ2MASTER",,oStruZZ2)
    oModel:SetPrimaryKey({'ZZ2_FILIAL', 'ZZ2_ID'})
    oModel:SetDescription("Modelo de Gerenciamento de Autores")
    oModel:GetModel('ZZ2MASTER'):SetDescription("Gerenciamento de Autores")

Return oModel

Static Function ViewDef()

    Local oView     
    Local oModel    := ModelDef()
    Local oStruZZ2  := FwFormStruct(2, "ZZ2")

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField('VIEW_ZZ2', oStruZZ2, 'ZZ2MASTER')
    oView:CreateHorizontalBox("TELA", 100)
    oView:SetOwnerView("VIEW_ZZ2", "TELA")

Return oView
