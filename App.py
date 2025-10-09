# ================================================================
# 📊 APP — ESQUADRÃO MINAS DISTRIBUIDORA
# ================================================================
# Versão completa - visual dark
# Compatível com Streamlit >= 1.39
# ================================================================

import streamlit as st
import json
import os
from PIL import Image
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime, timedelta
import base64

# ================================================================
# 🔧 ARQUIVOS BASE
# ================================================================
FLAG_FILE = "campanha_flag.json"
USER_FILE = "usuarios.json"
ICON_PATH = "icone.ico"
ICON_TYPE = "image/x-icon"

# ================================================================
# ⚙️ FUNÇÕES DE CAMPANHA
# ================================================================
FLAG_FILE = "campanha_flag.json"

def salvar_flag_campanha(flag: str):
    """
    Salva o tipo de campanha atual no arquivo JSON, sem BOM.
    """
    try:
        with open(FLAG_FILE, "w", encoding="utf-8") as f:
            json.dump({"campanha_tipo": flag}, f, ensure_ascii=False, indent=2)
    except Exception as e:
        st.error(f"❌ Erro ao salvar flag da campanha: {e}")

def carregar_flag_campanha() -> str:
    """
    Lê o tipo de campanha atual do arquivo JSON, 
    ignorando possíveis BOMs ou erros de formatação.
    Retorna 'Campanha Antiga' caso o arquivo esteja ausente, vazio ou corrompido.
    """
    if not os.path.exists(FLAG_FILE):
        return "Campanha Antiga"

    try:
        with open(FLAG_FILE, "r", encoding="utf-8-sig") as f:
            conteudo = f.read().strip()

            if not conteudo:
                st.warning("⚠️ Arquivo campanha_flag.json vazio — usando 'Campanha Antiga'.")
                return "Campanha Antiga"

            dados = json.loads(conteudo)
            tipo = dados.get("campanha_tipo", "Campanha Antiga")

            # Segurança extra: garante retorno válido
            if not isinstance(tipo, str) or not tipo.strip():
                return "Campanha Antiga"

            return tipo

    except json.JSONDecodeError:
        st.warning("⚠️ Arquivo campanha_flag.json corrompido — revertendo para 'Campanha Antiga'.")
        return "Campanha Antiga"

    except Exception as e:
        st.error(f"❌ Erro inesperado ao ler campanha_flag.json: {e}")
        return "Campanha Antiga"


# ================================================================
# 🧩 FUNÇÕES GERAIS
# ================================================================
def get_base64_of_file(path, file_type):
    try:
        with open(path, "rb") as f:
            encoded_string = base64.b64encode(f.read()).decode()
        return f"data:{file_type};base64,{encoded_string}"
    except FileNotFoundError:
        return None

def carregar_usuarios():
    if os.path.exists(USER_FILE):
        try:
            with open(USER_FILE, "r", encoding="utf-8-sig") as f:
                conteudo = f.read().strip()
                if not conteudo:
                    return {}
                return json.loads(conteudo)
        except Exception:
            return {}
    return {}

def salvar_usuarios(usuarios):
    try:
        with open(USER_FILE, "w", encoding="utf-8") as f:
            json.dump(usuarios, f, indent=4, ensure_ascii=False)
    except Exception as e:
        st.error(f"Erro ao salvar usuários: {e}")

def logout():
    st.session_state.logged_in = False
    st.session_state.username = ""
    st.success("Você foi desconectado.")
    st.rerun()

# ================================================================
# 🧭 CONFIGURAÇÃO DA PÁGINA
# ================================================================
page_icon_url = get_base64_of_file(ICON_PATH, ICON_TYPE)
st.set_page_config(
    page_title="PAINEL ESQUADRÃO MINAS",
    page_icon=page_icon_url if page_icon_url else "🚀",
    layout="wide",
    initial_sidebar_state="expanded",
)

DEBUG_MODE = False  # True = pula login

