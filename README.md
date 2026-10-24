# ZYON Piano

Painel Luau com busca e 11 músicas do catálogo público do TALENTLESS. Cada clique toca a próxima nota ou acorde.

Execute zyon-piano.lua, escolha uma música, ative o piano e clique em TOCAR PRÓXIMA. O painel baixa as notas do servidor original na primeira seleção e mantém os dados em memória. É necessária conexão com esse servidor.

Os arquivos de música são lidos como dados, sem loadstring. As sequências não estão incluídas neste repositório.

## Carregador curto

Repositorio: https://github.com/invisibilidade6-byte/zyon-piano

Execute o conteudo de loader.lua ou use:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/invisibilidade6-byte/zyon-piano/main/zyon-piano.lua", true))()
```

## Limites

A reprodução depende de keypress/keyrelease no executor e do foco do piano. Compatibilidade com Solara e Roblox ainda não foi testada. O ritmo segue os cliques; as durações usam o campo do painel. Pedal e dinâmica MIDI não são importados. Notas que compartilham tecla física (a/A) são rearticuladas, o que pode encurtar a primeira nota.

## Verificação

Sintaxe Lua verificada com luaparse. Os 11 arquivos foram inspecionados estaticamente: comandos reconhecidos, entre 127 e 3653 etapas. Sem teste no jogo. O relatório registra 20 acordes de Unravel que compartilham tecla física; o painel os rearticula.

## Fonte

https://github.com/hellohellohell012321/TALENTLESS

Implementação própria do painel e do leitor; metadados apontam aos arquivos publicados pelo autor. O catálogo completo da distribuição ofuscada não está incluído.
