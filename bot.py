import discord
import json
import os
import uuid
import asyncio
import requests
import base64
from datetime import datetime, timedelta

# ================================================================
#  SKY HUB — Bot de Keys
#  Comando : /sky.key.C
#  Validade: 12 horas por key
#  1 key por pessoa — só gera nova quando a atual expirar
# ================================================================

# ── CONFIGURAÇÕES ── edite só estas 5 linhas ────────────────────
DISCORD_TOKEN = os.getenv("DISCORD_TOKEN")
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
GITHUB_USER   = "skygod403"
GITHUB_REPO   = "...22"
GITHUB_FILE   = "keys_validas.txt"
# ───────────────────────────────────────────────────────────────

COMANDO    = "/sky.key.C"
KEYS_JSON  = "keys.json"

# ================================================================
#  FUNÇÕES DO GITHUB
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

def atualizar_github():
    """Lê as keys locais válidas e escreve no GitHub"""
    dados = carregar_json()
    lista = [
        v["key"]
        for v in dados.values()
        if datetime.utcnow() < datetime.fromisoformat(v["expira"])
    ]
    conteudo = "\n".join(lista)
    encoded  = base64.b64encode(conteudo.encode()).decode()
    sha      = pegar_sha()
    body     = {"message": "bot: update keys", "content": encoded}
    if sha:
        body["sha"] = sha
    r = requests.put(_url(), headers=_headers(), json=body)
    qtd = len(lista)
    print(f"[BOT] GitHub atualizado — {qtd} key(s) ativa(s)")

# ================================================================
#  FUNÇÕES LOCAIS (JSON)
# ================================================================

def carregar_json():
    if not os.path.exists(KEYS_JSON):
        return {}
    with open(KEYS_JSON, "r") as f:
        return json.load(f)

def salvar_json(data):
    with open(KEYS_JSON, "w") as f:
        json.dump(data, f, indent=2)

def nova_key():
    def p(): return uuid.uuid4().hex[:4].upper()
    return f"SKY-{p()}-{p()}-{p()}"

def ainda_valida(expira: str):
    return datetime.utcnow() < datetime.fromisoformat(expira)

# ================================================================
#  BOT
# ================================================================

intents = discord.Intents.default()
intents.message_content = True
intents.members = True
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

    user    = msg.author
    uid     = str(user.id)
    dados   = carregar_json()

    # ── Já tem key válida? ───────────────────────────────────────
    if uid in dados and ainda_valida(dados[uid]["expira"]):
        expira  = datetime.fromisoformat(dados[uid]["expira"])
        restante = expira - datetime.utcnow()
        h = int(restante.total_seconds() // 3600)
        m = int((restante.total_seconds() % 3600) // 60)

        embed = discord.Embed(
            title       = "🔑  Você já tem uma key ativa!",
            description = "Sua key ainda está válida, não precisa de uma nova.",
            color       = 0x7B2FFF
        )
        embed.add_field(name="🗝️  Key",        value=f"```{dados[uid]['key']}```",                  inline=False)
        embed.add_field(name="⏳  Expira em",   value=f"`{h}h {m}min`",                              inline=True)
        embed.add_field(name="📅  Válida até",  value=f"`{expira.strftime('%d/%m %H:%M')} UTC`",     inline=True)
        embed.set_footer(text="SKY HUB v2.0")

        try:
            await user.send(embed=embed)
            await msg.add_reaction("✅")
        except discord.Forbidden:
            await msg.reply(f"❌ {user.mention} Abre as DMs do servidor!", delete_after=8)
        return

    # ── Gera nova key ────────────────────────────────────────────
    key      = nova_key()
    expira   = (datetime.utcnow() + timedelta(hours=12)).isoformat()

    dados[uid] = {
        "key"    : key,
        "expira" : expira,
        "user"   : str(user),
        "criada" : datetime.utcnow().isoformat()
    }
    salvar_json(dados)

    # Atualiza o GitHub com a nova key
    try:
        loop = asyncio.get_event_loop()
        await loop.run_in_executor(None, atualizar_github)
    except Exception as e:
        print(f"[BOT] Erro GitHub: {e}")

    # Manda DM
    expira_dt = datetime.fromisoformat(expira)
    embed = discord.Embed(
        title       = "🔑  SKY HUB — Key Gerada!",
        description = "Cole essa key na tela do script e clique **ENTRAR**.",
        color       = 0x7B2FFF
    )
    embed.add_field(name="🗝️  Sua Key",    value=f"```{key}```",                                inline=False)
    embed.add_field(name="⏰  Validade",    value="`12 horas`",                                  inline=True)
    embed.add_field(name="📅  Expira em",   value=f"`{expira_dt.strftime('%d/%m %H:%M')} UTC`", inline=True)
    embed.add_field(
        name    = "📋  Como usar",
        value   = "1️⃣  Execute o script no Roblox\n2️⃣  Aparece a tela de acesso\n3️⃣  Cole a key acima\n4️⃣  Clique **ENTRAR**",
        inline  = False
    )
    embed.add_field(
        name    = "⚠️  Atenção",
        value   = "Não compartilhe sua key!\nApós 12h ela expira e você pode pegar uma nova.",
        inline  = False
    )
    embed.set_footer(text="SKY HUB v2.0  •  use /sky.key.C para renovar")

    try:
        await user.send(embed=embed)
        await msg.add_reaction("✅")
        print(f"[BOT] Key gerada → {user}  |  {key}")
    except discord.Forbidden:
        await msg.reply(f"❌ {user.mention} Abre as DMs do servidor!", delete_after=8)

# ================================================================
#  TASK — limpa expiradas a cada hora
# ================================================================

async def task_limpeza():
    await client.wait_until_ready()
    while not client.is_closed():
        dados  = carregar_json()
        antes  = len(dados)
        dados  = {uid: v for uid, v in dados.items() if ainda_valida(v["expira"])}
        depois = len(dados)
        if antes != depois:
            salvar_json(dados)
            try:
                loop = asyncio.get_event_loop()
                await loop.run_in_executor(None, atualizar_github)
                print(f"[BOT] Limpeza: {antes - depois} key(s) expirada(s) removida(s)")
            except Exception as e:
                print(f"[BOT] Erro limpeza: {e}")
        await asyncio.sleep(3600)

# ================================================================
client.run(DISCORD_TOKEN)