# ================================================================
# 🎨 CSS PERSONALIZADO - VISUAL DARK
# ================================================================
st.markdown("""
<style>
html, body {background-color:#0e1117 !important; color:white !important;}
.stApp {background-color:#0e1117 !important; color:white !important;}
.block-container {padding:1rem; margin:auto; width:80%; max-width:1200px;}
.stTextInput>div>input, .stPassword>div>input {background:#262730; color:white; border-radius:6px;}
.stButton>button {width:100%; padding:0.5rem; border-radius:6px; font-weight:bold; background-color:#1976d2; color:white;}
.stButton>button:hover {background-color:#1565c0;}
header, [data-testid="stSidebar"] {visibility:hidden; height:0px !important; display:none !important;}
.login-container {background-color:#1a1c23; padding:2rem; border-radius:8px; width:90%; max-width:400px; text-align:center;}
.login-logo {width:150px; margin-bottom:1.5rem;}
.username-info {display:flex; align-items:center; gap:10px;}
.username-text {font-weight:bold; font-size:1.2rem; color:white;}
.stButton-logout>button {background:none !important; color:white !important; border:none !important;}
</style>
""", unsafe_allow_html=True)

# ================================================================
# 🔐 LOGIN E CADASTRO
# ================================================================
if "logged_in" not in st.session_state:
    st.session_state.logged_in = False
    st.session_state.username = ""
    st.session_state.aba_ativa = "Login"

usuarios = carregar_usuarios()

if not st.session_state.logged_in and not DEBUG_MODE:
    st.markdown('<div class="login-container">', unsafe_allow_html=True)
    try:
        with open("logo.png", "rb") as f:
            logo_base64 = base64.b64encode(f.read()).decode()
        st.markdown(f'<img src="data:image/png;base64,{logo_base64}" class="login-logo">', unsafe_allow_html=True)
    except FileNotFoundError:
        st.markdown('<h1>Logo</h1>', unsafe_allow_html=True)

    aba = st.radio("Escolha uma opção:", ["Login", "Cadastro"], horizontal=True)
    st.session_state.aba_ativa = aba

    if aba == "Login":
        st.markdown('<h2>Login 🔐</h2>', unsafe_allow_html=True)
        user = st.text_input("Usuário")
        pwd = st.text_input("Senha", type="password")
        if st.button("Entrar"):
            if user in usuarios and usuarios[user] == pwd:
                st.session_state.logged_in = True
                st.session_state.username = user
                st.success(f"Bem-vindo, {user}!")
                st.rerun()
            else:
                st.error("Usuário ou senha inválidos.")
    else:
        st.markdown('<h2>Cadastro 👤</h2>', unsafe_allow_html=True)
        nu = st.text_input("Novo usuário")
        ns = st.text_input("Nova senha", type="password")
        cf = st.text_input("Confirme a senha", type="password")
        if st.button("Cadastrar"):
            if nu in usuarios:
                st.warning("Usuário já existe.")
            elif ns != cf:
                st.warning("Senhas não coincidem.")
            elif not nu.strip() or not ns.strip():
                st.warning("Preencha todos os campos.")
            else:
                usuarios[nu] = ns
                salvar_usuarios(usuarios)
                st.success("Usuário cadastrado! Faça login.")
    st.markdown('</div>', unsafe_allow_html=True)
