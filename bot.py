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
COMANDO       = "/sky.key.C"
KEYS_JSON     = "keys.json"

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
    lista = [
        v["key"]
        for v in dados
        if datetime.utcnow() < datetime.fromisoformat(v["expira"])
    ]
    conteudo = "\n".join(lista)
    encoded  = base64.b64encode(conteudo.encode()).decode()
    sha  = pegar_sha()
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

def buscar_key_usuario(uid):
    dados = carregar_json()
    for v in dados:
        if v.get("uid") == str(uid) and ainda_valida(v["expira"]):
            return v
    return None

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

    # Verifica se já tem key ativa
    key_existente = buscar_key_usuario(user.id)
    if key_existente:
        expira   = datetime.fromisoformat(key_existente["expira"])
        restante = expira - datetime.utcnow()
        h = int(restante.total_seconds() // 3600)
        m = int((restante.total_seconds() % 3600) // 60)

        embed = discord.Embed(
            title       = "🔑  Você já tem uma key ativa!",
            description = "Aguarde sua key expirar para pegar uma nova.",
            color       = 0x7B2FFF
        )
        embed.add_field(name="🗝️  Sua Key",    value=f"```{key_existente['key']}```", inline=False)
        embed.add_field(name="⏳  Expira em",  value=f"`{h}h {m}min`",               inline=True)
        embed.add_field(name="📅  Válida até", value=f"`{expira.strftime('%d/%m %H:%M')} UTC`", inline=True)
        embed.set_footer(text="SKY HUB v3.0")
        try:
            await user.send(embed=embed)
            await msg.add_reaction("✅")
        except discord.Forbidden:
            await msg.reply(f"❌ {user.mention} Abre as DMs!", delete_after=8)
        return

    # Gera nova key
    key    = nova_key()
    expira = (datetime.utcnow() + timedelta(hours=12)).isoformat()
    dados  = carregar_json()
    dados.append({
        "key"   : key,
        "expira": expira,
        "user"  : str(user),
        "uid"   : str(user.id),
        "criada": datetime.utcnow().isoformat()
    })
    salvar_json(dados)

    loop = asyncio.get_event_loop()
    await loop.run_in_executor(None, atualizar_github)

    expira_dt = datetime.fromisoformat(expira)
    embed = discord.Embed(
        title       = "🔑  SKY HUB — Key Gerada!",
        description = "Cole essa key na tela do script e clique **ENTRAR**.",
        color       = 0x7B2FFF
    )
    embed.add_field(name="🗝️  Sua Key",  value=f"```{key}```",                                inline=False)
    embed.add_field(name="⏰  Validade",  value="`12 horas`",                                  inline=True)
    embed.add_field(name="📅  Expira em", value=f"`{expira_dt.strftime('%d/%m %H:%M')} UTC`", inline=True)
    embed.add_field(
        name  = "📋  Como usar",
        value = "1️⃣  Execute o script no Roblox\n2️⃣  Cole a key acima\n3️⃣  Clique **ENTRAR**",
        inline= False
    )
    embed.add_field(
        name  = "⚠️  Atenção",
        value = "Não compartilhe sua key!\nApós 12h use **/sky.key.C** para renovar.",
        inline= False
    )
    embed.set_footer(text="SKY HUB v3.0  •  1 key por pessoa")
    try:
        await user.send(embed=embed)
        await msg.add_reaction("✅")
        print(f"[BOT] Key gerada → {user} | {key}")
    except discord.Forbidden:
        await msg.reply(f"❌ {user.mention} Abre as DMs!", delete_after=8)

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
            print(f"[BOT] Limpeza: {antes - len(dados)} key(s) removida(s)")
        await asyncio.sleep(3600)

client.run(DISCORD_TOKEN)
