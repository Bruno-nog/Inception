# Documentação do Desenvolvedor – Inception
## Propósito
Este documento explica o design técnico, arquitetura e escolhas de implementação do projeto Inception. É destinado a desenvolvedores e avaliadores que querem entender como e por que a infraestrutura foi construída dessa forma.
## Visão Geral da Arquitetura
O projeto usa Docker Compose para orquestrar múltiplos containers:
* NGINX: Proxy reverso HTTPS
* WordPress: Container de aplicação PHP-FPM
* MariaDB: Servidor de banco de dados
Cada serviço:
* Roda em seu próprio container
* Compartilha uma rede Docker privada
* Usa volumes para dados persistentes
## Responsabilidades dos Containers
### NGINX
* Termina TLS (HTTPS)
* Escuta na porta 443
* Faz proxy de requisições PHP para WordPress (php-fpm)
* Usa um certificado auto-assinado
### WordPress
* Roda apenas PHP-FPM (sem servidor web)
* Expõe porta 9000 internamente
* Conecta ao MariaDB usando credenciais
* Instala WordPress via script de entrypoint
### MariaDB
* Inicializa banco de dados e usuário
* Armazena dados do WordPress
* Usa um volume persistente para `/var/lib/mysql`
## Design dos Dockerfiles
Cada serviço tem seu próprio Dockerfile com os seguintes princípios:
* Baseado em Debian (versão explícita)
* Pacotes instalados mínimos
* Processo principal único por container
* Script de entrypoint para inicialização
Exemplo (WordPress):
* Instalar PHP e extensões
* Configurar php-fpm para escutar em TCP (9000)
* Iniciar php-fpm em modo foreground
## Rede
### Rede Docker (Bridge)
Todos os containers se comunicam através de uma rede bridge Docker customizada definida em `docker-compose.yml`.
Vantagens:
* Resolução DNS automática (nomes de serviço)
* Isolamento de rede
* Nenhuma exposição de serviços internos ao host
## Volumes
Volumes Docker são usados em vez de bind mounts:
* MariaDB: persistência de banco de dados
* WordPress: persistência de arquivos do site
Benefícios:
* Caminhos independentes do host
* Melhor portabilidade
* Mais seguro para ambientes de avaliação
## Gerenciamento de Secrets
O projeto inclui um diretório `secrets/` para armazenar dados sensíveis:
* Senhas do banco de dados
* Credenciais de admin do WordPress
Escolha de design:
* Secrets não são commitados no repositório
* Carregados em runtime via Docker secrets ou substituição de env
Isso segue as melhores práticas de segurança e está alinhado com os requisitos do projeto.
## Seções de Comparação
### Máquinas Virtuais vs Docker
| Máquinas Virtuais | Docker |
|---|---|
| SO pesado por VM | Containers leves |
| Inicialização lenta | Inicialização rápida |
| Alto uso de recursos | Uso eficiente de recursos |
| Isolamento de SO completo | Isolamento em nível de processo |
### Secrets vs Variáveis de Ambiente
| Secrets | Variáveis de Ambiente |
|---|---|
| Não expostos em `docker inspect` | Facilmente visíveis |
| Armazenados com segurança | Risco de vazamento |
| Recomendado para credenciais | OK para config não sensível |
### Rede Docker vs Rede Host
| Rede Docker | Rede Host |
|---|---|
| Containers isolados | Sem isolamento |
| DNS automático | Manipulação manual de IP |
| Mais seguro por padrão | Riscos de segurança |
### Volumes Docker vs Bind Mounts
| Volumes | Bind Mounts |
|---|---|
| Gerenciados pelo Docker | Depende de caminhos do host |
| Portáveis | Específicos do host |
| Mais limpo para produção | Melhor para dev local |
## Dicas de Debugging
Comandos úteis:

```bash
docker ps
docker logs nginx
docker logs wordpress
docker exec -it wordpress sh
```