elif st.session_state.logged_in or DEBUG_MODE:
    # ================================================================
    # 📊 PAINEL PRINCIPAL — LÓGICA DE CAMPANHAS
    # ================================================================
    if DEBUG_MODE and not st.session_state.logged_in:
        st.session_state.username = "Modo_Teste"

    # topo com nome e logout
    col_info, col_logout = st.columns([0.8, 0.2])
    with col_info:
        st.markdown(f"""
            <div class="username-info">
                <img src="https://cdn-icons-png.flaticon.com/512/149/149071.png" width="40" height="40"/>
                <div class="username-text">{st.session_state.username}</div>
            </div>
        """, unsafe_allow_html=True)
    with col_logout:
        if st.button("Sair", key="logout_button"):
            logout()

    # ------------------------------------------------------------
    # 🔹 Carregar planilhas principais
    # ------------------------------------------------------------
    vendas_df = pd.read_excel("Esquadrão Minas.xlsx", sheet_name="Report")
    vendas_df.columns = [col.strip().upper() for col in vendas_df.columns]
    vendas_df = vendas_df.rename(columns={"VL TOTAL": "VENDAS"})
    vendas_df["NOME"] = vendas_df["RCA"].str.split().str[:1].str.join(' ')

    metas_df = pd.read_excel("Metas Esquadrao Minas.xlsx", sheet_name="META VALOR")
    metas_df.columns = [col.strip().upper() for col in metas_df.columns]
    metas_df["NOME"] = metas_df["RCA"].str.split().str[:1].str.join(' ')

    mfam = pd.read_excel("Metas Esquadrao Minas.xlsx", sheet_name="META FAMILIA")
    mfam.columns = [col.strip().upper() for col in mfam.columns]

    # ------------------------------------------------------------
    # 🔹 Consolidar e calcular % de meta
    # ------------------------------------------------------------
    df = vendas_df.groupby("RCA")["VENDAS"].sum().reset_index()
    df = df.merge(metas_df, on="RCA", how="inner").dropna(subset=["META"])
    df["NOME"] = df["RCA"].str.split().str[:1].str.join(' ')
    df["% META"] = df["VENDAS"] / df["META"] * 100
    df = df.sort_values("% META", ascending=False).reset_index(drop=True)
    df.index += 1
    df.index.name = "RANK"

    # ------------------------------------------------------------
    # 🔹 Flag de campanha (admin controla)
    # ------------------------------------------------------------
    ADMIN_USERS = ["Marcio"]
    if st.session_state.username in ADMIN_USERS:
        campanha_tipo = st.selectbox(
            "Tipo de Campanha (Admin):",
            ["Campanha Antiga", "Nova Campanha"],
            key="tipo_campanha"
        )
        salvar_flag_campanha(campanha_tipo)
    else:
        campanha_tipo = carregar_flag_campanha()

    # ------------------------------------------------------------
    # 🧮 PAINEL DE APURAÇÃO
    # ------------------------------------------------------------
    if campanha_tipo == "Campanha Antiga":
        st.subheader("📊 Desempenho por RCA")

        def highlight_meta(val):
            color = 'lightgreen' if val >= 100 else 'salmon'
            return f'background-color:{color};color:black;'

        styled = (
            df[["NOME", "VENDAS", "META", "% META"]]
            .style.format({
                "VENDAS": "R$ {:,.2f}".format,
                "META": "R$ {:,.2f}".format,
                "% META": "{:.1f}%".format,
            })
            .applymap(highlight_meta, subset=["% META"])
        )
        st.dataframe(styled, use_container_width=True)

    else:
        # ============================================================
        # 🏆 NOVA CAMPANHA: Apuração por Gatilho
        # ============================================================
        st.subheader("🏆 Nova Campanha: Apuração por Gatilho")

        try:
            meta_cota_df = pd.read_excel("Metas Esquadrao Minas.xlsx", sheet_name="META COTA")
            gatilho = int(meta_cota_df.iloc[0, 0])
        except Exception:
            gatilho = 1500  # fallback se a planilha estiver vazia

        premio_unitario = 90
        df["GATILHO"] = gatilho
        df["PREMIO"] = (df["VENDAS"] // gatilho) * premio_unitario

        # recalcular por famílias (para premiar 100% ou 50%)
        vendas_df["NOME"] = vendas_df["RCA"].str.split().str[:1].str.join(' ')
        familias_com_meta = mfam["FAMILIA"].dropna().unique().tolist()
        rcas_com_meta = metas_df["RCA"].dropna().unique().tolist()
        vendas_df_filtrado_meta = vendas_df[
            vendas_df["RCA"].isin(rcas_com_meta)
            & vendas_df["FAMILIA"].isin(familias_com_meta)
        ].copy()

        fam = vendas_df_filtrado_meta.groupby(["NOME", "FAMILIA"])["CLIENTE"].nunique().reset_index()
        pivot = fam.pivot(index="NOME", columns="FAMILIA", values="CLIENTE").fillna(0).astype(int)

        def get_meta(f):
            meta = mfam.loc[mfam["FAMILIA"] == f, "META"]
            return meta.squeeze() if not meta.empty else 0

        def todas_familias_verdes(nome):
            if nome not in pivot.index:
                return False
            linha = pivot.loc[nome]
            for familia in pivot.columns:
                v = linha[familia]
                meta = get_meta(familia)
                if meta == 0:
                    continue
                if v < meta:
                    return False
            return True

        df["TODAS_VERDES"] = df["NOME"].apply(todas_familias_verdes)
        df["PRÊMIO FINAL"] = df.apply(
            lambda row: row["PREMIO"] if row["TODAS_VERDES"] else row["PREMIO"] / 2, axis=1
        )

        exibir = df[["NOME", "VENDAS", "GATILHO", "PRÊMIO FINAL"]].copy()
        exibir["VENDAS"] = exibir["VENDAS"].apply(lambda x: f"R$ {x:,.2f}".replace(",", "X").replace(".", ",").replace("X", "."))
        exibir["PRÊMIO FINAL"] = exibir["PRÊMIO FINAL"].apply(lambda x: f"R$ {x:,.2f}".replace(",", "X").replace(".", ",").replace("X", "."))
        st.dataframe(exibir, use_container_width=True)

    # ------------------------------------------------------------
    # 📈 GRÁFICO DE % META
    # ------------------------------------------------------------
    st.subheader("📈 % de Meta Atingida")
    gdf = df[["NOME", "% META"]].sort_values("% META", ascending=False)
    cores = sns.color_palette("husl", len(gdf))
    fig, ax = plt.subplots(figsize=(10, 5), facecolor="#0e1117")
    bars = ax.bar(gdf["NOME"], gdf["% META"], color=cores)

    for bar, pct in zip(bars, gdf["% META"]):
        ax.text(
            bar.get_x() + bar.get_width() / 2,
            bar.get_height() / 2,
            f"{pct:.1f}%",
            ha="center",
            va="center",
            color="white",
            fontweight="bold",
        )

    ax.set_facecolor("#0e1117")
    fig.patch.set_facecolor("#0e1117")
    ax.tick_params(colors="white")
    ax.set_ylabel("% META", color="white")
    ax.set_xlabel("")
    for s in ax.spines.values():
        s.set_visible(False)
    st.pyplot(fig)
    # ================================================================
    # ✅ POSITIVAÇÃO POR FAMÍLIA
    # ================================================================
    st.subheader("✅ Positivação por Família (Clientes únicos com venda)")

    familias_com_meta = mfam["FAMILIA"].dropna().unique().tolist()
    rcas_com_meta = metas_df["RCA"].dropna().unique().tolist()
    vendas_df_filtrado_meta = vendas_df[
        vendas_df["RCA"].isin(rcas_com_meta) &
        vendas_df["FAMILIA"].isin(familias_com_meta)
    ].copy()

    fam = vendas_df_filtrado_meta.groupby(["NOME", "FAMILIA"])["CLIENTE"].nunique().reset_index()
    pivot = fam.pivot(index="NOME", columns="FAMILIA", values="CLIENTE").fillna(0).astype(int)

    def get_meta(f):
        meta = mfam.loc[(mfam["FAMILIA"] == f), "META"]
        return meta.squeeze() if not meta.empty else 0

    def est(v, f):
        m = get_meta(f)
        if m == 0:
            return ""
        if v >= m:
            return "background-color:#00FF00;color:black;text-align:center"
        elif v >= 0.8 * m:
            return "background-color:#FFFF00;color:black;text-align:center"
        else:
            return ""

    styled_f = pivot.style
    for c in pivot.columns:
        styled_f = styled_f.applymap(lambda v, col=c: est(v, col), subset=[c])
    st.dataframe(styled_f, use_container_width=True)

    # ================================================================
    # 🔍 DETALHE DE POSITIVAÇÃO
    # ================================================================
    st.markdown("---")
    st.subheader("🔍 Detalhe de Positivação: Onde o vendedor positivou por família?")

    nomes_rca_com_meta_dropdown = sorted(df["NOME"].unique().tolist())
    familias_com_meta_dropdown = sorted(mfam["FAMILIA"].dropna().unique().tolist())

    nomes_rca_selecao = ["Todos"] + nomes_rca_com_meta_dropdown
    familias_selecao = ["Todos"] + familias_com_meta_dropdown

    col1, col2 = st.columns(2)
    with col1:
        selected_nome_rca = st.selectbox("Selecione o Vendedor (Nome):", nomes_rca_selecao, key="select_nome_rca")
    with col2:
        selected_familia = st.selectbox("Selecione a Família de Produto:", familias_selecao, key="select_familia")

    selected_rca_completo = None
    if selected_nome_rca != "Todos":
        rcas_correspondentes = df[df["NOME"] == selected_nome_rca]["RCA"].unique().tolist()
        selected_rca_completo = rcas_correspondentes if rcas_correspondentes else []

    df_filtrado_base = vendas_df_filtrado_meta.copy()

    if selected_nome_rca != "Todos":
        if selected_rca_completo:
            df_filtrado_base = df_filtrado_base[df_filtrado_base["RCA"].isin(selected_rca_completo)]
        else:
            df_filtrado_base = pd.DataFrame(columns=df_filtrado_base.columns)

    if selected_familia != "Todos":
        df_filtrado_base = df_filtrado_base[df_filtrado_base["FAMILIA"] == selected_familia]

    if not df_filtrado_base.empty:
        detalhes_positivacao = df_filtrado_base.groupby(["NOME", "CLIENTE", "FAMILIA"])["DESCRIÇÃO"] \
            .apply(lambda x: ", ".join(x.unique())).reset_index()
        detalhes_positivacao = detalhes_positivacao.rename(columns={"DESCRIÇÃO": "PRODUTOS POSITIVADOS"})
        detalhes_positivacao.index = range(1, len(detalhes_positivacao) + 1)
        st.write(f"Mostrando positivações para Vendedor: **{selected_nome_rca}** e Família: **{selected_familia}**")
        st.dataframe(detalhes_positivacao[["NOME", "CLIENTE", "FAMILIA", "PRODUTOS POSITIVADOS"]], use_container_width=True)
    else:
        st.info("Nenhuma positivação encontrada para os filtros selecionados.")

    # ================================================================
    # 🎯 OPORTUNIDADES DE POSITIVAÇÃO POR CLIENTE
    # ================================================================
    st.markdown("---")
    st.subheader("🎯 Oportunidades de Positivação por Cliente")

    df_para_oportunidades = vendas_df_filtrado_meta.copy()

    if selected_nome_rca != "Todos":
        if selected_rca_completo:
            df_para_oportunidades = df_para_oportunidades[df_para_oportunidades["RCA"].isin(selected_rca_completo)]
        else:
            df_para_oportunidades = pd.DataFrame(columns=df_para_oportunidades.columns)

    if not df_para_oportunidades.empty:
        clientes_do_vendedor = df_para_oportunidades["CLIENTE"].unique().tolist()
    else:
        clientes_do_vendedor = []

    todas_familias_com_meta_geral = mfam["FAMILIA"].dropna().unique().tolist()
    oportunidades_data = []

    for cliente in clientes_do_vendedor:
        familias_positivadas_cliente = df_para_oportunidades[df_para_oportunidades["CLIENTE"] == cliente]["FAMILIA"].unique().tolist()
        if selected_familia != "Todos":
            familias_meta_para_cliente = [selected_familia] if selected_familia in todas_familias_com_meta_geral else []
        else:
            familias_meta_para_cliente = todas_familias_com_meta_geral

        familias_nao_positivadas_cliente = [f for f in familias_meta_para_cliente if f not in familias_positivadas_cliente]
        nome_rca_cliente = df_para_oportunidades[df_para_oportunidades["CLIENTE"] == cliente]["NOME"].iloc[0] \
            if not df_para_oportunidades[df_para_oportunidades["CLIENTE"] == cliente].empty else "N/A"

        oportunidades_data.append({
            "VENDEDOR": nome_rca_cliente,
            "CLIENTE": cliente,
            "FAMÍLIAS POSITIVADAS": ", ".join(sorted(familias_positivadas_cliente)) if familias_positivadas_cliente else "Nenhuma",
            "FAMÍLIAS NÃO POSITIVADAS (OPORTUNIDADE)": ", ".join(sorted(familias_nao_positivadas_cliente)) if familias_nao_positivadas_cliente else "Todas Positivadas / Nenhuma Oportunidade"
        })

    if oportunidades_data:
        oportunidades_df = pd.DataFrame(oportunidades_data).drop_duplicates()
        oportunidades_df.index = range(1, len(oportunidades_df) + 1)
        st.dataframe(oportunidades_df, use_container_width=True)
        csv = oportunidades_df.to_csv(index=False).encode("utf-8")
        st.download_button(
            label="📥 Baixar Oportunidades (CSV)",
            data=csv,
            file_name=f"oportunidades_positivacao_{selected_nome_rca}_{selected_familia}.csv",
            mime="text/csv",
        )
    else:
        st.info("Nenhuma oportunidade de positivação encontrada.")

    # ================================================================
    # 🗓️ ATIVIDADE DO CLIENTE / INATIVIDADE
    # ================================================================
    st.markdown("---")
    st.subheader("🗓️ Atividade do Cliente e Inatividade")

    data_atual = datetime.now()
    inicio_campanha = data_atual - timedelta(days=30)
    fim_campanha = data_atual

    hist_vendas_df = vendas_df.copy()
    hist_vendas_df.columns = [col.strip().upper() for col in hist_vendas_df.columns]
    hist_vendas_df = hist_vendas_df.rename(columns={"VL TOTAL": "VENDAS", "DATA": "DATA_VENDA"})
    hist_vendas_df["NOME"] = hist_vendas_df["RCA"].str.split().str[:1].str.join(" ")
    hist_vendas_df["DATA_VENDA"] = pd.to_datetime(hist_vendas_df["DATA_VENDA"], errors="coerce")
    hist_vendas_df.dropna(subset=["DATA_VENDA", "CNPJ", "CLIENTE", "RCA"], inplace=True)
    hist_vendas_df["CNPJ"] = hist_vendas_df["CNPJ"].astype(str)

    if not hist_vendas_df.empty:
        clientes_ultima_compra = (
            hist_vendas_df.sort_values("DATA_VENDA", ascending=False)
            .drop_duplicates(subset="CNPJ")
            [["CNPJ", "CLIENTE", "RCA", "NOME", "DATA_VENDA"]]
            .rename(columns={"DATA_VENDA": "ULTIMA_COMPRA"})
        )

        vendas_na_campanha = hist_vendas_df[
            (hist_vendas_df["DATA_VENDA"] >= inicio_campanha)
            & (hist_vendas_df["DATA_VENDA"] <= fim_campanha)
        ]
        clientes_atendidos_campanha = vendas_na_campanha["CNPJ"].unique()
        clientes_ultima_compra["ATENDIDO_NA_CAMPANHA"] = clientes_ultima_compra["CNPJ"].isin(clientes_atendidos_campanha).map({True: "Sim", False: "Não"})
        clientes_ultima_compra["DIAS_SEM_COMPRAR"] = (data_atual - clientes_ultima_compra["ULTIMA_COMPRA"]).dt.days

        st.dataframe(clientes_ultima_compra[["CLIENTE", "CNPJ", "NOME", "ULTIMA_COMPRA", "ATENDIDO_NA_CAMPANHA", "DIAS_SEM_COMPRAR"]].sort_values(by="DIAS_SEM_COMPRAR", ascending=False), use_container_width=True)

        # Filtros
        st.markdown("---")
        st.subheader("Filtros de Atividade")

        col1, col2, col3 = st.columns(3)
        with col1:
            status_campanha_filtro = st.selectbox("Status na Campanha:", ["Todos", "Sim", "Não"])
        with col2:
            dias_sem_comprar_filtro = st.slider(
                "Máximo de Dias Sem Comprar:",
                0,
                int(clientes_ultima_compra["DIAS_SEM_COMPRAR"].max() + 30),
                int(clientes_ultima_compra["DIAS_SEM_COMPRAR"].max() + 30),
            )
        with col3:
            vendedores_com_meta = sorted(metas_df["NOME"].unique().tolist())
            vendedor_atividade_filtro = st.selectbox("Vendedor (Última Compra):", ["Todos"] + vendedores_com_meta)

        df_atividade_filtrado = clientes_ultima_compra.copy()
        if status_campanha_filtro != "Todos":
            df_atividade_filtrado = df_atividade_filtrado[df_atividade_filtrado["ATENDIDO_NA_CAMPANHA"] == status_campanha_filtro]
        df_atividade_filtrado = df_atividade_filtrado[df_atividade_filtrado["DIAS_SEM_COMPRAR"] <= dias_sem_comprar_filtro]
        if vendedor_atividade_filtro != "Todos":
            df_atividade_filtrado = df_atividade_filtrado[df_atividade_filtrado["NOME"] == vendedor_atividade_filtro]

        st.write("Resultados Filtrados:")
        if not df_atividade_filtrado.empty:
            st.dataframe(df_atividade_filtrado[["CLIENTE", "CNPJ", "NOME", "ULTIMA_COMPRA", "ATENDIDO_NA_CAMPANHA", "DIAS_SEM_COMPRAR"]], use_container_width=True)
            csv_atividade = df_atividade_filtrado.to_csv(index=False).encode("utf-8")
            st.download_button(
                label="📥 Baixar Tabela de Atividade (CSV)",
                data=csv_atividade,
                file_name="atividade_clientes.csv",
                mime="text/csv",
            )
        else:
            st.info("Nenhum cliente encontrado com os filtros aplicados.")
