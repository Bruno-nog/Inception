# Documentação do Usuário – Inception
## Visão Geral
Este documento explica como **usar e executar** o projeto Inception. É destinado a usuários, avaliadores ou qualquer pessoa que queira lançar a infraestrutura sem mergulhar nos detalhes internos de implementação.
O projeto configura uma pequena infraestrutura web usando **Docker e Docker Compose**, incluindo:
* NGINX (proxy reverso HTTPS)
* WordPress (PHP-FPM)
* MariaDB (banco de dados)
Todos os serviços rodam em **containers separados** e se comunicam através de uma rede Docker.
---
## Pré-requisitos
Antes de executar o projeto, certifique-se de ter:
* Docker
* Docker Compose (ou plugin docker compose)
* GNU Make
Para verificar:
```bash
docker --version
docker-compose --version || docker compose version
make --version
```
---
## Estrutura do Projeto
```
.
├── Makefile
├── secrets/
├── srcs/
│   ├── docker-compose.yml
│   └── requirements/
│       ├── nginx/
│       ├── wordpress/
│       └── mariadb/
├── README.md
├── user_doc.md
└── dev_doc.md
```
---
## Como Executar o Projeto
A partir da raiz do repositório:
### Construir e iniciar containers
```bash
make up
```
Este comando:
* Constrói as imagens Docker
* Cria uma rede Docker
* Inicia todos os containers em modo detached
---
### Parar containers
```bash
make down
```
---
### Reconstruir tudo (estado limpo)
```bash
make re
```
---
## Acessando o Site
O container NGINX expõe **HTTPS na porta 443**.
A partir da máquina host:
```bash
https://localhost
```
No primeiro acesso, o WordPress redirecionará para a página de instalação:
```
https://localhost/wp-admin/install.php
```
---
## Problemas Comuns
### 502 Bad Gateway
* WordPress (php-fpm) pode ainda não estar pronto
* MariaDB pode ainda estar inicializando
Solução:
```bash
docker logs wordpress
docker logs mariadb
```
Aguarde alguns segundos e atualize a página.
---
### Não consigo acessar da VM
Se sua VM não tem navegador:
```bash
curl -k https://localhost
```
Um redirecionamento `302` ou resposta HTML confirma que o site está rodando corretamente.
---
## Pasta Secrets
O diretório `secrets/` está intencionalmente vazio por padrão.
Ele existe para demonstrar o tratamento seguro de dados sensíveis (senhas, credenciais) usando Docker secrets em vez de valores hardcoded ou variáveis de ambiente.
Não commitar secrets é **esperado e correto**.
---
## Notas para Avaliação
* Containers rodam um processo principal cada
* HTTPS está habilitado via NGINX
* Nenhum serviço roda diretamente no host
* Persistência de dados é tratada via volumes Docker
---
## Limpando o Ambiente
Para remover todos os containers, volumes e redes criados pelo projeto:
```bash
make fclean
```

## English

# User Documentation – Inception

## Overview

This document explains how to **use and run** the Inception project. It is intended for users, evaluators, or anyone who wants to launch the infrastructure without diving into the internal implementation details.

The project sets up a small web infrastructure using **Docker and Docker Compose**, including:

* NGINX (HTTPS reverse proxy)
* WordPress (PHP-FPM)
* MariaDB (database)

All services run in **separate containers** and communicate through a Docker network.

---

## Prerequisites

Before running the project, make sure you have:

* Docker
* Docker Compose (or docker compose plugin)
* GNU Make

To check:

```bash
docker --version
docker-compose --version || docker compose version
make --version
```

---

## Project Structure

```
.
├── Makefile
├── secrets/
├── srcs/
│   ├── docker-compose.yml
│   └── requirements/
│       ├── nginx/
│       ├── wordpress/
│       └── mariadb/
├── README.md
├── user_doc.md
└── dev_doc.md
```

---

## How to Run the Project

From the root of the repository:

### Build and start containers

```bash
make up
```

This command:

* Builds Docker images
* Creates a Docker network
* Starts all containers in detached mode

---

### Stop containers

```bash
make down
```

---

### Rebuild everything (clean state)

```bash
make re
```

---

## Accessing the Website

The NGINX container exposes **HTTPS on port 443**.

From the host machine:

```bash
https://localhost
```

On first access, WordPress will redirect to the installation page:

```
https://localhost/wp-admin/install.php
```

---

## Common Issues

### 502 Bad Gateway

* WordPress (php-fpm) may not be ready yet
* MariaDB may still be initializing

Solution:

```bash
docker logs wordpress
docker logs mariadb
```

Wait a few seconds and refresh.

---

### Cannot access from VM

If your VM has no browser:

```bash
curl -k https://localhost
```

A `302` redirect or HTML response confirms the site is running correctly.

---

## Secrets Folder

The `secrets/` directory is intentionally empty by default.

It exists to demonstrate secure handling of sensitive data (passwords, credentials) using Docker secrets instead of hardcoded values or environment variables.

Not committing secrets is **expected and correct**.

---

## Notes for Evaluation

* Containers run one main process each
* HTTPS is enabled via NGINX
* No services run directly on the host
* Data persistence is handled via Docker volumes

---

## Cleaning the Environment

To remove all containers, volumes, and networks created by the project:

```bash
make fclean
```
