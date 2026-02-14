import discord
import os
import uuid
import asyncio
import requests
import base64
from datetime import datetime, timedelta

# ================================================================
#  SKY HUB — Bot de Keys (CORRIGIDO - múltiplas keys)
#  Comando : /sky.key.C
#  Validade: 12 horas por key
# ================================================================

# ── CONFIGURAÇÕES ──
DISCORD_TOKEN = os.getenv("DISCORD_TOKEN")
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
GITHUB_USER   = "skygod403"
GITHUB_REPO   = "...22"
GITHUB_FILE   = "keys_validas.txt"

COMANDO = "/sky.key.C"

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
    """Pega o SHA do arquivo atual no GitHub"""
    r = requests.get(_url(), headers=_headers())
    return r.json().get("sha") if r.status_code == 200 else None

def ler_keys_github():
    """Lê todas as keys do GitHub e retorna dict {uid: {key, expira, user}}"""
    r = requests.get(_url(), headers=_headers())
    if r.status_code != 200:
        return {}
    
    content = base64.b64decode(r.json()["content"]).decode()
    dados = {}
    
    for linha in content.strip().split("\n"):
        if not linha or "|" not in linha:
            continue
        
        partes = linha.split("|")
        if len(partes) >= 4:  # key|expira|uid|user
            key, expira, uid, user = partes[0], partes[1], partes[2], partes[3]
            
            # Só adiciona se ainda não expirou
            if datetime.utcnow() < datetime.fromisoformat(expira):
                dados[uid] = {
                    "key": key,
                    "expira": expira,
                    "user": user
                }
    
    return dados

def salvar_keys_github(dados):
    """Salva todas as keys válidas no GitHub"""
    # Monta o conteúdo com todas as keys
    linhas = []
    for uid, v in dados.items():
        # Formato: KEY|EXPIRA|UID|USER
        linhas.append(f"{v['key']}|{v['expira']}|{uid}|{v['user']}")
    
    conteudo = "\n".join(linhas)
    encoded = base64.b64encode(conteudo.encode()).decode()
    
    sha = pegar_sha()
    body = {"message": "bot: update keys", "content": encoded}
    if sha:
        body["sha"] = sha
    
    r = requests.put(_url(), headers=_headers(), json=body)
    
    if r.status_code in [200, 201]:
        print(f"[BOT] ✅ GitHub atualizado — {len(dados)} key(s) ativa(s)")
        return True
    else:
        print(f"[BOT] ❌ Erro GitHub: {r.status_code} - {r.text}")
        return False

def nova_key():
    """Gera uma key no formato SKY-XXXX-XXXX-XXXX"""
    def p(): 
        return uuid.uuid4().hex[:4].upper()
    return f"SKY-{p()}-{p()}-{p()}"

def ainda_valida(expira: str):
    """Verifica se a key ainda é válida"""
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

    user = msg.author
    uid = str(user.id)
    
    # Lê as keys direto do GitHub
    loop = asyncio.get_event_loop()
    dados = await loop.run_in_executor(None, ler_keys_github)

    # ── Verifica se já tem key válida ───────────────────────────
    if uid in dados and ainda_valida(dados[uid]["expira"]):
        expira = datetime.fromisoformat(dados[uid]["expira"])
        restante = expira - datetime.utcnow()
        h = int(restante.total_seconds() // 3600)
        m = int((restante.total_seconds() % 3600) // 60)

        embed = discord.Embed(
            title = "🔑  Você já tem uma key ativa!",
            description = "Sua key ainda está válida, não precisa de uma nova.",
            color = 0x7B2FFF
        )
        embed.add_field(
            name="🗝️  Key", 
            value=f"```{dados[uid]['key']}```", 
            inline=False
        )
        embed.add_field(
            name="⏳  Expira em", 
            value=f"`{h}h {m}min`", 
            inline=True
        )
        embed.add_field(
            name="📅  Válida até", 
            value=f"`{expira.strftime('%d/%m %H:%M')} UTC`", 
            inline=True
        )
        embed.set_footer(text="SKY HUB v2.0")

        try:
            await user.send(embed=embed)
            await msg.add_reaction("✅")
        except discord.Forbidden:
            await msg.reply(
                f"❌ {user.mention} Abre as DMs do servidor!", 
                delete_after=8
            )
        return

    # ── Gera nova key ────────────────────────────────────────────
    key = nova_key()
    expira = (datetime.utcnow() + timedelta(hours=12)).isoformat()

    # Adiciona a nova key nos dados
    dados[uid] = {
        "key": key,
        "expira": expira,
        "user": str(user)
    }

    # Salva no GitHub
    try:
        sucesso = await loop.run_in_executor(None, salvar_keys_github, dados)
        if not sucesso:
            await msg.reply("❌ Erro ao salvar key no GitHub!", delete_after=8)
            return
    except Exception as e:
        print(f"[BOT] Erro GitHub: {e}")
        await msg.reply("❌ Erro ao salvar key!", delete_after=8)
        return

    # Manda DM
    expira_dt = datetime.fromisoformat(expira)
    embed = discord.Embed(
        title = "🔑  SKY HUB — Key Gerada!",
        description = "Cole essa key na tela do script e clique **ENTRAR**.",
        color = 0x7B2FFF
    )
    embed.add_field(
        name="🗝️  Sua Key", 
        value=f"```{key}```", 
        inline=False
    )
    embed.add_field(
        name="⏰  Validade", 
        value="`12 horas`", 
        inline=True
    )
    embed.add_field(
        name="📅  Expira em", 
        value=f"`{expira_dt.strftime('%d/%m %H:%M')} UTC`", 
        inline=True
    )
    embed.add_field(
        name="📋  Como usar",
        value="1️⃣  Execute o script no Roblox\n2️⃣  Aparece a tela de acesso\n3️⃣  Cole a key acima\n4️⃣  Clique **ENTRAR**",
        inline=False
    )
    embed.add_field(
        name="⚠️  Atenção",
        value="Não compartilhe sua key!\nApós 12h ela expira e você pode pegar uma nova.",
        inline=False
    )
    embed.set_footer(text="SKY HUB v2.0  •  use /sky.key.C para renovar")

    try:
        await user.send(embed=embed)
        await msg.add_reaction("✅")
        print(f"[BOT] ✅ Key gerada → {user}  |  {key}")
    except discord.Forbidden:
        await msg.reply(
            f"❌ {user.mention} Abre as DMs do servidor!", 
            delete_after=8
        )

# ================================================================
#  TASK — limpa expiradas a cada hora
# ================================================================

async def task_limpeza():
    await client.wait_until_ready()
    while not client.is_closed():
        await asyncio.sleep(3600)  # 1 hora
        
        try:
            loop = asyncio.get_event_loop()
            dados = await loop.run_in_executor(None, ler_keys_github)
            antes = len(dados)
            
            # Remove expiradas
            dados = {
                uid: v 
                for uid, v in dados.items() 
                if ainda_valida(v["expira"])
            }
            depois = len(dados)
            
            if antes != depois:
                await loop.run_in_executor(None, salvar_keys_github, dados)
                print(f"[BOT] 🧹 Limpeza: {antes - depois} key(s) expirada(s) removida(s)")
        except Exception as e:
            print(f"[BOT] ❌ Erro limpeza: {e}")

# ================================================================
client.run(DISCORD_TOKEN)
