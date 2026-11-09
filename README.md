# neo4j-loja-virtual

Banco de dados em grafos de uma **loja virtual**, feito em Neo4j para um trabalho acadêmico sobre bancos de dados orientados a grafos.

O banco tem milhares de nós e relacionamentos: clientes, pedidos, produtos, categorias, marcas, fornecedores, cidades, cupons e avaliações.

## Arquivos

| Arquivo | O que faz |
|---|---|
| `loja-virtual.cypher` | Cria o banco inteiro: restrições, catálogo, clientes, pedidos, itens, cupons, avaliações e indicações |
| `consultas-demo.cypher` | 10 consultas prontas para explorar o banco (recomendações, faturamento, rede de indicações etc.) |

## Modelo de dados

```
(Cliente)-[:COMPROU]->(Pedido)-[:CONTEM]->(Produto)-[:PERTENCE_A]->(Categoria)
(Produto)-[:DA_MARCA]->(Marca)
(Produto)-[:FORNECIDO_POR]->(Fornecedor)
(Cliente)-[:MORA_EM]->(Cidade)-[:EM]->(Estado)
(Cliente)-[:AVALIOU {nota, comentario}]->(Produto)
(Pedido)-[:USOU_CUPOM]->(Cupom)
(Cliente)-[:INDICOU]->(Cliente)
```

## Como rodar

1. Crie uma conta gratuita em [console.neo4j.io](https://console.neo4j.io) e uma instância **AuraDB Free**.
2. Abra a ferramenta **Query** (em português: **Consulta**).
3. Cole o conteúdo de `loja-virtual.cypher` e execute. Os comandos são separados por `;`.
4. Se só o primeiro comando rodar, execute um bloco de cada vez, na ordem do arquivo.
5. Teste as consultas de `consultas-demo.cypher`.

## Exemplo

Quais produtos a Ana comprou?

```cypher
MATCH (c:Cliente {nome: 'Ana'})-[:COMPROU]->(:Pedido)-[:CONTEM]->(p:Produto)
RETURN p.nome
```

## Observações

- Os dados são fictícios e gerados por fórmulas, então o resultado é sempre o mesmo.
- O plano gratuito do Aura aceita até 200 mil nós e 400 mil relacionamentos, e este banco usa uma pequena parte disso.
- Para recomeçar do zero, rode `MATCH (n) DETACH DELETE n;` (apaga tudo).
