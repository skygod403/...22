import discord
import os
import uuid
import asyncio
import requests
import base64
from datetime import datetime, timedelta

# ================================================================
# SKY HUB — BOT DE KEYS (VERSÃO SIMPLES E FUNCIONAL)
# ================================================================

DISCORD_TOKEN = os.getenv("DISCORD_TOKEN")
GITHUB_TOKEN  = os.getenv("GITHUB_TOKEN")

GITHUB_USER = "skygod403"
GITHUB_REPO = "...22"
GITHUB_FILE = "keys_validas.txt"

COMANDO = "/sky.key.C"

# Guarda validade em memória
keys_ativas = {}

# ================================================================
# GITHUB
# ================================================================

def _headers():
    return {
        "Authorization": f"token {GITHUB_TOKEN}",
        "Accept": "application/vnd.github.v3+json"
    }

def _url():
    return f"https://api.github.com/repos/{GITHUB_USER}/{GITHUB_REPO}/contents/{GITHUB_FILE}"

def pegar_sha():
    r = requests.get(_url(), headers=_headers())
    return r.json().get("sha") if r.status_code == 200 else None

def salvar_keys_github():
    linhas = list(keys_ativas.keys())
    conteudo = "\n".join(linhas)

    encoded = base64.b64encode(conteudo.encode()).decode()
    sha = pegar_sha()

    body = {
        "message": "bot: update keys",
        "content": encoded
    }

    if sha:
        body["sha"] = sha

    requests.put(_url(), headers=_headers(), json=body)

# ================================================================
# KEY
# ================================================================

def nova_key():
    def p():
        return uuid.uuid4().hex[:4].upper()
    return f"SKY-{p()}-{p()}-{p()}"

def limpar_expiradas():
    agora = datetime.utcnow()
    expiradas = [k for k, v in keys_ativas.items() if v < agora]

    for k in expiradas:
        del keys_ativas[k]

    if expiradas:
        salvar_keys_github()

# ================================================================
# DISCORD
# ================================================================

intents = discord.Intents.default()
intents.message_content = True
client = discord.Client(intents=intents)

@client.event
async def on_ready():
    print(f"[BOT] Online como {client.user}")
    client.loop.create_task(task_limpeza())

@client.event
async def on_message(msg):
    if msg.author.bot:
        return

    if msg.content.strip().lower() != COMANDO.lower():
        return

    user = msg.author

    # Verifica se já tem key ativa
    for key, expira in keys_ativas.items():
        if expira > datetime.utcnow():
            # Já existe uma ativa
            await user.send(
                f"🔑 Você já tem uma key ativa:\n```{key}```\n⏳ Expira em 12h"
            )
            await msg.add_reaction("✅")
            return

    # Gera nova
    key = nova_key()
    expira = datetime.utcnow() + timedelta(hours=12)

    keys_ativas[key] = expira
    salvar_keys_github()

    await user.send(
        f"🔑 SKY HUB — Key Gerada:\n```{key}```\n⏳ Válida por 12 horas"
    )

    await msg.add_reaction("✅")
    print(f"[BOT] Key criada: {key}")

# ================================================================
# LIMPEZA AUTOMÁTICA
# ================================================================

async def task_limpeza():
    await client.wait_until_ready()

    while not client.is_closed():
        await asyncio.sleep(3600)
        limpar_expiradas()

# ================================================================
client.run(DISCORD_TOKEN)
