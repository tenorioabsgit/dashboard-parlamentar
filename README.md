# 📊 Dashboard de Atuação Parlamentar

Este projeto tem como objetivo coletar, processar e analisar dados públicos da **Câmara dos Deputados do Brasil** utilizando a **API de Dados Abertos da Câmara**. O script gera um **arquivo Excel (`deputados.xlsx`)** contendo informações detalhadas sobre deputados, despesas, votações, proposições e tramitações legislativas.

---

## 🚀 **Funcionalidades**

✅ **Coleta de dados da API da Câmara dos Deputados**  
✅ **Salvamento de dados em planilhas do Excel**  
✅ **Registro de despesas de cada deputado**  
✅ **Monitoramento de proposições e votações**  
✅ **Barra de progresso para acompanhar a execução**  

---

## 🛠️ **Tecnologias Utilizadas**
- **Python 3.x**
- **Pandas** (Manipulação de dados)
- **Requests** (Requisições HTTP para API)
- **TQDM** (Barra de progresso)

---

## 📥 **Instalação e Execução**

### **1️⃣ Clone o repositório**
```bash
git clone https://github.com/seu-usuario/dashboard-parlamentar.git
cd dashboard-parlamentar
```

### **2️⃣ Instale as dependências**
```bash
pip install pandas requests tqdm openpyxl
```

### **3️⃣ Execute o script**
```bash
python dashboard_parlamentar.py
```

Ao final da execução, será gerado o arquivo **`deputados.xlsx`**, contendo todas as informações coletadas.

---

## 📊 **Saída do Arquivo Excel**

O script gera um arquivo `deputados.xlsx` contendo múltiplas abas:
- **Deputados** → Lista completa de deputados.
- **Despesas** → Gastos de cada deputado.
- **Votações** → Registros das votações.
- **Proposições** → Projetos de lei apresentados.
- **Tramitações** → Histórico de tramitações das proposições.

---

## 📡 **Fonte de Dados**
Os dados são obtidos através da [API de Dados Abertos da Câmara dos Deputados](https://dadosabertos.camara.leg.br/swagger/api.html).

---

## 📌 **Licença**
Este projeto está sob a licença **MIT**, permitindo uso livre para qualquer finalidade.

📩 **Dúvidas ou sugestões?** Sinta-se à vontade para abrir uma issue ou contribuir! 🚀
