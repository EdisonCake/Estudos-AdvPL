## Projeto Gestão de Livros + ERP Protheus

• Objetivos:
    Catalogar todos os livros "em estoque", catalogar a lista de desejos e desenvolver fluxo entre os módulos do ERP para popular e/ou alterar tabelas padrões e personalizadas do sistema.

Tabelas customizadas:
ZZ1 -> Gestão de livros
ZZ2 -> Cadastro de autores
ZZ3 -> Cadastro de editoras

Tabelas padrões:
SB1 -> Cadastrar/registrar o livros
    -> Adicionar campo para registrar o código de barras (ISBN13)
    -> Adicionar validação de dígito verificador para novos cadastros

Fluxo:
• Ao cadastrar um livro novo na SB1, o cadastro resumido será copiado através de ponto de entrada para a tabela ZZ1.
• Após o cadastro, abrirá uma tela de "informações complementares", na qual adicionaremos o autor e a editora do livro.
• Ao confirmar, será gerado um registro na ZZ1, com a legenda "Lista de Compras".
• Ao dar entrada no saldo desse item (significa que "adquirimos" o mesmo), será adicionado 1 (um) ao estoque, e alterará a legenda para "em estoque".
• Haverá um botão/rotina que emprestará/devolverá o livro do/no estoque.