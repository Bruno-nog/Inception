# Inception

Inception é um projeto de administração de sistemas e DevOps cujo objetivo é projetar, construir e implantar uma pilha web completa usando **Docker** e **Docker Compose**. O projeto foca em compreender containerização, isolamento de serviços, redes, volumes e práticas de segurança.

A pilha é composta por três serviços principais:

* **NGINX** atuando como proxy reverso com **TLS (HTTPS)**
* **WordPress** rodando com **PHP-FPM**
* **MariaDB** como backend de banco de dados

Cada serviço roda em seu próprio container, construído a partir de um Dockerfile customizado, e todos os containers se comunicam através de uma rede Docker dedicada.

O objetivo não é apenas fazer os serviços funcionarem, mas entender *por que* eles são construídos dessa forma e como o Docker se compara a outras abordagens de infraestrutura.

---

## Instruções

### Requisitos

* Docker
* Docker Compose
* Ambiente Linux (recomendado)

### Estrutura do Projeto

```
.
├── Makefile
├── secrets/
├── srcs/
│   ├── docker-compose.yml
│   ├── .env
│   └── requirements/
│       ├── nginx/
│       ├── wordpress/
│       └── mariadb/
```

### Construir e Executar

A partir da raiz do repositório:

```bash
make up
```

Para parar e limpar os containers:

```bash
make down
```

O site estará acessível em:

```
https://localhost
```

⚠️ Um certificado auto-assinado é usado, então o navegador pode mostrar um aviso de segurança.

---

## Docker e Design de Arquitetura

### Por que Docker?

Docker permite executar cada serviço em um ambiente isolado com suas próprias dependências, configuração e ciclo de vida. Isso evita conflitos de dependências e torna o sistema reproduzível em qualquer máquina.

Cada serviço:

* Tem seu próprio **Dockerfile**
* Roda como um **container** separado
* Comunica-se apenas através de **redes** definidas

### Fontes Incluídas no Projeto

* Imagens base oficiais do Debian
* Pacotes oficiais do NGINX, PHP e MariaDB
* WordPress baixado e configurado na inicialização do container

Nenhuma imagem pré-construída é usada; tudo é construído localmente para garantir controle total e compreensão.

---

## Comparações Técnicas

### Máquinas Virtuais vs Docker

**Máquinas Virtuais**:

* Incluem um sistema operacional completo
* Mais pesadas (mais uso de RAM e CPU)
* Inicialização mais lenta
* Isolamento forte

**Containers Docker**:

* Compartilham o kernel do host
* Leves e rápidos
* Iniciam em segundos
* Ideais para microserviços

➡️ Docker foi escolhido por eficiência, simplicidade e práticas modernas de DevOps.

---

### Secrets vs Variáveis de Ambiente

**Variáveis de Ambiente**:

* Adequadas para configuração não sensível
* Fáceis de injetar via `.env`
* Visíveis para o runtime do container

**Secrets**:

* Destinados a dados sensíveis (senhas, chaves)
* Não devem ser commitados no Git
* Armazenados fora do controle de versão

➡️ Este projeto usa `.env` por simplicidade, enquanto o diretório `secrets/` existe para respeitar as melhores práticas e requisitos do projeto. Secrets intencionalmente não são rastreados.

---

### Rede Docker vs Rede Host

**Rede Host**:

* Containers compartilham a pilha de rede do host
* Menos isolamento
* Maior risco de conflitos de porta

**Rede Docker**:

* Rede virtual isolada
* Containers se comunicam por nome de serviço
* Melhor segurança e clareza

➡️ Uma rede bridge Docker customizada é usada para isolar serviços e permitir comunicação inter-container limpa.

---

### Volumes Docker vs Bind Mounts

**Bind Mounts**:

* Mapeamento direto para o sistema de arquivos do host
* Caminhos dependentes do host
* Menos portável

**Volumes Docker**:

* Gerenciados pelo Docker
* Persistentes e portáveis
* Mais seguros e limpos

➡️ Volumes são usados para dados do banco de dados e WordPress para garantir persistência através de reinicializações de container.

---

## Recursos

