import discord
import os
import uuid
import asyncio
import requests
import base64
from datetime import datetime, timedelta

# ================================================================
#  SKY HUB — Bot de Keys (VERSÃO FINAL CORRIGIDA)
# ================================================================

DISCORD_TOKEN = os.getenv("DISCORD_TOKEN")
GITHUB_TOKEN  = os.getenv("GITHUB_TOKEN")

GITHUB_USER = "skygod403"
GITHUB_REPO = "...22"
GITHUB_FILE = "keys_validas.txt"

COMANDO = "/sky.key.C"

# ================================================================
#  GITHUB
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

def ler_keys_github():
    """
    Retorna:
    {
        uid: {
            key,
            expira,
            user
        }
    }
    """
    r = requests.get(_url(), headers=_headers())
    if r.status_code != 200:
        return {}

    content = base64.b64decode(r.json()["content"]).decode()
    dados = {}

    for linha in content.strip().split("\n"):
        if "|" not in linha:
            continue

        partes = linha.split("|")
        if len(partes) < 4:
            continue

        key = partes[0].strip().upper()
        expira = partes[1].strip()
        uid = partes[2].strip()
        user = partes[3].strip()

        try:
            if datetime.utcnow() < datetime.fromisoformat(expira):
                dados[uid] = {
                    "key": key,
                    "expira": expira,
                    "user": user
                }
        except:
            continue

    return dados

def salvar_keys_github(dados):
    linhas = []

    for uid, v in dados.items():
        linhas.append(f"{v['key']}|{v['expira']}|{uid}|{v['user']}")

    conteudo = "\n".join(linhas)
    encoded = base64.b64encode(conteudo.encode()).decode()

    sha = pegar_sha()

    body = {
        "message": "bot: update keys",
        "content": encoded
    }

    if sha:
        body["sha"] = sha

    r = requests.put(_url(), headers=_headers(), json=body)

    if r.status_code in [200, 201]:
        print(f"[BOT] GitHub atualizado — {len(dados)} key(s) ativa(s)")
        return True
    else:
        print(f"[BOT] Erro GitHub: {r.status_code} - {r.text}")
        return False

# ================================================================
#  KEY
# ================================================================

def nova_key():
    def p():
        return uuid.uuid4().hex[:4].upper()
    return f"SKY-{p()}-{p()}-{p()}"

def ainda_valida(expira):
    try:
        return datetime.utcnow() < datetime.fromisoformat(expira)
    except:
        return False

# ================================================================
#  DISCORD
# ================================================================

intents = discord.Intents.default()
intents.message_content = True
client = discord.Client(intents=intents)

@client.event
async def on_ready():
    print(f"[BOT] Online como → {client.user}")
    print(f"[BOT] Comando ativo: {COMANDO}")
    client.loop.create_task(task_limpeza())

@client.event
async def on_message(msg: discord.Message):
    if msg.author.bot:
        return

    if msg.content.strip().lower() != COMANDO.lower():
        return

    user = msg.author
    uid = str(user.id)

    loop = asyncio.get_event_loop()
    dados = await loop.run_in_executor(None, ler_keys_github)

    # ── Já tem key válida?
    if uid in dados and ainda_valida(dados[uid]["expira"]):
        key = dados[uid]["key"]
        expira = datetime.fromisoformat(dados[uid]["expira"])
        restante = expira - datetime.utcnow()

        h = int(restante.total_seconds() // 3600)
        m = int((restante.total_seconds() % 3600) // 60)

        embed = discord.Embed(
            title="🔑 Você já tem uma key ativa!",
            description="Use a key abaixo:",
            color=0x7B2FFF
        )

        embed.add_field(name="Key", value=f"```{key}```", inline=False)
        embed.add_field(name="Expira em", value=f"{h}h {m}min", inline=False)

        await user.send(embed=embed)
        await msg.add_reaction("✅")
        return

    # ── Gera nova key
    key = nova_key()
    expira = (datetime.utcnow() + timedelta(hours=12)).isoformat()

    dados[uid] = {
        "key": key,
        "expira": expira,
        "user": str(user)
    }

    sucesso = await loop.run_in_executor(None, salvar_keys_github, dados)

    if not sucesso:
        await msg.reply("Erro ao salvar key.", delete_after=8)
        return

    embed = discord.Embed(
        title="🔑 SKY HUB — Key Gerada!",
        description="Copie e cole no script:",
        color=0x7B2FFF
    )

    embed.add_field(name="Sua Key", value=f"```{key}```", inline=False)
    embed.add_field(name="Validade", value="12 horas", inline=False)

    await user.send(embed=embed)
    await msg.add_reaction("✅")

    print(f"[BOT] Key gerada → {user} | {key}")

# ================================================================
#  LIMPEZA AUTOMÁTICA
# ================================================================

async def task_limpeza():
    await client.wait_until_ready()

    while not client.is_closed():
        await asyncio.sleep(3600)

        try:
            loop = asyncio.get_event_loop()
            dados = await loop.run_in_executor(None, ler_keys_github)

            dados = {
                uid: v
                for uid, v in dados.items()
                if ainda_valida(v["expira"])
            }

            await loop.run_in_executor(None, salvar_keys_github, dados)
            print("[BOT] Limpeza automática concluída")

        except Exception as e:
            print(f"[BOT] Erro limpeza: {e}")

# ================================================================
client.run(DISCORD_TOKEN)
