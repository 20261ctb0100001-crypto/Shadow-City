# Shadow City

Jogo 3D de mundo aberto em desenvolvimento com **Godot 4**, planejado para Android.

## Visão
Um simulador de vida em mundo aberto inspirado em cidades reais: exploração, veículos, lojas, personalização de personagem, casas, profissões e missões. O mundo será construído por regiões, com identidade própria para cada cidade.

## Protótipo atual no repositório

**Estado realista atual:** ainda é um protótipo de geometria procedural. As mudanças recentes melhoram céu, iluminação, sombras e fachadas, mas não equivalem a gráficos fotorrealistas nem a um jogo final. O projeto ainda não contém 8 GB de modelos e texturas; 8–10 GB é apenas a meta definida para a versão Android.
- Projeto Godot 4 com renderizador Mobile.
- Cena 3D principal e bairro procedural de teste.
- Personagem provisório em terceira pessoa.
- Câmera acompanhando o personagem.
- Ações de movimento por teclado e botões de toque na tela.
- Primeiro carro provisório com entrada/saída e condução básica usando os mesmos controles.
- Primeira loja de roupas interativa, com saldo inicial e compra de uma jaqueta de teste.
- Primeiras construções, uma casa de madeira, fachada de mercado e árvores.
- Casa inicial com interior mobiliado em área própria do mapa; o jogador pode entrar e sair pelo botão AÇÃO.
- Interações domésticas: descansar na cama, preparar comida na geladeira (custa $10) e tomar banho no chuveiro; as necessidades e o dinheiro são atualizados e salvos.
- Mapa ampliado com quatro zonas de referência: escola, hospital, bairro gastronômico e centro comercial.
- Interiores separados e acessíveis para escola, hospital, restaurante e centro comercial, com piso e paredes com colisão.
- Necessidades e dinheiro incluídos no salvamento local.
- Ajustes iniciais de apresentação com tonemapping cinematográfico, neblina leve, calçadas, faixas de pedestres e postes com iluminação.
- Primeira área identificada como Ponta Grossa, Paraná, Brasil.
- Primeiros animais ambientais: cachorro, gato, papagaio e cavalo, com movimento autônomo simples.
- Quatro moradores com nomes, profissões, personalidades, falas, aparência e velocidades diferentes.
- Primeira rotina diária dos moradores: deslocamento entre casa, local de trabalho e área de lazer conforme o horário do relógio do mundo.
- Primeiros veículos de trânsito autônomo circulando pelas avenidas: carros, um ônibus e motocicletas, com semáforo central e parada no sinal vermelho.
- Sistema inicial de trabalhos com objetivo físico: aceitar uma tarefa, seguir um marcador dourado pelo bairro e receber pagamento ao chegar ao destino.
- Carteira na tela que atualiza o dinheiro recebido pelos turnos.
- Sistema de necessidades com fome, energia e higiene, menu VIDA para comer, descansar e tomar banho.
- Salvamento local automático de dinheiro, posição, roupa e necessidades.
- Ciclo inicial de dia e noite com relógio na tela, mudança gradual da luz solar e iluminação ambiente.
- Iluminação direcional com sombras em quatro divisões, céu procedural, iluminação ambiente baseada no céu, materiais e colisões básicas.
- Fachadas com janelas em quatro lados e detalhes de cobertura nos prédios do distrito central.

## Próximas etapas
1. Executar o projeto no Godot 4 e corrigir problemas encontrados nos testes (ainda pendente; Godot não está disponível neste ambiente).
2. Melhorar personagem, câmera, animações e controles de toque.
3. Evoluir o carro provisório com física, sons e visual mais detalhado.
4. Evoluir os animais com modelos, animações, sons, necessidades e interações.
5. Evoluir o trânsito com cruzamentos, semáforos, ônibus, motos e regras de circulação.
6. Ampliar profissões, tarefas com objetivos no mapa, rotinas diárias, relações e diálogos dos moradores.
7. Expandir a loja com mais roupas, barbearia e personalização.
8. Substituir blocos provisórios por modelos 3D e materiais mais detalhados.
9. Criar novas regiões inspiradas em cidades reais, começando por bairros e pontos reconhecíveis.
10. Expandir os interiores e os serviços dos prédios públicos, com mais atividades e objetos interativos.
11. Adicionar modelos 3D profissionais, animações, sons e otimização gráfica.
12. Instalar Godot 4, testar o projeto, configurar exportação Android e gerar APK/AAB (ainda não realizado).

## Meta de qualidade e tamanho\n- Meta de tamanho do conteúdo final: **mínimo planejado de 8 GB e máximo de 10 GB**. Esse é um orçamento de conteúdo, não uma exigência de preencher espaço artificialmente.\n- Prioridade de produção: modelos 3D detalhados, texturas de alta resolução, animações, áudio, interiores e cidades variadas. Não reduzir a qualidade visual apenas para atingir um pacote pequeno.\n- A versão Android será planejada dentro desse orçamento. A versão de navegador continuará sendo uma compilação separada, pois navegadores e GitHub Pages têm limitações práticas para distribuir um jogo desse porte.\n- O desempenho será medido e otimizado sem remover detalhes indiscriminadamente; qualidade gráfica e desempenho serão tratados como objetivos separados.\n\nEste repositório contém um protótipo inicial em construção, não um jogo completo. Os sistemas precisam ser executados e testados no Godot e em dispositivos Android antes de serem considerados concluídos.

## Abrir
Importe este repositório no Godot 4 e execute `scenes/main.tscn`.
