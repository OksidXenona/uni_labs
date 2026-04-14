from setuptools import setup, Extension
import pybind11

ext_modules = [
    Extension(
        'stl_list_module',
        ['STL_list.cpp'],
        include_dirs=[pybind11.get_include()],
        language='c++'
    ),
]

setup(
    name='stl_list_module',
    version='1.0',
    ext_modules=ext_modules
)