* Documentação do Docker: [https://docs.docker.com/](https://docs.docker.com/)
* Docker Compose: [https://docs.docker.com/compose/](https://docs.docker.com/compose/)
* Documentação do NGINX: [https://nginx.org/en/docs/](https://nginx.org/en/docs/)
* Documentação do WordPress: [https://wordpress.org/documentation/](https://wordpress.org/documentation/)
* Documentação do PHP-FPM: [https://www.php.net/manual/en/install.fpm.php](https://www.php.net/manual/en/install.fpm.php)

### Uso de IA

IA foi usada como **assistente de aprendizado e debugging**, principalmente para:

* Entender conceitos de Docker e redes
* Debugar problemas de comunicação entre containers
* Esclarecer erros de configuração

Todas as decisões de design, implementações e validação final foram realizadas pelo autor.

---

## Notas Adicionais

Este projeto enfatiza compreensão sobre automação. Cada escolha de configuração foi feita intencionalmente para alinhar com os critérios de avaliação do currículo da 42 e para construir uma base sólida em infraestrutura baseada em containers.

## English

# Inception

Inception is a system administration and DevOps project whose goal is to design, build, and deploy a complete web stack using **Docker** and **Docker Compose**. The project focuses on understanding containerization, service isolation, networking, volumes, and security best practices.

The stack is composed of three main services:

* **NGINX** acting as a reverse proxy with **TLS (HTTPS)**
* **WordPress** running with **PHP-FPM**
* **MariaDB** as the database backend

Each service runs in its own container, built from a custom Dockerfile, and all containers communicate through a dedicated Docker network.

The objective is not only to make the services work, but to understand *why* they are built this way and how Docker compares to other infrastructure approaches.

---

## Instructions

### Requirements

* Docker
* Docker Compose
* Linux environment (recommended)

### Project Structure

```
.
├── Makefile
├── secrets/
├── srcs/
│   ├── docker-compose.yml
│   ├── .env
│   └── requirements/
│       ├── nginx/
│       ├── wordpress/
│       └── mariadb/
```

### Build and Run

From the root of the repository:

```bash
make up
```

To stop and clean the containers:

```bash
make down
```

The website will be accessible at:

```
https://localhost
```

⚠️ A self-signed certificate is used, so the browser may show a security warning.

---

## Docker and Architecture Design

### Why Docker?

Docker allows running each service in an isolated environment with its own dependencies, configuration, and lifecycle. This avoids dependency conflicts and makes the system reproducible on any machine.

Each service:

* Has its own **Dockerfile**
* Runs as a separate **container**
* Communicates only through defined **networks**

### Sources Included in the Project

* Official Debian base images
* Official NGINX, PHP, and MariaDB packages
* WordPress downloaded and configured at container startup

No prebuilt images are used; everything is built locally to ensure full control and understanding.

---

## Technical Comparisons

### Virtual Machines vs Docker

**Virtual Machines**:

* Include a full operating system
* Heavier (more RAM and CPU usage)
* Slower startup
* Strong isolation

**Docker Containers**:

* Share the host kernel
* Lightweight and fast
* Start in seconds
* Ideal for microservices

➡️ Docker was chosen for efficiency, simplicity, and modern DevOps practices.

---

### Secrets vs Environment Variables

**Environment Variables**:

* Suitable for non-sensitive configuration
* Easy to inject via `.env`
* Visible to the container runtime

**Secrets**:

* Intended for sensitive data (passwords, keys)
* Must not be committed to Git
* Stored outside version control

➡️ This project uses `.env` for simplicity, while the `secrets/` directory exists to respect best practices and project requirements. Secrets are intentionally not tracked.

---

### Docker Network vs Host Network

**Host Network**:

* Containers share the host’s network stack
* Less isolation
* Higher risk of port conflicts

**Docker Network**:

* Isolated virtual network
* Containers communicate by service name
* Better security and clarity

➡️ A custom Docker bridge network is used to isolate services and allow clean inter-container communication.

---

### Docker Volumes vs Bind Mounts

**Bind Mounts**:

* Direct mapping to host filesystem
* Host-dependent paths
* Less portable

**Docker Volumes**:

* Managed by Docker
* Persistent and portable
* Safer and cleaner

➡️ Volumes are used for database and WordPress data to ensure persistence across container restarts.

---

## Resources

* Docker Documentation: [https://docs.docker.com/](https://docs.docker.com/)
* Docker Compose: [https://docs.docker.com/compose/](https://docs.docker.com/compose/)
* NGINX Documentation: [https://nginx.org/en/docs/](https://nginx.org/en/docs/)
* WordPress Documentation: [https://wordpress.org/documentation/](https://wordpress.org/documentation/)
* PHP-FPM Documentation: [https://www.php.net/manual/en/install.fpm.php](https://www.php.net/manual/en/install.fpm.php)

### Use of AI

AI was used as a **learning and debugging assistant**, mainly for:

* Understanding Docker and networking concepts
* Debugging container communication issues
* Clarifying configuration errors

All design decisions, implementations, and final validation were performed by the author.

---

## Additional Notes

This project emphasizes understanding over automation. Every configuration choice was made intentionally to align with the evaluation criteria of the 42 curriculum and to build a solid foundation in container-based infrastructure.
