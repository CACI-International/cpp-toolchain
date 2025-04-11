load("@rules_python//python:pip.bzl", "compile_pip_requirements")
load("@rules_python//python:py_binary.bzl", "py_binary")

compile_pip_requirements(
    name = "requirements",
    src = "requirements.txt",
    requirements_txt = "requirements_lock.txt",
)

py_binary(
    name = "update",
    srcs = ["update.py"],
    deps = [
        "@pypi//requests",
    ],
)
