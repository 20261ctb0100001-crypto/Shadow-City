# Shadow City

Jogo 3D de mundo aberto em desenvolvimento com **Godot 4**, planejado para Android.

## Visão
Um simulador de vida em mundo aberto inspirado em cidades reais: exploração, veículos, lojas, personalização de personagem, casas, profissões e missões. O mundo será construído por regiões, com identidade própria para cada cidade.

## Protótipo atual no repositório
- Projeto Godot 4 com renderizador Mobile.
- Cena 3D principal e bairro procedural de teste.
- Personagem provisório em terceira pessoa.
- Câmera acompanhando o personagem.
- Ações de movimento por teclado e botões de toque na tela.
- Primeiro carro provisório com entrada/saída e condução básica usando os mesmos controles.
- Primeira loja de roupas interativa, com saldo inicial e compra de uma jaqueta de teste.
- Primeiras construções, uma casa de madeira, fachada de mercado e árvores.
- Mapa ampliado com quatro zonas de referência: escola, hospital, bairro gastronômico e centro comercial.
- Sistema inicial de necessidades: fome, energia e higiene diminuem com o tempo; o jogador pode comer, descansar e tomar banho pelo menu VIDA.
- Necessidades e dinheiro incluídos no salvamento local.
- Ajustes iniciais de apresentação com tonemapping cinematográfico e neblina leve.
- Primeira área identificada como Ponta Grossa, Paraná, Brasil.
- Primeiros animais ambientais: cachorro, gato, papagaio e cavalo, com movimento autônomo simples.
- Quatro moradores com nomes, profissões, personalidades, falas, aparência e velocidades diferentes.
- Primeiros veículos de trânsito autônomo circulando pelas avenidas e semáforo central com fases alternadas; carros param no sinal vermelho antes do cruzamento.
- Sistema inicial de trabalhos com objetivo físico: aceitar uma tarefa, seguir um marcador dourado pelo bairro e receber pagamento ao chegar ao destino.
- Carteira na tela que atualiza o dinheiro recebido pelos turnos.
- Sistema de necessidades com fome, energia e higiene, menu VIDA para comer, descansar e tomar banho.
- Salvamento local automático de dinheiro, posição, roupa e necessidades.
- Ciclo inicial de dia e noite com relógio na tela, mudança gradual da luz solar e iluminação ambiente.
- Iluminação direcional, materiais e colisões básicas.

## Próximas etapas
1. Executar o projeto no Godot 4 e corrigir problemas encontrados nos testes (ainda pendente; Godot não está disponível neste ambiente).
2. Melhorar personagem, câmera, animações e controles de toque.
3. Evoluir o carro provisório com física, sons e visual mais detalhado.
4. Evoluir os animais com modelos, animações, sons, necessidades e interações.
5. Evoluir o trânsito com cruzamentos, semáforos, ônibus, motos e regras de circulação.
6. Ampliar profissões, tarefas com objetivos no mapa, rotina diária e diálogos dos moradores.
7. Expandir a loja com mais roupas, barbearia e personalização.
8. Substituir blocos provisórios por modelos 3D e materiais mais detalhados.
9. Criar novas regiões inspiradas em cidades reais, começando por bairros e pontos reconhecíveis.
10. Criar interiores acessíveis e interações funcionais para escola, hospital, restaurante e centro comercial.
11. Adicionar modelos 3D profissionais, animações, sons e otimização gráfica.
12. Instalar Godot 4, testar o projeto, configurar exportação Android e gerar APK/AAB (ainda não realizado).

Este repositório contém um protótipo inicial em construção, não um jogo completo. Os sistemas precisam ser executados e testados no Godot e em dispositivos Android antes de serem considerados concluídos.

## Abrir
Importe este repositório no Godot 4 e execute `scenes/main.tscn`.
