import discord
import os
import uuid
import asyncio
import requests
import base64
from datetime import datetime, timedelta

# ====================================================
# SKY HUB — BOT DE KEY (GITHUB SALVA SÓ A KEY)
# ====================================================

DISCORD_TOKEN = os.getenv("DISCORD_TOKEN")
GITHUB_TOKEN  = os.getenv("GITHUB_TOKEN")

GITHUB_USER = "skygod403"
GITHUB_REPO = "...22"
GITHUB_FILE = "keys_validas.txt"

COMANDO = "/sky.key.C"

# ====================================================
# ARMAZENAMENTO EM MEMÓRIA (validade 12h)
# ====================================================

keys_ativas = {}  # user_id : (key, expira)

# ====================================================
# GITHUB
# ====================================================

def headers():
    return {
        "Authorization": f"token {GITHUB_TOKEN}",
        "Accept": "application/vnd.github.v3+json"
    }

def url():
    return f"https://api.github.com/repos/{GITHUB_USER}/{GITHUB_REPO}/contents/{GITHUB_FILE}"

def pegar_sha():
    r = requests.get(url(), headers=headers())
    if r.status_code == 200:
        return r.json()["sha"]
    return None

def salvar_github():
    # Salva somente as KEYS (uma por linha)
    linhas = [dados[0] for dados in keys_ativas.values()]
    conteudo = "\n".join(linhas)

    encoded = base64.b64encode(conteudo.encode()).decode()
    sha = pegar_sha()

    body = {
        "message": "update keys",
        "content": encoded
    }

    if sha:
        body["sha"] = sha

    requests.put(url(), headers=headers(), json=body)

# ====================================================
# KEY
# ====================================================

def gerar_key():
    def p():
        return uuid.uuid4().hex[:4].upper()
    return f"SKY-{p()}-{p()}-{p()}"

def limpar_expiradas():
    agora = datetime.utcnow()
    removidos = []

    for uid in list(keys_ativas.keys()):
        key, expira = keys_ativas[uid]
        if expira < agora:
            removidos.append(uid)

    for uid in removidos:
        del keys_ativas[uid]

    if removidos:
        salvar_github()

# ====================================================
# DISCORD
# ====================================================

intents = discord.Intents.default()
intents.message_content = True
client = discord.Client(intents=intents)

@client.event
async def on_ready():
    print(f"[BOT] Online como {client.user}")
    client.loop.create_task(task_limpeza())

@client.event
async def on_message(message):
    if message.author.bot:
        return

    if message.content.strip().lower() != COMANDO.lower():
        return

    user = message.author

    # Já tem key ativa?
    if user.id in keys_ativas:
        key, expira = keys_ativas[user.id]
        if expira > datetime.utcnow():
            await user.send(
                f"🔑 Sua key ativa:\n```{key}```\n⏳ Válida por 12h"
            )
            await message.add_reaction("✅")
            return

    # Gera nova key
    key = gerar_key()
    expira = datetime.utcnow() + timedelta(hours=12)

    keys_ativas[user.id] = (key, expira)
    salvar_github()

    await user.send(
        f"🔑 SKY HUB — Key Gerada:\n```{key}```\n⏳ Válida por 12 horas"
    )

    await message.add_reaction("✅")
    print(f"[BOT] Key criada: {key}")

# ====================================================
# LIMPEZA AUTOMÁTICA (a cada 1 hora)
# ====================================================

async def task_limpeza():
    await client.wait_until_ready()
    while not client.is_closed():
        await asyncio.sleep(3600)
        limpar_expiradas()

# ====================================================
client.run(DISCORD_TOKEN)
