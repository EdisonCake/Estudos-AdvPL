#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'

// 01. Uma rotina que solicite ao usuário que ele escreva seu nome, e após isso, apresente uma mensagem de boas vindas.
user function ex02001()

    local cMensagem := "Olá! Qual o seu nome?"
    local cResposta := ""

    cResposta := FwInputBox(cMensagem)
    MsgInfo("Legal! Muito prazer em te conhecer " + cResposta + ".", cResposta)

return 


// 02. Uma rotina que solicite ao usuário dois números. Após os dois serem preenchidos, o sistema fará a soma e apresentará o resultado.
user function ex02002()

    local nNumero01 := 0
    local nNumero02 := 0
    local nSoma     := 0

    nNumero01 := val(fwinputbox("olá! digite um número!"))
    nNumero02 := val(fwinputbox("agora, outro número!"))

    nSoma := nNumero01 + nNumero02

    MsgInfo("Aqui está a soma dos dois números: " + cvaltochar(nSoma) + ".")

return


// 03. Uma rotina que solicite ao usuário dois números, e após isso, verifique qual operação que o usuário quer fazer (adição, subtração, multiplicação, divisão).
user function ex02003()

    local nNumero01     := 0
    local nNumero02     := 0
    local nResultado    := 0
    local cSinal        := ""

    nNumero01 := val(fwinputbox("olá! digite o primeiro número"))
    nNumero02 := val(fwinputbox("agora, o segundo número"))
    cSinal    := alltrim(fwinputbox("qual operação quer realizar?"))

    if cSinal == "+"
        nResultado := nNumero01 + nNumero02
    elseif cSinal == "-"
        nResultado := nNumero01 - nNumero02
    elseif cSinal == "*"
        nResultado := nNumero01 * nNumero02
    elseif cSinal == "/"
        nResultado := nNumero01 / nNumero02
    else
        MsgStop("Inválido!")
    endif

    MsgInfo("Aqui está o resultado da sua operação: " + cvaltochar(nResultado) + ".")
return

// 04. Uma rotina em que seja exibida uma mensagem ao usuário, e o mesmo deverá interagir com a rotina (escolha livre, use sua criatividade!).
user function ex02004()

    local lRet      as logical

    lRet := msgyesno("Olá! Tudo bem com você?")

    if lRet 
        msginfo("Que legal! Que bom que está bem!")
    else
        msgstop("Ah... que pena... se eu puder ajudar, estou aqui!")
    endif

return

// 05. Uma rotina que leia uma palavra e conte quantas vogais tem. Após isso, implemente sua rotina para exibir quantas consoantes tem também.
user function ex02005()
    local cPalavra  := ""
    local cLetra    := ""
    local nContador := 0
    local nX        := 0
    local nY        := 0
    local aVogal    := {"a", "e", "i", "o", "u"}

    cPalavra := alltrim(lower(fwinputbox("olá! digite uma palavra!")))

    For nX := 1 to len(cPalavra)
        
        cLetra := substr(cPalavra, nX, 1)

        For nY := 1 to len(aVogal)
            if cLetra == aVogal[nY]
                nContador++
            endif
        Next
    Next

    if nContador < 1
        msgstop("sua palavra não possui vogais!")
    elseif nContador == 1
        msginfo("sua palavra possui " + cvaltochar(ncontador) + " vogal.")
    elseif nContador > 1
        msginfo("sua palavra possui " + cvaltochar(ncontador) + " vogais.")
    endif
return

// 06. Uma rotina em que o usuário coloque um número e o sistema informe se é par, se é ímpar ou se é zero.
user function ex02006()

    local nNumero := 0

    nNumero := val(fwinputbox("digite um numero:"))

    if nNumero == 0
        msginfo("você digitou o número zero!")
    elseif (nNumero % 2) == 0
        msginfo("o numero digitado é par!")
    else
        msginfo("o numero digitado é ímpar")
    endif
return

// 07. Uma rotina em que o usuário coloque um número e o sistema informa se o mesmo pode ser divisível por 5.
user function ex02007()

    local nNumero := 0

    nNumero := val(fwinputbox("olá! digite um número:"))

    if (nNumero % 5) == 0
        msginfo("o número " + cvaltochar(nNumero) + " é divisível por 5!")
    else
        msgstop("o número " + cvaltochar(nNumero) + " não é divisível por 5!")
    endif
return

// 08. Uma rotina em que o sistema gere um número aleatório de 0 a 10 e o usuário terá de adivinhar (vamos nos divertir com as máquinas).
user function ex02008()

    local nRandom   := 0
    local nUsuario  := 0
    local lLoop     := .t.

    while lLoop

        nRandom := randomize(1, 10)
        nUsuario := val(fwinputbox("olá. sorteei um número de 1 a 10... qual você acha que é?"))

        if nUsuario == nRandom
            msginfo("Parabéns! Você acertou!")
            if !(msgyesno("Tentar novamente?"))
                lLoop := .f.
            endif
        else
            msgstop("Opa... Não foi dessa vez!")
            if !(msgyesno("Tentar novamente?"))
                lLoop := .f.
            endif
        endif
    end do

return

// 09. Uma rotina em que o usuário possa responder uma pergunta pré-definida pelo desenvolvedor. O usuário deverá responder apenas "Sim" ou "Não". Gere um comportamento na rotina com base na resposta do usuário.
user function ex02009()

    local cMensagem := "Olá! Tudo bem com você?"
    local lGood     := .t.

    lGood := msgyesno(cmensagem)
    if lGood
        msginfo("Fico feliz em saber disso!")
    else
        msginfo("FIco triste em saber disso...")
    endif
return