## Notas Finais
O projeto prioriza:
* Segurança (HTTPS, isolamento, secrets)
* Manutenibilidade
* Conformidade com as regras de avaliação do Inception da 42
Todas as escolhas de design foram feitas para balancear simplicidade, correção e valor pedagógico.

## English

# Developer Documentation – Inception

## Purpose

This document explains the **technical design, architecture, and implementation choices** of the Inception project. It is intended for developers and evaluators who want to understand *how* and *why* the infrastructure was built this way.

---

## Architecture Overview

The project uses **Docker Compose** to orchestrate multiple containers:

* **NGINX**: HTTPS reverse proxy
* **WordPress**: PHP-FPM application container
* **MariaDB**: Database server

Each service:

* Runs in its own container
* Shares a private Docker network
* Uses volumes for persistent data

---

## Container Responsibilities

### NGINX

* Terminates TLS (HTTPS)
* Listens on port 443
* Proxies PHP requests to WordPress (php-fpm)
* Uses a self-signed certificate

### WordPress

* Runs PHP-FPM only (no web server)
* Exposes port 9000 internally
* Connects to MariaDB using credentials
* Installs WordPress via entrypoint script

### MariaDB

* Initializes database and user
* Stores WordPress data
* Uses a persistent volume for `/var/lib/mysql`

---

## Dockerfile Design

Each service has its own Dockerfile with the following principles:

* Based on **Debian** (explicit version)
* Minimal installed packages
* Single main process per container
* Entrypoint script for initialization

Example (WordPress):

* Install PHP and extensions
* Configure php-fpm to listen on TCP (9000)
* Start php-fpm in foreground mode

---

## Networking

### Docker Network (Bridge)

All containers communicate through a **custom Docker bridge network** defined in `docker-compose.yml`.

Advantages:

* Automatic DNS resolution (service names)
* Network isolation
* No exposure of internal services to host

---

## Volumes

Docker volumes are used instead of bind mounts:

* **MariaDB**: database persistence
* **WordPress**: site files persistence

Benefits:

* Host-independent paths
* Better portability
* Safer for evaluation environments

---

## Secrets Management

The project includes a `secrets/` directory to store sensitive data:

* Database passwords
* WordPress admin credentials

Design choice:

* Secrets are **not committed** to the repository
* Loaded at runtime via Docker secrets or env substitution

This follows security best practices and aligns with the project requirements.

---

## Comparison Sections

### Virtual Machines vs Docker

| Virtual Machines    | Docker                   |
| ------------------- | ------------------------ |
| Heavy OS per VM     | Lightweight containers   |
| Slow startup        | Fast startup             |
| High resource usage | Efficient resource usage |
| Full OS isolation   | Process-level isolation  |

---

### Secrets vs Environment Variables

| Secrets                         | Environment Variables       |
| ------------------------------- | --------------------------- |
| Not exposed in `docker inspect` | Easily visible              |
| Stored securely                 | Risk of leakage             |
| Recommended for credentials     | OK for non-sensitive config |

---

### Docker Network vs Host Network

| Docker Network      | Host Network       |
| ------------------- | ------------------ |
| Isolated containers | No isolation       |
| Automatic DNS       | Manual IP handling |
| Safer by default    | Security risks     |

---

### Docker Volumes vs Bind Mounts

| Volumes                | Bind Mounts           |
| ---------------------- | --------------------- |
| Managed by Docker      | Depends on host paths |
| Portable               | Host-specific         |
| Cleaner for production | Better for local dev  |

---

## Debugging Tips

Useful commands:

```bash
docker ps
docker logs nginx
docker logs wordpress
docker exec -it wordpress sh
```

---

## Final Notes

The project prioritizes:

* Security (HTTPS, isolation, secrets)
* Maintainability
* Compliance with 42 Inception evaluation rules

All design choices were made to balance simplicity, correctness, and pedagogical value.
