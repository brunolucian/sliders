# =====================================================================================================================
# = Python in R: reticulate                                                                                           =
# =                                                                                                                   =
# = Author: Andrew B. Collier <andrew@exegetic.biz> | @datawookie                                                     =
# =====================================================================================================================

# CONFIGURATION -------------------------------------------------------------------------------------------------------

# LIBRARIES -----------------------------------------------------------------------------------------------------------

# INSTALL:
#
# - From CRAN
#
# > install.packages("reticulate")
#
# - from GitHub
#
# > devtools::install_github("rstudio/reticulate")
#
library(reticulate)

# Library for making magic squares.
#
library(magic)

library(magrittr)
#
# The pipe: a solid argument for using R.

# CHECK FOR PYTHON ----------------------------------------------------------------------------------------------------

# Check if Python is in PATH.
#
Sys.which("python")

# Check for current configuration and alternative options.
#
py_config()

# Choosing a different Python:
#
# - use_python()
# - use_virtualenv()
# - use_condaenv() or
# - use the RETICULATE_PYTHON environment variable.
#
if (FALSE) {
  use_python("/usr/bin/python3")
}

# PYTHON MODULES ------------------------------------------------------------------------------------------------------

# reticulate::py_install() - Install specified module.
# reticulate::import()     - Import specified module.
#
sys <- import("sys")
sys$version                            # [Python] Equivalent to sys.version

os <- import("os")
#
# Access components of module using list notation.
#
os$getcwd()                            # [Python] Working directory
getwd()                                # [R]      Working directory
#
os$listdir(".")                        # [Python] List files (shows hidden files)
list.files(all.files = TRUE)           # [R]      List files

# GETTING HELP --------------------------------------------------------------------------------------------------------

?list.files                            # [R]
py_help(os$listdir)                    # [Python]

# VIRTUAL ENVIRONMENTS ------------------------------------------------------------------------------------------------

# R handles library dependencies rather elegantly.
# Python can be temperamental. So it's good practice to use virtual environments.
#
# - There's a set of virtualenv_*() functions for working with virtual environments.
# - There are analogous functions for Conda environments.

# Where are virtual environments stored?
#
virtualenv_root()

# List existing virtual environments.
#
virtualenv_list()

# Let's create a new one.
#
virtualenv_create("test")
#
# What's the default configuration for a virtual environment?
#
reticulate:::virtualenv_config()       # Use ::: to access hidden function.
#
# It's using Python 2. There's currently no easy way to change this.

# Install a few packages into the virtual environment.
#
virtualenv_install("test", c("numpy", "pandas", "matplotlib", "pycountry==17.5.14"))

# Start working with the freshly minted virtual environment...
#
use_virtualenv("test")
import("matplotlib")
#
# There's a catch: reticulate has already bound to the system version of Python.
#
# Reload reticulate!
#
detach("package:reticulate", unload=TRUE); library(reticulate)

use_virtualenv("test")
#
# Check whether a module is installed.
#
py_module_available("matplotlib")
#
pandas <- import("pandas")
numpy <- import("numpy")

# PYTHON FROM R -------------------------------------------------------------------------------------------------------

# Magic squares are a mathematical novelty: a matrix of integers where the sums of rows, columns and diagonals are all
# the same.
#
# There doesn't seem to be a Python package that will build magic squares. But we can do this in R.
#
(M7 <- magic(7))
#
# Quickly explore this mathematical oddity.
#
colSums(M7)                            # [R] Sums of columns
rowSums(M7)                            # [R] Sums of rows
sum(diag(M7))                          # [R] Sum of diagonal

# Let's do some simple linear algebra using Python.
#
numpy$transpose(M7)                    # [Python] Equivalent to numpy.transpose()
#
numpy$linalg$eig(M7)                   # [Python] Equivalent to numpy.linalg.eig()
#
# Isn't the data transfer between R and Python going to be inefficient? No!!
#
# The R matrix is being mapped directly to a Numpy ndarray. There is no copy taking place!

# PYTHON: EXECUTING CODE ----------------------------------------------------------------------------------------------

# We've seen how to access Python functionality from within R, but what if we literally want to run Python code from R?

py_run_string("x = 10")
#
# You can also run entire scripts using py_run_file().
#
# Both execute code within the Python __main__ module.
#
py$x

# Does assignment to existing Python variables work from R?
#
py$x = 13
#
py_run_string("print x")
#
# Note: Numbers in R are floating point by default!

# What about creating new variables?
#
py$hello = "Hello World!"
#
py_run_string("print hello")

# PYTHON: SOURCING  ---------------------------------------------------------------------------------------------------

source_python("class-person.py")
#
# Execute code in the Python __main__ module and expose all resulting objects to R.
#
# The resulting objects are created in the global R environment but you can specify an alternative environment.

