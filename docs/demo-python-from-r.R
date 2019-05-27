# =====================================================================================================================
# = Python no R: reticulate                                                                                           =
# =                                                                                                                   =
# =====================================================================================================================

# Configurações -------------------------------------------------------------------------------------------------------

# Pacotes -----------------------------------------------------------------------------------------------------------

# Instalação:
#
# - Do CRAN
#
# > install.packages("reticulate")
#
# - Versão de desenvolvimento no GitHub
#
# > devtools::install_github("rstudio/reticulate")
#
library(reticulate)

# Pacote para fazer magic squares.
#
library(magic)

library(magrittr)
#
# Pipe: Uma maravilha do R

# Verifica PYTHON ----------------------------------------------------------------------------------------------------

# Verifica onde está o Python
#
Sys.which("python")
use_python("/opt/anaconda3/bin/python3")
# Verifica configurações e outras opções
#
py_config()

# Para escolher uma versão de python diferente da retornada em Sys.which("python")
#
# - use_python()
# - use_virtualenv()
# - use_condaenv() 
#

# Módulos Python ------------------------------------------------------------------------------------------------------

# reticulate::py_install() - Instala módulo especificado.
# reticulate::import()     - Importa módulo.
#
sys <- import("sys")
sys$version                            # Equivalente em Python ao sys.version

os <- import("os")
#
# Notação de lista para acessar componentes dos módulos importados
#
os$getcwd()                            # [Python] Diretório de trabalho
getwd()                                # [R]      Diretório de trabalho
#
os$listdir(".")                        # [Python] Lista arquivos
list.files(all.files = TRUE)           # [R]      Lista arquivos

# Ajuda --------------------------------------------------------------------------------------------------------

?list.files                            # [R]
py_help(os$listdir)                    # [Python]

# Ambientes virtuais ------------------------------------------------------------------------------------------------

# R lida com dependências de maneira mais elegante.
# Python pode ser temperamental. É uma boa prática usar ambientes virtuais.
#
# - Há algumas funções virtualenv_*() para trabalhar com isso.
# - Conda environments possuem funções análogas..

# Onde ficam ambientes virtuais?
#
virtualenv_root()

# Lista ambientes virtuais existentes
#
virtualenv_list()

# Vamos criar um ambiente virtual
#
virtualenv_create("teste")

# Instalação de pacotes no ambiente virtual.
#
virtualenv_install("teste", c("numpy", "pandas", "matplotlib", "pycountry==17.5.14"))

# Começando a trabalhar com o ambiente recém criado.
#
use_virtualenv("teste")
#
# Verifica se o módulo está instalado.
#
py_module_available("matplotlib")
#
plt <- import("matplotlib")
pandas <- import("pandas")
numpy <- import("numpy")

# PYTHON do R -------------------------------------------------------------------------------------------------------

# Magic squares são matrizes de números inteiros onde
# as somas das linhas, colunas e diagonais são todas iguais.
#
# Não parece existir um pacote Python para trabalhar com magic squares. Mas em R temos um.
#
(M7 <- magic(7))
#
# Vamos verificar essas propriedades
#
colSums(M7)                            # [R] soma de colunas
rowSums(M7)                            # [R] soma de linhas
sum(diag(M7))                          # [R] soma da diagonal principal

# Vamos fazer álgebra linear simples com python.
#
numpy$transpose(M7)                    # [Python] equivalente a t()
#
numpy$linalg$eig(M7)                   # [Python] equivalente a eigen()
#
# A transferência de dados entre a linguagem não é ineficiente
#
# A matriz do R é convertida diretamente para um ndarry do numpy. Não há cópia!

# PYTHON: Executando código ----------------------------------------------------------------------------------------------

# Vimos como acessar funcionalidades do python do R, mas e para literalmente rodar Python no R?

py_run_string("x = 10")
#
# Podemos rodar scripts inteiros com py_run_file().
#
# As duas funções executam código no módulo __main__ do Python.
#
py$x

# PYTHON: Source de scripts  ---------------------------------------------------------------------------------------------------

