import discord
import json
import os
import uuid
import asyncio
import requests
import base64
from datetime import datetime, timedelta

# ================= CONFIG =================

DISCORD_TOKEN = os.getenv("DISCORD_TOKEN")
GITHUB_TOKEN  = os.getenv("GITHUB_TOKEN")
GITHUB_USER   = "skygod403"
GITHUB_REPO   = "...22"
GITHUB_FILE   = "keys_validas.txt"

COMANDO   = "/sky.key.C"
KEYS_JSON = "keys.json"

# ====================================================
# GITHUB
# ====================================================

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

def atualizar_github():
    dados = carregar_json()

    # pega apenas keys ainda válidas
    lista = [
        v["key"]
        for v in dados
        if datetime.utcnow() < datetime.fromisoformat(v["expira"])
    ]

    conteudo = "\n".join(lista)
    encoded  = base64.b64encode(conteudo.encode()).decode()

    sha = pegar_sha()
    body = {"message": "bot: update keys", "content": encoded}
    if sha:
        body["sha"] = sha

    requests.put(_url(), headers=_headers(), json=body)
    print(f"[BOT] GitHub atualizado — {len(lista)} key(s) ativa(s)")

# ====================================================
# LOCAL JSON
# ====================================================

def carregar_json():
    if not os.path.exists(KEYS_JSON):
        return []
    with open(KEYS_JSON, "r") as f:
        return json.load(f)

def salvar_json(data):
    with open(KEYS_JSON, "w") as f:
        json.dump(data, f, indent=2)

def nova_key():
    def p(): return uuid.uuid4().hex[:4].upper()
    return f"SKY-{p()}-{p()}-{p()}"

def ainda_valida(expira):
    return datetime.utcnow() < datetime.fromisoformat(expira)

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
async def on_message(msg):
    if msg.author.bot:
        return

    if msg.content.strip().lower() != COMANDO.lower():
        return

    user = msg.author
    dados = carregar_json()

    # SEM VERIFICAÇÃO DE KEY EXISTENTE
    # sempre gera nova

    key = nova_key()
    expira = (datetime.utcnow() + timedelta(hours=12)).isoformat()

    dados.append({
        "key": key,
        "expira": expira,
        "user": str(user),
        "uid": str(user.id),
        "criada": datetime.utcnow().isoformat()
    })

    salvar_json(dados)

    loop = asyncio.get_event_loop()
    await loop.run_in_executor(None, atualizar_github)

    await user.send(
        f"🔑 SKY HUB — Key Gerada:\n```{key}```\n⏳ Válida por 12 horas"
    )

    await msg.add_reaction("✅")
    print(f"[BOT] Key gerada → {user} | {key}")

# ====================================================
# LIMPEZA AUTOMÁTICA
# ====================================================

async def task_limpeza():
    await client.wait_until_ready()

    while not client.is_closed():
        dados = carregar_json()
        antes = len(dados)

        dados = [v for v in dados if ainda_valida(v["expira"])]

        if len(dados) != antes:
            salvar_json(dados)
            loop = asyncio.get_event_loop()
            await loop.run_in_executor(None, atualizar_github)
            print(f"[BOT] Limpeza feita")

        await asyncio.sleep(3600)

# ====================================================

client.run(DISCORD_TOKEN)
