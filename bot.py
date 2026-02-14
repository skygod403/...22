import discord
import os
import uuid
import asyncio
import requests
import base64
from datetime import datetime, timedelta

# ================= CONFIG =================

DISCORD_TOKEN = os.getenv("DISCORD_TOKEN")
GITHUB_TOKEN  = os.getenv("GITHUB_TOKEN")

GITHUB_USER = "SEU_USER"
GITHUB_REPO = "SEU_REPO"
GITHUB_FILE = "keys_validas.txt"

COMANDO = "/sky.key.C"

# ==========================================

# Guarda key por usuário
keys_ativas = {}  # user_id : (key, expira)

# ================= GITHUB =================

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

# ================= KEY =================

def gerar_key():
    def p():
        return uuid.uuid4().hex[:4].upper()
    return f"SKY-{p()}-{p()}-{p()}"

def limpar_expiradas():
    agora = datetime.utcnow()
    removidas = []

    for user_id in list(keys_ativas.keys()):
        key, expira = keys_ativas[user_id]
        if expira < agora:
            removidas.append(user_id)

    for user_id in removidas:
        del keys_ativas[user_id]

    if removidas:
        salvar_github()

# ================= DISCORD =================

intents = discord.Intents.default()
intents.message_content = True
client = discord.Client(intents=intents)

@client.event
async def on_ready():
    print(f"Online como {client.user}")
    client.loop.create_task(task_limpeza())

@client.event
async def on_message(message):
    if message.author.bot:
        return

    if message.content.strip().lower() != COMANDO.lower():
        return

    user = message.author

    # Já tem key?
    if user.id in keys_ativas:
        key, expira = keys_ativas[user.id]
        if expira > datetime.utcnow():
            await user.send(f"🔑 Sua key ativa:\n```{key}```\n⏳ Válida por 12h")
            await message.add_reaction("✅")
            return

    # Gera nova
    key = gerar_key()
    expira = datetime.utcnow() + timedelta(hours=12)

    keys_ativas[user.id] = (key, expira)
    salvar_github()

    await user.send(f"🔑 SKY HUB — Key:\n```{key}```\n⏳ Válida por 12h")
    await message.add_reaction("✅")

# ================= LOOP LIMPEZA =================

async def task_limpeza():
    await client.wait_until_ready()
    while not client.is_closed():
        await asyncio.sleep(3600)
        limpar_expiradas()

# ==========================================

client.run(DISCORD_TOKEN)