# Access the objects created in the Python script.
#
emma
storm
#
# Note: We don't need to use the special py object!

# Instantiate the class defined in the Python script.
#
claire = Person("Claire", "1980-04-13")
#
# Person - a Python class
# claire - an instance of class Person
#
elizabeth = Person("Elizabeth", "2016-03-14")

# Attributes.
claire$id
claire$name
claire$birth
# Method.
elizabeth$age()
#
# We have gained access to Python's Object Oriented capabilities from within R. This is HUGE!

py_list_attributes(claire)
#
py_get_attr(claire, "birth")           # [Python] Get attribute
claire$birth                           # [R] Get attribute

# REPL (INTERACTIVE) --------------------------------------------------------------------------------------------------

# Launch the REPL (Read–Eval–Print Loop).
#
repl_python()

# ---> PYTHON CODE
#
import pandas as pd

# Creating a DataFrame in Python.
#
people = pd.DataFrame({
  'age': pd.Series([35, 29, 27, 29, 18, 21], index=['Bob', 'Alice', 'Peggy', 'Victor', 'Frank', 'Erin']),
  'height': pd.Series({'Bob': 180.3, 'Alice': 157.5, 'Victor': 162.6, 'Frank': 190.5, 'Erin': 148.3}),
  'mass': pd.Series({'Bob': 81.2, 'Alice': 50.7, 'Victor': 72.1, 'Frank': 88.5, 'Erin': 51.3})
})
people

# While we're in the Python REPL we can still access data from R using the special r object.
#
r.iris
#
# Here's the kicker: the R object behaves like a Python object.
#
r.iris.head()

exit
#
# <--- PYTHON CODE

# Use the py object to access the objects we've justed created in the Python REPL.
#
py$people

# There's an elegant symmetry:
#
# - in Python use the r object to access R data (eg. r.x) and
# - in R use the py object to access Python data (eg. py$x).

# [!!!] Skip forward to Case Study.

# PYTHON DATA TO R: IMPLICIT CONVERSION -------------------------------------------------------------------------------

# By default Python objects returned to R are converted to equivalent R types.

ten <- numpy$array(1:10)
ten
#
# Note: This is a R object, so the following will not work!
#
tryCatch(
  ten$cumsum()
)

# PYTHON DATA TO R: EXPLICIT CONVERSION -------------------------------------------------------------------------------

# You can disable type conversion.
#
numpy <- import("numpy", convert = FALSE)

ten <- numpy$array(1:10)
ten
#
# Note: This is still a Python object, so we can call methods on it.
#
ten$cumsum()

# Explicitly convert to R.
#
py_to_r(ten)

# R DATA TO PYTHON: EXPLICIT CONVERSION -------------------------------------------------------------------------------

# Pair of functions:
#
# - r_to_py() and
# - py_to_r().

# VECTOR -> list in Python
#
r_to_py(1:10)
#
1:10 %>% r_to_py() %>% py_to_r()

# LIST -> dictionary in Python
#
list(pi = 22/7, e = 2.7, ten = 10) %>% r_to_py()

# MATRIX -> Numpy ndarray in Python
#
M7 %>% r_to_py()
#
# This conversion is very efficient because the NumPy array is mapped directly to the memory occupied by the R matrix.
# No copy! The memory layout in both languages is by column.
#
# There's a lot more to working with arrays! (See https://rstudio.github.io/reticulate/articles/arrays.html.)

# DATA FRAME -> Pandas DataFrame
#
iris %>% r_to_py()

# Explicitly create Python compound types.
#
np_array(c(1:8), dtype = "float16")
#
tuple("foo", 13, FALSE)
#
dict(first = 1, second  = 2, third = 3L)
#
# [!] Take that and pipe it into py_to_r().

# CONTEXT MANAGERS ----------------------------------------------------------------------------------------------------

builtin <- import_builtins()

# Python context managers are a great tool for ensuring that resources are managed correctly.
#
# For example, the following code will automatically close the file after writing.
#
# with open("hello-world.txt", "w") as file:
#   file.write("Hello world!")
#
# We can access this functionality from within R too.
#
with(builtin$open("hello-world.txt", "w") %as% file, {
  file$write("Hello world!")
})

# ITERATORS -----------------------------------------------------------------------------------------------------------

ten = builtin$iter(1:10)
#
# Apply a function along the iterator.
#
(iterate(ten, sqrt))

# [!] Go back and recreate the iterator.
#
iter_next(ten)
iter_next(ten)
iter_next(ten)

# CASE STUDY ----------------------------------------------------------------------------------------------------------

# Look at the Country Codes case study.

# CLEAN UP ------------------------------------------------------------------------------------------------------------

virtualenv_remove("test")