source_python("class-person.py")
#
# Executa o código no módulo  __main__ do Python e passa objetos resultantes pro R.
#
# Os objetos são criados no global environment, mas podemos especificar um environment alternativo.

# Acessando objetos criados num script Python.
#
emma
storm
#
# Note que não precisamos usar o objeto especial py.

# Cria um objeto da classe definida no script Python.
#
claire = Person("Claire", "1980-04-13")
#
# Person - classe do Python
# claire - Um objeto de classe person
#
elizabeth = Person("Elizabeth", "2016-03-14")

# Atributos:
claire$id
claire$name
claire$birth
# Método.
elizabeth$age()
#
# Ganhamos acesso às classes de objetos criadas em python, o que é muito bom!

py_list_attributes(claire)
#
py_get_attr(claire, "birth")           # [Python] Atributo birth
claire$birth                           # [R] Atributo birth

# REPL (Interativo) --------------------------------------------------------------------------------------------------

# Executa o REPL (Read–Eval–Print Loop).
#
repl_python()

# ---> Código Python
#
import pandas as pd

# Criando DataFrame no Python.
#
people = pd.DataFrame({
  'age': pd.Series([35, 29, 27, 29, 18, 21], index=['Bob', 'Alice', 'Peggy', 'Victor', 'Frank', 'Erin']),
  'height': pd.Series({'Bob': 180.3, 'Alice': 157.5, 'Victor': 162.6, 'Frank': 190.5, 'Erin': 148.3}),
  'mass': pd.Series({'Bob': 81.2, 'Alice': 50.7, 'Victor': 72.1, 'Frank': 88.5, 'Erin': 51.3})
})
people

# Estando no Python REPL podemos ainda acessar dados do R com o objeto especial r
#
r.iris
#
# O objeto R se comporta como um objeto python.
#
r.iris.head()

exit
#
# <--- Código Python

# Usando o objeto py pra acessar os objetos que acabamos de criar com o Python REPL.
#
py$people

# Há uma simetria:
# 
# - No Python usamos o objeto r pra acessar objetos do r (r.x)
# - No R usamos o objeto py pra acessar objetos do Python (py$x).

# Dados do Python pro R: Conversão implícita -------------------------------------------------------------------------------

# Por padrão objetos Python no R são convertidos pros tipos R equivalentes

ten <- numpy$array(1:10)
ten
class(ten)
#
# Note que isso é um objeto R, então o código a seguir não vai funcionar!
#
tryCatch(
  ten$cumsum()
)

# Dados do Python pro R: Conversão explícita -------------------------------------------------------------------------------

# Podemos desabilitar a conversão.
#
numpy <- import("numpy", convert = FALSE)

ten <- numpy$array(1:10)
ten
class(ten)
#
# Note que isso ainda é um objeto Python, então podemos usar métodos nele.
#
ten$cumsum()

# Convertendo explicitamente pro R
#
ten <- py_to_r(ten)
class(ten)
# Dados de R pro Python: Conversão explícita -------------------------------------------------------------------------------

# Dupla de funções:
#
# - r_to_py() e
# - py_to_r().

# VETOR -> lista no Python
#
r_to_py(1:10)
#
1:10 %>% 
  r_to_py() %>% 
  py_to_r()

# LISTA NOMEADA -> dicionário no Python
#
list(pi = 22/7, e = 2.7, ten = 10) %>% 
  r_to_py()

# MATRIZ -> ndarray do numpy no Python
#
M7 %>% 
  r_to_py()
#
# Essa conversão é bastante eficiente porque o NumPy array é apontado diretamente pra memória
# ocupada pela matriz do R.
# Não há cópia! O layout de memória nas duas linguagens é por coluna.
#
# Há mais coisa a se fazer com arrays! (Veja https://rstudio.github.io/reticulate/articles/arrays.html.)

# DATA FRAME -> Pandas DataFrame
#
iris %>% 
  r_to_py()

# Limpando ------------------------------------------------------------------------------------------------------------

virtualenv_remove("teste")
